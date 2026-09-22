extends Control
class_name OptionsScreen
## Ekran opcji — klawiaturowy, ta sama konwencja co ui/keybind_screen.gd
## (strzałki + Enter/Escape), plus podstawowa obsługa myszy. Reużywany z menu
## głównego (menu.tscn) i menu pauzy (pause_menu.tscn) — process_mode ALWAYS
## jak reszta tych ekranów.
##
## Krok 9 (polish ekranów): "podzielić na dźwięk/grafikę/sterowanie/
## dostępność" — dawniej płaska lista 4 suwaków + jeden wpis klawiszy. Teraz
## 4 zakładki (Tab/Shift+Tab, ui_focus_next/prev — wbudowane akcje Godota,
## bez nowej konfiguracji wejścia), każda z natychmiastowym efektem: głośność
## już była live (AudioServer od razu), pełny ekran przełącza się w miejscu,
## trzęsienie ekranu odpala próbkę zaraz po przełączeniu.

signal closed

var SETTINGS_PATH := "user://settings.json" ## var (nie const) tylko po to, żeby test mógł podmienić ścieżkę na tymczasową
const VOLUME_STEP_DB := 3.0
const MIN_VOLUME_DB := -40.0
const MAX_VOLUME_DB := 6.0
const BUS_NAMES := ["Master", "Music", "SFX", "UI"]
const BUS_LABELS := ["Głośność główna", "Głośność muzyki", "Głośność efektów", "Głośność interfejsu"]

const FONT_TITLE := preload("res://assets/fonts/Cinzel-SemiBold.woff")
const FONT_BODY := preload("res://assets/fonts/EBGaramond-Regular.woff")
const FONT_BODY_MEDIUM := preload("res://assets/fonts/EBGaramond-Medium.woff")
const SELECTED_COLOR := Color("#E8C547")
const SELECTED_BG := Color("#E8C547", 0.16)
const TEXT_COLOR := Color("#E9E1F0")
const HINT_COLOR := Color("#8A7FA0")

enum Category { SOUND, GRAPHICS, CONTROLS, ACCESSIBILITY }
const CATEGORY_NAMES := ["Dźwięk", "Grafika", "Sterowanie", "Dostępność"]
## Ile nawigowalnych wierszy ma każda zakładka — CATEGORY_ITEM_COUNTS[SOUND]
## musi zostać zsynchronizowane z BUS_NAMES.size(), stąd zbudowane z niego,
## nie wpisane na sztywno drugi raz.
const CATEGORY_ITEM_COUNTS := [4, 2, 1, 1]

@export var font_size: int = 22
@export var title_font_size: int = 32

@onready var keybind_screen: KeybindScreen = $KeybindScreen

var _category: int = Category.SOUND
var _selected_index: int = 0
var _fullscreen: bool = true
var _item_rects: Array[Rect2] = [] ## jak w menu.gd — ręczne trafienie myszką, bo to _draw(), nie Control/Button
var _tab_rects: Array[Rect2] = []

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	_fullscreen = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
	_load_settings()
	keybind_screen.closed.connect(queue_redraw)

func _process(_delta: float) -> void:
	if visible:
		queue_redraw()

## Wywoływane przez rodzica (menu.gd/pause_menu.gd), jak KeybindScreen.open().
## Krok 12 (menu, dokument): "panel opcji wchodzi z dołu lub z prawej" —
## dawniej to był twardy cut (visible=true w tej samej klatce, bez przejścia).
## Pozycja to offset PONAD zakotwiczeniem full-rect (anchors_preset=15), więc
## przesunięcie w dół nadal renderuje się poprawnie, tylko z tymczasowym
## przesunięciem — ta sama sztuczka co fade_rect w menu.gd.
const OPEN_SLIDE_DISTANCE := 36.0
const OPEN_TWEEN_TIME := 0.28 ## dokument: "wejście elementu 0,25-0,4s"
var _open_tween: Tween

