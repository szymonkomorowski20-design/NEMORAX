extends RefCounted
## Odświeżenie wzorców ataku 6 wcieleń (CLAUDE_CODE_GAME_CONTENT_BIBLE.md
## sekcja 11): tempo przy niskim zdrowiu (wspólne dla całej klasy Incarnation)
## i po jednej "grupie wzorców" (łańcuch 2 istniejących umiejętności) na
## każde z sześciu wcieleń.

func _fresh_player(root: Node) -> Player:
	var player: Player = load("res://entities/player.tscn").instantiate()
	root.add_child(player)
	return player

func _cleanup(node: Node, root: Node) -> void:
	root.remove_child(node)
	node.queue_free()

# --- Tempo przy niskim zdrowiu (entities/incarnation.gd) ---

func test_full_health_uses_normal_tempo(_root: Node) -> void:
	var enemy := Incarnation.new()
	enemy.max_health = 100.0
	enemy.health = 100.0
	enemy.attack_interval = 2.0
	enemy.telegraph_duration = 0.5
	NemoraxTest.assert_almost_eq(enemy._effective_attack_interval(), 2.0, 0.01, "pełne zdrowie -> normalne tempo ataku")
	NemoraxTest.assert_almost_eq(enemy._effective_telegraph_duration(), 0.5, 0.01, "pełne zdrowie -> normalny telegraf")

func test_low_health_speeds_up_tempo(_root: Node) -> void:
	var enemy := Incarnation.new()
	enemy.max_health = 100.0
	enemy.health = 30.0 # <= domyślny low_health_threshold (0.40)
	enemy.attack_interval = 2.0
	enemy.telegraph_duration = 0.5
	NemoraxTest.assert_almost_eq(enemy._effective_attack_interval(), 2.0 * enemy.low_health_tempo_multiplier, 0.01, "niskie zdrowie -> szybszy odstęp ataku")
	NemoraxTest.assert_almost_eq(enemy._effective_telegraph_duration(), 0.5 * enemy.low_health_tempo_multiplier, 0.01, "niskie zdrowie -> krótszy telegraf")

func test_health_exactly_at_threshold_counts_as_low(_root: Node) -> void:
	var enemy := Incarnation.new()
	enemy.max_health = 100.0
	enemy.health = 100.0 * enemy.low_health_threshold
	NemoraxTest.assert_true(enemy._is_low_health(), "dokładnie na progu powinno się liczyć jako niskie zdrowie (<=, nie <)")

# --- Grupy wzorców — po jednej na wcielenie ---

func _make_incarnation(root: Node, path: String) -> Incarnation:
	var enemy: Incarnation = load(path).instantiate()
	root.add_child(enemy)
	enemy.arena_rect = Rect2(0, 0, 2000, 2000)
	enemy.global_position = Vector2(1000, 900)
	return enemy

func test_each_incarnation_has_four_skills_including_a_pattern(root: Node) -> void:
	var player := _fresh_player(root)
	player.global_position = Vector2(1000, 1000)
	var paths := [
		"res://entities/incarnations/zalazek.tscn",
		"res://entities/incarnations/cisza_incarnation.tscn",
		"res://entities/incarnations/zwloka_incarnation.tscn",
		"res://entities/incarnations/ciezar_incarnation.tscn",
		"res://entities/incarnations/glod_incarnation.tscn",
		"res://entities/incarnations/zacmienie_incarnation.tscn",
	]
	for path in paths:
		var enemy := _make_incarnation(root, path)
		NemoraxTest.assert_eq(enemy._skills.size(), 4, "%s powinien mieć 3 podstawowe umiejętności + 1 grupę wzorców" % path)
		_cleanup(enemy, root)
	_cleanup(player, root)

func test_pattern_groups_execute_without_crashing(root: Node) -> void:
	var player := _fresh_player(root)
	player.global_position = Vector2(1000, 1000)
	var cases := [
		["res://entities/incarnations/zalazek.tscn", "_pattern_teleport_and_burst"],
		["res://entities/incarnations/cisza_incarnation.tscn", "_pattern_pulse_and_rush"],
		["res://entities/incarnations/zwloka_incarnation.tscn", "_pattern_pull_and_stutter"],
		["res://entities/incarnations/ciezar_incarnation.tscn", "_pattern_lunge_and_crush"],
		["res://entities/incarnations/glod_incarnation.tscn", "_pattern_pulse_and_bite"],
		["res://entities/incarnations/zacmienie_incarnation.tscn", "_pattern_pull_and_vanish_strike"],
	]
	for case in cases:
		var enemy := _make_incarnation(root, case[0])
		var method: String = case[1]
		NemoraxTest.assert_true(enemy.has_method(method), "%s powinien mieć metodę %s" % [case[0], method])
		enemy.call(method) # nie powinno rzucić błędu — pierwszy krok leci synchronicznie, reszta czeka na timer (nigdy nie odpali w tym runnerze, i to w porządku)
		_cleanup(enemy, root)
	_cleanup(player, root)
