extends SceneTree
## Matryca czterech pilotażowych motywów (audyt nagrania 24.09, P1.8): ten sam
## zoom, jasność i pozycje. Dla każdego motywu arkusz 4×2: pusty pokój, walka,
## stan motywu (woda / kryształ / zapowiedź prasy / uderzenie prasy) i gracz
## (układ jak w generatorze: biblioteka zawsze „oslona”, patrz GameFlow._assign_room_plans)
## w każdych z czterech drzwi. Zapis izolowany.
## Użycie: Godot --path <projekt> --script res://debug/motif_matrix.gd -- <katalog>

const TILE := Vector2i(480, 270)
const MOTIFS := [
	{"name": "zalana_katakumba", "theme": 0, "trap": false, "layout": "open"},
	{"name": "biblioteka", "theme": 1, "trap": false, "layout": "oslona"},
	{"name": "krysztalowa_grota", "theme": 6, "trap": false, "layout": "open"},
	{"name": "zardzewiala_hala", "theme": 7, "trap": true, "layout": "open"},
]

var out_dir := ""
var gf: Node

func _initialize() -> void:
	await process_frame
	out_dir = OS.get_cmdline_user_args()[0]
	gf = root.get_node("GameFlow")
	gf.SAVE_PATH = "user://test_capture_run.json"
	gf.PERSISTENT_SAVE_PATH = "user://test_capture_persistent.json"
	gf.mark_prolog_seen()
	gf.set_run_intent("ostrze")
	for m in MOTIFS:
		await _sheet(m)
	quit(0)

func _map(m: Dictionary, cleared: bool) -> void:
	gf.reset_run(7)
	var center := {"type": gf.RoomType.RANDOM, "chapter": -1, "enemy_index": 0, "cleared": cleared,
		"has_chest": false, "chest_opened": false, "theme": m["theme"], "layout": m["layout"], "trap": m["trap"],
		"elite": false, "rest": false, "rest_used": false}
	gf.room_map = {Vector2i.ZERO: center}
	for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
		gf.room_map[d] = {"type": gf.RoomType.RANDOM, "chapter": -1, "enemy_index": 1, "cleared": true,
			"has_chest": false, "chest_opened": false, "theme": 2, "layout": "open", "trap": false,
			"elite": false, "rest": false, "rest_used": false}
	gf.current_room_pos = Vector2i.ZERO
	gf.entry_direction = Vector2i(0, -1)
	gf.rooms_cleared_count = 6

func _grab(full_name: String = "") -> Image:
	await RenderingServer.frame_post_draw
	var img: Image = root.get_texture().get_image()
	if full_name != "":
		img.save_png("%s/%s.png" % [out_dir, full_name])
	img.resize(TILE.x, TILE.y, Image.INTERPOLATE_LANCZOS)
	return img

func _room(m: Dictionary, cleared: bool) -> Node2D:
	_map(m, cleared)
	var room: Node2D = load("res://rooms/room.tscn").instantiate()
	root.add_child(room)
	for i in 4:
		await process_frame
	return room

func _free(room: Node2D) -> void:
	root.remove_child(room)
	room.queue_free()
	await process_frame

func _sheet(m: Dictionary) -> void:
	var tiles: Array[Image] = []
	# 1. Pusty pokój (wyczyszczony), gracz na środku.
	var room := await _room(m, true)
	room.player.global_position = room._play_rect.get_center()
	tiles.append(await _grab())
	# 5–8. Gracz tuż przy każdych drzwiach (ten sam pokój).
	var door_tiles: Array[Image] = []
	for side in ["top", "bottom", "left", "right"]:
		var wall_pos: Vector2 = Walls.wall_point(room._play_rect, side)
		room.player.global_position = wall_pos + (room._play_rect.get_center() - wall_pos).normalized() * 70.0
		for i in 3:
			await process_frame
		door_tiles.append(await _grab())
	await _free(room)
	# 2. Walka: przeciwnicy po wejściu, bez czekania na ich śmierć.
	room = await _room(m, false)
	room.player.set_physics_process(false)
	room.player.global_position = room._play_rect.get_center() + Vector2(0, 90)
	for i in 70:
		await process_frame
	tiles.append(await _grab())
	# 3–4. Stan motywu.
	var terrain = room.terrain
	match m["name"]:
		"zalana_katakumba":
			room.player.global_position = terrain.slow_lane.get_center() + Vector2(-120, 0)
			for e in room._active_enemies:
				if is_instance_valid(e):
					e.set_physics_process(false)
					e.global_position = terrain.slow_lane.get_center() + Vector2(140, 0)
					break
			for i in 20:
				await process_frame
			tiles.append(await _grab("pelny_woda"))
			room.player.global_position = Vector2(terrain.slow_lane.get_center().x, terrain.slow_lane.position.y - 4)
			for i in 10:
				await process_frame
			tiles.append(await _grab())
		"krysztalowa_grota":
			var shot: Node2D = load("res://entities/enemy_projectile.tscn").instantiate()
			shot.direction = Vector2(0.3, -1.0).normalized()
			shot.lifetime = 6.0
			room.add_child(shot)
			shot.global_position = Vector2(room._play_rect.get_center().x, room._play_rect.position.y + 110)
			for i in 14:
				await process_frame
			tiles.append(await _grab("pelny_krysztal"))
			for i in 12:
				await process_frame
			tiles.append(await _grab())
		"zardzewiala_hala":
			terrain.trap_time = EncounterPlan.TRAP_PERIOD + EncounterPlan.TRAP_TELEGRAPH * 0.7
			for i in 2:
				await process_frame
			tiles.append(await _grab("pelny_prasa_zapowiedz"))
			terrain.trap_time = EncounterPlan.TRAP_PERIOD + EncounterPlan.TRAP_TELEGRAPH + 0.1
			for i in 2:
				await process_frame
			tiles.append(await _grab())
		_:
			for i in 60:
				await process_frame
			tiles.append(await _grab())
			tiles.append(tiles[1])
	await _free(room)
	tiles.append_array(door_tiles)
	var sheet := Image.create(TILE.x * 4, TILE.y * 2, false, tiles[0].get_format())
	for i in tiles.size():
		sheet.blit_rect(tiles[i], Rect2i(Vector2i.ZERO, TILE), Vector2i((i % 4) * TILE.x, (i / 4) * TILE.y))
	var path := "%s/matryca_%s.png" % [out_dir, m["name"]]
	print("SHEET %s %d" % [path, sheet.save_png(path)])
