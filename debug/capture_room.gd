extends SceneTree
## Użycie: Godot --path <projekt> --script res://debug/capture_room.gd -- <png> [start|mordrath]
## Izoluje zapis testowy, więc zrzut nie zmienia prawdziwej próby gracza.

func _initialize() -> void:
	await process_frame
	var args := OS.get_cmdline_user_args()
	if args.is_empty():
		push_error("Podaj ścieżkę docelowego PNG po --")
		quit(2)
		return
	var game_flow: Node = root.get_node("GameFlow")
	game_flow.SAVE_PATH = "user://test_capture_run.json"
	game_flow.PERSISTENT_SAVE_PATH = "user://test_capture_persistent.json"
	game_flow.mark_prolog_seen()
	game_flow.reset_run()
	if args.size() > 1 and args[1].begins_with("mordrath"):
		game_flow.entry_direction = Vector2i(0, -1) # gracz przy dolnej ścianie, nie pod sprite'em bossa
		game_flow.room_map[Vector2i.ZERO] = {
			"type": game_flow.RoomType.SOUL, "chapter": 1, "enemy_index": -1,
			"cleared": false, "has_chest": false, "chest_opened": false,
		}
	var room: Node2D = load("res://rooms/room.tscn").instantiate()
	root.add_child(room)
	if args.size() > 1 and args[1] == "mordrath_bottom":
		var enemy = room.incarnation
		enemy.global_position = enemy._clamp_to_arena(
			Vector2(room._play_rect.get_center().x, room._play_rect.end.y + 500.0))
	await process_frame
	await RenderingServer.frame_post_draw
	var image: Image = root.get_texture().get_image()
	var err := image.save_png(args[0])
	print("ROOM_CAPTURE=%s STATUS=%d" % [args[0], err])
	quit(0 if err == OK else 1)
