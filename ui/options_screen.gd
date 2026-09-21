extends Control
class_name OptionsScreen
## Ekran opcji — klawiaturowy, ta sama konwencja co ui/keybind_screen.gd (bez
## myszy, strzałki + Enter/Escape). Cztery suwaki głośności (Master/Music/
## SFX/UI, regulowane lewo/prawo) + wejście do istniejącego KeybindScreen.
## Reużywany z menu głównego (menu.tscn) i menu pauzy (pause_menu.tscn) —
## process_mode ALWAYS jak reszta tych ekranów.

signal closed

var SETTINGS_PATH := "user://settings.json" ## var (nie const) tylko po to, żeby test mógł podmienić ścieżkę na tymczasową
const VOLUME_STEP_DB := 3.0
const MIN_VOLUME_DB := -40.0
const MAX_VOLUME_DB := 6.0
const BUS_NAMES := ["Master", "Music", "SFX", "UI"]
const BUS_LABELS := ["Głośność główna", "Głośność muzyki", "Głośność efektów", "Głośność interfejsu"]
const KEYBIND_ITEM_INDEX := 4 # = BUS_NAMES.size(), ostatni wpis listy to nie suwak
const ITEM_COUNT := 5
## Palette.HIT_FLASH to czysta biel (#FFFFFF), taka sama jak kolor
## niezaznaczonych wierszy poniżej — podświetlenie było więc niewidoczne
## (patrz ten sam bug naprawiony w menu.gd).
const SELECTED_COLOR := Color("#E8C547")
const SELECTED_BG := Color("#E8C547", 0.16)

@export var font_size: int = 22
@export var title_font_size: int = 32

@onready var keybind_screen: KeybindScreen = $KeybindScreen

var _selected_index: int = 0
var _item_rects: Array[Rect2] = [] ## jak w menu.gd — ręczne trafienie myszką, bo to _draw(), nie Control/Button

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	_load_settings()
	keybind_screen.closed.connect(queue_redraw)

func _process(_delta: float) -> void:
	if visible:
		queue_redraw()

## Wywoływane przez rodzica (menu.gd/pause_menu.gd), jak KeybindScreen.open().
func open() -> void:
	_selected_index = 0
	visible = true

func _unhandled_input(event: InputEvent) -> void:
	if not visible or keybind_screen.visible:
		return
	if event is InputEventMouseMotion:
		_update_hover(event.position)
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_handle_click(event.position)
	elif event.is_action_pressed("ui_down"):
		_selected_index = (_selected_index + 1) % ITEM_COUNT
	elif event.is_action_pressed("ui_up"):
		_selected_index = (_selected_index - 1 + ITEM_COUNT) % ITEM_COUNT
	elif event.is_action_pressed("ui_left") and _selected_index < BUS_NAMES.size():
		_adjust_volume(_selected_index, -VOLUME_STEP_DB)
	elif event.is_action_pressed("ui_right") and _selected_index < BUS_NAMES.size():
		_adjust_volume(_selected_index, VOLUME_STEP_DB)
	elif event.is_action_pressed("ui_accept") and _selected_index == KEYBIND_ITEM_INDEX:
		keybind_screen.open()
	elif event.is_action_pressed("ui_cancel"):
		visible = false
		_save_settings()
		closed.emit()

func _update_hover(mouse_pos: Vector2) -> void:
	for i in range(_item_rects.size()):
		if _item_rects[i].has_point(mouse_pos):
			_selected_index = i
			return

## Suwaki głośności: klik w lewą połowę wiersza = ciszej, w prawą = głośniej
## (tak jak strzałki lewo/prawo) — "Zmień klawisze" aktywuje się kliknięciem
## w dowolnym miejscu wiersza, bo to nie suwak.
func _handle_click(mouse_pos: Vector2) -> void:
	for i in range(_item_rects.size()):
		if not _item_rects[i].has_point(mouse_pos):
			continue
		_selected_index = i
		if i == KEYBIND_ITEM_INDEX:
			keybind_screen.open()
		else:
			var rect := _item_rects[i]
			var delta_db := VOLUME_STEP_DB if mouse_pos.x > rect.position.x + rect.size.x * 0.5 else -VOLUME_STEP_DB
			_adjust_volume(i, delta_db)
		return

