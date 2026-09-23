extends RefCounted
## Paczka 3 (AUDYT): trzymana tarcza zamiast jednorazowego odpychającego
## impulsu. Blok z przodu kosztuje staminę zależnie od siły ciosu, idealny blok
## (tuż po podniesieniu) kosztuje połowę i wyzwala Znamię kontry, brak staminy
## przełamuje gardę, a cios z tyłu i strefy na podłożu przechodzą przez tarczę.

func _fresh_player(root: Node) -> Player:
	var player: Player = load("res://entities/player.tscn").instantiate()
	root.add_child(player)
	player.global_position = Vector2(500.0, 500.0)
	return player

func _cleanup(node: Node, root: Node) -> void:
	root.remove_child(node)
	node.queue_free()

## Tarcza skierowana w prawo, podniesiona dawno (poza oknem idealnego bloku).
func _raise_shield(player: Player, held_for: float = 1.0) -> void:
	player._shield_up = true
	player._shield_dir = Vector2.RIGHT
	player._shield_time = held_for

func _front(player: Player) -> Vector2:
	return player.global_position + Vector2(80.0, 0.0)

func test_front_hit_is_blocked_for_stamina(root: Node) -> void:
	var player := _fresh_player(root)
	_raise_shield(player)
	player.stamina = 100.0
	var hp := player.health
	var hurt := player.take_damage(20.0, _front(player))
	NemoraxTest.assert_true(not hurt, "cios z przodu przy podniesionej tarczy nie powinien ranić")
	NemoraxTest.assert_almost_eq(player.health, hp, 0.01, "HP nie powinno spaść przy bloku")
	NemoraxTest.assert_almost_eq(player.stamina, 100.0 - player.shield_block_cost(20.0), 0.01, "blok powinien kosztować staminę wg siły ciosu")
	NemoraxTest.assert_true(player.is_shield_up(), "zwykły blok nie zdejmuje tarczy")
	_cleanup(player, root)

func test_block_cost_scales_with_damage_within_bounds(root: Node) -> void:
	var player := _fresh_player(root)
	NemoraxTest.assert_almost_eq(player.shield_block_cost(1.0), player.shield_block_cost_min, 0.01, "słaby cios kosztuje minimum")
	NemoraxTest.assert_almost_eq(player.shield_block_cost(500.0), player.shield_block_cost_max, 0.01, "potężny cios kosztuje maksimum, nie więcej")
	NemoraxTest.assert_true(player.shield_block_cost(25.0) > player.shield_block_cost(10.0), "mocniejszy cios powinien kosztować więcej")
	_cleanup(player, root)

func test_perfect_block_costs_half_and_reports_perfect(root: Node) -> void:
	var player := _fresh_player(root)
	_raise_shield(player, 0.05)
	player.stamina = 100.0
	var feedback: Array = []
	player.block_feedback.connect(func(kind): feedback.append(kind))
	player.take_damage(20.0, _front(player))
	NemoraxTest.assert_almost_eq(player.stamina, 100.0 - player.shield_block_cost(20.0) * player.perfect_block_cost_multiplier, 0.01, "idealny blok kosztuje połowę")
	NemoraxTest.assert_eq(feedback, ["perfect"], "idealny blok powinien mieć własny sygnał")
	_cleanup(player, root)

func test_guard_breaks_when_stamina_is_short(root: Node) -> void:
	var player := _fresh_player(root)
	_raise_shield(player)
	player.stamina = 5.0
	var hp := player.health
	var feedback: Array = []
	var denied: Array = []
	player.block_feedback.connect(func(kind): feedback.append(kind))
	player.resource_denied.connect(func(kind): denied.append(kind))
	var hurt := player.take_damage(20.0, _front(player))
	NemoraxTest.assert_true(hurt, "przełamana garda przepuszcza cios")
	NemoraxTest.assert_almost_eq(player.health, hp - 20.0, 0.01, "pełne obrażenia po przełamaniu")
	NemoraxTest.assert_almost_eq(player.stamina, 0.0, 0.01, "przełamanie zeruje staminę")
	NemoraxTest.assert_true(not player.is_shield_up(), "przełamanie opuszcza tarczę")
	NemoraxTest.assert_eq(feedback, ["broken"], "gracz dostaje sygnał przełamania")
	NemoraxTest.assert_eq(denied, ["stamina"], "pasek staminy mruga przy przełamaniu")
	_cleanup(player, root)

