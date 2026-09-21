extends RefCounted
## Powrót do już wyczyszczonego pokoju (możliwe na siatce — graf, nie
## jednokierunkowy korytarz) nie może respawnować przeciwnika ani drugi raz
## doliczać fragmentu duszy/licznika wyczyszczonych pokoi.

func _reset() -> void:
	GameFlow.reset_run()

func test_revisiting_cleared_random_room_does_not_respawn_enemy(root: Node) -> void:
	_reset()
	var pos: Vector2i = GameFlow.DIRECTIONS[0]
	for d in GameFlow.DIRECTIONS:
		if GameFlow.room_map.has(Vector2i.ZERO + d) and GameFlow.room_map[Vector2i.ZERO + d]["type"] == GameFlow.RoomType.RANDOM:
			pos = d
			break
	GameFlow.current_room_pos = pos
	GameFlow.room_map[pos]["cleared"] = true

	var before_count := get_hittable_count(root)
	var room = load("res://rooms/room.tscn").instantiate()
	root.add_child(room)

	NemoraxTest.assert_eq(get_hittable_count(root), before_count, "wyczyszczony pokój RANDOM nie powinien zespawnować przeciwnika przy ponownym wejściu")

	root.remove_child(room)
	room.queue_free()
	_reset()

func test_revisiting_cleared_soul_room_does_not_respawn_enemy(root: Node) -> void:
	_reset()
	var soul_pos: Vector2i
	for p in GameFlow.room_map.keys():
		if GameFlow.room_map[p]["type"] == GameFlow.RoomType.SOUL:
			soul_pos = p
			break
	GameFlow.current_room_pos = soul_pos
	GameFlow.room_map[soul_pos]["cleared"] = true

	var before_count := get_hittable_count(root)
	var room = load("res://rooms/room.tscn").instantiate()
	root.add_child(room)

	NemoraxTest.assert_eq(get_hittable_count(root), before_count, "wyczyszczony pokój SOUL nie powinien zespawnować wcielenia przy ponownym wejściu")

	root.remove_child(room)
	room.queue_free()
	_reset()

func test_uncleared_random_room_still_spawns_enemy_normally(root: Node) -> void:
	_reset()
	var pos: Vector2i = GameFlow.DIRECTIONS[0]
	for d in GameFlow.DIRECTIONS:
		if GameFlow.room_map.has(Vector2i.ZERO + d) and GameFlow.room_map[Vector2i.ZERO + d]["type"] == GameFlow.RoomType.RANDOM:
			pos = d
			break
	GameFlow.current_room_pos = pos
	# cleared zostaje false (świeży, nieodwiedzony pokój)

	var before_count := get_hittable_count(root)
	var room = load("res://rooms/room.tscn").instantiate()
	root.add_child(room)

	NemoraxTest.assert_true(get_hittable_count(root) > before_count, "regresja: świeży, nieoczyszczony pokój RANDOM powinien nadal spawnować przeciwnika")

	root.remove_child(room)
	room.queue_free()
	_reset()

func get_hittable_count(root: Node) -> int:
	return root.get_tree().get_nodes_in_group("hittable").size()