func open() -> void:
	_category = Category.SOUND
	_selected_index = 0
	visible = true
	modulate.a = 0.0
	position.y = OPEN_SLIDE_DISTANCE
	if _open_tween != null and _open_tween.is_valid():
		_open_tween.kill()
	_open_tween = create_tween()
	_open_tween.set_parallel(true)
	_open_tween.tween_property(self, "modulate:a", 1.0, OPEN_TWEEN_TIME).set_ease(Tween.EASE_OUT)
	_open_tween.tween_property(self, "position:y", 0.0, OPEN_TWEEN_TIME).set_ease(Tween.EASE_OUT)

func _unhandled_input(event: InputEvent) -> void:
	if not visible or keybind_screen.visible:
		return
	if event is InputEventMouseMotion:
		_update_hover(event.position)
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_handle_click(event.position)
	elif event.is_action_pressed("ui_focus_next"):
		_switch_category(1)
	elif event.is_action_pressed("ui_focus_prev"):
		_switch_category(-1)
	elif event.is_action_pressed("ui_down"):
		_selected_index = (_selected_index + 1) % CATEGORY_ITEM_COUNTS[_category]
	elif event.is_action_pressed("ui_up"):
		_selected_index = (_selected_index - 1 + CATEGORY_ITEM_COUNTS[_category]) % CATEGORY_ITEM_COUNTS[_category]
	elif event.is_action_pressed("ui_left"):
		_handle_adjust(-1)
	elif event.is_action_pressed("ui_right"):
		_handle_adjust(1)
	elif event.is_action_pressed("ui_accept"):
		_activate_selected()
	elif event.is_action_pressed("ui_cancel"):
		visible = false
		_save_settings()
		closed.emit()

func _switch_category(direction: int) -> void:
	_category = (_category + direction + CATEGORY_NAMES.size()) % CATEGORY_NAMES.size()
	_selected_index = 0

## Lewo/prawo: suwak głośności w Dźwięku, przełącznik (dowolny kierunek) gdzie
## indziej — Enter robi dokładnie to samo dla przełączników (patrz
## _activate_selected), więc obie konwencje działają tak, jak gracz spróbuje.
func _handle_adjust(direction: int) -> void:
	if _category == Category.SOUND:
		_adjust_volume(_selected_index, direction * VOLUME_STEP_DB)
	else:
		_activate_selected()

func _activate_selected() -> void:
	match _category:
		Category.CONTROLS:
			keybind_screen.open()
		Category.GRAPHICS:
			_toggle_graphics_item(_selected_index)
		Category.ACCESSIBILITY:
			Palette.reduce_flashing = not Palette.reduce_flashing
		_:
			pass

func _toggle_graphics_item(index: int) -> void:
	if index == 0:
		_set_fullscreen(not _fullscreen)
	else:
		Juice.shake_enabled = not Juice.shake_enabled
		# Natychmiastowy podgląd (dokument: "screen shake pokazuje próbkę") —
		# woła TĘ SAMĄ funkcję co realna walka, więc jeśli teraz jest
		# wyłączone, podgląd uczciwie pokazuje "nic się nie dzieje".
		Juice.screen_shake()

func _set_fullscreen(enabled: bool) -> void:
	_fullscreen = enabled
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if enabled else DisplayServer.WINDOW_MODE_WINDOWED)

func _update_hover(mouse_pos: Vector2) -> void:
	for i in range(_item_rects.size()):
		if _item_rects[i].has_point(mouse_pos):
			_selected_index = i
			return

func _handle_click(mouse_pos: Vector2) -> void:
	for i in range(_tab_rects.size()):
		if _tab_rects[i].has_point(mouse_pos):
			_category = i
			_selected_index = 0
			return
	for i in range(_item_rects.size()):
		if not _item_rects[i].has_point(mouse_pos):
			continue
		_selected_index = i
		if _category == Category.SOUND:
			var rect := _item_rects[i]
			var delta_db := VOLUME_STEP_DB if mouse_pos.x > rect.position.x + rect.size.x * 0.5 else -VOLUME_STEP_DB
			_adjust_volume(i, delta_db)
		else:
			_activate_selected()
		return

func _adjust_volume(bus_slot: int, delta_db: float) -> void:
	var idx := AudioServer.get_bus_index(BUS_NAMES[bus_slot])
	if idx < 0:
		return
	var new_db: float = clamp(AudioServer.get_bus_volume_db(idx) + delta_db, MIN_VOLUME_DB, MAX_VOLUME_DB)
	AudioServer.set_bus_volume_db(idx, new_db)