func test_hit_from_behind_passes_the_shield(root: Node) -> void:
	var player := _fresh_player(root)
	_raise_shield(player)
	player.stamina = 100.0
	var feedback: Array = []
	player.block_feedback.connect(func(kind): feedback.append(kind))
	var hurt := player.take_damage(20.0, player.global_position + Vector2(-80.0, 0.0))
	NemoraxTest.assert_true(hurt, "cios z tyłu nie jest blokowany")
	NemoraxTest.assert_almost_eq(player.stamina, 100.0, 0.01, "nieudany blok nie kosztuje staminy")
	NemoraxTest.assert_eq(feedback, ["direction"], "gracz dostaje sygnał złego kierunku")
	_cleanup(player, root)

func test_floor_zone_ignores_shield(root: Node) -> void:
	var player := _fresh_player(root)
	_raise_shield(player)
	player.stamina = 100.0
	var feedback: Array = []
	player.block_feedback.connect(func(kind): feedback.append(kind))
	var hurt := player.take_damage(8.0, _front(player), false)
	NemoraxTest.assert_true(hurt, "strefa na podłożu jest nie do zablokowania")
	NemoraxTest.assert_eq(feedback, ["unblockable"], "gracz dostaje sygnał 'nie do zablokowania'")
	_cleanup(player, root)

func test_real_damage_zone_is_unblockable(root: Node) -> void:
	var player := _fresh_player(root)
	_raise_shield(player)
	player.stamina = 100.0
	var zone = load("res://entities/damage_zone.tscn").instantiate()
	root.add_child(zone)
	zone.global_position = player.global_position + Vector2(10.0, 0.0)
	var hp := player.health
	zone._try_damage_player()
	NemoraxTest.assert_true(player.health < hp, "DamageZone powinna ranić mimo tarczy skierowanej w jej stronę")
	_cleanup(zone, root)
	_cleanup(player, root)

func test_shield_does_not_rise_without_minimum_stamina(root: Node) -> void:
	var player := _fresh_player(root)
	player.stamina = player.shield_block_cost_min - 1.0
	Input.action_press("block")
	player._handle_block_input()
	Input.action_release("block")
	NemoraxTest.assert_true(not player.is_shield_up(), "bez staminy na najtańszy blok tarcza nie wstaje")
	_cleanup(player, root)

func test_shield_rises_while_held_and_slows_movement(root: Node) -> void:
	var player := _fresh_player(root)
	player.stamina = player.max_stamina
	Input.action_press("block")
	player._handle_block_input()
	NemoraxTest.assert_true(player.is_shield_up(), "trzymany PPM podnosi tarczę")
	Input.action_press("move_right")
	for i in 60:
		player._process_normal_movement(1.0 / 60.0)
	var shielded_speed := player.velocity.length()
	Input.action_release("block")
	player._handle_block_input()
	NemoraxTest.assert_true(not player.is_shield_up(), "puszczony PPM opuszcza tarczę")
	for i in 60:
		player._process_normal_movement(1.0 / 60.0)
	Input.action_release("move_right")
	NemoraxTest.assert_true(shielded_speed < player.velocity.length() * 0.8, "z tarczą gracz porusza się wyraźnie wolniej")
	_cleanup(player, root)

func test_dash_drops_the_shield(root: Node) -> void:
	var player := _fresh_player(root)
	player.stamina = player.max_stamina
	_raise_shield(player)
	Input.action_press("dash")
	player._handle_dash_input(0.0)
	Input.action_release("dash")
	NemoraxTest.assert_eq(player.state, Player.State.DASHING, "dash powinien ruszyć mimo tarczy")
	NemoraxTest.assert_true(not player.is_shield_up(), "dash zdejmuje tarczę")
	_cleanup(player, root)

func test_attack_waits_while_shield_is_up(root: Node) -> void:
	var player := _fresh_player(root)
	player.current_weapon = "sword"
	player.stamina = player.max_stamina
	_raise_shield(player)
	Input.action_press("attack")
	player._handle_attack_input(0.0)
	Input.action_release("attack")
	NemoraxTest.assert_eq(player._attack_phase, "", "przy podniesionej tarczy atak nie rusza")
	player._shield_up = false
	player._handle_attack_input(0.01)
	NemoraxTest.assert_eq(player._attack_phase, "windup", "po opuszczeniu tarczy zbuforowany atak rusza sam")
	_cleanup(player, root)

