extends RefCounted
## 11 archetypów wrogów losowych + rozszerzenia bazy Incarnation
## (CLAUDE_CODE_GAME_CONTENT_BIBLE.md sekcja 6) — keep_distance/orbit/elite.

func _fresh_player(root: Node) -> Player:
	var player: Player = load("res://entities/player.tscn").instantiate()
	root.add_child(player)
	return player

func _cleanup(node: Node, root: Node) -> void:
	root.remove_child(node)
	node.queue_free()

# --- Rozszerzenia entities/incarnation.gd ---

func test_keep_distance_approaches_when_too_far(root: Node) -> void:
	var player := _fresh_player(root)
	var enemy: Incarnation = load("res://entities/random_enemies/shooter.tscn").instantiate()
	root.add_child(enemy)
	enemy.arena_rect = Rect2(0, 0, 2000, 2000)
	player.global_position = Vector2(1000, 1000)
	enemy.global_position = Vector2(1000, 1000 + enemy.keep_distance_range + 200.0) # daleko za progiem

	var distance_before := enemy.global_position.distance_to(player.global_position)
	enemy._drift_towards_player(1.0)
	var distance_after := enemy.global_position.distance_to(player.global_position)

	NemoraxTest.assert_true(distance_after < distance_before, "za daleko od preferowanego dystansu -> powinien podejść")
	_cleanup(enemy, root)
	_cleanup(player, root)

func test_keep_distance_retreats_when_too_close(root: Node) -> void:
	var player := _fresh_player(root)
	var enemy: Incarnation = load("res://entities/random_enemies/shooter.tscn").instantiate()
	root.add_child(enemy)
	enemy.arena_rect = Rect2(0, 0, 2000, 2000)
	player.global_position = Vector2(1000, 1000)
	enemy.global_position = Vector2(1000, 1050) # dużo bliżej niż keep_distance_range

	var distance_before := enemy.global_position.distance_to(player.global_position)
	enemy._drift_towards_player(1.0)
	var distance_after := enemy.global_position.distance_to(player.global_position)

	NemoraxTest.assert_true(distance_after > distance_before, "za blisko preferowanego dystansu -> powinien się odsunąć")
	_cleanup(enemy, root)
	_cleanup(player, root)

func test_keep_distance_holds_still_within_tolerance_band(root: Node) -> void:
	var player := _fresh_player(root)
	var enemy: Incarnation = load("res://entities/random_enemies/shooter.tscn").instantiate()
	root.add_child(enemy)
	enemy.arena_rect = Rect2(0, 0, 2000, 2000)
	player.global_position = Vector2(1000, 1000)
	enemy.global_position = Vector2(1000, 1000 + enemy.keep_distance_range) # dokładnie w paśmie

	var pos_before := enemy.global_position
	enemy._drift_towards_player(1.0)

	NemoraxTest.assert_almost_eq(enemy.global_position.distance_to(pos_before), 0.0, 0.5, "w paśmie tolerancji (bez orbit_mode) powinien stać w miejscu")
	_cleanup(enemy, root)
	_cleanup(player, root)

func test_orbit_mode_moves_tangentially_not_radially(root: Node) -> void:
	var player := _fresh_player(root)
	var enemy: Incarnation = load("res://entities/random_enemies/orbiter.tscn").instantiate()
	root.add_child(enemy)
	enemy.arena_rect = Rect2(0, 0, 2000, 2000)
	player.global_position = Vector2(1000, 1000)
	enemy.global_position = Vector2(1000, 1000 + enemy.keep_distance_range) # w paśmie -> powinien krążyć, nie stać

	var pos_before := enemy.global_position
	var distance_before := pos_before.distance_to(player.global_position)
	enemy._drift_towards_player(0.1)
	var distance_after := enemy.global_position.distance_to(player.global_position)

	NemoraxTest.assert_true(enemy.global_position.distance_to(pos_before) > 1.0, "orbit_mode w paśmie dystansu powinien się ruszać (stycznie), nie stać")
	NemoraxTest.assert_almost_eq(distance_after, distance_before, 5.0, "ruch styczny nie powinien znacząco zmienić dystansu do gracza")
	_cleanup(enemy, root)
	_cleanup(player, root)

