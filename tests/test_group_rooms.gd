extends RefCounted

func test_group_room_waits_for_all_enemies_before_clearing(root: Node) -> void:
	var old_map := GameFlow.room_map
	var old_pos := GameFlow.current_room_pos
	var old_count := GameFlow.rooms_cleared_count
	var old_state := GameFlow.saved_player_state
	var old_entry := GameFlow.entry_direction
	GameFlow.room_map = {Vector2i.ZERO: {"type": GameFlow.RoomType.RANDOM, "chapter": 0, "enemy_index": 0, "cleared": false, "has_chest": false, "chest_opened": false}}
	GameFlow.current_room_pos = Vector2i.ZERO
	GameFlow.rooms_cleared_count = 3
	GameFlow.saved_player_state = {}
	GameFlow.entry_direction = Vector2i.ZERO
	var room = load("res://rooms/room.tscn").instantiate()
	root.add_child(room)
	NemoraxTest.assert_eq(room._active_enemies.size(), 2, "co czwarta wybrana komnata ma dwoje słabszych wrogów")
	var first: Incarnation = room._active_enemies[0]
	var second: Incarnation = room._active_enemies[1]
	NemoraxTest.assert_true(first.global_position.distance_to(second.global_position) > 200.0, "wrogowie nie powinni nachodzić na siebie")
	first.take_damage(10000.0)
	NemoraxTest.assert_eq(room._active_enemies.size(), 1, "pierwszy zgon usuwa tylko jednego wroga")
	NemoraxTest.assert_true(not GameFlow.room_map[Vector2i.ZERO]["cleared"], "pokój nie może się otworzyć po pierwszym zgonie")
	root.remove_child(room)
	room.queue_free()
	GameFlow.room_map = old_map
	GameFlow.current_room_pos = old_pos
	GameFlow.rooms_cleared_count = old_count
	GameFlow.saved_player_state = old_state
	GameFlow.entry_direction = old_entry
