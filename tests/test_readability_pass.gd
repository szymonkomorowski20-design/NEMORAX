extends RefCounted
## Audyt nagrania 24.09 (P0.1–P0.2): gracz czytelny przy dużych wrogach
## (obrys zamiast zasłaniającego dysku) oraz log każdego ciosu w gracza.

func _cleanup(node: Node, root: Node) -> void:
	root.remove_child(node)
	node.queue_free()

func _fresh_player(root: Node) -> Player:
	var player: Player = load("res://entities/player.tscn").instantiate()
	root.add_child(player)
	player.global_position = Vector2(500.0, 500.0)
	Juice.player_hits.clear()
	return player

func _raise_shield(player: Player, held_for: float = 1.0) -> void:
	player._shield_up = true
	player._shield_dir = Vector2.RIGHT
	player._shield_time = held_for

func test_player_sprite_has_subtle_outline(root: Node) -> void:
	var player := _fresh_player(root)
	var mat := player.sprite.material as ShaderMaterial
	NemoraxTest.assert_true(mat != null and mat.shader == Player.OUTLINE_SHADER, "sylwetka gracza ma shader obrysu")
	player._update_outline()
	NemoraxTest.assert_almost_eq(float(mat.get_shader_parameter("outline_strength")), Player.OUTLINE_BASE, 0.01, "bez wrogów obrys stały i subtelny")
	_cleanup(player, root)

func test_outline_strengthens_over_large_enemy(root: Node) -> void:
	var player := _fresh_player(root)
	var boss: Boss = load("res://entities/boss.tscn").instantiate()
	root.add_child(boss)
	boss.global_position = player.global_position + Vector2(20.0, 0.0)
	for i in 30:
		player._update_outline()
	var mat := player.sprite.material as ShaderMaterial
	NemoraxTest.assert_almost_eq(float(mat.get_shader_parameter("outline_strength")), Player.OUTLINE_OVERLAP, 0.01, "na ciele dużego wroga obrys mocniejszy")
	NemoraxTest.assert_true(float(mat.get_shader_parameter("lift")) > 0.2, "i sylwetka rozjaśniona")
	boss.global_position = player.global_position + Vector2(900.0, 0.0)
	for i in 30:
		player._update_outline()
	NemoraxTest.assert_almost_eq(float(mat.get_shader_parameter("outline_strength")), Player.OUTLINE_BASE, 0.01, "po odejściu wraca do subtelnego")
	_cleanup(boss, root)
	_cleanup(player, root)

func test_hit_log_records_plain_hit(root: Node) -> void:
	var player := _fresh_player(root)
	var hp := player.health
	player.take_damage(12.0, player.global_position + Vector2(80, 0), true, null, "kontakt")
	NemoraxTest.assert_eq(Juice.player_hits.size(), 1, "jeden wpis na jeden cios")
	var e: Dictionary = Juice.player_hits[-1]
	NemoraxTest.assert_eq(e["outcome"], "trafienie", "wynik")
	NemoraxTest.assert_eq(e["kind"], "kontakt", "rodzaj od wołającego")
	NemoraxTest.assert_almost_eq(float(e["hp_before"]), hp, 0.01, "HP przed")
	NemoraxTest.assert_almost_eq(float(e["hp_after"]), hp - 12.0, 0.01, "HP po")
	NemoraxTest.assert_true(Juice.format_player_hit(e).contains("HP"), "wpis da się wypisać")
	_cleanup(player, root)

func test_hit_log_records_avoided_hits(root: Node) -> void:
	var player := _fresh_player(root)
	player._invuln_timer = 0.3
	player.take_damage(10.0, player.global_position + Vector2(80, 0))
	NemoraxTest.assert_eq(Juice.player_hits[-1]["outcome"], "nietykalność", "cios w i-frame też w logu")
	player._invuln_timer = 0.0
	_raise_shield(player)
	player.stamina = 100.0
	player.take_damage(10.0, player.global_position + Vector2(80, 0))
	NemoraxTest.assert_eq(Juice.player_hits[-1]["outcome"], "blok", "blok")
	NemoraxTest.assert_true(Juice.player_hits[-1]["shield"], "stan tarczy zapisany")
	player._invuln_timer = 0.0
	_raise_shield(player)
	player.stamina = 1.0
	player.take_damage(10.0, player.global_position + Vector2(80, 0))
	NemoraxTest.assert_eq(Juice.player_hits[-1]["outcome"], "przełamanie gardy", "przełamanie")
	player._invuln_timer = 0.0
	_raise_shield(player)
	player.stamina = 100.0
	player.take_damage(10.0, player.global_position + Vector2(-80, 0))
	NemoraxTest.assert_eq(Juice.player_hits[-1]["outcome"], "poza tarczą — tył", "cios z tyłu")
	player._invuln_timer = 0.0
	player.take_damage(10.0, player.global_position + Vector2(80, 0), false)
	NemoraxTest.assert_eq(Juice.player_hits[-1]["outcome"], "nieblokowalny", "nieblokowalny przy podniesionej tarczy")
	_cleanup(player, root)

func test_hit_log_kind_from_source_type(root: Node) -> void:
	var player := _fresh_player(root)
	var shot: Node2D = load("res://entities/enemy_projectile.tscn").instantiate()
	root.add_child(shot)
	player.take_damage(9.0, player.global_position + Vector2(80, 0), true, shot)
	NemoraxTest.assert_eq(Juice.player_hits[-1]["kind"], "pocisk", "pocisk rozpoznany po typie źródła")
	_cleanup(shot, root)
	_cleanup(player, root)

## Po teleporcie wypad nie rusza w tej samej klatce: zapowiedź z zablokowanym
## kierunkiem (log trafień: Vhar’Nokh zabierał HP wypadami bez zapowiedzi).
func test_teleport_strike_has_arrival_windup(root: Node) -> void:
	var player := _fresh_player(root)
	var enemy = load("res://entities/incarnations/zalazek.tscn").instantiate()
	root.add_child(enemy)
	enemy.player = player
	enemy.arena_rect = Rect2(0, 0, 1280, 720)
	enemy.global_position = player.global_position + Vector2(-220.0, 0.0)
	enemy._lunge_after_arrival(420.0, 0.3)
	NemoraxTest.assert_true(not enemy._lunge_active, "wypad nie startuje w klatce pojawienia się")
	NemoraxTest.assert_true(enemy._windup_timer > 0.0, "trwa zapowiedź")
	NemoraxTest.assert_true(enemy._windup_dir.is_equal_approx(Vector2.RIGHT), "kierunek na gracza w chwili pojawienia się")
	var pos: Vector2 = enemy.global_position
	player.global_position += Vector2(0.0, 150.0) # krok w bok
	enemy._physics_process(0.1)
	NemoraxTest.assert_true(enemy.global_position.distance_to(pos) < 1.0, "w czasie zapowiedzi stoi w miejscu")
	enemy._lunge_toward_player(420.0, 0.3, enemy._windup_dir)
	NemoraxTest.assert_true(enemy._lunge_direction.is_equal_approx(Vector2.RIGHT), "wypad leci zapowiedzianą linią, nie za graczem")
	_cleanup(enemy, root)
	_cleanup(player, root)
