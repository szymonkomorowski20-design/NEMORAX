extends SceneTree
## Osobny smoke test renderowania zalanego pokoju:
## godot --headless --script res://tests/smoke_water_render.gd

func _initialize() -> void:
	await process_frame
	var terrain: Node2D = load("res://rooms/room_terrain.gd").new()
	terrain.slow_lane = Rect2(120.0, 180.0, 930.0, 280.0)
	root.add_child(terrain)
	for i in 5:
		terrain.queue_redraw()
		await process_frame
	root.remove_child(terrain)
	terrain.queue_free()
	quit()
