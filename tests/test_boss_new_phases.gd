extends RefCounted
## Nowe fazy Nemoraksa — Motion/Force/Instinct/Dominion/Ruin/Sovereignty
## (CLAUDE_CODE_GAME_CONTENT_BIBLE.md sekcja 13, entities/boss.gd).

func _fresh_boss(root: Node) -> Boss:
	var player: Player = load("res://entities/player.tscn").instantiate()
	root.add_child(player)
	var boss: Boss = load("res://entities/boss.tscn").instantiate()
	root.add_child(boss)
	boss.arena_rect = Rect2(0, 0, 2000, 2000)
	player.global_position = Vector2(1000, 1000)
	boss.global_position = Vector2(1000, 800)
	return boss

## Niektóre testy (przywołanie, wachlarz, strefa) spawnują dodatkowe węzły
## BEZPOŚREDNIO jako rodzeństwo bossa w `root` (get_parent().add_child(...) w
## boss.gd) — trzeba je posprzątać razem z bossem/graczem, inaczej zostają na
## stałe w `root` i zanieczyszczają KOLEJNE testy w całym przebiegu (root to
## ten sam SceneTree.root przez cały test_runner.gd). Filtrowane po typie,
## żeby nigdy nie tknąć autoloadów (GameFlow/Juice/...), które też są dziećmi
## tego samego root przez CAŁY przebieg testów.
func _cleanup(boss: Boss, root: Node) -> void:
	var player := boss.player
	for child in root.get_children():
		if child == boss or child == player or child is Chaser or child is DamageZone or child is EnemyProjectile:
			root.remove_child(child)
			child.queue_free()

func test_phase_hp_scales_by_documented_multipliers(root: Node) -> void:
	var boss := _fresh_boss(root)
	boss.phase_max_health = 100.0
	for target_index in range(1, 6):
		boss._enter_phase(target_index)
		var expected := 100.0 * Boss.PHASE_HP_MULTIPLIERS[target_index]
		NemoraxTest.assert_almost_eq(boss.max_health, expected, 0.01, "faza %d powinna mieć HP = base * %.2f" % [target_index, Boss.PHASE_HP_MULTIPLIERS[target_index]])
		NemoraxTest.assert_almost_eq(boss.health, expected, 0.01, "health powinien zacząć fazę w pełni")
	_cleanup(boss, root)

func test_phase_names_match_document(_root: Node) -> void:
	NemoraxTest.assert_eq(Palette.PHASE_NAMES, ["Motion", "Force", "Instinct", "Dominion", "Ruin", "Sovereignty"], "nazwy faz powinny być z dokumentu sekcja 13")

func test_low_health_speeds_up_attack_tempo(root: Node) -> void:
	var boss := _fresh_boss(root)
	boss.max_health = 100.0
	boss.attack_interval = 2.0
	boss.health = 100.0
	var normal := boss._effective_attack_interval()
	boss.health = 40.0 # <= domyślny low_health_threshold (0.45)
	var fast := boss._effective_attack_interval()
	NemoraxTest.assert_almost_eq(normal, 2.0, 0.01, "pełne zdrowie -> normalne tempo")
	NemoraxTest.assert_almost_eq(fast, 2.0 * boss.low_health_tempo_multiplier, 0.01, "niskie zdrowie -> szybsze tempo")
	_cleanup(boss, root)

func test_pattern_groups_are_rebuilt_on_phase_change(root: Node) -> void:
	var boss := _fresh_boss(root)
	var motion_names := []
	for g in boss._pattern_groups:
		motion_names.append(g["name"])
	NemoraxTest.assert_true("M1_dash_only" in motion_names, "faza 0 powinna mieć grupy Motion")

	boss._enter_phase(3) # Dominion
	var dominion_names := []
	for g in boss._pattern_groups:
		dominion_names.append(g["name"])
	NemoraxTest.assert_true("D1_zone" in dominion_names, "faza 3 powinna mieć grupy Dominion")
	NemoraxTest.assert_true("D5_void_lock" in dominion_names, "Ząb Zera powinien zostać zachowany jako opcja Dominion")
	_cleanup(boss, root)

