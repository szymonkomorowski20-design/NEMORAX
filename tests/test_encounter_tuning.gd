extends RefCounted
## Paczka 4 (AUDYT): pule HP wcieleń i Nemoraksa po strojeniu według
## debug/measure_*.gd (wyniki w POMIARY_WALKI.md). Te testy pilnują, żeby
## zmiana gdzie indziej nie cofnęła po cichu długości walk do 2-4 s.

func _soul_room_with_progress(root: Node, rooms_cleared: int) -> Node:
	var previous := GameFlow.rooms_cleared_count
	GameFlow.rooms_cleared_count = rooms_cleared
	var room = load("res://rooms/room.tscn").instantiate()
	root.add_child(room)
	room._spawn_enemy(GameFlow.INCARNATION_SCENES[0], false)
	GameFlow.rooms_cleared_count = previous
	return room

func _cleanup(room: Node, root: Node) -> void:
	root.remove_child(room)
	room.queue_free()

func test_soul_incarnation_starts_from_tuned_base(root: Node) -> void:
	var room := _soul_room_with_progress(root, 0)
	NemoraxTest.assert_almost_eq(room.incarnation.max_health, room.SOUL_BASE_HEALTH, 0.01, "wcielenie na starcie trasy ma bazowe HP pokoju z duszą")
	NemoraxTest.assert_almost_eq(room.incarnation.health, room.incarnation.max_health, 0.01, "i zaczyna z pełnym HP")
	_cleanup(room, root)

func test_soul_incarnation_scales_with_progress_up_to_cap(root: Node) -> void:
	var room := _soul_room_with_progress(root, 10)
	NemoraxTest.assert_almost_eq(room.incarnation.max_health, room.SOUL_BASE_HEALTH * 1.45, 0.01, "10 pokoi = +45% HP, ta sama krzywa co zwykli wrogowie")
	_cleanup(room, root)
	room = _soul_room_with_progress(root, 60)
	NemoraxTest.assert_almost_eq(room.incarnation.max_health, room.SOUL_BASE_HEALTH * 2.10, 0.01, "skalowanie ma sufit 2,1x")
	_cleanup(room, root)

func test_nemorax_total_pool_is_tuned(root: Node) -> void:
	var boss: Boss = load("res://entities/boss.tscn").instantiate()
	var total := boss.final_health
	for m in Boss.PHASE_HP_MULTIPLIERS:
		total += roundf(boss.phase_max_health * m)
	NemoraxTest.assert_true(total >= 2800.0 and total <= 3500.0, "łączna pula Nemoraksa po Paczce 4 ~3100 HP (jest %.0f)" % total)
	boss.free()

## --- Postawa (prototyp E1, tylko Nekravor) ---

func _nekravor(root: Node) -> Incarnation:
	var enemy: Incarnation = load(GameFlow.INCARNATION_SCENES[3]).instantiate()
	root.add_child(enemy)
	return enemy

func test_stance_prototype_only_on_nekravor(root: Node) -> void:
	for i in GameFlow.INCARNATION_SCENES.size():
		var enemy: Incarnation = load(GameFlow.INCARNATION_SCENES[i]).instantiate()
		NemoraxTest.assert_eq(enemy.stance_enabled, i == 3, "postawa tylko u jednego wcielenia (pilotaż), rozdział %d" % i)
		enemy.free()

func test_primary_hits_break_stance_then_immunity_blocks_stun_lock(root: Node) -> void:
	var enemy := _nekravor(root)
	var threshold := enemy.stance_threshold()
	enemy.add_stance_damage(threshold * 0.6)
	NemoraxTest.assert_true(not enemy.is_stance_broken(), "za mało, by przełamać")
	enemy.add_stance_damage(threshold * 0.5)
	NemoraxTest.assert_true(enemy.is_stance_broken(), "próg przekroczony = odsłonięcie")
	NemoraxTest.assert_true(enemy.stance_threshold() > threshold, "kolejne przełamanie wymaga więcej")
	enemy._tick_stance(enemy.stance_break_duration + 0.01)
	NemoraxTest.assert_true(not enemy.is_stance_broken(), "odsłonięcie jest krótkie")
	enemy.add_stance_damage(enemy.stance_threshold() * 5.0)
	NemoraxTest.assert_true(not enemy.is_stance_broken(), "odporność po odsłonięciu = brak stun-locka")
	NemoraxTest.assert_almost_eq(enemy.stance, 0.0, 0.01, "w odporności postawa nie rośnie")
	_cleanup(enemy, root)

func test_broken_stance_stops_attacks(root: Node) -> void:
	var enemy := _nekravor(root)
	enemy._break_stance()
	NemoraxTest.assert_true(not enemy._damage_pulse(9999.0, 50.0), "w odsłonięciu wcielenie nie rani pulsem")
	enemy._lunge_toward_player(400.0, 0.3)
	NemoraxTest.assert_true(not enemy._lunge_active, "ani nie wykonuje wypadu")
	_cleanup(enemy, root)

func test_stance_decays_without_pressure(root: Node) -> void:
	var enemy := _nekravor(root)
	enemy.add_stance_damage(enemy.stance_threshold() * 0.5)
	enemy._tick_stance(enemy.stance_decay_delay + 0.01)
	var after_delay := enemy.stance
	enemy._tick_stance(1.0)
	NemoraxTest.assert_true(enemy.stance < after_delay, "bez trafień postawa wraca do równowagi")
	_cleanup(enemy, root)

func test_counter_hit_after_block_hits_stance_twice_as_hard(root: Node) -> void:
	var enemy := _nekravor(root)
	var player: Player = load("res://entities/player.tscn").instantiate()
	root.add_child(player)
	player.on_hit_confirmed(enemy, 10.0, "sword", enemy.health, 900)
	NemoraxTest.assert_almost_eq(enemy.stance, 10.0, 0.01, "zwykły cios pierwotny = postawa równa obrażeniom")
	player._counter_timer = 1.0
	player.resolve_hit_damage(enemy, 10.0)
	player.on_hit_confirmed(enemy, 10.0, "sword", enemy.health, 901)
	NemoraxTest.assert_almost_eq(enemy.stance, 30.0, 0.01, "cios z okna kontry liczy się podwójnie")
	player.apply_skill_bonus(enemy, 10.0, 901, 10.0, "twin_cut")
	NemoraxTest.assert_almost_eq(enemy.stance, 30.0, 0.01, "efekty wtórne nie nabijają postawy")
	_cleanup(player, root)
	_cleanup(enemy, root)

## A10: każda faza finału ma własne wzorce (nie tylko barwę) — zestawy nazw
## są rozłączne, a każda faza ma ich co najmniej trzy.
func test_finale_phases_have_distinct_threats(root: Node) -> void:
	var boss: Boss = load("res://entities/boss.tscn").instantiate()
	root.add_child(boss)
	var seen := {}
	for phase in 6:
		var groups: Array[Dictionary] = boss._build_pattern_groups(phase)
		NemoraxTest.assert_true(groups.size() >= 3, "faza %d ma co najmniej 3 wzorce" % phase)
		for g in groups:
			NemoraxTest.assert_true(not seen.has(g["name"]), "wzorzec %s powtarza się w fazie %d" % [g["name"], phase])
			seen[g["name"]] = phase
	root.remove_child(boss)
	boss.queue_free()
