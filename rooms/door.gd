extends Node2D
class_name Door
## Drzwi — na starcie pokoju prowadzą do wcielenia, po jego pokonaniu nowe drzwi
## prowadzą dalej. Przechodzi się przez nie samym podejściem, bez przycisku
## (rozszerzenie poza dokument bazowy, patrz LORE_I_ASSETY.md).

signal entered

# rotatable_v3 — symetryczny łuk z klejnotami na wszystkich 4 krawędziach,
# bezpiecznie obracalny pod każdą ścianę. Poprzedni embedded_v2 miał wtopiony
# fragment ściany, który nie dawał się obrócić na boki — odrzucony, zostaje
# w katalogu jako historia. rift_doorway.png (jeszcze wcześniejsza wersja)
# też zostaje jako rollback.
const TEX_DOOR := preload("res://assets/sprites/pokoje/obiekty/rift_doorway_rotatable_v3.png")
const SPRITE_SCALE := 0.12

@export var trigger_range: float = 40.0
@export var door_color: Color = Color("#C9C2B4")

var player: Player = null
## Ustawiane przez Room. Ten sam symetryczny asset obraca się poprawnie pod
## każdą ścianę zamiast leżeć płasko na podłodze.
var wall_side: String = "top"
var _triggered: bool = false

@onready var sprite: Sprite2D = $Sprite

func _ready() -> void:
	sprite.texture = TEX_DOOR
	sprite.scale = Vector2(SPRITE_SCALE, SPRITE_SCALE)
	sprite.modulate = door_color
	sprite.rotation = _rotation_for_wall_side()
	var contact_shadow := ContactShadow.new()
	contact_shadow.position = _threshold_offset()
	contact_shadow.configure(64.0, 16.0, 0.46) # wyraźniejszy — portal ma wyglądać na osadzony w ścianie, nie naklejony (KIERUNEK_WIZUALNY_REFERENCJE.md)
	add_child(contact_shadow)

func _rotation_for_wall_side() -> float:
	match wall_side:
		"bottom": return PI
		"left": return -PI * 0.5
		"right": return PI * 0.5
		_: return 0.0 # top

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
