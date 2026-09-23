class_name Walls
extends RefCounted
## Wspólne budowanie ścian areny — używane przez arena.gd, room.gd i altar.gd,
## żeby nie kopiować tego samego kodu w każdym pomieszczeniu (rozszerzenie o
## wiele pokoi poza pierwotny dokument, patrz LORE_I_ASSETY.md).
##
## Kafelkowanie: Sprite2D nie powtarza tekstury samo z siebie — trzeba włączyć
## region_enabled z region_rect WIĘKSZYM niż sama tekstura i ustawić
## texture_repeat na Enabled, żeby przekroczone [0,1] UV zawijały się zamiast
## rozciągać brzegowy piksel.

const WALL_GROUP := "room_wall"

## Paczka 11: pociski (gracza i wrogów) gasną na ścianie zamiast przelatywać
## nad nią poza pokój — jedno zapytanie punktowe na klatkę, tylko ciała ścian
## (przeszkody terenu mają własną logikę w RoomTerrain.projectile_step).
static func point_in_wall(node: Node2D, pos: Vector2) -> bool:
	if not node.is_inside_tree():
		return false
	var query := PhysicsPointQueryParameters2D.new()
	query.position = pos
	query.collision_mask = 1
	for hit in node.get_world_2d().direct_space_state.intersect_point(query, 8):
		if hit["collider"] != null and hit["collider"].is_in_group(WALL_GROUP):
			return true
	return false

static func build(parent: Node2D, rect: Rect2, thickness: float, wall_texture: Texture2D = null, wall_modulate: Color = Color.WHITE) -> void:
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
		body.add_to_group(WALL_GROUP)
		body.collision_mask = 0
		body.position = seg["pos"]
		var shape := CollisionShape2D.new()
		var rect_shape := RectangleShape2D.new()
		rect_shape.size = seg["size"]
		shape.shape = rect_shape
		body.add_child(shape)
		parent.add_child(body)

		if wall_texture != null:
			var sprite := Sprite2D.new()
			sprite.texture = wall_texture
			sprite.region_enabled = true
			sprite.region_rect = Rect2(Vector2.ZERO, seg["size"])
			sprite.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
			sprite.position = seg["pos"]
			sprite.z_index = -5
			sprite.modulate = wall_modulate
			parent.add_child(sprite)

## Kafelkowana podłoga pod całą areną — osobno od build(), bo ściany zawsze są
## kolizją + opcjonalnym wyglądem, a podłoga to czysto wizualny spód sceny.
## `material` opcjonalny (np. entities/arena_stone_shader.gd, arena Nemoraxa) —
## zwykłe pokoje/ołtarz go nie podają i wyglądają dokładnie jak dotąd.
static func build_floor(parent: Node2D, rect: Rect2, floor_texture: Texture2D, material: Material = null) -> void:
	var sprite := Sprite2D.new()
	sprite.texture = floor_texture
	sprite.centered = false
	sprite.region_enabled = true
	sprite.region_rect = Rect2(Vector2.ZERO, rect.size)
	sprite.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	sprite.position = rect.position
	sprite.z_index = -10
	if material != null:
		sprite.material = material
	parent.add_child(sprite)

## Punkt na środku danej ściany, dokładnie tam gdzie build() powyżej stawia jej
## segment (na granicy rect, nie gdzieś w otwartej podłodze) — do stawiania
## drzwi TAK, żeby wizualnie tkwiły w ścianie, na życzenie autora (poprzednio
## drzwi dostawały dowolne przesunięcie od środka areny i floated na podłodze).
static func wall_point(rect: Rect2, side: String) -> Vector2:
	var center := rect.get_center()
	match side:
		"top":
			return Vector2(center.x, rect.position.y)
		"bottom":
			return Vector2(center.x, rect.position.y + rect.size.y)
		"left":
			return Vector2(rect.position.x, center.y)
		"right":
			return Vector2(rect.position.x + rect.size.x, center.y)
		_:
			return center

## Tło poza areną (reszta viewportu) — najgłębsza warstwa, kafelkowana tak samo.
static func build_void_background(parent: Node2D, viewport_size: Vector2, texture: Texture2D, bg_modulate: Color = Color.WHITE) -> void:
	var sprite := Sprite2D.new()
	sprite.texture = texture
	sprite.centered = false
	sprite.region_enabled = true
	sprite.region_rect = Rect2(Vector2.ZERO, viewport_size)
	sprite.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	sprite.position = Vector2.ZERO
	sprite.z_index = -20
	sprite.modulate = bg_modulate
	parent.add_child(sprite)
