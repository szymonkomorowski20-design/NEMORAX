extends RefCounted
## Podgląd na żywo pod F3 (autoload/juice.gd) — Game Feel, sekcja Debug Mode.

func _fresh_player(root: Node) -> Player:
	var player: Player = load("res://entities/player.tscn").instantiate()
	root.add_child(player)
	return player

func _cleanup(player: Player, root: Node) -> void:
	root.remove_child(player)
	player.queue_free()

func _toggle_event() -> InputEventAction:
	var event := InputEventAction.new()
	event.action = "toggle_debug"
	event.pressed = true
	return event

func test_toggle_debug_shows_and_hides_label(_root: Node) -> void:
	Juice.debug_visible = false
	Juice._debug_label.visible = false

	Juice._unhandled_input(_toggle_event())
	NemoraxTest.assert_true(Juice.debug_visible, "F3 powinno włączyć podgląd")
	NemoraxTest.assert_true(Juice._debug_label.visible, "etykieta powinna stać się widoczna")

	Juice._unhandled_input(_toggle_event())
	NemoraxTest.assert_true(not Juice.debug_visible, "drugie F3 powinno wyłączyć podgląd")
	NemoraxTest.assert_true(not Juice._debug_label.visible, "etykieta powinna zniknąć")

func test_debug_label_reflects_player_state(root: Node) -> void:
	var player := _fresh_player(root)
	player.stamina = 42.0
	player.max_stamina = 100.0
	player.current_weapon = "wand"

	Juice._update_debug_label()

	var text: String = Juice._debug_label.text
	NemoraxTest.assert_true(text.find("wand") != -1, "podgląd powinien pokazywać aktualną broń")
	NemoraxTest.assert_true(text.find("42/100") != -1, "podgląd powinien pokazywać aktualną staminę")
	_cleanup(player, root)

func test_debug_label_works_without_a_player_in_the_scene(_root: Node) -> void:
	# Np. w menu/ołtarzu, gdzie w danym momencie może nie być gracza w grupie
	# "player" — podgląd nie powinien się wywalić, po prostu pominąć te linie.
	Juice._update_debug_label()
	NemoraxTest.assert_true(Juice._debug_label.text.find("FPS:") != -1, "linia FPS/time_scale powinna zawsze się pojawić")
