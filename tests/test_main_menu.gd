extends RefCounted
## Menu główne (menu.gd) — krok 12: potwierdzenie wyjścia (EXITING) i przejście
## do OPTIONS_OPEN. Testy wymuszają _state=IDLE wprost zamiast czekać na
## prawdziwy tween _play_intro() (ta sama konwencja co reszta zestawu —
## wymuszanie stanu zamiast oczekiwania na realne klatki/tweeny).
##
## Celowo NIE testujemy tu drugiego (potwierdzającego) wywołania
## _confirm_exit() — z _exit_confirm_pending=true woła ono get_tree().quit(),
## co ubiłoby cały proces test-runnera, nie tylko ten jeden test.

func _fresh_menu(root: Node) -> Node:
	var menu = load("res://menu.tscn").instantiate()
	root.add_child(menu)
	menu._state = menu.State.IDLE # pomija INTRO
	return menu

func _cleanup(menu: Node, root: Node) -> void:
	root.remove_child(menu)
	menu.queue_free()

func test_escape_asks_for_confirmation_before_quitting(root: Node) -> void:
	var menu := _fresh_menu(root)
	NemoraxTest.assert_true(not menu._exit_confirm_pending, "menu nie powinno zaczynać z pytaniem o wyjście")

	var cancel := InputEventAction.new()
	cancel.action = "ui_cancel"
	cancel.pressed = true
	menu._unhandled_input(cancel)

	NemoraxTest.assert_true(menu._exit_confirm_pending, "pierwsze Escape powinno zapytać, nie zamknąć gry od razu")
	NemoraxTest.assert_eq(menu.hint_label.text, menu.HINT_TEXT_CONFIRM_EXIT, "podpowiedź powinna zmienić się na pytanie potwierdzające")

	_cleanup(menu, root)

func test_second_escape_cancels_the_pending_confirmation(root: Node) -> void:
	var menu := _fresh_menu(root)
	menu._confirm_exit() # pierwsze wywołanie = samo pytanie, bezpieczne (nie woła quit())

	var cancel := InputEventAction.new()
	cancel.action = "ui_cancel"
	cancel.pressed = true
	menu._unhandled_input(cancel)

	NemoraxTest.assert_true(not menu._exit_confirm_pending, "drugie Escape (gdy pytanie już wisi) powinno anulować wyjście, nie zamknąć gry")
	NemoraxTest.assert_eq(menu.hint_label.text, menu.HINT_TEXT_DEFAULT, "podpowiedź powinna wrócić do domyślnej")

	_cleanup(menu, root)

func test_changing_selection_cancels_pending_exit_confirmation(root: Node) -> void:
	var menu := _fresh_menu(root)
	menu._confirm_exit() # zapytaj o wyjście
	NemoraxTest.assert_true(menu._exit_confirm_pending, "pytanie powinno wisieć przed zmianą zaznaczenia")

	menu._select_index(0)

	NemoraxTest.assert_true(not menu._exit_confirm_pending, "zmiana zaznaczenia w trakcie pytania powinna po cichu je anulować")
	_cleanup(menu, root)

## Krok 12: "główne pozycje miękko znikają, panel opcji wchodzi z dołu lub z
## prawej" — sprawdzamy przejście stanu i widoczność, nie same wartości tweena
## (te zweryfikowane wizualnie zrzutem ekranu, nie da się ich sensownie
## assertować bez czekania na realny czas).
func test_opening_options_switches_state_and_shows_options_screen(root: Node) -> void:
	var menu := _fresh_menu(root)
	menu._selected_index = menu.MENU_ITEMS.find("Opcje")

	var accept := InputEventAction.new()
	accept.action = "ui_accept"
	accept.pressed = true
	menu._unhandled_input(accept)

	NemoraxTest.assert_eq(menu._state, menu.State.OPTIONS_OPEN, "Enter na 'Opcje' powinno przejść w stan OPTIONS_OPEN")
	NemoraxTest.assert_true(menu.options_screen.visible, "OPTIONS_OPEN powinno pokazać OptionsScreen")

	menu.options_screen.visible = false
	_cleanup(menu, root)

func test_returning_from_options_restores_idle_state(root: Node) -> void:
	var menu := _fresh_menu(root)
	menu._open_options()
	# Escape podczas trwającego zanikania pozycji — dawniej kończyło się
	# niewidocznym menu, bo stary tween dopiero później ustawiał alpha=0.
	var cancel := InputEventAction.new()
	cancel.action = "ui_cancel"
	cancel.pressed = true
	menu.options_screen._unhandled_input(cancel)
	NemoraxTest.assert_eq(menu._state, menu.State.IDLE, "Escape w Opcjach powinien wrócić do IDLE")
	NemoraxTest.assert_true(not menu.options_screen.visible, "panel opcji powinien się zamknąć")
	NemoraxTest.assert_true(menu._items_fade_tween.is_valid(), "powrót powinien animować pozycje menu")
	menu._items_fade_tween.custom_step(1.0)
	NemoraxTest.assert_almost_eq(menu.items_container.modulate.a, 1.0, 0.001, "po powrocie pozycje menu mają być widoczne")
	_cleanup(menu, root)
