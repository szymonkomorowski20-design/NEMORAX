extends Node2D
class_name DoorBadge
## Paczka 7: znacznik nad drzwiami — co czeka w sąsiednim pokoju (ten sam
## symbol co na mapie + krótki napis). Rysowany nad podłogą, pod postaciami.

const FONT := preload("res://assets/fonts/EBGaramond-Medium.woff")
var kind: String = ""

func _ready() -> void:
	z_index = -2

func _draw() -> void:
	if kind == "":
		return
	draw_circle(Vector2.ZERO, 17.0, Color(0.05, 0.04, 0.08, 0.82))
	draw_arc(Vector2.ZERO, 17.0, 0.0, TAU, 24, Color(MapMarker.COLORS[kind], 0.9), 1.5, true)
	MapMarker.draw_marker(self, Vector2.ZERO, 16.0, kind)
	var text: String = MapMarker.LABELS[kind]
	var w := FONT.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, 15).x
	draw_string(FONT, Vector2(-w * 0.5, 34.0), text, HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color(MapMarker.COLORS[kind], 0.95))
