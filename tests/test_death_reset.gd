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

## Krok 9 (polish ekranów): "przyciski: spróbuj ponownie / menu" — dawniej z
## ekranu porażki dało się TYLKO zrestartować, bez wyjścia do menu. Musi
## resetować przebieg identycznie jak restart (menu wznawia od GameFlow, więc
## zostawiony postęp wznowiłby się w połowie przebiegu przy następnym "Graj").
func test_exit_to_menu_from_death_resets_progress(root: Node) -> void:
	GameFlow.reset_run()
	GameFlow.fragments_collected.append("Vhar’Nokh, Wygnany z Otchłani")
	GameFlow.rooms_cleared_count = 5
	GameFlow.current_room_pos = Vector2i(2, -1)
	GameFlow.reached_arena = true

	var room = load("res://rooms/room.tscn").instantiate()
	root.add_child(room)

	room._exit_to_menu_from_death()

	NemoraxTest.assert_true(GameFlow.fragments_collected.is_empty(), "wyjście do menu po śmierci powinno wyczyścić zebrane fragmenty")
	NemoraxTest.assert_eq(GameFlow.rooms_cleared_count, 0, "wyjście do menu po śmierci powinno wyzerować licznik wyczyszczonych pokoi")
	NemoraxTest.assert_true(not GameFlow.reached_arena, "wyjście do menu po śmierci powinno zdjąć reached_arena")

	root.remove_child(room)
	room.queue_free()
	GameFlow.reset_run()

## Krok 9: "przyczyna lub pokój" w panelu porażki — w zwykłym pokoju to nazwa
## pokoju (ta sama, którą pokazuje baner wejścia, krok 8).
func test_room_death_overlay_shows_room_name_as_reason(root: Node) -> void:
	var room = load("res://rooms/room.tscn").instantiate()
	root.add_child(room) # _ready() ustawia _room_data z GameFlow — nadpisujemy PO, nie przed
	room._room_data = {"type": GameFlow.RoomType.RANDOM}

	room._on_player_died()

	NemoraxTest.assert_true("Komnata" in room.ui._overlay_text, "panel porażki w pokoju losowym powinien pokazać nazwę pokoju jako przyczynę")
	NemoraxTest.assert_true("spróbuj ponownie" in room.ui._overlay_text, "panel porażki powinien wspominać opcję ponowienia")
	NemoraxTest.assert_true("wyjdź do menu" in room.ui._overlay_text, "panel porażki powinien wspominać opcję wyjścia do menu")

	root.remove_child(room)
	room.queue_free()

## j.w., ale dla arena.gd (walka z Nemoraxem) — reason to numer próby, nie
## nazwa pokoju (nie ma jej sensu pokazywać — cała walka toczy się w jednej,
## dedykowanej arenie).
func test_arena_death_overlay_shows_attempt_number_as_reason(root: Node) -> void:
	var save_path := "user://test_death_reset_arena.json"
	if FileAccess.file_exists(save_path): # ślad po poprzednim przebiegu tego testu — _save_progress() zostawia plik na dysku
		DirAccess.remove_absolute(save_path)
	var arena = load("res://arena.tscn").instantiate()
	arena.SAVE_PATH = save_path
	root.add_child(arena)

	arena._on_player_died()

	# _attempts() == deaths+1 liczy NASTĘPNĄ próbę (deaths już zinkrementowane
	# przez _on_player_died() PRZED tym odczytem) — pierwsza śmierć (deaths: 0->1)
	# pokazuje więc "Próba: 2" ("to będzie twoja 2. próba"), nie "Próba: 1".
	# Zachowanie sprzed tej poprawki, niezmienione — sam _attempts() nie był
	# dotykany, tylko tekst dookoła niego (show_death_overlay zamiast show_overlay).
	NemoraxTest.assert_true("Próba: 2" in arena.ui._overlay_text, "pierwsza śmierć w arenie powinna pokazać 'Próba: 2' (deaths+1 liczy NASTĘPNĄ próbę)")
	NemoraxTest.assert_eq(arena._game_over_kind, "death", "_on_player_died() powinno ustawić _game_over_kind na 'death'")

	root.remove_child(arena)
	arena.queue_free()
	if FileAccess.file_exists(save_path):
		DirAccess.remove_absolute(save_path)
