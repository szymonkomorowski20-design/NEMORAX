extends RefCounted
## Ekran opcji (ui/options_screen.gd) — 4 zakładki (Dźwięk/Grafika/Sterowanie/
## Dostępność, krok 9 polish ekranów), ta sama klawiaturowa konwencja co
## tests/test_pause_menu.gd sprawdza dla KeybindScreen.

const TEST_SETTINGS_PATH := "user://test_settings.json"

func _cleanup(path: String) -> void:
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)

func _fresh_options(root: Node) -> OptionsScreen:
	var options: OptionsScreen = load("res://ui/options_screen.tscn").instantiate()
	options.SETTINGS_PATH = TEST_SETTINGS_PATH
	root.add_child(options)
	return options

func _accept(options: OptionsScreen) -> void:
	# InputEventAction skonstruowany wprost (nie Input.action_press(), które
	# steruje is_action_just_pressed() na Input, a nie event.is_action_pressed()
	# sprawdzane w _unhandled_input) — jedyny sposób, żeby ten konkretny
	# warunek faktycznie się zapalił bez realnej klatki silnika.
	var event := InputEventAction.new()
	event.action = "ui_accept"
	event.pressed = true
	options._unhandled_input(event)

func test_open_shows_screen_and_defaults_to_sound_tab(root: Node) -> void:
	_cleanup(TEST_SETTINGS_PATH)
	var options := _fresh_options(root)
	NemoraxTest.assert_true(not options.visible, "ekran opcji powinien być domyślnie ukryty")

	options.open()
	NemoraxTest.assert_true(options.visible, "open() powinno pokazać ekran")
	NemoraxTest.assert_eq(options._category, OptionsScreen.Category.SOUND, "open() powinno zaczynać od zakładki Dźwięk")
	NemoraxTest.assert_eq(options._selected_index, 0, "open() powinno zresetować zaznaczenie na pierwszy wiersz")

	root.remove_child(options)
	options.queue_free()
	_cleanup(TEST_SETTINGS_PATH)

func test_focus_next_cycles_through_all_four_categories(root: Node) -> void:
	_cleanup(TEST_SETTINGS_PATH)
	var options := _fresh_options(root)
	options.open()

	var seen: Array[int] = [options._category]
	for i in range(5):
		var event := InputEventAction.new()
		event.action = "ui_focus_next"
		event.pressed = true
		options._unhandled_input(event)
		seen.append(options._category)

	NemoraxTest.assert_eq(seen, [0, 1, 2, 3, 0, 1], "Tab powinien cyklicznie przechodzić przez Dźwięk/Grafika/Sterowanie/Dostępność")
	root.remove_child(options)
	options.queue_free()
	_cleanup(TEST_SETTINGS_PATH)

func test_right_arrow_raises_selected_bus_volume(root: Node) -> void:
	_cleanup(TEST_SETTINGS_PATH)
	var options := _fresh_options(root)
	options.open()

	var master_idx := AudioServer.get_bus_index("Master")
	var before := AudioServer.get_bus_volume_db(master_idx)
	options._adjust_volume(0, options.VOLUME_STEP_DB)
	var after := AudioServer.get_bus_volume_db(master_idx)

	NemoraxTest.assert_almost_eq(after - before, options.VOLUME_STEP_DB, 0.01, "strzałka w prawo powinna podnieść głośność o VOLUME_STEP_DB")

	# Sprzątanie: wróć głośność do stanu sprzed testu, żeby nie zmienić realnego
	# ustawienia procesu na resztę zestawu (AudioServer to globalny, żywy stan).
	AudioServer.set_bus_volume_db(master_idx, before)
	root.remove_child(options)
	options.queue_free()
	_cleanup(TEST_SETTINGS_PATH)

func test_volume_does_not_exceed_max_db(root: Node) -> void:
	_cleanup(TEST_SETTINGS_PATH)
	var options := _fresh_options(root)
	var master_idx := AudioServer.get_bus_index("Master")
	var before := AudioServer.get_bus_volume_db(master_idx)

	for i in range(50): # dużo więcej niż trzeba, żeby na pewno uderzyć w sufit
		options._adjust_volume(0, options.VOLUME_STEP_DB)
	NemoraxTest.assert_almost_eq(AudioServer.get_bus_volume_db(master_idx), options.MAX_VOLUME_DB, 0.01, "głośność nie powinna przekroczyć MAX_VOLUME_DB")

	AudioServer.set_bus_volume_db(master_idx, before)
	root.remove_child(options)
	options.queue_free()
	_cleanup(TEST_SETTINGS_PATH)

func test_save_and_load_round_trip(root: Node) -> void:
	_cleanup(TEST_SETTINGS_PATH)
	var options := _fresh_options(root)
	var master_idx := AudioServer.get_bus_index("Master")
	var original := AudioServer.get_bus_volume_db(master_idx)
	var shake_before := Juice.shake_enabled
	var flashing_before := Palette.reduce_flashing

	AudioServer.set_bus_volume_db(master_idx, -12.0)
	Juice.shake_enabled = false
	Palette.reduce_flashing = true
	options._save_settings()

	AudioServer.set_bus_volume_db(master_idx, 0.0) # symuluj świeży start procesu (inne wartości niż zapisane)
	Juice.shake_enabled = true
	Palette.reduce_flashing = false
	options._load_settings()

	NemoraxTest.assert_almost_eq(AudioServer.get_bus_volume_db(master_idx), -12.0, 0.01, "_load_settings() powinno przywrócić zapisaną głośność")
	NemoraxTest.assert_true(not Juice.shake_enabled, "_load_settings() powinno przywrócić wyłączone trzęsienie ekranu")
	NemoraxTest.assert_true(Palette.reduce_flashing, "_load_settings() powinno przywrócić włączoną redukcję migotania")

	AudioServer.set_bus_volume_db(master_idx, original)
	Juice.shake_enabled = shake_before
	Palette.reduce_flashing = flashing_before
	root.remove_child(options)
	options.queue_free()
	_cleanup(TEST_SETTINGS_PATH)