func _adjust_volume(bus_slot: int, delta_db: float) -> void:
	var idx := AudioServer.get_bus_index(BUS_NAMES[bus_slot])
	if idx < 0:
		return
	var new_db: float = clamp(AudioServer.get_bus_volume_db(idx) + delta_db, MIN_VOLUME_DB, MAX_VOLUME_DB)
	AudioServer.set_bus_volume_db(idx, new_db)

func _load_settings() -> void:
	if not FileAccess.file_exists(SETTINGS_PATH):
		return
	var file := FileAccess.open(SETTINGS_PATH, FileAccess.READ)
	if file == null:
		return
	var data = JSON.parse_string(file.get_as_text())
	if typeof(data) != TYPE_DICTIONARY:
		return
	var volumes: Dictionary = data.get("bus_volumes_db", {})
	for bus_name in volumes.keys():
		var idx := AudioServer.get_bus_index(bus_name)
		if idx >= 0:
			AudioServer.set_bus_volume_db(idx, float(volumes[bus_name]))

func _save_settings() -> void:
	var volumes := {}
	for bus_name in BUS_NAMES:
		var idx := AudioServer.get_bus_index(bus_name)
		if idx >= 0:
			volumes[bus_name] = AudioServer.get_bus_volume_db(idx)
	var file := FileAccess.open(SETTINGS_PATH, FileAccess.WRITE)
	if file == null:
		push_warning("OptionsScreen: nie udało się zapisać ustawień (%s), błąd %d" % [SETTINGS_PATH, FileAccess.get_open_error()])
		return
	file.store_string(JSON.stringify({"bus_volumes_db": volumes}))

func _draw() -> void:
	if not visible or keybind_screen.visible:
		return
	var viewport_size := get_viewport_rect().size
	draw_rect(Rect2(Vector2.ZERO, viewport_size), Color(Palette.BACKGROUND, 0.92), true)
	var font := ThemeDB.fallback_font

	var title := "Opcje"
	var title_size := font.get_string_size(title, HORIZONTAL_ALIGNMENT_CENTER, -1, title_font_size)
	draw_string(font, Vector2((viewport_size.x - title_size.x) * 0.5, viewport_size.y * 0.15), title,
		HORIZONTAL_ALIGNMENT_LEFT, -1, title_font_size, Palette.PLAYER_BODY)

	var start_y := viewport_size.y * 0.30
	var line_height := font_size * 1.8
	_item_rects.resize(ITEM_COUNT)
	for i in range(BUS_NAMES.size()):
		var idx := AudioServer.get_bus_index(BUS_NAMES[i])
		var db := AudioServer.get_bus_volume_db(idx) if idx >= 0 else 0.0
		var pct := int(round(clamp((db - MIN_VOLUME_DB) / (MAX_VOLUME_DB - MIN_VOLUME_DB), 0.0, 1.0) * 100.0))
		var line := "%s:  %d%%" % [BUS_LABELS[i], pct]
		var is_selected := i == _selected_index
		var line_size := font.get_string_size(line, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size)
		var baseline := Vector2((viewport_size.x - line_size.x) * 0.5, start_y + i * line_height)
		var row_rect := Rect2(0.0, baseline.y - line_size.y - 4.0, viewport_size.x, line_size.y + 12.0)
		_item_rects[i] = row_rect
		if is_selected:
			draw_rect(row_rect, SELECTED_BG, true)
		draw_string(font, baseline, line, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, SELECTED_COLOR if is_selected else Color.WHITE)

	var keybind_line := "Zmień klawisze"
	var kb_selected := _selected_index == KEYBIND_ITEM_INDEX
	var kb_size := font.get_string_size(keybind_line, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size)
	var kb_baseline := Vector2((viewport_size.x - kb_size.x) * 0.5, start_y + BUS_NAMES.size() * line_height)
	var kb_row_rect := Rect2(0.0, kb_baseline.y - kb_size.y - 4.0, viewport_size.x, kb_size.y + 12.0)
	_item_rects[KEYBIND_ITEM_INDEX] = kb_row_rect
	if kb_selected:
		draw_rect(kb_row_rect, SELECTED_BG, true)
	draw_string(font, kb_baseline, keybind_line, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, SELECTED_COLOR if kb_selected else Color.WHITE)

	var hint := "Strzałki: wybór / regulacja — Enter: klawisze — Escape: powrót"
	var hint_size := font.get_string_size(hint, HORIZONTAL_ALIGNMENT_CENTER, -1, 18)
	draw_string(font, Vector2((viewport_size.x - hint_size.x) * 0.5, viewport_size.y * 0.92), hint,
		HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color.WHITE)
