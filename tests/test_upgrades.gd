extends RefCounted
## 10 ulepszeń ze skrzyń (CLAUDE_CODE_GAME_CONTENT_BIBLE.md sekcja 8), player.gd.
## Pokrywa mechanikę rdzenia każdego ulepszenia — nie każdy skrajny przypadek z
## dokumentu (np. 1000-seedowa walidacja) — dopasowane do skali tego projektu.

func _fresh_player(root: Node) -> Player:
	var player: Player = load("res://entities/player.tscn").instantiate()
	root.add_child(player)
	return player

func _cleanup(player: Player, root: Node) -> void:
	root.remove_child(player)
	player.queue_free()

func test_acquire_upgrade_rejects_unknown_and_duplicate(root: Node) -> void:
	var player := _fresh_player(root)
	NemoraxTest.assert_true(not player.acquire_upgrade("nie_istnieje"), "nieznane ID nie powinno się przyjąć")
	NemoraxTest.assert_true(player.acquire_upgrade("iron_heart"), "pierwsze przyjęcie znanego ID powinno się udać")
	NemoraxTest.assert_true(not player.acquire_upgrade("iron_heart"), "drugie przyjęcie TEGO SAMEGO ID (nie-stackowalne) powinno się nie udać")
	NemoraxTest.assert_eq(player.owned_upgrades.size(), 1, "duplikat nie powinien trafić do owned_upgrades")
	_cleanup(player, root)

func test_blood_edge_arms_on_hit_and_boosts_next_attack_once(root: Node) -> void:
	var player := _fresh_player(root)
	player.acquire_upgrade("blood_edge")
	player.stamina = player.max_stamina
	var base_damage := player.attack_damage

	# Zamach BEZ uzbrojenia: zwykłe obrażenia, ale trafienie na końcu uzbraja kolejny.
	player._start_attack()
	NemoraxTest.assert_almost_eq(player._current_attack_damage, base_damage, 0.01, "pierwszy zamach nie powinien mieć jeszcze bonusu")
	player.on_hit_confirmed(player, base_damage) # cel jaki jest, na potrzeby testu wystarczy dowolny Node
	NemoraxTest.assert_true(player._blood_edge_armed, "trafienie powinno uzbroić Blood Edge")

	# Kolejny zamach: powinien dostać +20% i zużyć uzbrojenie.
	player._start_attack()
	NemoraxTest.assert_almost_eq(player._current_attack_damage, base_damage * 1.20, 0.01, "uzbrojony zamach powinien dostać +20% obrażeń")
	NemoraxTest.assert_true(not player._blood_edge_armed, "uzbrojenie powinno się zużyć po jednym zamachu")

	# Trzeci zamach (bez nowego trafienia): z powrotem bazowe obrażenia.
	player._start_attack()
	NemoraxTest.assert_almost_eq(player._current_attack_damage, base_damage, 0.01, "bonus nie powinien się utrzymać na kolejny zamach bez nowego trafienia")
	_cleanup(player, root)

func test_void_step_grants_speed_and_range_after_dash(root: Node) -> void:
	var player := _fresh_player(root)
	player.acquire_upgrade("void_step")
	NemoraxTest.assert_almost_eq(player._upgrade_speed_multiplier(), 1.0, 0.001, "bez zakończonego dasha brak bonusu prędkości")

	player.state = Player.State.DASHING
	player._dash_timer = 0.0
	player._process_dash(0.0) # symuluje koniec dasha (identyczna ścieżka co w _physics_process)

	NemoraxTest.assert_almost_eq(player._upgrade_speed_multiplier(), 1.15, 0.001, "koniec dasha powinien dać +15% prędkości")
	player._start_attack()
	NemoraxTest.assert_almost_eq(player._current_attack_range, player.attack_range * 1.20, 0.01, "koniec dasha powinien naładować +20% zasięgu na najbliższy zamach")
	_cleanup(player, root)

func test_void_step_range_charge_is_single_use(root: Node) -> void:
	var player := _fresh_player(root)
	player.acquire_upgrade("void_step")
	player.state = Player.State.DASHING
	player._dash_timer = 0.0
	player._process_dash(0.0)

	player._start_attack() # zużywa ładunek zasięgu
	player._start_attack() # drugi zamach: już bez ładunku
	NemoraxTest.assert_almost_eq(player._current_attack_range, player.attack_range, 0.01, "ładunek zasięgu Void Step to JEDNO użycie, nie trwały bonus")
	_cleanup(player, root)