func test_dominion_projectile_fan_spawns_expected_count(root: Node) -> void:
	var boss := _fresh_boss(root)
	boss.dominion_fan_count = 5
	var before := root.get_children().size()
	boss._attack_dominion_projectile_fan()
	var after := root.get_children().size()
	NemoraxTest.assert_eq(after, before + 5, "wachlarz powinien zespawnować dokładnie dominion_fan_count pocisków")
	_cleanup(boss, root)

func test_dominion_summon_adds_are_not_connected_to_anything(root: Node) -> void:
	var boss := _fresh_boss(root)
	boss.dominion_summon_count = 2
	var before := root.get_children().size()
	boss._attack_dominion_summon()
	var after := root.get_children().size()
	NemoraxTest.assert_eq(after, before + 2, "przywołanie powinno dodać dokładnie dominion_summon_count dodatków")
	for child in root.get_children():
		if child is Chaser:
			NemoraxTest.assert_eq(child.died.get_connections().size(), 0, "dodatki Dominion nie mogą być podpięte pod nic (0 XP, dokument)")
			NemoraxTest.assert_true(child.max_health < 30.0, "dodatki powinny być osłabione względem bazowego Chasera")
	_cleanup(boss, root)

func test_dominion_zone_spawns_a_damage_zone(root: Node) -> void:
	var boss := _fresh_boss(root)
	var found := false
	boss._attack_dominion_zone()
	for child in root.get_children():
		if child is DamageZone:
			found = true
	NemoraxTest.assert_true(found, "_attack_dominion_zone() powinno zespawnować DamageZone")
	_cleanup(boss, root)

func test_void_lock_attack_still_spawns_void_zone(root: Node) -> void:
	var boss := _fresh_boss(root)
	var before := root.get_children().size()
	boss._attack_dominion_void_lock()
	NemoraxTest.assert_eq(root.get_children().size(), before + 1, "Ząb Zera (D5) powinien nadal działać, zachowany z poprzedniej wersji")
	_cleanup(boss, root)

func test_motion_dash_only_never_doubles(root: Node) -> void:
	var boss := _fresh_boss(root)
	boss._attack_motion_dash_only()
	NemoraxTest.assert_eq(boss._lunge_state, "telegraph", "M1 powinno rozpocząć wypad")
	NemoraxTest.assert_almost_eq(boss._pending_double_chance, 0.0, 0.001, "M1 (dash only) nigdy nie powinien się podwoić")
	_cleanup(boss, root)

func test_motion_dash_through_return_forces_double(root: Node) -> void:
	var boss := _fresh_boss(root)
	boss._attack_motion_dash_through_return()
	NemoraxTest.assert_almost_eq(boss._pending_double_chance, 1.0, 0.001, "M3 (Delayed Return) powinien wymusić podwójny wypad")
	_cleanup(boss, root)

func test_instinct_feint_deals_no_damage(root: Node) -> void:
	var boss := _fresh_boss(root)
	var health_before: float = boss.player.health
	boss._attack_instinct_feint()
	NemoraxTest.assert_almost_eq(boss.player.health, health_before, 0.01, "zapowiedź (feint) nie może zadać obrażeń (dokument)")
	_cleanup(boss, root)

func test_sovereignty_crown_sequence_weight_increases_at_low_health(root: Node) -> void:
	var boss := _fresh_boss(root)
	boss.max_health = 100.0
	boss.health = 100.0
	var groups_full := boss._build_pattern_groups_sovereignty()
	var groups_low := []
	boss.health = 40.0
	groups_low = boss._build_pattern_groups_sovereignty()

	var weight_full := 0.0
	var weight_low := 0.0
	for g in groups_full:
		if g["name"] == "S4_crown_sequence":
			weight_full = g["weight"]
	for g in groups_low:
		if g["name"] == "S4_crown_sequence":
			weight_low = g["weight"]
	NemoraxTest.assert_true(weight_low > weight_full, "S4 (Crown Sequence) powinien mieć wyższą wagę poniżej progu niskiego zdrowia")
	_cleanup(boss, root)
