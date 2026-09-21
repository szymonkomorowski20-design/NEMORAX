extends RefCounted
## Round-trip zapisu/odczytu GameFlow (autoload) i Arena (entities gołego
## skryptu, bez sceny — _load_progress/_save_progress nie dotykają żadnych
## @onready węzłów) przez tymczasowe pliki user://, plus ścieżki błędów
## naprawione w Fazie A (plik nie do otwarcia -> zostają wartości domyślne,
## bez crasha na null-referencji).

const TEST_GAMEFLOW_PATH := "user://test_gauntlet_progress.json"
const TEST_ARENA_PATH := "user://test_progress.json"

func _cleanup(path: String) -> void:
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)

func test_gameflow_round_trip(_root: Node) -> void:
	var original_path := GameFlow.SAVE_PATH
	GameFlow.SAVE_PATH = TEST_GAMEFLOW_PATH
	_cleanup(TEST_GAMEFLOW_PATH)

	GameFlow.room_map = {
		Vector2i.ZERO: {"type": GameFlow.RoomType.START, "chapter": -1, "enemy_index": -1, "cleared": true, "has_chest": false, "chest_opened": false},
		Vector2i(1, 0): {"type": GameFlow.RoomType.RANDOM, "chapter": -1, "enemy_index": 0, "cleared": true, "has_chest": true, "chest_opened": true},
	}
	GameFlow.current_room_pos = Vector2i(2, -1)
	GameFlow.rooms_cleared_count = 3
	GameFlow.fragments_collected = ["A", "B"]
	GameFlow.saved_player_state = {"health": 42.0}
	GameFlow._save_progress()

	GameFlow.room_map = {}
	GameFlow.current_room_pos = Vector2i.ZERO
	GameFlow.rooms_cleared_count = 0
	GameFlow.fragments_collected = []
	GameFlow.saved_player_state = {}
	var loaded := GameFlow._load_progress()

	NemoraxTest.assert_true(loaded, "_load_progress() powinno zwrócić true dla prawdziwego zapisu")
	NemoraxTest.assert_eq(GameFlow.current_room_pos, Vector2i(2, -1), "current_room_pos po round-tripie")
	NemoraxTest.assert_eq(GameFlow.rooms_cleared_count, 3, "rooms_cleared_count po round-tripie")
	NemoraxTest.assert_eq(GameFlow.fragments_collected, ["A", "B"], "fragments_collected po round-tripie")
	NemoraxTest.assert_eq(GameFlow.saved_player_state.get("health"), 42.0, "saved_player_state po round-tripie")
	NemoraxTest.assert_true(GameFlow.room_map.has(Vector2i.ZERO), "mapa pokoi powinna się odtworzyć")
	NemoraxTest.assert_true(GameFlow.room_map[Vector2i(1, 0)]["has_chest"], "has_chest po round-tripie")
	NemoraxTest.assert_true(GameFlow.room_map[Vector2i(1, 0)]["chest_opened"], "chest_opened po round-tripie")

	_cleanup(TEST_GAMEFLOW_PATH)
	GameFlow.SAVE_PATH = original_path
	GameFlow.reset_run() # autoload przeżywa cały proces testowy — zostaw go czystym dla kolejnych testów

func test_gameflow_missing_file_keeps_defaults(_root: Node) -> void:
	var original_path := GameFlow.SAVE_PATH
	GameFlow.SAVE_PATH = "user://test_gauntlet_progress_nieistnieje.json"
	_cleanup(GameFlow.SAVE_PATH)

	GameFlow.current_room_pos = Vector2i(5, 5)
	var loaded := GameFlow._load_progress() # plik nie istnieje -> false, stan bez zmian
	NemoraxTest.assert_true(not loaded, "brak pliku powinien zwrócić false")
	NemoraxTest.assert_eq(GameFlow.current_room_pos, Vector2i(5, 5), "brak pliku nie powinien nadpisywać stanu w pamięci")

	GameFlow.SAVE_PATH = original_path
	GameFlow.reset_run()

func test_gameflow_open_failure_no_crash(_root: Node) -> void:
	# Katalog zamiast pliku -> FileAccess.open() niezawodnie zwraca null, bez
	# grzebania w realnych uprawnieniach/pełnym dysku — dokładnie ścieżka
	# błędu naprawiona w Fazie A (przedtem: crash na null-referencji).
	var dir_path := "user://test_progress_dir.json"
	DirAccess.make_dir_absolute(dir_path)
	var original_path := GameFlow.SAVE_PATH
	GameFlow.SAVE_PATH = dir_path

	GameFlow.current_room_pos = Vector2i(1, 1)
	var loaded := GameFlow._load_progress() # file_exists(dir)==true, ale open() zwraca null
	NemoraxTest.assert_true(not loaded, "błąd otwarcia powinien zwrócić false, nie crashować")
	NemoraxTest.assert_eq(GameFlow.current_room_pos, Vector2i(1, 1), "błąd otwarcia nie powinien nadpisywać stanu")
	GameFlow._save_progress() # też nie powinno crashować (open() do zapisu też zwróci null na katalogu)

	GameFlow.SAVE_PATH = original_path
	DirAccess.remove_absolute(dir_path)
	GameFlow.reset_run()

func test_arena_round_trip(_root: Node) -> void:
	var arena_script := load("res://arena.gd") # brak class_name na arena.gd — ładujemy skrypt bezpośrednio
	var arena = arena_script.new()
	arena.SAVE_PATH = TEST_ARENA_PATH
	_cleanup(TEST_ARENA_PATH)

	arena.deaths = 4
	arena.wins = 2
	arena._save_progress()

	var arena2 = arena_script.new()
	arena2.SAVE_PATH = TEST_ARENA_PATH
	arena2._load_progress()

	NemoraxTest.assert_eq(arena2.deaths, 4, "deaths po round-tripie")
	NemoraxTest.assert_eq(arena2.wins, 2, "wins po round-tripie")

	_cleanup(TEST_ARENA_PATH)