func test_stamina_does_not_regen_while_shielding_or_right_after_block(root: Node) -> void:
	var player := _fresh_player(root)
	player.stamina = 50.0
	_raise_shield(player)
	player._tick_stamina_regen(0.5)
	NemoraxTest.assert_almost_eq(player.stamina, 50.0, 0.01, "tarcza wstrzymuje regenerację")
	player._shield_up = false
	player._stamina_regen_delay_timer = player.stamina_regen_delay
	player._tick_stamina_regen(0.5)
	NemoraxTest.assert_almost_eq(player.stamina, 50.0, 0.01, "krótka przerwa po wydatku wstrzymuje regenerację")
	player._stamina_regen_delay_timer = 0.0
	player._tick_stamina_regen(0.5)
	NemoraxTest.assert_true(player.stamina > 50.0, "po przerwie stamina wraca")
	_cleanup(player, root)

func test_blocked_glod_bite_does_not_heal_it(root: Node) -> void:
	var player := _fresh_player(root)
	_raise_shield(player)
	player.stamina = 100.0
	var glod = load("res://entities/incarnations/glod_incarnation.tscn").instantiate()
	root.add_child(glod)
	glod.player = player
	glod.global_position = player.global_position + Vector2(glod.radius + player.radius - 4.0, 0.0)
	glod.health = glod.max_health * 0.5
	glod._lunge_active = true
	var glod_hp: float = glod.health
	glod._check_contact()
	NemoraxTest.assert_almost_eq(glod.health, glod_hp, 0.01, "zablokowane ugryzienie nie leczy Głodu")
	_cleanup(glod, root)
	_cleanup(player, root)

func test_successful_block_opens_one_counter_hit(root: Node) -> void:
	var player := _fresh_player(root)
	_raise_shield(player)
	player.stamina = 100.0
	player.take_damage(20.0, _front(player))
	NemoraxTest.assert_true(player.has_counter_ready(), "udany blok otwiera okno kontry")
	var target := Node2D.new()
	root.add_child(target)
	var boosted := player.resolve_hit_damage(target, 10.0)
	var normal := player.resolve_hit_damage(target, 10.0)
	NemoraxTest.assert_almost_eq(boosted, 10.0 * (1.0 + player.counter_bonus), 0.01, "pierwszy pierwotny cios po bloku jest wzmocniony")
	NemoraxTest.assert_almost_eq(normal, 10.0, 0.01, "kontra działa tylko na JEDNO trafienie")
	_cleanup(target, root)
	_cleanup(player, root)

func test_broken_guard_gives_no_counter(root: Node) -> void:
	var player := _fresh_player(root)
	_raise_shield(player)
	player.stamina = 1.0
	player.take_damage(20.0, _front(player))
	NemoraxTest.assert_true(not player.has_counter_ready(), "przełamana garda nie daje kontry")
	_cleanup(player, root)

## Nietykalność po trafieniu nie może chować gracza (sprite znikał co 50 ms).
func test_player_stays_visible_during_hit_invulnerability(root: Node) -> void:
	var player := _fresh_player(root)
	for t in [0.95, 0.9, 0.85, 0.8, 0.75]:
		player._invuln_timer = t
		player._update_visuals()
		NemoraxTest.assert_true(player.sprite.visible and player.sprite.modulate.a > 0.3, "gracz musi być widoczny przy nietykalności %.2f" % t)
	_cleanup(player, root)

func test_reduced_flashing_keeps_a_hit_reaction(root: Node) -> void:
	var previous := Palette.reduce_flashing
	Palette.reduce_flashing = true
	var player := _fresh_player(root)
	var enemy = load("res://entities/incarnations/glod_incarnation.tscn").instantiate()
	root.add_child(enemy)
	enemy.player = player
	enemy.global_position = player.global_position + Vector2(100.0, 0.0)
	enemy.flash_white()
	enemy._tick_hit_recoil(0.01)
	NemoraxTest.assert_true(enemy.sprite.position.x > 1.0, "przy redukcji migotania wróg nadal reaguje odskokiem od gracza")
	enemy._tick_hit_recoil(1.0)
	NemoraxTest.assert_eq(enemy.sprite.position, Vector2.ZERO, "odskok wraca do zera")
	Palette.reduce_flashing = previous
	_cleanup(enemy, root)
	_cleanup(player, root)