## Wspólny plik z Keybinds ("user://settings.json") — wczytuje istniejącą
## zawartość i scala, żeby zapis stąd nie kasował rebindów (patrz
## autoload/keybinds.gd._save_bindings(), ten sam problem naprawiony tam).
func _read_existing_settings() -> Dictionary:
	if not FileAccess.file_exists(SETTINGS_PATH):
		return {}
	var file := FileAccess.open(SETTINGS_PATH, FileAccess.READ)
	if file == null:
		return {}
	var data = JSON.parse_string(file.get_as_text())
	return data if typeof(data) == TYPE_DICTIONARY else {}

func _load_settings() -> void:
	var data := _read_existing_settings()
	var volumes: Dictionary = data.get("bus_volumes_db", {})
	for bus_name in volumes.keys():
		var idx := AudioServer.get_bus_index(bus_name)
		if idx >= 0:
			AudioServer.set_bus_volume_db(idx, float(volumes[bus_name]))
	var graphics: Dictionary = data.get("graphics", {})
	if graphics.has("fullscreen"):
		_set_fullscreen(bool(graphics["fullscreen"]))
	Juice.shake_enabled = bool(graphics.get("screen_shake", true))
	var accessibility: Dictionary = data.get("accessibility", {})
	Palette.reduce_flashing = bool(accessibility.get("reduce_flashing", false))

func _save_settings() -> void:
	var data := _read_existing_settings()
	var volumes := {}
	for bus_name in BUS_NAMES:
		var idx := AudioServer.get_bus_index(bus_name)
		if idx >= 0:
			volumes[bus_name] = AudioServer.get_bus_volume_db(idx)
	data["bus_volumes_db"] = volumes
	data["graphics"] = {"fullscreen": _fullscreen, "screen_shake": Juice.shake_enabled}
	data["accessibility"] = {"reduce_flashing": Palette.reduce_flashing}
	var file := FileAccess.open(SETTINGS_PATH, FileAccess.WRITE)
	if file == null:
		push_warning("OptionsScreen: nie udało się zapisać ustawień (%s), błąd %d" % [SETTINGS_PATH, FileAccess.get_open_error()])
		return
	file.store_string(JSON.stringify(data))

func _on_off(value: bool) -> String:
	return "WŁ" if value else "WYŁ"

func _draw() -> void:
	if not visible or keybind_screen.visible:
		return
	var viewport_size := get_viewport_rect().size
	draw_rect(Rect2(Vector2.ZERO, viewport_size), Color(Palette.BACKGROUND, 0.92), true)

	var title := "Opcje"
	var title_size := FONT_TITLE.get_string_size(title, HORIZONTAL_ALIGNMENT_CENTER, -1, title_font_size)
	draw_string(FONT_TITLE, Vector2((viewport_size.x - title_size.x) * 0.5, viewport_size.y * 0.13), title,
		HORIZONTAL_ALIGNMENT_LEFT, -1, title_font_size, SELECTED_COLOR)

	_draw_tabs(viewport_size)

	match _category:
		Category.SOUND:
			_draw_sound_items(viewport_size)
		Category.GRAPHICS:
			_draw_graphics_items(viewport_size)
		Category.CONTROLS:
			_draw_controls_items(viewport_size)
		Category.ACCESSIBILITY:
			_draw_accessibility_items(viewport_size)

	var hint := "Tab: zakładka — Strzałki: wybór/regulacja — Enter: zatwierdź — Escape: powrót"
	var hint_size := FONT_BODY.get_string_size(hint, HORIZONTAL_ALIGNMENT_CENTER, -1, 18)
	draw_string(FONT_BODY, Vector2((viewport_size.x - hint_size.x) * 0.5, viewport_size.y * 0.92), hint,
		HORIZONTAL_ALIGNMENT_LEFT, -1, 18, HINT_COLOR)

