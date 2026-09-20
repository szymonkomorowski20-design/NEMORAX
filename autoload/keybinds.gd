extends Node
## Rebinding klawiszy (na życzenie autora, poza dokumentem bazowym) — nakłada
## się na domyślną mapę wejścia zdefiniowaną w `palette.gd` (`_setup_input_map`,
## odpalane wcześniej w kolejności autoloadów). Ten autoload TYLKO nadpisuje
## pojedyncze zdarzenia dla akcji, których użytkownik jawnie użył do rebindu —
## reszta zostaje przy domyślnych klawiszach z palette.gd.

var SETTINGS_PATH := "user://settings.json" ## var (nie const) tylko po to, żeby test mógł podmienić ścieżkę na tymczasową

## Kolejność jak w palette.gd._setup_input_map() — to ta lista napędza ekran
## rebindingu (ui/keybind_screen.gd). "ui_accept"/"ui_cancel" (silnikowe
## domyślne Space/Escape do nawigacji w menu/pauzie) celowo NIE są tutaj —
## rebindowanie klawisza, który otwiera sam ekran rebindingu, robiłoby bałagan.
const REBINDABLE_ACTIONS: Array[String] = [
	"move_left", "move_right", "move_up", "move_down",
	"dash", "attack", "block", "weapon_sword", "weapon_wand", "heal", "pickup",
]

const ACTION_LABELS := {
	"move_left": "Ruch — lewo",
	"move_right": "Ruch — prawo",
	"move_up": "Ruch — góra",
	"move_down": "Ruch — dół",
	"dash": "Dash",
	"attack": "Atak",
	"block": "Blok",
	"weapon_sword": "Miecz",
	"weapon_wand": "Różdżka",
	"heal": "Leczenie",
	"pickup": "Podniesienie duszy",
}

func _ready() -> void:
	_load_bindings()

func label_for(action: String) -> String:
	return ACTION_LABELS.get(action, action)

## Tekst do wyświetlenia na ekranie rebindingu — pierwsze (jedyne, w tej grze)
## zdarzenie przypisane do akcji, jako czytelny napis.
func display_for(action: String) -> String:
	var events := InputMap.action_get_events(action)
	if events.is_empty():
		return "—"
	return _event_display_string(events[0])

func _event_display_string(event: InputEvent) -> String:
	if event is InputEventKey:
		return OS.get_keycode_string(event.physical_keycode)
	if event is InputEventMouseButton:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				return "LPM"
			MOUSE_BUTTON_RIGHT:
				return "PPM"
			MOUSE_BUTTON_MIDDLE:
				return "Środkowy przycisk myszy"
			_:
				return "Przycisk myszy %d" % event.button_index
	return "?"

## Nadpisuje jedyne zdarzenie akcji nowym (klawisz LUB przycisk myszy) i
## zapisuje na dysk. Wywoływane przez ui/keybind_screen.gd po przechwyceniu
## kolejnego wciśnięcia.
func rebind_action(action: String, event: InputEvent) -> void:
	InputMap.action_erase_events(action)
	InputMap.action_add_event(action, event)
	_save_bindings()

func _load_bindings() -> void:
	if not FileAccess.file_exists(SETTINGS_PATH):
		return
	var file := FileAccess.open(SETTINGS_PATH, FileAccess.READ)
	if file == null:
		push_warning("Keybinds: nie udało się otworzyć ustawień do odczytu (%s), błąd %d" % [SETTINGS_PATH, FileAccess.get_open_error()])
		return
	var data = JSON.parse_string(file.get_as_text())
	if typeof(data) != TYPE_DICTIONARY:
		return
	for action in REBINDABLE_ACTIONS:
		if not data.has(action) or not InputMap.has_action(action):
			continue
		var entry: Dictionary = data[action]
		var event := _event_from_dict(entry)
		if event != null:
			InputMap.action_erase_events(action)
			InputMap.action_add_event(action, event)

func _save_bindings() -> void:
	var data := {}
	for action in REBINDABLE_ACTIONS:
		var events := InputMap.action_get_events(action)
		if events.is_empty():
			continue
		var entry = _dict_from_event(events[0])
		if entry != null:
			data[action] = entry
	var file := FileAccess.open(SETTINGS_PATH, FileAccess.WRITE)
	if file == null:
		push_warning("Keybinds: nie udało się zapisać ustawień (%s), błąd %d" % [SETTINGS_PATH, FileAccess.get_open_error()])
		return
	file.store_string(JSON.stringify(data))

func _dict_from_event(event: InputEvent):
	if event is InputEventKey:
		return {"type": "key", "keycode": event.physical_keycode}
	if event is InputEventMouseButton:
		return {"type": "mouse", "button": event.button_index}
	return null

func _event_from_dict(entry: Dictionary) -> InputEvent:
	match entry.get("type", ""):
		"key":
			var event := InputEventKey.new()
			event.physical_keycode = int(entry.get("keycode", 0))
			return event
		"mouse":
			var event := InputEventMouseButton.new()
			event.button_index = int(entry.get("button", 0))
			return event
		_:
			return null
