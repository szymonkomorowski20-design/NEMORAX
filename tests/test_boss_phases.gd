extends RefCounted
## _on_boss_phase_changed (arena.gd) — jedyne miejsce, które zna gracza i bossa
## naraz, więc jedyne, gdzie dają się przetestować modyfikatory fazowe (sekcja
## 7). Potrzebuje pełnej sceny arena.tscn (player/boss/ui/vision_overlay to
## @onready węzły), stąd cięższy test niż reszta — osobna instancja areny na
## fazę, żeby efekty kumulujące się (np. dash_cooldown *= 2) nie mieszały testów.

func _fresh_arena(root: Node) -> Node:
	var arena = load("res://arena.tscn").instantiate()
	arena.SAVE_PATH = "user://test_boss_phase_arena.json" # przed add_child(), zanim _ready() zdąży odczytać prawdziwy zapis
	root.add_child(arena)
	return arena

func _cleanup(arena: Node, root: Node) -> void:
	root.remove_child(arena)
	arena.queue_free()

func test_phase_zwloka_doubles_dash_cooldown(root: Node) -> void:
	var arena := _fresh_arena(root)
	var before: float = arena.player.dash_cooldown
	arena._on_boss_phase_changed(2, Color.WHITE, "Zwłoka")
	NemoraxTest.assert_almost_eq(arena.player.dash_cooldown, before * 2.0, 0.001, "dash_cooldown powinien się podwoić w fazie Zwłoka")
	_cleanup(arena, root)

func test_phase_ciezar_sets_gravity_pull(root: Node) -> void:
	var arena := _fresh_arena(root)
	NemoraxTest.assert_true(arena.player.pull_source == null, "pull_source powinien być pusty przed fazą Ciężar")
	arena._on_boss_phase_changed(3, Color.WHITE, "Ciężar")
	NemoraxTest.assert_true(arena.player.pull_source == arena.boss, "pull_source powinien wskazywać na bossa po fazie Ciężar")
	NemoraxTest.assert_almost_eq(arena.player.pull_strength, arena.boss.gravity_pull_strength, 0.001, "pull_strength powinien przejąć gravity_pull_strength bossa")
	_cleanup(arena, root)

func test_phase_zacmienie_activates_eclipse(root: Node) -> void:
	var arena := _fresh_arena(root)
	NemoraxTest.assert_true(not arena.vision_overlay.visible, "vision_overlay powinien być niewidoczny przed fazą Zaćmienie")
	arena._on_boss_phase_changed(5, Color.WHITE, "Zaćmienie")
	NemoraxTest.assert_true(arena.vision_overlay.visible, "vision_overlay powinien stać się widoczny w fazie Zaćmienie")
	NemoraxTest.assert_true(arena.vision_overlay._target == arena.player, "vision_overlay powinien śledzić gracza")
	_cleanup(arena, root)
