extends Node2D
class_name RoomAtmosphere
## Lekka warstwa głębi pokoju. Nie jest filtrem ekranu: leży wyłącznie nad
## podłogą, ale pod postaciami i VFX. Dzięki temu centrum walki pozostaje
## czytelne, a obrzeża nie wyglądają jak goła, jasna tekstura.
##
## Trzy warstwy, od najniższej: (1) płaska "przyciemniona" mycie całej areny
## (KIERUNEK_WIZUALNY_REFERENCJE.md — "podłoga zbyt szczegółowa i jasna"),
## (2) miękka plama uspokajająca ŚRODEK areny mocniej niż krawędzie (odwrotność
## typowej winiety — to środek jest polem walki i ma być NAJSPOKOJNIEJSZY,
## nie krawędzie), (3) istniejąca winieta krawędzi/narożników.

var arena_rect: Rect2

@export var floor_dim_opacity: float = 0.30 ## płaskie przyciemnienie całej podłogi
@export var center_calm_layer_opacity: float = 0.10 ## alfa KAŻDEJ z warstw plamy środkowej — nakładają się (blending), więc realna siła w samym centrum to znacznie więcej niż ta liczba
@export var center_calm_layers: int = 6
@export var center_calm_radius_fraction: float = 0.48 ## promień plamy środkowej, ułamek połowy krótszego boku areny
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
	var base_shade_color := Color(0.02, 0.017, 0.03)

	# (1) Płaskie mycie całej areny — jednolite przyciemnienie/"odszumienie"
	# szczegółu podłogi, niezależnie od pozycji.
	draw_rect(arena_rect, Color(base_shade_color.r, base_shade_color.g, base_shade_color.b, floor_dim_opacity))

	# (2) Miękka plama w środku areny, silniejsza niż mycie z (1) — kilka
	# NAKŁADAJĄCYCH SIĘ kół o tej samej alfie (blending sam daje narastanie ku
	# środkowi: przy N warstwach alfa w samym centrum to 1-(1-a)^N, a na
	# krawędzi plamy tylko pojedyncza warstwa) — ta sama idea co
	# ContactShadow._draw(), ale z dużo mocniejszym efektem końcowym.
	var center := arena_rect.get_center()
	var max_radius: float = min(arena_rect.size.x, arena_rect.size.y) * 0.5 * center_calm_radius_fraction
	var calm_color := Color(base_shade_color.r, base_shade_color.g, base_shade_color.b, center_calm_layer_opacity)
	for i in range(center_calm_layers, 0, -1):
		var t := float(i) / float(center_calm_layers)
		draw_circle(center, max_radius * t, calm_color)

	# (3) Winieta krawędzi/narożników (istniejąca, bez zmian w koncepcji).
	var shade := Color(base_shade_color.r, base_shade_color.g, base_shade_color.b, edge_opacity)
	var soft_shade := Color(base_shade_color.r, base_shade_color.g, base_shade_color.b, edge_opacity * 0.42)
	draw_rect(Rect2(arena_rect.position, Vector2(arena_rect.size.x, edge_size)), shade)
	draw_rect(Rect2(Vector2(arena_rect.position.x, arena_rect.end.y - edge_size), Vector2(arena_rect.size.x, edge_size)), shade)
	draw_rect(Rect2(arena_rect.position, Vector2(edge_size, arena_rect.size.y)), shade)
	draw_rect(Rect2(Vector2(arena_rect.end.x - edge_size, arena_rect.position.y), Vector2(edge_size, arena_rect.size.y)), shade)

	var inner_offset := edge_size * 0.55
	draw_rect(Rect2(Vector2(arena_rect.position.x + inner_offset, arena_rect.position.y + edge_size), Vector2(arena_rect.size.x - inner_offset * 2.0, edge_size * 0.35)), soft_shade)
	draw_rect(Rect2(Vector2(arena_rect.position.x + inner_offset, arena_rect.end.y - edge_size * 1.35), Vector2(arena_rect.size.x - inner_offset * 2.0, edge_size * 0.35)), soft_shade)

	var corner_size := Vector2(edge_size * 0.9, edge_size * 0.9)
	var corner := Color(base_shade_color.r, base_shade_color.g, base_shade_color.b, corner_opacity)
	draw_rect(Rect2(arena_rect.position, corner_size), corner)
	draw_rect(Rect2(Vector2(arena_rect.end.x - corner_size.x, arena_rect.position.y), corner_size), corner)
	draw_rect(Rect2(Vector2(arena_rect.position.x, arena_rect.end.y - corner_size.y), corner_size), corner)
	draw_rect(Rect2(arena_rect.end - corner_size, corner_size), corner)
