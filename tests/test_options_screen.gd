extends RefCounted
## Ekran opcji (ui/options_screen.gd) — suwaki głośności (Master/Music/SFX/UI)
## i wejście do KeybindScreen, ta sama klawiaturowa konwencja co
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

func test_open_shows_screen_and_defaults_to_first_item(root: Node) -> void:
	_cleanup(TEST_SETTINGS_PATH)
	var options := _fresh_options(root)
	NemoraxTest.assert_true(not options.visible, "ekran opcji powinien być domyślnie ukryty")

	options.open()
	NemoraxTest.assert_true(options.visible, "open() powinno pokazać ekran")
	NemoraxTest.assert_eq(options._selected_index, 0, "open() powinno zresetować zaznaczenie na pierwszy suwak")

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

	AudioServer.set_bus_volume_db(master_idx, -12.0)
	options._save_settings()
	AudioServer.set_bus_volume_db(master_idx, 0.0) # symuluj świeży start procesu (inna wartość niż zapisana)
	options._load_settings()

	NemoraxTest.assert_almost_eq(AudioServer.get_bus_volume_db(master_idx), -12.0, 0.01, "_load_settings() powinno przywrócić zapisaną głośność")

	AudioServer.set_bus_volume_db(master_idx, original)
	root.remove_child(options)
	options.queue_free()
	_cleanup(TEST_SETTINGS_PATH)

func test_accept_on_keybind_item_opens_keybind_screen(root: Node) -> void:
	_cleanup(TEST_SETTINGS_PATH)
	var options := _fresh_options(root)
	options.open()
	options._selected_index = options.KEYBIND_ITEM_INDEX

	# InputEventAction skonstruowany wprost (nie Input.action_press(), które
	# steruje is_action_just_pressed() na Input, a nie event.is_action_pressed()
	# sprawdzane w _unhandled_input) — jedyny sposób, żeby ten konkretny
	# warunek faktycznie się zapalił bez realnej klatki silnika.
	var event := InputEventAction.new()
	event.action = "ui_accept"
	event.pressed = true
	options._unhandled_input(event)

	NemoraxTest.assert_true(options.keybind_screen.visible, "Enter na wpisie 'Zmień klawisze' powinno otworzyć KeybindScreen")

	root.remove_child(options)
	options.queue_free()
	_cleanup(TEST_SETTINGS_PATH)
