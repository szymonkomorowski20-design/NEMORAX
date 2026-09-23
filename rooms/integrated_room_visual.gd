class_name IntegratedRoomVisual
extends Node2D
## Tło i cztery ściany z portalami osadzonymi w murze.
## Przejście pozostaje wygaszone, dopóki Room nie utworzy aktywnych drzwi.

const ART_ROOT := "res://assets/sprites/pokoje/prototypy/integrated_wall_doors_v1/"
const PORTAL_SHADER := preload("res://rooms/integrated_portal_seal.gdshader")
const FLOOR_REGION := Rect2(150.0, 175.0, 1236.0, 674.0)
const SIDES := ["top", "bottom", "left", "right"]

var _portal_sprites: Dictionary = {}

func configure(arena_rect: Rect2, theme_slug: String) -> bool:
	var prefix := ART_ROOT + theme_slug + "/"
	var floor_texture := load(prefix + "room_preview.png") as Texture2D
	if floor_texture == null:
		push_warning("Brak tła zintegrowanego pokoju: " + theme_slug)
		return false
	for side in SIDES:
		if not ResourceLoader.exists(prefix + "wall_door_" + side + ".png"):
			push_warning("Brak ściany zintegrowanego pokoju: " + theme_slug + "/" + side)
			return false

	var floor_sprite := Sprite2D.new()
	floor_sprite.name = "IntegratedFloor"
	floor_sprite.texture = floor_texture
	floor_sprite.centered = false
	floor_sprite.region_enabled = true
	floor_sprite.region_rect = FLOOR_REGION
	floor_sprite.position = arena_rect.position
	floor_sprite.scale = Vector2(arena_rect.size.x / FLOOR_REGION.size.x, arena_rect.size.y / FLOOR_REGION.size.y)
	floor_sprite.z_index = -10
	add_child(floor_sprite)

	for side in SIDES:
		var wall_texture := load(prefix + "wall_door_" + side + ".png") as Texture2D
		if wall_texture == null:
			push_warning("Nie można wczytać ściany: " + theme_slug + "/" + side)
			return false
		var wall_sprite := Sprite2D.new()
		wall_sprite.name = "WallDoor_" + side
		wall_sprite.texture = wall_texture
		wall_sprite.position = Walls.wall_point(arena_rect, side)
		wall_sprite.z_index = -5
		if side == "top" or side == "bottom":
			wall_sprite.scale = Vector2((arena_rect.size.x + 110.0) / wall_texture.get_width(), 0.32)
		else:
			wall_sprite.scale = Vector2(0.32, (arena_rect.size.y + 70.0) / wall_texture.get_height())
			wall_sprite.position.x += 14.0 if side == "left" else -14.0
		var seal_material := ShaderMaterial.new()
		seal_material.shader = PORTAL_SHADER
		seal_material.set_shader_parameter("open_amount", 0.0)
		wall_sprite.material = seal_material
		add_child(wall_sprite)
		_portal_sprites[side] = wall_sprite
	return true

func set_portal_open(side: String) -> void:
	var wall_sprite := _portal_sprites.get(side) as Sprite2D
	if wall_sprite == null:
		return
	var seal_material := wall_sprite.material as ShaderMaterial
	seal_material.set_shader_parameter("open_amount", 1.0)
