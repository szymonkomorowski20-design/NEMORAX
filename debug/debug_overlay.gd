extends Node2D
class_name DebugOverlay
## Faza 0 (PLAN_PROFESSIONAL_GAME_FEEL_DLA_CLAUDE.md) — nakładka debugowa nad
## WSZYSTKIMI innymi CanvasItem w scenie. Musi być OSOBNYM, POŹNO DODANYM
## węzłem z wysokim z_index — rysowanie bezpośrednio w _draw() rodzica ląduje
## POD sprite'ami dzieci (ta sama zasada co niewidoczne wcześniej menu:
## rodzic rysuje siebie PRZED dziećmi przy równym z_index), więc małe hitboxy
## (np. gracz, promień 14px) chowałyby się całkowicie pod sprite'em.

const HITBOX_COLOR := Color(0.3, 1.0, 1.0, 0.9) # cyjan — hitbox gracza
const HURTBOX_COLOR := Color(1.0, 0.35, 0.25, 0.9) # czerwono-pomarańczowy — hurtbox wroga
const ATTACK_COLOR := Color(1.0, 0.85, 0.2, 0.85) # żółty — obszar obrażeń ataku
const COLLIDER_COLOR := Color(0.4, 0.9, 0.4, 0.85) # zielony — collider ściany/drzwi
const SHADOW_COLOR := Color(1.0, 0.2, 1.0, 0.9) # magenta — pozycja cienia kontaktowego
const LINE_WIDTH := 2.0

var _hitboxes: Array[Dictionary] = [] # {pos, radius, color}
var _wall_rects: Array[Rect2] = []
var _legend_lines: Array[Array] = [] # [text, color]
var _shadow_markers: Array[Vector2] = []

func _ready() -> void:
	z_index = 5 # nad postaciami/skrzyniami (0) i pociskami/efektami (1-3), pod UI (CanvasLayer, poza z_index)
	z_as_relative = false # niezależne od z_index rodzica — zawsze ma być na wierzchu tej sceny

func add_circle(pos: Vector2, radius: float, color: Color) -> void:
	_hitboxes.append({"pos": pos, "radius": radius, "color": color})

func add_wall_rect(rect: Rect2) -> void:
	_wall_rects.append(rect)

func add_legend_line(text: String, color: Color) -> void:
	_legend_lines.append([text, color])

func refresh() -> void:
	queue_redraw()

func _draw() -> void:
	for rect in _wall_rects:
		draw_rect(rect, COLLIDER_COLOR, false, LINE_WIDTH)
	for hb in _hitboxes:
		draw_arc(hb["pos"], hb["radius"], 0.0, TAU, 48, hb["color"], LINE_WIDTH)
	for marker_pos in _shadow_markers:
		draw_line(marker_pos - Vector2(7.0, 0.0), marker_pos + Vector2(7.0, 0.0), SHADOW_COLOR, LINE_WIDTH)
		draw_line(marker_pos - Vector2(0.0, 7.0), marker_pos + Vector2(0.0, 7.0), SHADOW_COLOR, LINE_WIDTH)
	var font := ThemeDB.fallback_font
	var pos := Vector2(16.0, 100.0) # niżej niż tekstowy debug F3 (Juice._debug_label), żeby się nie nakładały
	for line in _legend_lines:
		draw_string(font, pos, line[0], HORIZONTAL_ALIGNMENT_LEFT, -1, 16, line[1])
		pos.y += 20.0

## Rysuje mały krzyżyk w miejscu cienia kontaktowego danej postaci (jeśli ma
## dziecko ContactShadow) — osobno od add_circle(), bo to krzyż, nie okrąg.
## Szuka PO TYPIE, nie po nazwie węzła — ContactShadow.new() bez jawnego .name
## dostaje domyślną nazwę od silnikowej klasy bazowej (Node2D), nie od
## class_name skryptu, więc get_node("ContactShadow") zawodzi po cichu.
func add_contact_shadow_marker(entity: Node2D) -> void:
	for child in entity.get_children():
		if child is ContactShadow:
			_shadow_markers.append(entity.global_position + child.position)
			return
