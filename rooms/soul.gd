extends Node2D
class_name Soul
## Dusza wcielenia — wypada po jego pokonaniu, trzeba do niej podejść i nacisnąć
## F, żeby ją podnieść (rozszerzenie poza dokument bazowy, patrz LORE_I_ASSETY.md).

signal collected

@export var pickup_range: float = 45.0
@export var pulse_speed: float = 3.0
@export var hint_font_size: int = 16

var color: Color = Color.WHITE
var player: Player = null

func _physics_process(_delta: float) -> void:
	if player == null:
		return
	if global_position.distance_to(player.global_position) <= pickup_range:
		if Input.is_action_just_pressed("pickup"):
			collected.emit()
			queue_free()
			return
	queue_redraw()

func _draw() -> void:
	var pulse := 0.75 + 0.25 * sin(Time.get_ticks_msec() / 1000.0 * pulse_speed)
	draw_circle(Vector2.ZERO, 9.0 * pulse, color)
	draw_arc(Vector2.ZERO, 14.0, 0.0, TAU, 20, Color(color, 0.6), 2.0)

	if player and global_position.distance_to(player.global_position) <= pickup_range:
		var font := ThemeDB.fallback_font
		var text := "[F]"
		var text_size := font.get_string_size(text, HORIZONTAL_ALIGNMENT_CENTER, -1, hint_font_size)
		draw_string(font, Vector2(-text_size.x * 0.5, -26.0), text,
			HORIZONTAL_ALIGNMENT_LEFT, -1, hint_font_size, Palette.HIT_FLASH)