func test_soul_echo_procs_on_kill_and_boosts_damage(root: Node) -> void:
	var player := _fresh_player(root)
	player.acquire_upgrade("soul_echo")
	player.soul_echo_proc_chance = 1.0 # deterministyczny test — patrz komentarz w player.gd o randf()
	var base_damage := player.attack_damage

	player.gain_xp() # traktowane jak zabójstwo (patrz komentarz w gain_xp())
	player._start_attack()
	NemoraxTest.assert_almost_eq(player._current_attack_damage, base_damage * 1.15, 0.01, "proc Soul Echo powinien dać +15% obrażeń")
	_cleanup(player, root)

func test_iron_heart_increases_max_health_and_heals_by_delta_not_full(root: Node) -> void:
	var player := _fresh_player(root)
	var old_max := player.max_health
	player.health = old_max * 0.5 # w połowie zdrowia przed zdobyciem

	player.acquire_upgrade("iron_heart")

	var expected_max := old_max * 1.20
	NemoraxTest.assert_almost_eq(player.max_health, expected_max, 0.01, "Iron Heart powinien dać +20% max zdrowia")
	NemoraxTest.assert_almost_eq(player.health, old_max * 0.5 + (expected_max - old_max), 0.01, "powinna dojść RÓŻNICA max zdrowia, nie pełne wyleczenie")
	_cleanup(player, root)

func test_iron_heart_reduces_received_knockback(root: Node) -> void:
	var player := _fresh_player(root)
	player.acquire_upgrade("iron_heart")
	player.apply_knockback(Vector2(100.0, 0.0))
	NemoraxTest.assert_almost_eq(player.velocity.x, 75.0, 0.01, "Iron Heart powinien zredukować odepchnięcie o 25%")
	_cleanup(player, root)

func test_razor_wind_increases_attack_range(root: Node) -> void:
	var player := _fresh_player(root)
	var old_range := player.attack_range
	player.acquire_upgrade("razor_wind")
	NemoraxTest.assert_almost_eq(player.attack_range, old_range * 1.18, 0.01, "Razor Wind powinien dać +18% zasięgu ataku")
	_cleanup(player, root)

func test_hunters_mark_no_bonus_on_first_hit_bonus_on_second(root: Node) -> void:
	var player := _fresh_player(root)
	player.acquire_upgrade("hunters_mark")
	var target := Node.new()
	root.add_child(target)

	var first := player.resolve_hit_damage(target, 10.0)
	NemoraxTest.assert_almost_eq(first, 10.0, 0.01, "trafienie zakładające znak nie powinno dostać własnego bonusu")
	var second := player.resolve_hit_damage(target, 10.0)
	NemoraxTest.assert_almost_eq(second, 11.2, 0.01, "drugie trafienie OZNACZONEGO celu powinno dostać +12%")

	root.remove_child(target)
	target.queue_free()
	_cleanup(player, root)

func test_hunters_mark_does_not_move_to_new_target_while_active(root: Node) -> void:
	var player := _fresh_player(root)
	player.acquire_upgrade("hunters_mark")
	var target_a := Node.new()
	var target_b := Node.new()
	root.add_child(target_a)
	root.add_child(target_b)

	player.resolve_hit_damage(target_a, 10.0) # zakłada znak na A
	var hit_on_b := player.resolve_hit_damage(target_b, 10.0) # znak na A wciąż aktywny -> B bez bonusu, znak się NIE przenosi
	NemoraxTest.assert_almost_eq(hit_on_b, 10.0, 0.01, "trafienie innego celu przy aktywnym znaku nie powinno dostać bonusu ani przenieść znaku")
	var second_hit_on_a := player.resolve_hit_damage(target_a, 10.0)
	NemoraxTest.assert_almost_eq(second_hit_on_a, 11.2, 0.01, "znak powinien zostać na oryginalnym celu")

	root.remove_child(target_a)
	root.remove_child(target_b)
	target_a.queue_free()
	target_b.queue_free()
	_cleanup(player, root)

func test_second_impact_fires_delayed_hit_at_reduced_damage(root: Node) -> void:
	var player := _fresh_player(root)
	player.acquire_upgrade("second_impact")
	var incarnation: Incarnation = load("res://entities/incarnations/zalazek.tscn").instantiate()
	root.add_child(incarnation)
	incarnation.player = player
	incarnation.arena_rect = Rect2(0, 0, 1000, 1000)
	var health_before := incarnation.health

	# _maybe_schedule_second_impact() zostawia timer (get_tree().create_timer),
	# który w tym runnerze nigdy nie odpali synchronicznie (patrz test_input_buffer.gd
	# — żaden test nigdy nie przechodzi przez realną klatkę) — testujemy więc
	# bezpośrednio _fire_second_impact(), pomijając samo opóźnienie czasowe.
	player._fire_second_impact(incarnation, 5.0, incarnation.global_position)
	NemoraxTest.assert_almost_eq(incarnation.health, health_before - 5.0, 0.01, "drugie trafienie powinno zadać dokładnie przekazane obrażenia")

	root.remove_child(incarnation)
	incarnation.queue_free()
	_cleanup(player, root)

