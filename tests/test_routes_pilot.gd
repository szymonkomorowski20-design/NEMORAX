extends RefCounted
## Paczka 7 (AUDYT E3/A13/D): ryzyko i nagroda widoczne przed wejściem,
## elita zaplanowana przy generowaniu, pokoje odpoczynku, motywy bez powtórek
## u sąsiadów, zapis/wczytanie bez ponownego losowania, wersja generatora.

func _restore() -> void:
	GameFlow.reset_run()

func test_markers_show_risk_and_reward(_root: Node) -> void:
	NemoraxTest.assert_eq(MapMarker.kind_for({"type": GameFlow.RoomType.RANDOM, "trap": true, "cleared": false}), "trap", "pułapka widoczna")
	NemoraxTest.assert_eq(MapMarker.kind_for({"type": GameFlow.RoomType.RANDOM, "trap": true, "cleared": true}), "", "po oczyszczeniu znika")
	NemoraxTest.assert_eq(MapMarker.kind_for({"type": GameFlow.RoomType.RANDOM, "has_chest": true, "chest_opened": false, "cleared": true}), "chest", "nieotwarta skrzynia widoczna też po walce")
	NemoraxTest.assert_eq(MapMarker.kind_for({"type": GameFlow.RoomType.RANDOM, "elite": true}), "elite", "elita widoczna")
	NemoraxTest.assert_eq(MapMarker.kind_for({"type": GameFlow.RoomType.RANDOM, "rest": true}), "rest", "odpoczynek widoczny")
	NemoraxTest.assert_eq(MapMarker.kind_for({"type": GameFlow.RoomType.SOUL, "cleared": false}), "soul", "dusza widoczna")
	NemoraxTest.assert_eq(MapMarker.kind_for({"type": GameFlow.RoomType.ALTAR}), "altar", "ołtarz widoczny")

func test_generation_plans_elites_and_two_rest_rooms(_root: Node) -> void:
	for s in 30:
		GameFlow.reset_run(300 + s)
		var rests := 0
		var dist := GameFlow.room_distances()
		for pos in GameFlow.room_map:
			var d: Dictionary = GameFlow.room_map[pos]
			if d.get("rest", false):
				rests += 1
				NemoraxTest.assert_true(int(dist[pos]) >= 3, "odpoczynek nie tuż przy starcie")
				NemoraxTest.assert_true(not d.get("trap", false) and not d.get("has_chest", false) and not d.get("elite", false), "odpoczynek nie łączy się z pułapką/skrzynią/elitą")
			if d.get("trap", false):
				NemoraxTest.assert_true(not d.get("elite", false), "pułapka bez elity")
		NemoraxTest.assert_eq(rests, GameFlow.REST_ROOM_COUNT, "dwa pokoje odpoczynku (seed %d)" % (300 + s))
	_restore()

func test_neighbouring_random_rooms_do_not_share_a_theme(_root: Node) -> void:
	var clashes := 0
	var pairs := 0
	for s in 30:
		GameFlow.reset_run(600 + s)
		for pos in GameFlow.room_map:
			var d: Dictionary = GameFlow.room_map[pos]
			if d["type"] != GameFlow.RoomType.RANDOM:
				continue
			for dir in [Vector2i(1, 0), Vector2i(0, 1)]:
				var n: Dictionary = GameFlow.room_map.get(pos + dir, {})
				if n.get("type") == GameFlow.RoomType.RANDOM:
					pairs += 1
					clashes += 1 if int(n["theme"]) == int(d["theme"]) and not n.get("trap", false) and not d.get("trap", false) else 0
	NemoraxTest.assert_true(clashes <= pairs / 50, "sąsiednie komnaty prawie nigdy nie mają tego samego motywu (%d / %d)" % [clashes, pairs])
	_restore()

