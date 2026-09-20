extends RefCounted
## Ekran statystyk (ui/stats_screen.gd) wpięty w room.gd przez Tab — sprawdza,
## że open()/_close() faktycznie przełącza tree.paused i widoczność, oraz że
## Enter na wybranej statystyce realnie wydaje punkt gracza.

func _fresh_room(root: Node) -> Node:
	var room = load("res://rooms/room.tscn").instantiate()
	root.add_child(room)
	return room

func _cleanup(room: Node, root: Node) -> void:
	root.get_tree().paused = false
	root.remove_child(room)
	room.queue_free()

func test_open_pauses_tree_and_close_resumes(root: Node) -> void:
	var room := _fresh_room(root)
	NemoraxTest.assert_true(not room.stats_screen.visible, "ekran statystyk powinien być domyślnie ukryty")

	room.stats_screen.open(room.player)
	NemoraxTest.assert_true(room.stats_screen.visible, "open() powinien pokazać ekran")
	NemoraxTest.assert_true(root.get_tree().paused, "open() powinien spauzować drzewo")

	room.stats_screen._close()
	NemoraxTest.assert_true(not room.stats_screen.visible, "_close() powinien schować ekran")
	NemoraxTest.assert_true(not root.get_tree().paused, "_close() powinien wznowić drzewo")
	_cleanup(room, root)

func test_enter_spends_a_point_on_selected_stat(root: Node) -> void:
	var room := _fresh_room(root)
	room.player.gain_xp(); room.player.gain_xp(); room.player.gain_xp() # level 1, 1 punkt

	room.stats_screen.open(room.player)
	NemoraxTest.assert_eq(room.stats_screen._selected_index, 0, "open() powinno zresetować zaznaczenie na 0 (health)")

	var accept := InputEventAction.new()
	accept.action = "ui_accept"
	accept.pressed = true
	room.stats_screen._unhandled_input(accept)

	NemoraxTest.assert_eq(room.player.unspent_stat_points, 0, "Enter na zaznaczonej statystyce powinien wydać punkt")
	NemoraxTest.assert_eq(room.player.stat_points["health"], 1, "punkt powinien trafić w statystykę pod indeksem 0 (health)")

	room.stats_screen._close()
	_cleanup(room, root)