func test_knockback_resistance_reduces_incoming_impulse(root: Node) -> void:
	var enemy: Incarnation = load("res://entities/random_enemies/tank.tscn").instantiate()
	root.add_child(enemy)
	enemy.apply_knockback(Vector2(100.0, 0.0))
	NemoraxTest.assert_almost_eq(enemy._knockback_velocity.x, 25.0, 0.01, "Tank ma 0.75 odporności -> 25% odepchnięcia powinno przejść")
	root.remove_child(enemy)
	enemy.queue_free()

func test_elite_modifier_scales_stats_and_sets_flag(root: Node) -> void:
	var enemy: Incarnation = load("res://entities/random_enemies/chaser.tscn").instantiate()
	root.add_child(enemy)
	var base_max := enemy.max_health
	var base_damage := enemy.contact_damage
	var base_speed := enemy.drift_speed
	var base_kb := enemy.knockback_resistance

	enemy.apply_elite_modifier()

	NemoraxTest.assert_true(enemy.is_elite, "apply_elite_modifier() powinno ustawić is_elite")
	NemoraxTest.assert_almost_eq(enemy.max_health, base_max * 1.30, 0.01, "Elite: +30% HP")
	NemoraxTest.assert_almost_eq(enemy.health, enemy.max_health, 0.01, "zdrowie powinno zostać ustawione na nowe max")
	NemoraxTest.assert_almost_eq(enemy.contact_damage, base_damage * 1.15, 0.01, "Elite: +15% obrażeń")
	NemoraxTest.assert_almost_eq(enemy.drift_speed, base_speed * 1.08, 0.01, "Elite: +8% prędkości")
	NemoraxTest.assert_almost_eq(enemy.knockback_resistance, base_kb + 0.15, 0.01, "Elite: +0.15 odporności na odepchnięcie")
	root.remove_child(enemy)
	enemy.queue_free()

func test_elite_chance_grows_with_progress_and_caps(_root: Node) -> void:
	GameFlow.rooms_cleared_count = 0
	var base := GameFlow.elite_chance_for_current_progress()
	GameFlow.rooms_cleared_count = 10
	var later := GameFlow.elite_chance_for_current_progress()
	GameFlow.rooms_cleared_count = 1000
	var capped := GameFlow.elite_chance_for_current_progress()

	NemoraxTest.assert_true(later > base, "szansa na elita powinna rosnąć z postępem")
	NemoraxTest.assert_eq(capped, GameFlow.ELITE_MAX_CHANCE, "szansa nie powinna przekroczyć ELITE_MAX_CHANCE")
	GameFlow.rooms_cleared_count = 0

# --- Konkretne archetypy ---

func test_all_eleven_random_enemy_scenes_load_as_incarnation(root: Node) -> void:
	for path in GameFlow.RANDOM_ENEMY_SCENES:
		var enemy = load(path).instantiate()
		NemoraxTest.assert_true(enemy is Incarnation, "%s powinien rozszerzać Incarnation" % path)
		root.add_child(enemy)
		root.remove_child(enemy)
		enemy.queue_free()
	NemoraxTest.assert_eq(GameFlow.RANDOM_ENEMY_SCENES.size(), 11, "dokument sekcja 6.1: 11 ciał + Elite jako modyfikator, nie 12. ciało")

func test_shooter_fires_projectile_toward_player(root: Node) -> void:
	var player := _fresh_player(root)
	var shooter: Incarnation = load("res://entities/random_enemies/shooter.tscn").instantiate()
	root.add_child(shooter)
	shooter.arena_rect = Rect2(0, 0, 2000, 2000)
	player.global_position = Vector2(1000, 1000)
	shooter.global_position = Vector2(1000, 800)

	var before := root.get_children().size()
	shooter._skill_fire()
	var after := root.get_children().size()

	# +2, nie +1: pocisk (EnemyProjectile) ORAZ czysto wizualny błysk wystrzału
	# (AttackVfx, KIERUNEK_WIZUALNY_REFERENCJE.md/enemy_vfx) — ten drugi sam się
	# usuwa przez tween po chwili i nie uczestniczy w żadnej mechanice.
	NemoraxTest.assert_eq(after, before + 2, "_skill_fire() powinno zespawnować pocisk i błysk wystrzału")
	_cleanup(shooter, root)
	_cleanup(player, root)