func test_route_plan_survives_save_and_load(_root: Node) -> void:
	GameFlow.reset_run(4321)
	var before := {}
	for pos in GameFlow.room_map:
		var d: Dictionary = GameFlow.room_map[pos]
		if d["type"] != GameFlow.RoomType.RANDOM:
			continue
		before[pos] = [d.get("elite", false), d.get("rest", false), d.get("theme", -1), d.get("trap", false)]
	GameFlow._save_progress()
	GameFlow.room_map.clear()
	NemoraxTest.assert_true(GameFlow._load_progress(), "zapis się wczytuje")
	for pos in before:
		var d: Dictionary = GameFlow.room_map[pos]
		NemoraxTest.assert_eq([d.get("elite", false), d.get("rest", false), d.get("theme", -1), d.get("trap", false)], before[pos], "pokój %s po wczytaniu bez zmian" % pos)
	NemoraxTest.assert_eq(GameFlow.run_seed, 4321, "seed zapisany")
	var file := FileAccess.open(GameFlow.SAVE_PATH, FileAccess.READ)
	var data = JSON.parse_string(file.get_as_text())
	NemoraxTest.assert_eq(int(data.get("map_version", 0)), GameFlow.MAP_VERSION, "wersja generatora w zapisie")
	_restore()

func _room_with(root: Node, data: Dictionary) -> Node:
	GameFlow.room_map = {Vector2i(2, 0): data, Vector2i(1, 0): {"type": GameFlow.RoomType.RANDOM, "chapter": -1, "enemy_index": 0, "cleared": false, "has_chest": false, "chest_opened": false, "trap": true}}
	GameFlow.current_room_pos = Vector2i(2, 0)
	GameFlow.entry_direction = Vector2i(1, 0)
	var room = load("res://rooms/room.tscn").instantiate()
	root.add_child(room)
	return room

func test_rest_room_heals_once_without_a_fight(root: Node) -> void:
	var old_map := GameFlow.room_map
	var old_pos := GameFlow.current_room_pos
	var old_entry := GameFlow.entry_direction
	var data := {"type": GameFlow.RoomType.RANDOM, "chapter": -1, "enemy_index": 0, "cleared": false, "has_chest": false, "chest_opened": false, "rest": true, "rest_used": false, "theme": 2}
	GameFlow.saved_player_state = {"health": 20.0}
	var room := _room_with(root, data)
	NemoraxTest.assert_eq(room._active_enemies.size(), 0, "w pokoju odpoczynku nie ma walki")
	NemoraxTest.assert_true(data["cleared"] and data["rest_used"], "drzwi otwarte, odpoczynek zużyty")
	NemoraxTest.assert_almost_eq(room.player.health, 20.0 + room.player.max_health * GameFlow.REST_HEAL_FRACTION, 0.01, "+30% życia")
	var hp: float = room.player.health
	root.remove_child(room)
	room.queue_free()
	GameFlow.saved_player_state = {"health": hp}
	room = _room_with(root, data)
	NemoraxTest.assert_almost_eq(room.player.health, hp, 0.01, "drugi raz nie leczy")
	root.remove_child(room)
	room.queue_free()
	GameFlow.saved_player_state = {}
	GameFlow.room_map = old_map
	GameFlow.current_room_pos = old_pos
	GameFlow.entry_direction = old_entry

func test_planned_elite_is_spawned_and_door_shows_marker(root: Node) -> void:
	var old_map := GameFlow.room_map
	var old_pos := GameFlow.current_room_pos
	var old_entry := GameFlow.entry_direction
	var data := {"type": GameFlow.RoomType.RANDOM, "chapter": -1, "enemy_index": 0, "cleared": false, "has_chest": false, "chest_opened": false, "elite": true, "theme": 2}
	GameFlow.saved_player_state = {}
	var room := _room_with(root, data)
	NemoraxTest.assert_true(room.incarnation.is_elite, "zaplanowana elita pojawia się jako elita")
	room._active_enemies.clear()
	data["cleared"] = true
	room._spawn_doors_for_open_directions()
	var badges := 0
	for c in room.get_children():
		if c is DoorBadge and c.kind == "trap":
			badges += 1
	NemoraxTest.assert_eq(badges, 1, "nad drzwiami do pokoju pułapek jest znacznik")
	root.remove_child(room)
	room.queue_free()
	GameFlow.room_map = old_map
	GameFlow.current_room_pos = old_pos
	GameFlow.entry_direction = old_entry
