extends RefCounted
## Cykl chodu (PLAN_ANIMACJE_KIERUNKOWE.md, Faza 1b) — tempo stawiania kroków
## rośnie z prędkością, faza zamraża się (nie resetuje do zera) po zatrzymaniu.

func _fresh_player(root: Node) -> Player:
	var player: Player = load("res://entities/player.tscn").instantiate()
	root.add_child(player)
	return player

func _cleanup(player: Player, root: Node) -> void:
	root.remove_child(player)
	player.queue_free()

func test_walk_cycle_does_not_advance_while_standing_still(root: Node) -> void:
	var player := _fresh_player(root)
	player.velocity = Vector2.ZERO
	player._update_walk_cycle(1.0)
	NemoraxTest.assert_almost_eq(player._walk_cycle_phase, 0.0, 0.001, "stanie w miejscu nie powinno ruszać fazy cyklu")
	_cleanup(player, root)

func test_walk_cycle_advances_faster_at_higher_speed(root: Node) -> void:
	var player := _fresh_player(root)
	player.velocity = Vector2(player.max_speed, 0.0) # pełna prędkość
	player._update_walk_cycle(1.0)
	var phase_full_speed := player._walk_cycle_phase

	player._walk_cycle_phase = 0.0
	player.velocity = Vector2(player.max_speed * 0.5, 0.0) # połowa prędkości
	player._update_walk_cycle(1.0)
	var phase_half_speed := player._walk_cycle_phase

	NemoraxTest.assert_true(phase_full_speed > phase_half_speed, "pełna prędkość powinna dawać szybszy cykl niż połowa prędkości")
	NemoraxTest.assert_almost_eq(phase_full_speed, player.walk_cycle_speed, 0.001, "przy pełnej prędkości faza rośnie w tempie walk_cycle_speed/s")
	_cleanup(player, root)

func test_walk_cycle_freezes_frame_instead_of_resetting_on_stop(root: Node) -> void:
	var player := _fresh_player(root)
	player.velocity = Vector2(player.max_speed, 0.0)
	player._update_walk_cycle(1.0) # rusza fazę
	var phase_while_moving := player._walk_cycle_phase

	player.velocity = Vector2.ZERO
	player._update_walk_cycle(1.0) # stoi
	NemoraxTest.assert_almost_eq(player._walk_cycle_phase, phase_while_moving, 0.001, "zatrzymanie powinno zamrozić fazę, nie zresetować do zera")
	_cleanup(player, root)

func test_walk_cycle_frame_alternates_between_zero_and_one(root: Node) -> void:
	var player := _fresh_player(root)
	player._walk_cycle_phase = 0.5
	NemoraxTest.assert_eq(player._walk_cycle_frame(), 0, "faza < 1 powinna dać klatkę 0")
	player._walk_cycle_phase = 1.5
	NemoraxTest.assert_eq(player._walk_cycle_frame(), 1, "faza w [1,2) powinna dać klatkę 1")
	player._walk_cycle_phase = 2.5
	NemoraxTest.assert_eq(player._walk_cycle_frame(), 0, "faza w [2,3) powinna wrócić do klatki 0")
	_cleanup(player, root)

func test_incarnation_walk_cycle_only_advances_while_drifting(root: Node) -> void:
	var incarnation: Incarnation = load("res://entities/incarnations/zalazek.tscn").instantiate()
	var player := _fresh_player(root)
	root.add_child(incarnation)
	incarnation.player = player
	incarnation.arena_rect = Rect2(0, 0, 1000, 1000)
	incarnation.global_position = Vector2(500, 500)
	player.global_position = Vector2(700, 500) # daleko, więc _drift_towards_player faktycznie rusza

	incarnation._physics_process(1.0) # gałąź "else" -> dryfowanie, powinno ruszyć fazę
	NemoraxTest.assert_true(incarnation._walk_cycle_phase > 0.0, "dryfowanie w stronę gracza powinno ruszyć fazę cyklu chodu")

	incarnation._lunge_active = true
	var phase_before_lunge := incarnation._walk_cycle_phase
	incarnation._physics_process(1.0) # gałąź "_lunge_active" -> BEZ dryfowania
	NemoraxTest.assert_almost_eq(incarnation._walk_cycle_phase, phase_before_lunge, 0.001, "wypad nie powinien ruszać fazy chodu")

	root.remove_child(incarnation)
	incarnation.queue_free()
	_cleanup(player, root)