func test_zoner_places_a_damage_zone_on_player_position(root: Node) -> void:
	var player := _fresh_player(root)
	var zoner: Incarnation = load("res://entities/random_enemies/zoner.tscn").instantiate()
	root.add_child(zoner)
	zoner.arena_rect = Rect2(0, 0, 2000, 2000)
	player.global_position = Vector2(1234, 567)
	zoner.global_position = Vector2(1000, 1000)

	zoner._skill_place_zone()
	var zone: Node = null
	for child in root.get_children():
		if child is DamageZone:
			zone = child
	NemoraxTest.assert_true(zone != null, "_skill_place_zone() powinno zespawnować DamageZone")
	NemoraxTest.assert_almost_eq(zone.global_position.distance_to(player.global_position), 0.0, 1.0, "strefa powinna wylądować na pozycji gracza")
	_cleanup(zoner, root)
	_cleanup(player, root)

func test_summoner_spawns_weaker_adds_not_connected_to_room_clear(root: Node) -> void:
	var player := _fresh_player(root)
	var summoner: Incarnation = load("res://entities/random_enemies/summoner.tscn").instantiate()
	root.add_child(summoner)
	summoner.arena_rect = Rect2(0, 0, 2000, 2000)
	player.global_position = Vector2(1000, 1000)
	summoner.global_position = Vector2(1000, 1000)

	var before := root.get_children().size()
	summoner._skill_summon()
	var after := root.get_children().size()

	# +summon_count dodatków, +1 VFX kanałowania (skill) na sobie, +summon_count VFX portalu (attack) pod każdym dodatkiem.
	NemoraxTest.assert_eq(after, before + summoner.summon_count * 2 + 1, "_skill_summon() powinno zespawnować dokładnie summon_count dodatków")
	for child in root.get_children():
		if child is Chaser:
			NemoraxTest.assert_almost_eq(child.max_health, 30.0 * summoner.summon_strength_fraction, 0.01, "dodatek powinien być osłabiony o summon_strength_fraction")
			NemoraxTest.assert_eq(child.died.get_connections().size(), 0, "śmierć dodatku nie może być podpięta pod nic (0 XP, brak wpływu na czyszczenie pokoju)")
	_cleanup(summoner, root)
	_cleanup(player, root)

## Faza 2B (PLAN_PROFESSIONAL_GAME_FEEL_DLA_CLAUDE.md): trafienie Summonera W
## TRAKCIE kanałowania (_telegraph_active) ma zepsuć nadchodzące przywołanie —
## bez tego "czas na przerwanie czaru" z dokumentu nic by faktycznie nie robił.
func test_summoner_channel_interrupted_by_damage_cancels_summon(root: Node) -> void:
	var player := _fresh_player(root)
	var summoner: Incarnation = load("res://entities/random_enemies/summoner.tscn").instantiate()
	root.add_child(summoner)
	summoner.arena_rect = Rect2(0, 0, 2000, 2000)
	player.global_position = Vector2(1000, 1000)
	summoner.global_position = Vector2(1000, 1000)

	summoner._telegraph_active = true
	summoner.take_damage(5.0)
	NemoraxTest.assert_true(summoner._channel_interrupted, "trafienie w trakcie kanałowania powinno ustawić flagę przerwania")

	var before := root.get_children().size()
	summoner._skill_summon()
	NemoraxTest.assert_eq(root.get_children().size(), before, "przerwane kanałowanie nie powinno zespawnować żadnych dodatków")
	NemoraxTest.assert_true(not summoner._channel_interrupted, "flaga przerwania powinna się skonsumować po nieudanej próbie przywołania")

	# Kolejne, nieprzerwane kanałowanie ma działać normalnie.
	summoner._skill_summon()
	NemoraxTest.assert_eq(root.get_children().size(), before + summoner.summon_count * 2 + 1, "kolejne, nieprzerwane przywołanie powinno zadziałać normalnie")

	_cleanup(summoner, root)
	_cleanup(player, root)

func test_support_self_buffs_move_speed_temporarily(root: Node) -> void:
	var player := _fresh_player(root)
	var support: Incarnation = load("res://entities/random_enemies/support.tscn").instantiate()
	root.add_child(support)
	support.arena_rect = Rect2(0, 0, 2000, 2000)
	player.global_position = Vector2(1000, 1000)
	support.global_position = Vector2(1000, 1000)

	var base_speed: float = support._base_drift_speed
	support._skill_self_buff()
	NemoraxTest.assert_almost_eq(support.drift_speed, base_speed * 1.15, 0.01, "self-buff powinien dać +15% prędkości")

	support._physics_process(support.buff_duration + 0.1)
	NemoraxTest.assert_almost_eq(support.drift_speed, base_speed, 0.01, "buff powinien wygasnąć i wrócić do bazowej prędkości")
	_cleanup(support, root)
	_cleanup(player, root)
