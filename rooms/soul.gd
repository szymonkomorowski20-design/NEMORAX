extends Node2D
class_name Soul
## Dusza wcielenia — wypada po jego pokonaniu, trzeba do niej podejść i nacisnąć
## F, żeby ją podnieść (rozszerzenie poza dokument bazowy, patrz LORE_I_ASSETY.md).

signal collected

const TEX_SOUL := preload("res://assets/sprites/pokoje/obiekty/incarnation_soul.png")
const SND_PICKUP := preload("res://assets/audio/sfx/swiat/W03_soul_pickup.wav")
const BASE_SPRITE_SCALE := 0.055

@export var pickup_range: float = 45.0
@export var pulse_speed: float = 3.0
@export var pulse_strength: float = 0.15 ## +/- ułamek skali, jak mocno "oddycha"
@export var hint_font_size: int = 16

var color: Color = Color.WHITE
var player: Player = null

@onready var sprite: Sprite2D = $Sprite

func _ready() -> void:
	sprite.texture = TEX_SOUL
	sprite.modulate = color

func _physics_process(_delta: float) -> void:
	var pulse := 1.0 + pulse_strength * sin(Time.get_ticks_msec() / 1000.0 * pulse_speed)
	sprite.scale = Vector2(BASE_SPRITE_SCALE, BASE_SPRITE_SCALE) * pulse

	if player == null:
		return
	if global_position.distance_to(player.global_position) <= pickup_range:
		if Input.is_action_just_pressed("pickup"):
			Juice.play_sfx_at(SND_PICKUP, global_position)
			collected.emit()
			queue_free()
			return
	queue_redraw()

## Zostaje kodem — to tekst, nie grafika.
func _draw() -> void:
	if player and global_position.distance_to(player.global_position) <= pickup_range:
		var font := ThemeDB.fallback_font
		var text := "[F]"
		var text_size := font.get_string_size(text, HORIZONTAL_ALIGNMENT_CENTER, -1, hint_font_size)
		draw_string(font, Vector2(-text_size.x * 0.5, -40.0), text,
			HORIZONTAL_ALIGNMENT_LEFT, -1, hint_font_size, Palette.HIT_FLASH)
