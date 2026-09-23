extends Node2D
class_name RestSpring
## Źródło w pokoju odpoczynku (Paczka 7) — rysowane w podłodze, pod postaciami.
## Po użyciu przygasa (odpoczynek jest jednorazowy).

var used: bool = false
var _t: float = 0.0

func _ready() -> void:
	z_index = -3

func _process(delta: float) -> void:
	_t += delta
	queue_redraw()

func _draw() -> void:
	var c: Color = MapMarker.COLORS["rest"]
	var glow := 0.25 if used else 0.45 + 0.15 * sin(_t * 2.0)
	draw_circle(Vector2.ZERO, 70.0, Color(0.05, 0.08, 0.07, 0.8))
	draw_circle(Vector2.ZERO, 58.0, Color(c, glow * 0.6))
	for i in 3:
		var r := fposmod(_t * 18.0 + i * 20.0, 58.0)
		draw_arc(Vector2.ZERO, r, 0.0, TAU, 32, Color(c, glow * (1.0 - r / 58.0)), 2.0, true)
	draw_arc(Vector2.ZERO, 70.0, 0.0, TAU, 40, Color(0.35, 0.33, 0.30, 0.9), 5.0, true)
	MapMarker.draw_marker(self, Vector2.ZERO, 18.0, "" if used else "rest")