func _draw_tabs(viewport_size: Vector2) -> void:
	var tab_font_size := 20
	var gap := 36.0
	var sizes: Array[Vector2] = []
	var total_width := 0.0
	for name in CATEGORY_NAMES:
		var s := FONT_TITLE.get_string_size(name, HORIZONTAL_ALIGNMENT_CENTER, -1, tab_font_size)
		sizes.append(s)
		total_width += s.x
	total_width += gap * (CATEGORY_NAMES.size() - 1)

	_tab_rects.resize(CATEGORY_NAMES.size())
	var x := (viewport_size.x - total_width) * 0.5
	var y := viewport_size.y * 0.22
	for i in range(CATEGORY_NAMES.size()):
		var is_selected := i == _category
		var color := SELECTED_COLOR if is_selected else TEXT_COLOR
		draw_string(FONT_TITLE, Vector2(x, y), CATEGORY_NAMES[i], HORIZONTAL_ALIGNMENT_LEFT, -1, tab_font_size, color)
		_tab_rects[i] = Rect2(x, y - sizes[i].y - 4.0, sizes[i].x, sizes[i].y + 12.0)
		if is_selected:
			draw_rect(Rect2(x, y + 6.0, sizes[i].x, 2.0), SELECTED_COLOR, true)
		x += sizes[i].x + gap

## Rect pełnej szerokości to WYŁĄCZNIE trafienie myszką (klik gdziekolwiek w
## poziomym pasie wiersza musi trafić, patrz _handle_click — dla suwaków
## głośności lewa/prawa połowa TEGO pasa decyduje o kierunku) — samo
## podświetlenie tła jest węższe, dopasowane do tekstu (dokument o menu
## głównym: "nie pełny pasek na całą szerokość", ta sama zasada tutaj).
func _draw_row(viewport_size: Vector2, index: int, line: String, start_y: float, line_height: float) -> void:
	var is_selected := index == _selected_index
	var font := FONT_BODY_MEDIUM if is_selected else FONT_BODY
	var color := SELECTED_COLOR if is_selected else TEXT_COLOR
	var line_size := font.get_string_size(line, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size)
	var baseline := Vector2((viewport_size.x - line_size.x) * 0.5, start_y + index * line_height)
	var hit_rect := Rect2(0.0, baseline.y - line_size.y - 4.0, viewport_size.x, line_size.y + 12.0)
	_item_rects[index] = hit_rect
	if is_selected:
		var highlight_padding := 24.0
		var highlight_rect := Rect2(baseline.x - highlight_padding, hit_rect.position.y, line_size.x + highlight_padding * 2.0, hit_rect.size.y)
		draw_rect(highlight_rect, SELECTED_BG, true)
	draw_string(font, baseline, line, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)

func _draw_sound_items(viewport_size: Vector2) -> void:
	_item_rects.resize(BUS_NAMES.size())
	var start_y := viewport_size.y * 0.38
	var line_height := font_size * 1.8
	for i in range(BUS_NAMES.size()):
		var idx := AudioServer.get_bus_index(BUS_NAMES[i])
		var db := AudioServer.get_bus_volume_db(idx) if idx >= 0 else 0.0
		var pct := int(round(clamp((db - MIN_VOLUME_DB) / (MAX_VOLUME_DB - MIN_VOLUME_DB), 0.0, 1.0) * 100.0))
		_draw_row(viewport_size, i, "%s:  %d%%" % [BUS_LABELS[i], pct], start_y, line_height)

func _draw_graphics_items(viewport_size: Vector2) -> void:
	_item_rects.resize(2)
	var start_y := viewport_size.y * 0.38
	var line_height := font_size * 1.8
	_draw_row(viewport_size, 0, "Pełny ekran: %s" % _on_off(_fullscreen), start_y, line_height)
	_draw_row(viewport_size, 1, "Trzęsienie ekranu: %s" % _on_off(Juice.shake_enabled), start_y, line_height)

func _draw_controls_items(viewport_size: Vector2) -> void:
	_item_rects.resize(1)
	_draw_row(viewport_size, 0, "Zmień klawisze", viewport_size.y * 0.38, font_size * 1.8)

func _draw_accessibility_items(viewport_size: Vector2) -> void:
	_item_rects.resize(1)
	_draw_row(viewport_size, 0, "Redukcja migotania: %s" % _on_off(Palette.reduce_flashing), viewport_size.y * 0.38, font_size * 1.8)
