extends RefCounted
## Paczka 11 (AUDYT F11 pkt 1): integracja — wszystkie pola próby dodane w
## paczkach 5–9 przeżywają JEDEN wspólny zapis/odczyt (w środku trasy, przy
## odłożonej karcie, przed finałem), a to samo ziarno odtwarza tę samą mapę.

const TEST_PATH := "user://test_integration_run.json"

func _cleanup_file() -> void:
	if FileAccess.file_exists(TEST_PATH):
		DirAccess.remove_absolute(TEST_PATH)

func _map_signature() -> Array:
	var keys := GameFlow.room_map.keys()
	keys.sort()
	var out: Array = []
	for pos in keys:
		var d: Dictionary = GameFlow.room_map[pos]
		out.append([pos, d["type"], d["chapter"], d["enemy_index"], d.get("theme", 0), d.get("layout", "open"), d.get("trap", false), d.get("elite", false), d.get("rest", false), d.get("has_chest", false)])
	return out

func test_same_seed_rebuilds_the_same_run(_root: Node) -> void:
	GameFlow.reset_run(424242)
	var first := _map_signature()
	GameFlow.reset_run(99)
	NemoraxTest.assert_true(_map_signature() != first, "inne ziarno — inna mapa")
	GameFlow.reset_run(424242)
	NemoraxTest.assert_eq(_map_signature(), first, "to samo ziarno — identyczna mapa, motywy, układy, pułapki, elity")
	GameFlow.reset_run()

func test_every_run_field_survives_one_save(_root: Node) -> void:
	var original := GameFlow.SAVE_PATH
	GameFlow.SAVE_PATH = TEST_PATH
	_cleanup_file()
	GameFlow.reset_run(777)
	var signature := _map_signature()
	GameFlow.set_run_intent("kontra")
	GameFlow.pacts = {str(PactCatalog.PILOT_CHAPTER): PactCatalog.ZWIAZ}
	GameFlow.pending_pact = 3
	GameFlow.run_time = 612.5
	GameFlow.loop_level = 1
	GameFlow.rooms_cleared_count = 17
	GameFlow.fragments_collected = ["0", "1", "2", "3", "4"]
	GameFlow.reached_arena = true
	GameFlow.current_room_pos = Vector2i(2, -1)
	GameFlow.saved_player_state = {"pending_skill_choices": 2, "level": 8}
	var rest_pos := Vector2i(999, 999)
	for pos in GameFlow.room_map:
		if GameFlow.room_map[pos].get("rest", false):
			rest_pos = pos
			GameFlow.room_map[pos]["rest_used"] = true
			break
	GameFlow._save_progress()

	# Wyczyść stan w pamięci BEZ reset_run() — ten sam zapisuje nową próbę.
	GameFlow.room_map = {}
	GameFlow.run_seed = 0
	GameFlow.run_intent = ""
	GameFlow.pacts = {}
	GameFlow.pending_pact = -1
	GameFlow.run_time = 0.0
	GameFlow.loop_level = 0
	GameFlow.rooms_cleared_count = 0
	GameFlow.fragments_collected = []
	GameFlow.reached_arena = false
	GameFlow.current_room_pos = Vector2i.ZERO
	GameFlow.saved_player_state = {}
	NemoraxTest.assert_true(GameFlow._load_progress(), "zapis się wczytuje")
	NemoraxTest.assert_eq(GameFlow.run_seed, 777, "ziarno")
	NemoraxTest.assert_eq(_map_signature(), signature, "mapa z markerami trasy")
	NemoraxTest.assert_eq(GameFlow.run_intent, "kontra", "intencja startowa")
	NemoraxTest.assert_eq(PactCatalog.choice(), PactCatalog.ZWIAZ, "pakt")
	NemoraxTest.assert_eq(GameFlow.pending_pact, 3, "oczekujący pakt")
	NemoraxTest.assert_almost_eq(GameFlow.run_time, 612.5, 0.01, "czas próby")
	NemoraxTest.assert_eq(GameFlow.loop_level, 1, "Pętla Otchłani")
	NemoraxTest.assert_eq(GameFlow.rooms_cleared_count, 17, "wyczyszczone pokoje")
	NemoraxTest.assert_eq(GameFlow.fragments_collected.size(), 5, "fragmenty")
	NemoraxTest.assert_true(GameFlow.reached_arena, "dotarcie do finału")
	NemoraxTest.assert_eq(GameFlow.current_room_pos, Vector2i(2, -1), "bieżący pokój")
	NemoraxTest.assert_eq(int(GameFlow.saved_player_state.get("pending_skill_choices", 0)), 2, "odłożone karty")
	if rest_pos != Vector2i(999, 999):
		NemoraxTest.assert_true(GameFlow.room_map[rest_pos]["rest_used"], "zużyty odpoczynek")
	_cleanup_file()
	GameFlow.SAVE_PATH = original
	GameFlow.reset_run()

## Pocisk, który chybił, nie przelatuje nad ścianą poza pokój (znalezione
## w teście obciążenia Paczki 11).
func test_projectiles_stop_at_room_walls(root: Node) -> void:
	var holder := Node2D.new()
	root.add_child(holder)
	var rect := Rect2(100, 100, 600, 400)
	Walls.build(holder, rect, 60.0)
	NemoraxTest.assert_true(Walls.point_in_wall(holder, Vector2(400, 80)), "punkt w górnej ścianie")
	NemoraxTest.assert_true(not Walls.point_in_wall(holder, Vector2(400, 300)), "środek pokoju jest wolny")
	var shot: Node2D = load("res://entities/enemy_projectile.tscn").instantiate()
	shot.direction = Vector2.UP
	holder.add_child(shot)
	shot.global_position = Vector2(400, 106)
	for i in 10:
		if not is_instance_valid(shot) or shot.is_queued_for_deletion():
			break
		shot._physics_process(1.0 / 60.0)
	NemoraxTest.assert_true(not is_instance_valid(shot) or shot.is_queued_for_deletion(), "pocisk gaśnie na ścianie")
	root.remove_child(holder)
	holder.queue_free()

## Arena bez jawnej ścieżki pisze tam, gdzie GameFlow — izolacja zapisu w
## skryptach i testach obejmuje ją automatycznie (24.09: bot pomiarowy dopisał
## zwycięstwa do prawdziwego progress.json, bo arena miała własną stałą ścieżkę).
func test_arena_save_path_follows_game_flow(_root: Node) -> void:
	var arena = load("res://arena.gd").new()
	NemoraxTest.assert_eq(arena._save_path(), GameFlow.PERSISTENT_SAVE_PATH, "domyślnie ścieżka GameFlow")
	arena.SAVE_PATH = "user://inna.json"
	NemoraxTest.assert_eq(arena._save_path(), "user://inna.json", "jawna ścieżka ma pierwszeństwo")
	arena.free()
