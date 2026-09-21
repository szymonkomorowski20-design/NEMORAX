extends Node2D
class_name Door
## Drzwi — na starcie pokoju prowadzą do wcielenia, po jego pokonaniu nowe drzwi
## prowadzą dalej. Przechodzi się przez nie samym podejściem, bez przycisku
## (rozszerzenie poza dokument bazowy, patrz LORE_I_ASSETY.md).

signal entered

## Każda ściana ma własną perspektywę przejścia. Nie obracamy jednego PNG.
const TEX_TOP := preload("res://assets/sprites/pokoje/obiekty/rift_doorway_top_v4.png")
const TEX_BOTTOM := preload("res://assets/sprites/pokoje/obiekty/rift_doorway_bottom_v4.png")
const TEX_LEFT := preload("res://assets/sprites/pokoje/obiekty/rift_doorway_left_v4.png")
const TEX_RIGHT := preload("res://assets/sprites/pokoje/obiekty/rift_doorway_right_v4.png")
const SPRITE_SCALE := 0.12

@export var trigger_range: float = 40.0
@export var door_color: Color = Color("#C9C2B4")

var player: Player = null
## Ustawiane przez Room. Każdy bok wybiera własny asset.
var wall_side: String = "top"
var _triggered: bool = false

@onready var sprite: Sprite2D = $Sprite

func _ready() -> void:
	z_index = -3 # nad ścianą, pod postaciami i VFX
	sprite.texture = _texture_for_wall_side()
	sprite.scale = Vector2(SPRITE_SCALE, SPRITE_SCALE)
	sprite.modulate = door_color
	var contact_shadow := ContactShadow.new()
	contact_shadow.position = _threshold_offset()
	contact_shadow.configure(64.0, 16.0, 0.46) # wyraźniejszy — portal ma wyglądać na osadzony w ścianie, nie naklejony (KIERUNEK_WIZUALNY_REFERENCJE.md)
	add_child(contact_shadow)

func _texture_for_wall_side() -> Texture2D:
	match wall_side:
		"bottom": return TEX_BOTTOM
		"left": return TEX_LEFT
		"right": return TEX_RIGHT
		_: return TEX_TOP

func _threshold_offset() -> Vector2:
	match wall_side:
		"bottom": return Vector2(0.0, -30.0)
		"left": return Vector2(30.0, 0.0)
		"right": return Vector2(-30.0, 0.0)
		_: return Vector2(0.0, 30.0)

func _physics_process(_delta: float) -> void:
	if _triggered or player == null:
		return
	if global_position.distance_to(player.global_position) <= trigger_range:
		_triggered = true
		entered.emit()
		queue_free()
