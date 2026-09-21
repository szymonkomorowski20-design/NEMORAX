extends Node2D
class_name Door
## Drzwi — na starcie pokoju prowadzą do wcielenia, po jego pokonaniu nowe drzwi
## prowadzą dalej. Przechodzi się przez nie samym podejściem, bez przycisku
## (rozszerzenie poza dokument bazowy, patrz LORE_I_ASSETY.md).

signal entered

const TEX_DOOR := preload("res://assets/sprites/pokoje/obiekty/rift_doorway.png")
const SPRITE_SCALE := 0.12

@export var trigger_range: float = 40.0
@export var door_color: Color = Color("#C9C2B4")

var player: Player = null
var _triggered: bool = false

@onready var sprite: Sprite2D = $Sprite

func _ready() -> void:
	sprite.texture = TEX_DOOR
	sprite.scale = Vector2(SPRITE_SCALE, SPRITE_SCALE)
	sprite.modulate = door_color
	var contact_shadow := ContactShadow.new()
	contact_shadow.position = Vector2(0.0, 26.0)
	contact_shadow.configure(56.0, 12.0, 0.28)
	add_child(contact_shadow)

func _physics_process(_delta: float) -> void:
	if _triggered or player == null:
		return
	if global_position.distance_to(player.global_position) <= trigger_range:
		_triggered = true
		entered.emit()
		queue_free()
