extends RefCounted
## Struktura 30 pokoi (6 rozdziałów × [4 losowe + 1 wcielenie]) w game_flow.gd —
## ustalona z autorem: losowe pokoje NIE dają fragmentów, wcielenia dają
## dokładnie tak jak dotychczas, ołtarz otwiera się dopiero po 30. pokoju.

func _reset() -> void:
	GameFlow.reset_run()

func test_total_room_count_is_thirty(_root: Node) -> void:
	NemoraxTest.assert_eq(GameFlow.total_room_count(), 30, "6 rozdziałów × 5 pokoi = 30")

func test_is_random_enemy_room_matches_the_4_plus_1_pattern(_root: Node) -> void:
	_reset()
	# Rozdział 0: sloty 0-3 losowe, slot 4 wcielenie.
	for i in [0, 1, 2, 3]:
		GameFlow.current_room_index = i
		NemoraxTest.assert_true(GameFlow.is_random_enemy_room(), "slot %d rozdziału 0 powinien być losowy" % i)
	GameFlow.current_room_index = 4
	NemoraxTest.assert_true(not GameFlow.is_random_enemy_room(), "slot 4 rozdziału 0 to wcielenie, nie losowy")
	# Rozdział 5 (ostatni): sloty 25-28 losowe, slot 29 wcielenie.
	for i in [25, 26, 27, 28]:
		GameFlow.current_room_index = i
		NemoraxTest.assert_true(GameFlow.is_random_enemy_room(), "slot %d rozdziału 5 powinien być losowy" % i)
	GameFlow.current_room_index = 29
	NemoraxTest.assert_true(not GameFlow.is_random_enemy_room(), "slot 29 to ostatnie wcielenie, nie losowy")
	_reset()

func test_current_chapter_index_groups_five_rooms_together(_root: Node) -> void:
	_reset()
	GameFlow.current_room_index = 0
	NemoraxTest.assert_eq(GameFlow.current_chapter_index(), 0, "pokój 0 to rozdział 0")
	GameFlow.current_room_index = 4
	NemoraxTest.assert_eq(GameFlow.current_chapter_index(), 0, "pokój 4 (wcielenie) to wciąż rozdział 0")
	GameFlow.current_room_index = 5
	NemoraxTest.assert_eq(GameFlow.current_chapter_index(), 1, "pokój 5 to już rozdział 1")
	GameFlow.current_room_index = 29
	NemoraxTest.assert_eq(GameFlow.current_chapter_index(), 5, "pokój 29 to rozdział 5 (ostatni)")
	_reset()

func test_complete_current_room_only_awards_fragment_on_incarnation_slot(_root: Node) -> void:
	_reset()
	GameFlow.current_room_index = 2 # losowy slot w rozdziale 0
	GameFlow.complete_current_room()
	NemoraxTest.assert_eq(GameFlow.fragments_collected.size(), 0, "losowy pokój nie powinien dać fragmentu")
	NemoraxTest.assert_eq(GameFlow.current_room_index, 3, "current_room_index powinien się zwiększyć mimo braku fragmentu")

	GameFlow.current_room_index = 4 # slot wcielenia w rozdziale 0
	GameFlow.complete_current_room()
	NemoraxTest.assert_eq(GameFlow.fragments_collected.size(), 1, "slot wcielenia powinien dać dokładnie jeden fragment")
	NemoraxTest.assert_eq(GameFlow.fragments_collected[0], GameFlow.INCARNATION_NAMES[0], "fragment powinien nosić nazwę wcielenia z rozdziału 0")
	_reset()

func test_choose_random_enemy_never_repeats_previous(_root: Node) -> void:
	_reset()
	var previous := ""
	for i in range(500):
		var path := GameFlow.choose_random_enemy_scene_path()
		NemoraxTest.assert_true(path in GameFlow.RANDOM_ENEMY_SCENES, "wybrana ścieżka musi pochodzić z puli")
		if previous != "":
			NemoraxTest.assert_true(path != previous, "losowy przeciwnik nie powinien powtórzyć poprzedniego")
		previous = path
	_reset()
