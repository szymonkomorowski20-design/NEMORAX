extends RefCounted
## A1 (AUDYT_I_PLAN_ROZBUDOWY_GRY_DLA_CLAUDE.md): HP bossa wyświetlane jako
## "115/114" / "111/110". Przyczyna: 100.0 * 1.15 w double to 114.999…,
## ceili() dawał 115, int() 114. Wyświetlane HP nigdy nie może przekroczyć
## wyświetlonego maksimum.

func _fresh_boss(root: Node) -> Node:
	var boss = load("res://entities/boss.tscn").instantiate()
	boss.arena_rect = Rect2(90, 60, 1100, 600)
	root.add_child(boss)
	return boss

func _cleanup(node: Node, root: Node) -> void:
	root.remove_child(node)
	node.queue_free()

func _parts(label: String) -> Array:
	var p := label.split(" / ")
	return [int(p[0]), int(p[1])]

func test_float_noise_max_does_not_show_current_above_max(_root: Node) -> void:
	var noisy := 100.0 * 1.15
	NemoraxTest.assert_eq(GameUI.hp_label(noisy, noisy), "115 / 115", "pełne HP fazy ×1.15 ma dać 115/115, nie 115/114")
	var noisy_110 := 100.0 * 1.10
	NemoraxTest.assert_eq(GameUI.hp_label(noisy_110, noisy_110), "110 / 110", "pełne HP fazy ×1.10 ma dać 110/110, nie 111/110")

func test_current_is_clamped_to_displayed_max(_root: Node) -> void:
	var parts := _parts(GameUI.hp_label(120.4, 114.6))
	NemoraxTest.assert_true(parts[0] <= parts[1], "bieżące HP nie może przekroczyć wyświetlonego maksimum")

func test_alive_fraction_shows_at_least_one_and_zero_stays_zero(_root: Node) -> void:
	NemoraxTest.assert_eq(GameUI.hp_label(0.3, 100.0), "1 / 100", "żywy cel z 0,3 HP pokazuje 1, nie 0")
	NemoraxTest.assert_eq(GameUI.hp_label(0.0, 100.0), "0 / 100", "0 HP to 0")
	NemoraxTest.assert_eq(GameUI.hp_label(-4.0, 100.0), "0 / 100", "nadwyżka obrażeń nie daje ujemnego HP")

func test_every_boss_phase_has_integral_pool_and_consistent_label(root: Node) -> void:
	var boss := _fresh_boss(root)
	for i in range(boss.PHASE_HP_MULTIPLIERS.size()):
		boss._enter_phase(i)
		NemoraxTest.assert_eq(boss.health, boss.max_health, "faza %d: start z pełnym HP" % i)
		NemoraxTest.assert_eq(boss.max_health, roundf(boss.max_health), "faza %d: pula HP całkowita w danych" % i)
		var parts := _parts(GameUI.hp_label(boss.health, boss.max_health))
		NemoraxTest.assert_eq(parts[0], parts[1], "faza %d: pełne HP wyświetla się jako x/x" % i)
	boss.start_final_phase()
	var final_parts := _parts(GameUI.hp_label(boss.health, boss.max_health))
	NemoraxTest.assert_eq(final_parts[0], final_parts[1], "mała forma: pełne HP wyświetla się jako x/x")
	_cleanup(boss, root)

func test_damage_through_phase_keeps_label_within_bounds(root: Node) -> void:
	var boss := _fresh_boss(root)
	boss._enter_phase(5)
	boss._invulnerable = false
	boss.take_damage(0.35)
	var parts := _parts(GameUI.hp_label(boss.health, boss.max_health))
	NemoraxTest.assert_true(parts[0] <= parts[1] and parts[0] > 0, "po ułamkowym trafieniu HP mieści się w (0, max]")
	_cleanup(boss, root)
