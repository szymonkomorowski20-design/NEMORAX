class_name Walls
extends RefCounted
## Wspólne budowanie ścian areny — używane przez arena.gd i room.gd, żeby nie
## kopiować tego samego kodu w każdym pomieszczeniu (rozszerzenie o wiele pokoi
## poza pierwotny dokument, patrz LORE_I_ASSETY.md).

static func build(parent: Node2D, rect: Rect2, thickness: float) -> void:
	var segments := [
		{"pos": Vector2(rect.position.x + rect.size.x * 0.5, rect.position.y - thickness * 0.5),
			"size": Vector2(rect.size.x + thickness * 2.0, thickness)}, # góra
		{"pos": Vector2(rect.position.x + rect.size.x * 0.5, rect.position.y + rect.size.y + thickness * 0.5),
			"size": Vector2(rect.size.x + thickness * 2.0, thickness)}, # dół
		{"pos": Vector2(rect.position.x - thickness * 0.5, rect.position.y + rect.size.y * 0.5),
			"size": Vector2(thickness, rect.size.y)}, # lewo
		{"pos": Vector2(rect.position.x + rect.size.x + thickness * 0.5, rect.position.y + rect.size.y * 0.5),
			"size": Vector2(thickness, rect.size.y)}, # prawo
	]
	for seg in segments:
		var body := StaticBody2D.new()
		body.collision_layer = 1
		body.collision_mask = 0
		body.position = seg["pos"]
		var shape := CollisionShape2D.new()
		var rect_shape := RectangleShape2D.new()
		rect_shape.size = seg["size"]
		shape.shape = rect_shape
		body.add_child(shape)
		parent.add_child(body)
