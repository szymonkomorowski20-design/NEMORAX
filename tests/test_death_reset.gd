extends RefCounted
## Zgon gracza w ZWYKŁYM pokoju (dowolny wróg losowy/wcielenie, nie finałowa
## walka z Nemoraxem) musi resetować przebieg dokładnie tak samo jak zgon w
## arena.gd — prawdziwy bug sprzed tej poprawki: rooms/room.gd wołało
## get_tree().reload_current_scene(), które tylko odświeżało TEN SAM pokój na
## TYCH SAMYCH danych z GameFlow (fragmenty, wyczyszczone pokoje, pozycja bez
## zmian) zamiast cofać do świeżego pokoju startowego.

func test_restart_after_death_resets_progress(root: Node) -> void:
	GameFlow.reset_run()
	# Symuluj postęp w połowie przebiegu — dokładnie to, co dawny bug zostawiał
	# nietknięte po "Spacja, aby spróbować ponownie".
	GameFlow.fragments_collected.append("Vhar’Nokh, Wygnany z Otchłani")
	GameFlow.rooms_cleared_count = 5
	GameFlow.current_room_pos = Vector2i(2, -1)
	GameFlow.reached_arena = true

	var room = load("res://rooms/room.tscn").instantiate()
	root.add_child(room)

	room._restart_run_from_scratch()

	NemoraxTest.assert_true(GameFlow.fragments_collected.is_empty(), "restart po śmierci powinien wyczyścić zebrane fragmenty")
	NemoraxTest.assert_eq(GameFlow.rooms_cleared_count, 0, "restart po śmierci powinien wyzerować licznik wyczyszczonych pokoi")
	NemoraxTest.assert_eq(GameFlow.current_room_pos, Vector2i.ZERO, "restart po śmierci powinien cofnąć do pokoju startowego (0,0)")
	NemoraxTest.assert_true(not GameFlow.reached_arena, "restart po śmierci powinien zdjąć reached_arena, inaczej menu wznowiłoby prosto w arena.tscn")

	root.remove_child(room)
	room.queue_free()
	GameFlow.reset_run()