func test_second_impact_skips_already_dead_target(root: Node) -> void:
	var player := _fresh_player(root)
	player.acquire_upgrade("second_impact")
	var incarnation: Incarnation = load("res://entities/incarnations/zalazek.tscn").instantiate()
	root.add_child(incarnation)
	incarnation.player = player
	incarnation.arena_rect = Rect2(0, 0, 1000, 1000)
	incarnation.is_dead = true
	var health_before := incarnation.health

	player._fire_second_impact(incarnation, 5.0, incarnation.global_position)
	NemoraxTest.assert_almost_eq(incarnation.health, health_before, 0.01, "martwy cel nie powinien dostać drugiego trafienia")

	root.remove_child(incarnation)
	incarnation.queue_free()
	_cleanup(player, root)

func test_momentum_stacks_over_time_and_resets_on_damage(root: Node) -> void:
	var player := _fresh_player(root)
	player.acquire_upgrade("momentum")
	NemoraxTest.assert_almost_eq(player._upgrade_speed_multiplier(), 1.0, 0.001, "brak stacków na start")

	for i in range(3):
		player._tick_upgrade_timers(player.momentum_stack_interval)
	NemoraxTest.assert_eq(player._momentum_stacks, 3, "3 pełne interwały powinny dać 3 stacki")
	NemoraxTest.assert_almost_eq(player._upgrade_speed_multiplier(), 1.06, 0.001, "3 stacki * 2% = +6% prędkości")

	player.take_damage(5.0)
	NemoraxTest.assert_eq(player._momentum_stacks, 0, "prawdziwe obrażenia powinny zresetować stacki Momentum")
	_cleanup(player, root)

func test_last_resolve_activates_below_threshold_with_hysteresis(root: Node) -> void:
	var player := _fresh_player(root)
	player.acquire_upgrade("last_resolve")
	player.health = player.max_health * 0.5
	player._tick_upgrade_timers(0.0)
	NemoraxTest.assert_true(not player._last_resolve_active, "powyżej progu nie powinien być aktywny")

	player.health = player.max_health * 0.25
	player._tick_upgrade_timers(0.0)
	NemoraxTest.assert_true(player._last_resolve_active, "przy <= 30% max HP powinien się aktywować")

	player.health = player.max_health * 0.32 # między progiem (30%) a histerezą (35%)
	player._tick_upgrade_timers(0.0)
	NemoraxTest.assert_true(player._last_resolve_active, "powinien zostać aktywny w strefie histerezy")

	player.health = player.max_health * 0.40
	player._tick_upgrade_timers(0.0)
	NemoraxTest.assert_true(not player._last_resolve_active, "powyżej progu histerezy powinien się dezaktywować")
	_cleanup(player, root)

func test_soul_bond_applies_effect_and_new_soul_replaces_previous(root: Node) -> void:
	var player := _fresh_player(root)
	player.acquire_upgrade("soul_bond")

	player.activate_soul_bond(0) # Motion: +12% ruchu
	NemoraxTest.assert_almost_eq(player._upgrade_speed_multiplier(), 1.12, 0.001, "chapter 0 (Motion) powinien dać +12% ruchu")

	player.activate_soul_bond(4) # Ruin: +15% obrażeń — powinien NADPISAĆ Motion, nie się zsumować
	NemoraxTest.assert_almost_eq(player._upgrade_speed_multiplier(), 1.0, 0.001, "nowa dusza powinna zastąpić poprzedni bonus, nie dodać się do niego")
	player._start_attack()
	NemoraxTest.assert_almost_eq(player._current_attack_damage, player.attack_damage * 1.15, 0.01, "chapter 4 (Ruin) powinien dać +15% obrażeń")
	_cleanup(player, root)

func test_soul_bond_without_upgrade_does_nothing(root: Node) -> void:
	var player := _fresh_player(root)
	player.activate_soul_bond(0)
	NemoraxTest.assert_almost_eq(player._soul_bond_timer, 0.0, 0.001, "bez posiadania Soul Bond aktywacja nie powinna nic zrobić")
	_cleanup(player, root)
