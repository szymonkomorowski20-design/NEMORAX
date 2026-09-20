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

	GameFlow.current_room_index = 3
	GameFlow.fragments_collected = ["A", "B"]
	GameFlow.saved_player_state = {"health": 42.0}
	GameFlow._save_progress()

	GameFlow.current_room_index = 0
	GameFlow.fragments_collected = []
	GameFlow.saved_player_state = {}
	GameFlow._load_progress()

	NemoraxTest.assert_eq(GameFlow.current_room_index, 3, "current_room_index po round-tripie")
	NemoraxTest.assert_eq(GameFlow.fragments_collected, ["A", "B"], "fragments_collected po round-tripie")
	NemoraxTest.assert_eq(GameFlow.saved_player_state.get("health"), 42.0, "saved_player_state po round-tripie")

	_cleanup(TEST_GAMEFLOW_PATH)
	GameFlow.SAVE_PATH = original_path
	GameFlow.reset_run() # autoload przeżywa cały proces testowy — zostaw go czystym dla kolejnych testów

func test_gameflow_missing_file_keeps_defaults(_root: Node) -> void:
	var original_path := GameFlow.SAVE_PATH
	GameFlow.SAVE_PATH = "user://test_gauntlet_progress_nieistnieje.json"
	_cleanup(GameFlow.SAVE_PATH)

	GameFlow.current_room_index = 5
	GameFlow._load_progress() # plik nie istnieje -> wczesny return, stan bez zmian
	NemoraxTest.assert_eq(GameFlow.current_room_index, 5, "brak pliku nie powinien nadpisywać stanu w pamięci")

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

	GameFlow.current_room_index = 2
	GameFlow._load_progress() # file_exists(dir)==true, ale open() zwraca null
	NemoraxTest.assert_eq(GameFlow.current_room_index, 2, "błąd otwarcia nie powinien crashować ani nadpisywać stanu")
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
