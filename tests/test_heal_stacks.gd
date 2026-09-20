extends RefCounted
## System stacków leczenia (player.gd) — 10 trafień = 1 stack, max 3 w banku,
## E zużywa jeden stack na naciśnięcie (nie cały bank naraz).

func _fresh_player(root: Node) -> Node:
	var player = load("res://entities/player.tscn").instantiate()
	root.add_child(player)
	return player

func _cleanup(player: Node, root: Node) -> void:
	root.remove_child(player)
	player.queue_free()

func test_ten_hits_gives_one_stack(root: Node) -> void:
	var player := _fresh_player(root)
	NemoraxTest.assert_eq(player.get_heal_stacks(), 0, "gracz zaczyna bez stacków")
	for i in range(9):
		player.register_hit_on_enemy()
	NemoraxTest.assert_eq(player.get_heal_stacks(), 0, "9 trafień to jeszcze nie pełny stack")
	player.register_hit_on_enemy() # 10.
	NemoraxTest.assert_eq(player.get_heal_stacks(), 1, "10. trafienie powinno dać pierwszy stack")
	NemoraxTest.assert_eq(player.get_heal_charge_hits(), 0, "licznik powinien się wyzerować po zdobyciu stacka")
	_cleanup(player, root)

func test_stacks_cap_at_three_and_hits_beyond_cap_do_nothing(root: Node) -> void:
	var player := _fresh_player(root)
	for i in range(40): # 4 pełne stacki warte trafień, ale limit to 3
		player.register_hit_on_enemy()
	NemoraxTest.assert_eq(player.get_heal_stacks(), 3, "bank nie powinien przekroczyć max_heal_stacks")
	_cleanup(player, root)

func test_heal_input_consumes_exactly_one_stack(root: Node) -> void:
	var player := _fresh_player(root)
	player.set_heal_stacks(3)
	player.max_health = 100.0
	player.health = 10.0

	Input.action_press("heal")
	player._handle_heal_input()
	Input.action_release("heal")

	NemoraxTest.assert_eq(player.get_heal_stacks(), 2, "jedno naciśnięcie E powinno zużyć dokładnie jeden stack")
	NemoraxTest.assert_almost_eq(player.health, 60.0, 0.01, "jeden stack powinien oddać 50% max zdrowia (10 + 50)")
	_cleanup(player, root)

func test_heal_charge_ratio_reflects_progress_to_next_stack(root: Node) -> void:
	var player := _fresh_player(root)
	NemoraxTest.assert_almost_eq(player.heal_charge_ratio(), 0.0, 0.01, "brak trafień = 0% postępu")
	for i in range(5):
		player.register_hit_on_enemy()
	NemoraxTest.assert_almost_eq(player.heal_charge_ratio(), 0.5, 0.01, "5/10 trafień = 50% postępu do kolejnego stacka")
	_cleanup(player, root)
