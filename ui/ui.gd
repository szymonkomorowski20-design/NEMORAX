extends Control
class_name GameUI
## Interfejs (sekcja 6 + paski staminy/many dodane na życzenie autora, poza
## dokumentem — bez nich zasoby z player.gd byłyby niewidoczne dla gracza).
## Minimalny: pasek gracza, pasek bossa, ikona dasha, nazwa formy na 2 s.
## W fazie finałowej znika w całości (sekcja 8).
## CanvasLayer-rodzic sprawia, że to nie drży razem z trzęsieniem ekranu.

const ARENA_LEFT := 90.0
const ARENA_WIDTH := 1100.0

# Stamina/mana nie mają koloru w palecie z sekcji 2 (to zasoby, nie zagrożenia
# ani ciało gracza) — świadomie nowe, osobne odcienie, żeby niczego nie mylić.
const STAMINA_COLOR := Color("#E8A33D")
const MANA_COLOR := Color("#4FA8E8")
const HEAL_COLOR := Color("#6FCF7A")

@export var player_bar_size: Vector2 = Vector2(200.0, 20.0)
@export var resource_bar_size: Vector2 = Vector2(200.0, 8.0)
@export var resource_bar_gap: float = 4.0 ## px, odstęp między paskami staminy/many/życia
@export var boss_bar_height: float = 16.0
@export var dash_icon_size: float = 20.0
@export var heal_icon_size: float = 20.0
@export var form_name_display_time: float = 2.0 ## s
@export var form_name_font_size: int = 32
@export var taunt_font_size: int = 22
@export var overlay_font_size: int = 24

var player: Player = null
var boss: Boss = null
var hide_all: bool = false ## faza finałowa: UI znika w całości

var _center_message: String = ""
var _center_message_timer: float = 0.0
var _center_message_font_size: int = 32

var _overlay_text: String = ""
var _overlay_active: bool = false

func _process(delta: float) -> void:
	if _center_message_timer > 0.0:
		_center_message_timer -= delta
		if _center_message_timer <= 0.0:
			_center_message = ""
	queue_redraw()

func show_form_name(text: String) -> void:
	_center_message = text
	_center_message_timer = form_name_display_time
	_center_message_font_size = form_name_font_size

func show_taunt(text: String, duration: float) -> void:
	_center_message = text
	_center_message_timer = duration
	_center_message_font_size = taunt_font_size

func show_overlay(text: String) -> void:
	_overlay_text = text
	_overlay_active = true

func hide_overlay() -> void:
	_overlay_active = false

func _draw() -> void:
	if _overlay_active:
		_draw_overlay()
		return
	# hide_all (faza finałowa) chowa paski i ikonę, ale NIE komunikat na środku —
	# to nim właśnie pokazujemy 4-sekundowe pytanie finałowe (sekcja 8).
	if not hide_all:
		_draw_player_bar()
		_draw_resource_bars()
		_draw_boss_bar()
		_draw_dash_icon()
		_draw_heal_icon()
	_draw_center_message()

func _draw_player_bar() -> void:
	if player == null:
		return
	var pos := Vector2(30.0, size.y - 50.0)
	var ratio: float = clamp(player.health / player.max_health, 0.0, 1.0)
	draw_rect(Rect2(pos, player_bar_size), Palette.ARENA_WALL, true)
	draw_rect(Rect2(pos, Vector2(player_bar_size.x * ratio, player_bar_size.y)), Palette.PLAYER_BODY, true)
	draw_rect(Rect2(pos, player_bar_size), Palette.ARENA_FLOOR, false, 2.0)

func _draw_resource_bars() -> void:
	if player == null:
		return
	var stamina_pos := Vector2(30.0, size.y - 50.0 - resource_bar_gap - resource_bar_size.y)
	_draw_resource_bar(stamina_pos, player.stamina / player.max_stamina, STAMINA_COLOR)
	var mana_pos := stamina_pos - Vector2(0.0, resource_bar_gap + resource_bar_size.y)
	_draw_resource_bar(mana_pos, player.mana / player.max_mana, MANA_COLOR)