## Regresja na prawdziwy bug: Keybinds i OptionsScreen dzielą JEDEN plik
## (user://settings.json) — zapis jednego nie może kasować danych drugiego.
func test_saving_options_does_not_erase_keybind_rebinds(root: Node) -> void:
	_cleanup(TEST_SETTINGS_PATH)
	var previous_keybinds_path := Keybinds.SETTINGS_PATH
	Keybinds.SETTINGS_PATH = TEST_SETTINGS_PATH
	var previous_dash_events := InputMap.action_get_events("dash")

	var rebound_event := InputEventKey.new()
	rebound_event.physical_keycode = KEY_Q
	Keybinds.rebind_action("dash", rebound_event) # zapisuje do WSPÓLNEGO pliku

	var options := _fresh_options(root)
	options.open()
	options._save_settings() # dawny bug: to nadpisywało cały plik samymi ustawieniami dźwięku/grafiki

	InputMap.action_erase_events("dash")
	Keybinds._load_bindings() # symuluje świeży start procesu, wczytując z dysku ponownie
	var dash_key: Key = (InputMap.action_get_events("dash")[0] as InputEventKey).physical_keycode
	NemoraxTest.assert_eq(dash_key, KEY_Q, "zapis ekranu opcji nie powinien skasować rebindu klawisza zapisanego wcześniej")

	InputMap.action_erase_events("dash")
	for e in previous_dash_events:
		InputMap.action_add_event("dash", e)
	Keybinds.SETTINGS_PATH = previous_keybinds_path
	root.remove_child(options)
	options.queue_free()
	_cleanup(TEST_SETTINGS_PATH)

func test_accept_on_controls_tab_opens_keybind_screen(root: Node) -> void:
	_cleanup(TEST_SETTINGS_PATH)
	var options := _fresh_options(root)
	options.open()
	options._category = OptionsScreen.Category.CONTROLS
	options._selected_index = 0

	_accept(options)

	NemoraxTest.assert_true(options.keybind_screen.visible, "Enter na 'Zmień klawisze' powinno otworzyć KeybindScreen")

	root.remove_child(options)
	options.queue_free()
	_cleanup(TEST_SETTINGS_PATH)

func test_accept_on_graphics_shake_toggles_juice_shake_enabled(root: Node) -> void:
	_cleanup(TEST_SETTINGS_PATH)
	var options := _fresh_options(root)
	var shake_before := Juice.shake_enabled
	options.open()
	options._category = OptionsScreen.Category.GRAPHICS
	options._selected_index = 1 # wiersz "Trzęsienie ekranu"

	_accept(options)
	NemoraxTest.assert_eq(Juice.shake_enabled, not shake_before, "Enter na 'Trzęsienie ekranu' powinno przełączyć Juice.shake_enabled")

	Juice.shake_enabled = shake_before
	root.remove_child(options)
	options.queue_free()
	_cleanup(TEST_SETTINGS_PATH)

func test_disabling_shake_makes_screen_shake_a_no_op(root: Node) -> void:
	var shake_before := Juice.shake_enabled
	var time_before := Juice._shake_time_left
	Juice.shake_enabled = false
	Juice._shake_time_left = 0.0

	Juice.screen_shake()
	NemoraxTest.assert_almost_eq(Juice._shake_time_left, 0.0, 0.001, "screen_shake() nie powinien nic zrobić, gdy shake_enabled=false")

	Juice.shake_enabled = shake_before
	Juice._shake_time_left = time_before

func test_accept_on_accessibility_toggles_reduce_flashing(root: Node) -> void:
	_cleanup(TEST_SETTINGS_PATH)
	var options := _fresh_options(root)
	var flashing_before := Palette.reduce_flashing
	options.open()
	options._category = OptionsScreen.Category.ACCESSIBILITY
	options._selected_index = 0

	_accept(options)
	NemoraxTest.assert_eq(Palette.reduce_flashing, not flashing_before, "Enter na 'Redukcja migotania' powinno przełączyć Palette.reduce_flashing")

	Palette.reduce_flashing = flashing_before
	root.remove_child(options)
	options.queue_free()
	_cleanup(TEST_SETTINGS_PATH)

## Reduce_flashing gasi flash_white() (poza "hit") u wszystkich trzech
## rodzajów postaci — sprawdzone tu na Incarnation, bo najlżej ją zestawić.
func test_reduce_flashing_suppresses_incarnation_hit_flash(root: Node) -> void:
	var flashing_before := Palette.reduce_flashing
	var incarnation: Incarnation = load("res://entities/random_enemies/chaser.tscn").instantiate()
	root.add_child(incarnation)

	Palette.reduce_flashing = true
	incarnation._flash_frames = 0
	incarnation.flash_white()
	NemoraxTest.assert_eq(incarnation._flash_frames, 0, "z reduce_flashing=true flash_white() nie powinien nic zrobić")

	Palette.reduce_flashing = false
	incarnation.flash_white()
	NemoraxTest.assert_eq(incarnation._flash_frames, 2, "z reduce_flashing=false flash_white() powinien działać jak dawniej")

	Palette.reduce_flashing = flashing_before
	root.remove_child(incarnation)
	incarnation.queue_free()
