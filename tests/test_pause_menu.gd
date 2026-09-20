extends RefCounted
## Pauza (ui/pause_menu.gd) wpięta w room.gd przez Escape (ui_cancel) —
## sprawdza, że toggle() faktycznie przełącza tree.paused i widoczność menu,
## oraz że otwarty ekran rebindingu blokuje toggle() (Escape najpierw z niego
## wychodzi, dopiero drugie Escape wznawia grę).

func _fresh_room(root: Node) -> Node:
	var room = load("res://rooms/room.tscn").instantiate()
	root.add_child(room)
	return room

func _cleanup(room: Node, root: Node) -> void:
	root.get_tree().paused = false # na wszelki wypadek, gdyby test przerwał się w trakcie pauzy
	root.remove_child(room)
	room.queue_free()

func test_pause_toggle_pauses_tree(root: Node) -> void:
	var room := _fresh_room(root)
	NemoraxTest.assert_true(not room.pause_menu.visible, "menu pauzy powinno być domyślnie ukryte")
	NemoraxTest.assert_true(not root.get_tree().paused, "drzewo nie powinno startować spauzowane")

	room.pause_menu.toggle()
	NemoraxTest.assert_true(room.pause_menu.visible, "toggle() powinien pokazać menu pauzy")
	NemoraxTest.assert_true(root.get_tree().paused, "toggle() powinien spauzować drzewo")

	room.pause_menu.toggle()
	NemoraxTest.assert_true(not room.pause_menu.visible, "drugi toggle() powinien schować menu pauzy")
	NemoraxTest.assert_true(not root.get_tree().paused, "drugi toggle() powinien wznowić drzewo")

	_cleanup(room, root)

func test_pause_ignored_while_keybind_screen_open(root: Node) -> void:
	var room := _fresh_room(root)
	room.pause_menu.toggle() # otwórz pauzę
	room.pause_menu.keybind_screen.open()

	room.pause_menu.toggle() # nie powinno nic zmienić, dopóki keybind_screen jest aktywny
	NemoraxTest.assert_true(room.pause_menu.visible, "pauza powinna zostać otwarta, gdy keybind_screen jest aktywny")
	NemoraxTest.assert_true(root.get_tree().paused, "drzewo powinno zostać spauzowane")

	room.pause_menu.keybind_screen.visible = false
	room.pause_menu.toggle()
	NemoraxTest.assert_true(not root.get_tree().paused, "po zamknięciu keybind_screen toggle() powinien już wznowić")

	_cleanup(room, root)
