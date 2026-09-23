extends RefCounted
## Stacki leczenia (player.gd), wariant C z AUDYT_I_PLAN_ROZBUDOWY_GRY_DLA_CLAUDE.md:
## heal_hits_per_stack pierwotnych trafień = 1 stack, max_heal_stacks w banku,
## użycie trwa heal_channel_time, trafienie je przerywa, stack znika dopiero
## po udanym leczeniu. Testy czytają eksporty zamiast wpisanych liczb.

func _fresh_player(root: Node) -> Node:
	var player = load("res://entities/player.tscn").instantiate()
	root.add_child(player)
	return player

func _cleanup(player: Node, root: Node) -> void:
	root.remove_child(player)
	player.queue_free()

func _press_heal(player: Node) -> void:
	Input.action_press("heal")
	player._handle_heal_input()
	Input.action_release("heal")

func test_variant_c_values(root: Node) -> void:
	var player := _fresh_player(root)
	NemoraxTest.assert_eq(player.heal_hits_per_stack, 12, "wariant C: 12 pierwotnych trafień na stack")
	NemoraxTest.assert_eq(player.max_heal_stacks, 2, "wariant C: maks. 2 stacki")
	NemoraxTest.assert_almost_eq(player.heal_amount_fraction, 0.3, 0.001, "wariant C: 30% maks. HP")
	_cleanup(player, root)

func test_full_charge_gives_one_stack(root: Node) -> void:
	var player := _fresh_player(root)
	NemoraxTest.assert_eq(player.get_heal_stacks(), 0, "gracz zaczyna bez stacków")
	for i in range(player.heal_hits_per_stack - 1):
		player.register_hit_on_enemy()
	NemoraxTest.assert_eq(player.get_heal_stacks(), 0, "o jedno trafienie za mało to jeszcze nie stack")
	player.register_hit_on_enemy()
	NemoraxTest.assert_eq(player.get_heal_stacks(), 1, "pełne naładowanie daje pierwszy stack")
	NemoraxTest.assert_eq(player.get_heal_charge_hits(), 0, "licznik zeruje się po zdobyciu stacka")
	_cleanup(player, root)

func test_stacks_cap_and_hits_beyond_cap_do_nothing(root: Node) -> void:
	var player := _fresh_player(root)
	for i in range(player.heal_hits_per_stack * (player.max_heal_stacks + 2)):
		player.register_hit_on_enemy()
	NemoraxTest.assert_eq(player.get_heal_stacks(), player.max_heal_stacks, "bank nie przekracza max_heal_stacks")
	_cleanup(player, root)

func test_heal_is_a_channel_and_consumes_one_stack_on_completion(root: Node) -> void:
	var player := _fresh_player(root)
	player.set_heal_stacks(2)
	player.max_health = 100.0
	player.health = 10.0
	_press_heal(player)
	NemoraxTest.assert_true(player.is_heal_channeling(), "naciśnięcie rozpoczyna użycie, nie leczy od razu")
	NemoraxTest.assert_almost_eq(player.health, 10.0, 0.01, "przed końcem kanału HP bez zmian")
	NemoraxTest.assert_eq(player.get_heal_stacks(), 2, "stack nie znika w trakcie kanału")
	player._tick_heal_channel(player.heal_channel_time)
	NemoraxTest.assert_eq(player.get_heal_stacks(), 1, "udane leczenie zużywa dokładnie jeden stack")
	NemoraxTest.assert_almost_eq(player.health, 10.0 + 100.0 * player.heal_amount_fraction, 0.01, "stack oddaje heal_amount_fraction maks. HP")
	_cleanup(player, root)

func test_damage_interrupts_channel_without_losing_the_stack(root: Node) -> void:
	var player := _fresh_player(root)
	player.set_heal_stacks(1)
	player.max_health = 100.0
	player.health = 50.0
	_press_heal(player)
	player._tick_heal_channel(player.heal_channel_time * 0.5)
	player.take_damage(5.0)
	NemoraxTest.assert_true(not player.is_heal_channeling(), "trafienie przerywa leczenie")
	player._tick_heal_channel(player.heal_channel_time)
	NemoraxTest.assert_eq(player.get_heal_stacks(), 1, "przerwane leczenie nie zabiera stacka")
	NemoraxTest.assert_almost_eq(player.health, 45.0, 0.01, "przerwane leczenie nie leczy")
	_cleanup(player, root)

func test_summoned_minions_refund_mana_but_do_not_charge_heal(root: Node) -> void:
	var player := _fresh_player(root)
	var minion: Node2D = load("res://entities/random_enemies/chaser.tscn").instantiate()
	minion.set_meta("summoned", true)
	root.add_child(minion)
	player.mana = 0.0
	for i in range(player.heal_hits_per_stack * 3):
		player.on_hit_confirmed(minion, 5.0, "sword", 50.0, 1000 + i)
	NemoraxTest.assert_eq(player.get_heal_stacks(), 0, "przyzwańcy bez XP nie ładują leczenia")
	NemoraxTest.assert_eq(player.get_heal_charge_hits(), 0, "ani postępu do stacka")
	NemoraxTest.assert_true(player.mana > 0.0, "mana nadal wraca — mag musi móc walczyć z dodatkami")
	root.remove_child(minion)
	minion.queue_free()
	_cleanup(player, root)

func test_heal_charge_ratio_reflects_progress_to_next_stack(root: Node) -> void:
	var player := _fresh_player(root)
	NemoraxTest.assert_almost_eq(player.heal_charge_ratio(), 0.0, 0.01, "brak trafień = 0% postępu")
	for i in range(player.heal_hits_per_stack / 2):
		player.register_hit_on_enemy()
	NemoraxTest.assert_almost_eq(player.heal_charge_ratio(), 0.5, 0.01, "połowa trafień = 50% postępu")
	_cleanup(player, root)

func test_mana_has_combat_floor_and_regenerates_out_of_combat(root: Node) -> void:
	var player := _fresh_player(root)
	var enemy: Node2D = load("res://entities/random_enemies/chaser.tscn").instantiate()
	root.add_child(enemy)
	player.mana = 0.0
	player._combat_check_timer = 0.0
	player._tick_out_of_combat_mana(1.0)
	NemoraxTest.assert_almost_eq(player.mana, player.mana_combat_floor_regen, 0.001, "przy żywym wrogu mana rośnie tylko awaryjnie (Paczka 4)")
	player._tick_out_of_combat_mana(60.0)
	NemoraxTest.assert_almost_eq(player.mana, player._wand_mana_cost(), 0.001, "awaryjne dno many kończy się na koszcie jednego strzału")
	root.remove_child(enemy)
	enemy.queue_free()
	enemy.is_dead = true
	var before: float = player.mana
	player._combat_check_timer = 0.0
	player._tick_out_of_combat_mana(1.0)
	NemoraxTest.assert_almost_eq(player.mana, before + player.mana_out_of_combat_regen, 0.01, "po walce mana wraca powoli, także ponad koszt strzału")
	_cleanup(player, root)
