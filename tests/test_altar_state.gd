extends RefCounted
## Maszyna stanów ołtarza LOCKED->READY->ACTIVATING (rooms/altar.gd,
## CLAUDE_CODE_GAME_CONTENT_BIBLE.md sekcja 12). BOSS_ACTIVE/COMPLETE należą do
## arena.gd (osobna scena po GameFlow.complete_altar()) — nie testowane tutaj.

func _fresh_altar(root: Node) -> Node:
	var altar = load("res://rooms/altar.tscn").instantiate()
	root.add_child(altar)
	return altar

func _cleanup(altar: Node, root: Node) -> void:
	root.remove_child(altar)
	altar.queue_free()
	root.get_tree().paused = false # sprzątanie na wypadek testu ACTIVATING

func test_ready_state_when_fragments_complete(root: Node) -> void:
	var original := GameFlow.fragments_collected
	GameFlow.fragments_collected = ["A", "B", "C", "D", "E", "F"]

	var altar := _fresh_altar(root)
	NemoraxTest.assert_eq(altar.state, altar.AltarState.READY, "komplet fragmentów powinien dać stan READY")

	_cleanup(altar, root)
	GameFlow.fragments_collected = original

func test_locked_state_when_fragments_incomplete(root: Node) -> void:
	var original := GameFlow.fragments_collected
	GameFlow.fragments_collected = ["A", "B"] # symulacja "nie powinno się zdarzyć" (patrz komentarz w altar.gd)

	var altar := _fresh_altar(root)
	NemoraxTest.assert_eq(altar.state, altar.AltarState.LOCKED, "niekomplet fragmentów powinien dać stan LOCKED, nie pozwolić przejść dalej po cichu")

	_cleanup(altar, root)
	GameFlow.fragments_collected = original

func test_locked_altar_ignores_player_proximity(root: Node) -> void:
	var original := GameFlow.fragments_collected
	GameFlow.fragments_collected = ["A"]

	var altar := _fresh_altar(root)
	altar.player.global_position = altar.ARENA_RECT.get_center() # tuż przy pedestale
	altar._physics_process(0.0)
	NemoraxTest.assert_eq(altar.state, altar.AltarState.LOCKED, "LOCKED nie powinien reagować na bliskość gracza")

	_cleanup(altar, root)
	GameFlow.fragments_collected = original

func test_player_proximity_triggers_activation(root: Node) -> void:
	var original := GameFlow.fragments_collected
	GameFlow.fragments_collected = ["A", "B", "C", "D", "E", "F"]

	var altar := _fresh_altar(root)
	altar.player.global_position = altar.ARENA_RECT.get_center()
	altar._physics_process(0.0)

	NemoraxTest.assert_eq(altar.state, altar.AltarState.ACTIVATING, "bliskość gracza w stanie READY powinna rozpocząć aktywację")
	NemoraxTest.assert_true(root.get_tree().paused, "aktywacja powinna zapauzować drzewo (gracz traci sterowanie)")
	NemoraxTest.assert_eq(altar.process_mode, Node.PROCESS_MODE_ALWAYS, "ołtarz musi przetrwać własną pauzę, żeby dokończyć sekwencję")

	# Pierwsze gniazdo powinno się rozjaśnić SYNCHRONICZNIE przed pierwszym
	# await w _run_activation_sequence() (patrz komentarz w altar.gd) — reszta
	# sekwencji nigdy nie odpali w tym runnerze (żadna klatka nie mija między
	# wywołaniami testów), więc sprawdzamy tylko ten pierwszy, gwarantowany krok.
	var first_socket: Sprite2D = altar._sockets[0]
	var original_color: Color = altar.SOCKET_COLORS[0]
	var original_sum := original_color.r + original_color.g + original_color.b
	var current_sum: float = first_socket.modulate.r + first_socket.modulate.g + first_socket.modulate.b
	NemoraxTest.assert_true(current_sum > original_sum, "pierwsze gniazdo powinno się rozjaśnić od razu po rozpoczęciu aktywacji")

	_cleanup(altar, root)
	GameFlow.fragments_collected = original

func test_ready_altar_does_not_trigger_when_player_far(root: Node) -> void:
	var original := GameFlow.fragments_collected
	GameFlow.fragments_collected = ["A", "B", "C", "D", "E", "F"]

	var altar := _fresh_altar(root)
	altar.player.global_position = altar.ARENA_RECT.get_center() + Vector2(500.0, 0.0) # daleko
	altar._physics_process(0.0)

	NemoraxTest.assert_eq(altar.state, altar.AltarState.READY, "gracz daleko od pedestału nie powinien rozpocząć aktywacji")

	_cleanup(altar, root)
	GameFlow.fragments_collected = original
