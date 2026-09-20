extends Control
class_name KeybindScreen
## Prosty, klawiaturowy ekran zmiany klawiszy (bez myszy do nawigacji — spójne
## z resztą gry, gdzie nie ma dotąd żadnych klikanych przycisków, patrz
## menu.gd's "Naciśnij Spację"). Reużywany zarówno z menu głównego
## (menu.tscn) jak i z menu pauzy w trakcie gry (pause_menu.tscn) —
## process_mode ALWAYS, żeby działał nawet gdy get_tree().paused = true.

signal closed

@export var font_size: int = 22
@export var title_font_size: int = 32

var _selected_index: int = 0
var _listening: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false

func _process(_delta: float) -> void:
	if visible:
		queue_redraw()

## Wywoływane przez rodzica (menu.gd albo pause_menu.gd) zamiast bezpośrednio
## ustawiać visible=true — resetuje zaznaczenie i stan nasłuchiwania.
func open() -> void:
	_selected_index = 0
	_listening = false
	visible = true

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if _listening:
		_handle_listening_input(event)
		return
	if event.is_action_pressed("ui_down"):
		_selected_index = (_selected_index + 1) % Keybinds.REBINDABLE_ACTIONS.size()
	elif event.is_action_pressed("ui_up"):
		_selected_index = (_selected_index - 1 + Keybinds.REBINDABLE_ACTIONS.size()) % Keybinds.REBINDABLE_ACTIONS.size()
	elif event.is_action_pressed("ui_accept"):
		_listening = true
	elif event.is_action_pressed("ui_cancel"):
		visible = false
		closed.emit()

func _handle_listening_input(event: InputEvent) -> void:
	# ui_cancel (Escape) anuluje samo nasłuchiwanie, nie zamyka całego ekranu —
	# bez tego nie dałoby się w ogóle wyjść z trybu "naciśnij klawisz...".
	if event.is_action_pressed("ui_cancel"):
		_listening = false
		return
	var action: String = Keybinds.REBINDABLE_ACTIONS[_selected_index]
	if event is InputEventKey and event.pressed and not event.echo:
		var new_event := InputEventKey.new()
		new_event.physical_keycode = event.physical_keycode
		Keybinds.rebind_action(action, new_event)
		_listening = false
	elif event is InputEventMouseButton and event.pressed:
		var new_event := InputEventMouseButton.new()
		new_event.button_index = event.button_index
		Keybinds.rebind_action(action, new_event)
		_listening = false

func _draw() -> void:
	var size := get_viewport_rect().size
	draw_rect(Rect2(Vector2.ZERO, size), Color(Palette.BACKGROUND, 0.92), true)
	var font := ThemeDB.fallback_font

	var title := "Zmiana klawiszy"
	var title_size := font.get_string_size(title, HORIZONTAL_ALIGNMENT_CENTER, -1, title_font_size)
	draw_string(font, Vector2((size.x - title_size.x) * 0.5, size.y * 0.15), title,
		HORIZONTAL_ALIGNMENT_LEFT, -1, title_font_size, Palette.PLAYER_BODY)

	var start_y := size.y * 0.28
	var line_height := font_size * 1.6
	for i in range(Keybinds.REBINDABLE_ACTIONS.size()):
		var action: String = Keybinds.REBINDABLE_ACTIONS[i]
		var label := Keybinds.label_for(action)
		var key_text := "naciśnij klawisz..." if (_listening and i == _selected_index) else Keybinds.display_for(action)
		var line := "%s:  %s" % [label, key_text]
		var color := Palette.HIT_FLASH if i == _selected_index else Color.WHITE
		var line_size := font.get_string_size(line, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size)
		draw_string(font, Vector2((size.x - line_size.x) * 0.5, start_y + i * line_height), line,
			HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)

	var hint := "Strzałki: wybór — Enter: przypisz — Escape: powrót"
	var hint_size := font.get_string_size(hint, HORIZONTAL_ALIGNMENT_CENTER, -1, 18)
	draw_string(font, Vector2((size.x - hint_size.x) * 0.5, size.y * 0.92), hint,
		HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color.WHITE)
