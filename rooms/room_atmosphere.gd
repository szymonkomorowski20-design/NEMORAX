extends Node2D
class_name RoomAtmosphere
## Lekka warstwa głębi pokoju. Nie jest filtrem ekranu: leży wyłącznie nad
## podłogą, ale pod postaciami i VFX. Dzięki temu centrum walki pozostaje
## czytelne, a obrzeża nie wyglądają jak goła, jasna tekstura.

var arena_rect: Rect2
@export var edge_size: float = 112.0
@export var edge_opacity: float = 0.24
@export var corner_opacity: float = 0.10

func configure(rect: Rect2) -> void:
	arena_rect = rect
	queue_redraw()

func _ready() -> void:
	# Podłoga ma -10, ściany -5, a postacie domyślnie 0.
	z_index = -8
	queue_redraw()

func _draw() -> void:
	if arena_rect.size == Vector2.ZERO:
		return
	var shade := Color(0.015, 0.012, 0.025, edge_opacity)
	var soft_shade := Color(0.015, 0.012, 0.025, edge_opacity * 0.42)
	# Dwie stopniowane warstwy przy każdej ścianie. To celowo nie zasłania
	# środka areny, telegrafów ani kolorów VFX.
	draw_rect(Rect2(arena_rect.position, Vector2(arena_rect.size.x, edge_size)), shade)
	draw_rect(Rect2(Vector2(arena_rect.position.x, arena_rect.end.y - edge_size), Vector2(arena_rect.size.x, edge_size)), shade)
	draw_rect(Rect2(arena_rect.position, Vector2(edge_size, arena_rect.size.y)), shade)
	draw_rect(Rect2(Vector2(arena_rect.end.x - edge_size, arena_rect.position.y), Vector2(edge_size, arena_rect.size.y)), shade)

	var inner_offset := edge_size * 0.55
	draw_rect(Rect2(Vector2(arena_rect.position.x + inner_offset, arena_rect.position.y + edge_size), Vector2(arena_rect.size.x - inner_offset * 2.0, edge_size * 0.35)), soft_shade)
	draw_rect(Rect2(Vector2(arena_rect.position.x + inner_offset, arena_rect.end.y - edge_size * 1.35), Vector2(arena_rect.size.x - inner_offset * 2.0, edge_size * 0.35)), soft_shade)

	# Dodatkowe przyciemnienie czterech narożników wizualnie oddziela planszę
	# od otchłani, bez stosowania ciężkiego shadera pełnoekranowego.
	var corner_size := Vector2(edge_size * 0.9, edge_size * 0.9)
	var corner := Color(0.015, 0.012, 0.025, corner_opacity)
	draw_rect(Rect2(arena_rect.position, corner_size), corner)
	draw_rect(Rect2(Vector2(arena_rect.end.x - corner_size.x, arena_rect.position.y), corner_size), corner)
	draw_rect(Rect2(Vector2(arena_rect.position.x, arena_rect.end.y - corner_size.y), corner_size), corner)
	draw_rect(Rect2(arena_rect.end - corner_size, corner_size), corner)
