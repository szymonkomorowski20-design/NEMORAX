extends Node2D
class_name ContactShadow
## Lekki, wspólny cień kontaktowy. Rysowany kodem, więc nie wymaga osobnego PNG
## dla każdej postaci i osadza sprite'y w świecie zamiast nad nim lewitować.

@export var radius_x: float = 58.0
@export var radius_y: float = 18.0
@export var opacity: float = 0.36
@export var softness_layers: int = 4

func configure(width: float, height: float, alpha: float = 0.36) -> void:
	radius_x = width * 0.5
	radius_y = height * 0.5
	opacity = alpha
	queue_redraw()

func _ready() -> void:
	z_index = -1
	show_behind_parent = true
	queue_redraw()

func _draw() -> void:
	# Kilka półprzezroczystych elips daje miękką krawędź bez shadera.
	for i in range(softness_layers, 0, -1):
		var factor := 1.0 + float(i) * 0.16
		var layer_alpha := opacity * (0.055 + 0.045 * float(softness_layers - i))
		draw_set_transform(Vector2.ZERO, 0.0, Vector2(radius_x * factor, radius_y * factor))
		draw_circle(Vector2.ZERO, 1.0, Color(0.0, 0.0, 0.0, layer_alpha))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(radius_x, radius_y))
	draw_circle(Vector2.ZERO, 1.0, Color(0.0, 0.0, 0.0, opacity * 0.38))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
