extends RefCounted
## Prolog (rooms/room.gd + autoload/game_flow.gd, PLAN_CUTSCENEK.md sekcja 2.1)
## — raz na zapis, nigdy więcej w tym samym zapisie. tests/test_runner.gd
## ustawia GameFlow.PERSISTENT_SAVE_PATH globalnie na "już widziane" dla CAŁEGO
## zestawu (żeby świeże room.tscn w innych, niepowiązanych testach nie
## odpalało cutscenki i nie pauzowało drzewa jako efekt uboczny) — testy
## poniżej celowo przełączają na WŁASNĄ, izolowaną ścieżkę i przywracają stan
## globalny na końcu, żeby nie zepsuć testów uruchamianych PO nich.

const TEST_PATH := "user://test_prolog_progress.json"

func _cleanup(path: String) -> void:
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)

func test_has_seen_prolog_false_until_marked(_root: Node) -> void:
	var original_path := GameFlow.PERSISTENT_SAVE_PATH
	GameFlow.PERSISTENT_SAVE_PATH = TEST_PATH
	_cleanup(TEST_PATH)

	NemoraxTest.assert_true(not GameFlow.has_seen_prolog(), "brak pliku zapisu powinien dać false")
	GameFlow.mark_prolog_seen()
	NemoraxTest.assert_true(GameFlow.has_seen_prolog(), "po mark_prolog_seen() powinno być true")

	_cleanup(TEST_PATH)
	GameFlow.PERSISTENT_SAVE_PATH = original_path

func test_mark_prolog_seen_does_not_clobber_other_keys(_root: Node) -> void:
	var original_path := GameFlow.PERSISTENT_SAVE_PATH
	GameFlow.PERSISTENT_SAVE_PATH = TEST_PATH
	_cleanup(TEST_PATH)

	var f := FileAccess.open(TEST_PATH, FileAccess.WRITE)
	f.store_string(JSON.stringify({"deaths": 7, "wins": 2}))
	f.close()

	GameFlow.mark_prolog_seen()

	var check := FileAccess.open(TEST_PATH, FileAccess.READ)
	var data = JSON.parse_string(check.get_as_text())
	NemoraxTest.assert_eq(int(data.get("deaths", -1)), 7, "mark_prolog_seen() nie powinno nadpisać innych kluczy (deaths, dzielone z arena.gd)")
	NemoraxTest.assert_eq(int(data.get("wins", -1)), 2, "mark_prolog_seen() nie powinno nadpisać innych kluczy (wins)")
	NemoraxTest.assert_true(bool(data.get("seen_prolog", false)), "seen_prolog powinno zostać ustawione")

	_cleanup(TEST_PATH)
	GameFlow.PERSISTENT_SAVE_PATH = original_path

func test_start_room_plays_prolog_once(root: Node) -> void:
	var original_path := GameFlow.PERSISTENT_SAVE_PATH
	GameFlow.PERSISTENT_SAVE_PATH = TEST_PATH
	_cleanup(TEST_PATH)
	GameFlow.reset_run() # świeża mapa, START w (0,0), entry_direction ZERO

	var room = load("res://rooms/room.tscn").instantiate()
	root.add_child(room)

	NemoraxTest.assert_true(root.get_tree().paused, "pierwsze wejście do pokoju startowego powinno odpalić prolog i spauzować drzewo")
	NemoraxTest.assert_true(GameFlow.has_seen_prolog(), "wejście do pokoju startowego powinno od razu oznaczyć prolog jako widziany")
	NemoraxTest.assert_true(room.ui.hide_all, "prolog musi ukryć HUD i komunikaty pod dialogiem")

	root.get_tree().paused = false
	root.remove_child(room)
	room.queue_free()
	_cleanup(TEST_PATH)
	GameFlow.PERSISTENT_SAVE_PATH = original_path
	GameFlow.mark_prolog_seen() # przywróć globalny stan "widziany" dla testów PO tym pliku (kolejność alfabetyczna)
