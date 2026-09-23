extends Control
class_name MenuListPanel
## Paczka 9: panel listy w menu głównym — Kronika (tylko do czytania) i
## Komnata Echa (wybór wcielenia do treningu). Esc zamyka.

signal chosen(index: int)
signal closed

const FONT_TITLE := preload("res://assets/fonts/Cinzel-SemiBold.woff")
const FONT_BODY := preload("res://assets/fonts/EBGaramond-Regular.woff")

var title: String = ""
var subtitle: String = ""
var rows: Array = [] ## String albo [nagłówek, szczegół]
var selectable: bool = false
var selected: int = 0

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	visible = false

func open(p_title: String, p_rows: Array, p_selectable: bool, p_subtitle: String = "") -> void:
	title = p_title
	rows = p_rows
	selectable = p_selectable
	subtitle = p_subtitle
	selected = 0
	visible = true
	queue_redraw()

func close() -> void:
	visible = false
	closed.emit()

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("ui_cancel"):
		Juice.play_ui_sfx_variant(Juice.SND_UI_BACK)
		close()
	elif selectable and event.is_action_pressed("ui_down") and not rows.is_empty():
		selected = (selected + 1) % rows.size()
		Juice.play_ui_sfx_variant(Juice.SND_UI_NAVIGATE)
		queue_redraw()
	elif selectable and event.is_action_pressed("ui_up") and not rows.is_empty():
		selected = (selected - 1 + rows.size()) % rows.size()
		Juice.play_ui_sfx_variant(Juice.SND_UI_NAVIGATE)
		queue_redraw()
	elif selectable and event.is_action_pressed("ui_accept") and not rows.is_empty():
		Juice.play_ui_sfx_variant(Juice.SND_UI_CONFIRM)
		chosen.emit(selected)
	get_viewport().set_input_as_handled()

func _draw() -> void:
	if not visible:
		return
	var size := get_viewport_rect().size
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.035, 0.025, 0.06, 0.94), true)
	var tw := FONT_TITLE.get_string_size(title, HORIZONTAL_ALIGNMENT_LEFT, -1, 32).x
	draw_string(FONT_TITLE, Vector2((size.x - tw) * 0.5, 80.0), title, HORIZONTAL_ALIGNMENT_LEFT, -1, 32, Color("#e8c547"))
	if subtitle != "":
		var sw := FONT_BODY.get_string_size(subtitle, HORIZONTAL_ALIGNMENT_LEFT, -1, 19).x
		draw_string(FONT_BODY, Vector2((size.x - sw) * 0.5, 112.0), subtitle, HORIZONTAL_ALIGNMENT_LEFT, -1, 19, Color("#b8afc2"))
	var y := 160.0
	var left := 120.0
	var width := size.x - 240.0
	if rows.is_empty():
		draw_string(FONT_BODY, Vector2(left, y), "— pusto —", HORIZONTAL_ALIGNMENT_LEFT, width, 20, Color("#93879c"))
	for i in rows.size():
		var row = rows[i]
		var head: String = row[0] if row is Array else str(row)
		var detail: String = row[1] if row is Array and row.size() > 1 else ""
		var is_sel := selectable and i == selected
		if is_sel:
			draw_rect(Rect2(Vector2(left - 12.0, y - 24.0), Vector2(width + 24.0, 32.0 if detail == "" else 52.0)), Color("#E8C547", 0.14), true)
		draw_string(FONT_BODY, Vector2(left, y), head, HORIZONTAL_ALIGNMENT_LEFT, width, 20, Color("#e8c547") if is_sel else Color("#e9e1f0"))
		if detail != "":
			draw_string(FONT_BODY, Vector2(left + 16.0, y + 20.0), detail, HORIZONTAL_ALIGNMENT_LEFT, width - 16.0, 16, Color("#b8afc2"))
			y += 22.0
		y += 36.0
		if y > size.y - 70.0:
			break
	var hint := ("↑↓ wybór   Enter — start   " if selectable else "") + "Escape — wróć"
	var hw := FONT_BODY.get_string_size(hint, HORIZONTAL_ALIGNMENT_LEFT, -1, 16).x
	draw_string(FONT_BODY, Vector2((size.x - hw) * 0.5, size.y - 30.0), hint, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("#93879c"))
