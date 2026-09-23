extends RefCounted
## Skrzynie na siatce pokoi (CLAUDE_CODE_GAME_CONTENT_BIBLE.md sekcja 9,
## zaadaptowana z okien numerów pokoi na losową siatkę — patrz komentarz przy
## GameFlow.CHEST_COUNT) i mechanika otwierania w rooms/chest.gd.

func _reset() -> void:
	GameFlow.reset_run()

func test_exactly_five_chest_rooms_assigned_among_random_rooms(_root: Node) -> void:
	for i in range(20): # generacja jest losowa — kilka powtórzeń zamiast jednego ziarna
		_reset()
		var chest_rooms := 0
		for pos in GameFlow.room_map.keys():
			var data: Dictionary = GameFlow.room_map[pos]
			if data.get("has_chest", false):
				chest_rooms += 1
				NemoraxTest.assert_eq(data["type"], GameFlow.RoomType.RANDOM, "skrzynia powinna trafić tylko do pokoju RANDOM, próba %d" % i)
		NemoraxTest.assert_eq(chest_rooms, GameFlow.CHEST_COUNT, "dokładnie %d skrzyń na przebieg, próba %d" % [GameFlow.CHEST_COUNT, i])
	_reset()

func test_chest_flag_starts_unopened(_root: Node) -> void:
	_reset()
	for pos in GameFlow.room_map.keys():
		var data: Dictionary = GameFlow.room_map[pos]
		if data.get("has_chest", false):
			NemoraxTest.assert_true(not data["chest_opened"], "świeżo wygenerowana skrzynia nie powinna być otwarta")
	_reset()

func test_mark_chest_opened_persists_in_current_room(_root: Node) -> void:
	_reset()
	var chest_pos: Vector2i = Vector2i.ZERO
	var found := false
	for pos in GameFlow.room_map.keys():
		if GameFlow.room_map[pos].get("has_chest", false):
			chest_pos = pos
			found = true
			break
	NemoraxTest.assert_true(found, "powinna istnieć co najmniej jedna skrzynia do przetestowania")

	GameFlow.current_room_pos = chest_pos
	GameFlow.mark_chest_opened()
	NemoraxTest.assert_true(GameFlow.room_map[chest_pos]["chest_opened"], "mark_chest_opened() powinno oznaczyć bieżący pokój")
	_reset()

func test_chest_open_grants_an_unowned_upgrade(root: Node) -> void:
	var player: Player = load("res://entities/player.tscn").instantiate()
	root.add_child(player)
	var chest: Chest = load("res://rooms/chest.tscn").instantiate()
	root.add_child(chest)
	chest.player = player

	# GDScript przechwytuje zmienne lokalne w lambdach PRZEZ WARTOŚĆ, nie
	# referencję — `received_id = id` wewnątrz lambdy nadpisałoby tylko jej
	# własną kopię. Array to obiekt referencyjny, więc mutacja JEGO zawartości
	# faktycznie wraca do zewnętrznego zasięgu.
	var received: Array = []
	var offers: Array = []
	chest.opened.connect(func(id: String): received.append(id))
	chest.selection_requested.connect(func(ids: Array[String]): offers.assign(ids))
	chest._open()
	NemoraxTest.assert_eq(offers.size(), 3, "skrzynia pokazuje trzy różne relikwie")
	NemoraxTest.assert_eq(received.size(), 0, "skrzynia nie przyznaje relikwii przed wyborem")
	chest.choose(offers[0])

	NemoraxTest.assert_eq(received.size(), 1, "sygnał opened powinien wyemitować się dokładnie raz")
	NemoraxTest.assert_true(received[0] in Player.UPGRADE_IDS, "przyznane ID powinno być jednym z 10 znanych ulepszeń")
	NemoraxTest.assert_true(player.has_upgrade(received[0]), "gracz powinien faktycznie posiadać przyznane ulepszenie")

	root.remove_child(player)
	player.queue_free()

func test_chest_never_grants_an_already_owned_upgrade(root: Node) -> void:
	var player: Player = load("res://entities/player.tscn").instantiate()
	root.add_child(player)
	# Przyznaj 9 z 10 na sztywno, zostaw dokładnie jedno wolne — skrzynia MUSI trafić na nie.
	for id in Player.UPGRADE_IDS:
		if id != "soul_bond":
			player.acquire_upgrade(id)

	var chest: Chest = load("res://rooms/chest.tscn").instantiate()
	root.add_child(chest)
	chest.player = player
	var received: Array = []
	var offers: Array = []
	chest.opened.connect(func(id: String): received.append(id))
	chest.selection_requested.connect(func(ids: Array[String]): offers.assign(ids))
	chest._open()
	NemoraxTest.assert_eq(offers.size(), 1, "gdy została jedna relikwia, oferta pokazuje tylko ją")
	chest.choose(offers[0])

	NemoraxTest.assert_eq(received.size(), 1, "sygnał opened powinien wyemitować się dokładnie raz")
	NemoraxTest.assert_eq(received[0], "soul_bond", "z jednym wolnym slotem skrzynia musi trafić właśnie na niego")

	root.remove_child(player)
	player.queue_free()