func _draw_resource_bar(pos: Vector2, ratio: float, color: Color) -> void:
	ratio = clamp(ratio, 0.0, 1.0)
	draw_rect(Rect2(pos, resource_bar_size), Palette.ARENA_WALL, true)
	draw_rect(Rect2(pos, Vector2(resource_bar_size.x * ratio, resource_bar_size.y)), color, true)
	draw_rect(Rect2(pos, resource_bar_size), Palette.ARENA_FLOOR, false, 1.0)

func _draw_boss_bar() -> void:
	if boss == null:
		return
	var pos := Vector2(ARENA_LEFT, 20.0)
	var boss_size := Vector2(ARENA_WIDTH, boss_bar_height)
	var ratio: float = clamp(boss.health / boss.max_health, 0.0, 1.0)
	draw_rect(Rect2(pos, boss_size), Palette.ARENA_WALL, true)
	draw_rect(Rect2(pos, Vector2(boss_size.x * ratio, boss_size.y)), boss.current_color, true)
	draw_rect(Rect2(pos, boss_size), Palette.ARENA_FLOOR, false, 2.0)

func _draw_dash_icon() -> void:
	if player == null:
		return
	var pos := Vector2(30.0 + player_bar_size.x + 16.0, size.y - 50.0)
	var rect := Rect2(pos, Vector2(dash_icon_size, dash_icon_size))
	var color := Palette.PLAYER_BODY
	var alpha := 1.0
	if player.is_dash_on_cooldown():
		alpha = 0.35
	draw_rect(rect, Color(color, alpha), true)
	if player.is_dash_locked_by_void():
		# Blokada Zęba Zera: ikona przekreślona (sekcja 5), inaczej niż zwykły cooldown.
		draw_line(rect.position, rect.position + rect.size, Palette.HIT_FLASH, 3.0)
		draw_line(rect.position + Vector2(rect.size.x, 0.0), rect.position + Vector2(0.0, rect.size.y), Palette.HIT_FLASH, 3.0)

## Leczenie (E) — pierścień wypełnia się z każdym trafieniem wroga, w pełni
## jasny i wypełniony, gdy gotowy do użycia (sekcja o leczeniu, poza dokumentem).
func _draw_heal_icon() -> void:
	if player == null:
		return
	var pos := Vector2(30.0 + player_bar_size.x + 16.0 + dash_icon_size + 10.0, size.y - 50.0)
	var center := pos + Vector2(heal_icon_size, heal_icon_size) * 0.5
	var r := heal_icon_size * 0.5
	var ratio: float = clamp(player.heal_charge_ratio(), 0.0, 1.0)
	draw_arc(center, r, 0.0, TAU, 20, Color(HEAL_COLOR, 0.3), 2.0)
	if ratio > 0.0:
		draw_arc(center, r, -PI * 0.5, -PI * 0.5 + TAU * ratio, 20, HEAL_COLOR, 3.0)
	if player.is_heal_ready():
		draw_circle(center, r * 0.5, HEAL_COLOR)

func _draw_center_message() -> void:
	if _center_message == "":
		return
	var font := ThemeDB.fallback_font
	var font_size := _center_message_font_size
	var text_size := font.get_string_size(_center_message, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size)
	var pos := Vector2((size.x - text_size.x) * 0.5, size.y * 0.5)
	draw_string(font, pos, _center_message, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Palette.HIT_FLASH)

func _draw_overlay() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color(Palette.BACKGROUND, 0.85), true)
	var font := ThemeDB.fallback_font
	var lines := _overlay_text.split("\n")
	var line_height := overlay_font_size * 1.4
	var start_y := size.y * 0.5 - (lines.size() - 1) * line_height * 0.5
	for i in range(lines.size()):
		var line: String = lines[i]
		var text_size := font.get_string_size(line, HORIZONTAL_ALIGNMENT_CENTER, -1, overlay_font_size)
		var pos := Vector2((size.x - text_size.x) * 0.5, start_y + i * line_height)
		draw_string(font, pos, line, HORIZONTAL_ALIGNMENT_LEFT, -1, overlay_font_size, Palette.PLAYER_BODY)
