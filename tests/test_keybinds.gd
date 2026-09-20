extends RefCounted
## Keybinds (autoload) — rebind_action nadpisuje InputMap i persystuje na
## dysk; round-trip przez tymczasowy plik ustawień, żeby nie dotykać
## prawdziwego user://settings.json gracza.

func _cleanup(path: String) -> void:
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)

func test_rebind_action_updates_input_map(_root: Node) -> void:
	var original_events := InputMap.action_get_events("dash")
	var new_event := InputEventKey.new()
	new_event.physical_keycode = KEY_Q
	Keybinds.rebind_action("dash", new_event)

	var events := InputMap.action_get_events("dash")
	NemoraxTest.assert_eq(events.size(), 1, "rebind powinien zostawić dokładnie jedno zdarzenie")
	NemoraxTest.assert_eq(events[0].physical_keycode, KEY_Q, "nowy klawisz powinien być Q")

	# przywróć oryginał, żeby nie zanieczyścić kolejnych testów/sesji
	InputMap.action_erase_events("dash")
	for e in original_events:
		InputMap.action_add_event("dash", e)
	_cleanup(Keybinds.SETTINGS_PATH) # rebind_action() zapisało do prawdziwej ścieżki

func test_rebind_persists_and_reloads(_root: Node) -> void:
	var original_path := Keybinds.SETTINGS_PATH
	Keybinds.SETTINGS_PATH = "user://test_settings.json"
	_cleanup(Keybinds.SETTINGS_PATH)

	var original_events := InputMap.action_get_events("heal")
	var new_event := InputEventKey.new()
	new_event.physical_keycode = KEY_R
	Keybinds.rebind_action("heal", new_event)

	# symuluj restart: wyzeruj akcję z powrotem na "domyślną", potem wczytaj z pliku
	InputMap.action_erase_events("heal")
	InputMap.action_add_event("heal", original_events[0])
	Keybinds._load_bindings()

	var events := InputMap.action_get_events("heal")
	NemoraxTest.assert_eq(events[0].physical_keycode, KEY_R, "po _load_bindings() powinien wrócić zapisany R")

	InputMap.action_erase_events("heal")
	for e in original_events:
		InputMap.action_add_event("heal", e)
	_cleanup(Keybinds.SETTINGS_PATH)
	Keybinds.SETTINGS_PATH = original_path

func test_display_for_shows_readable_labels(_root: Node) -> void:
	NemoraxTest.assert_eq(Keybinds.label_for("move_left"), "Ruch — lewo", "etykieta move_left")
	NemoraxTest.assert_eq(Keybinds.display_for("attack"), "LPM", "attack powinien wyświetlać się jako LPM domyślnie")
	NemoraxTest.assert_eq(Keybinds.display_for("block"), "PPM", "block powinien wyświetlać się jako PPM domyślnie")

## Symuluje pełny przepływ z ekranu (nawigacja -> Enter -> naciśnięcie klawisza)
## przez InputEventAction (synteyczne "ui_down"/"ui_accept", niezależne od
## tego, jaki fizyczny klawisz jest pod spodem) + prawdziwy InputEventKey na
## sam moment przechwycenia nowego bindu — zamiast tylko wołać Keybinds API
## wprost, łapie ewentualne błędy w samym okablowaniu _unhandled_input.
func test_keybind_screen_full_flow(_root: Node) -> void:
	var original_path := Keybinds.SETTINGS_PATH
	Keybinds.SETTINGS_PATH = "user://test_settings_screen.json"
	_cleanup(Keybinds.SETTINGS_PATH)

	var screen: KeybindScreen = load("res://ui/keybind_screen.tscn").instantiate()
	screen.open()
	NemoraxTest.assert_eq(screen._selected_index, 0, "open() powinno zresetować zaznaczenie na 0")

	var down := InputEventAction.new()
	down.action = "ui_down"
	down.pressed = true
	screen._unhandled_input(down)
	NemoraxTest.assert_eq(screen._selected_index, 1, "ui_down powinno przesunąć zaznaczenie o 1")

	var accept := InputEventAction.new()
	accept.action = "ui_accept"
	accept.pressed = true
	screen._unhandled_input(accept)
	NemoraxTest.assert_true(screen._listening, "ui_accept powinno wejść w tryb nasłuchiwania")

	var action_name: String = Keybinds.REBINDABLE_ACTIONS[1] # to, co jest teraz zaznaczone
	var original_events := InputMap.action_get_events(action_name)

	var key_event := InputEventKey.new()
	key_event.pressed = true
	key_event.physical_keycode = KEY_J
	screen._unhandled_input(key_event)

	NemoraxTest.assert_true(not screen._listening, "po naciśnięciu klawisza nasłuchiwanie powinno się zakończyć")
	var events := InputMap.action_get_events(action_name)
	NemoraxTest.assert_eq(events[0].physical_keycode, KEY_J, "wybrana akcja powinna zostać przypisana do J")

	InputMap.action_erase_events(action_name)
	for e in original_events:
		InputMap.action_add_event(action_name, e)
	_cleanup(Keybinds.SETTINGS_PATH)
	Keybinds.SETTINGS_PATH = original_path
