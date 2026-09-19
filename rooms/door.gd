extends Node2D
class_name Door
## Drzwi — na starcie pokoju prowadzą do wcielenia, po jego pokonaniu nowe drzwi
## prowadzą dalej. Przechodzi się przez nie samym podejściem, bez przycisku
## (rozszerzenie poza dokument bazowy, patrz LORE_I_ASSETY.md).

signal entered

@export var trigger_range: float = 40.0
@export var door_color: Color = Color("#C9C2B4")

var player: Player = null
var _triggered: bool = false

func _physics_process(_delta: float) -> void:
	if _triggered or player == null:
		return
	if global_position.distance_to(player.global_position) <= trigger_range:
		_triggered = true
		entered.emit()
		queue_free()

func _draw() -> void:
	draw_rect(Rect2(Vector2(-16.0, -28.0), Vector2(32.0, 56.0)), Color(door_color, 0.3), true)
	draw_rect(Rect2(Vector2(-16.0, -28.0), Vector2(32.0, 56.0)), door_color, false, 4.0)
