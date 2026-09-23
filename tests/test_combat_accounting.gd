extends RefCounted
## Paczka 2: tylko skuteczne, pierwotne trafienia karmią zasoby gracza,
## a diagnostyka liczy rzeczywistą utratę HP (także przy zmianie fazy).

class DummyTarget extends Node2D:
	var health: float = 20.0
	var is_dead: bool = false
	func take_damage(amount: float) -> void:
		health = maxf(0.0, health - amount)
		is_dead = health <= 0.0

func test_damage_log_uses_actual_hp_loss_and_source(root: Node) -> void:
	Juice.reset_damage_metrics()
	var target := DummyTarget.new()
	root.add_child(target)
	var dealt: float = Juice.apply_hit(target, 50.0, 0.0, false, "sword_primary", false)
	NemoraxTest.assert_almost_eq(dealt, 20.0, 0.001, "dobicie nie liczy 50 obrażeń z 20 HP")
	NemoraxTest.assert_almost_eq(float(Juice.damage_totals_snapshot().get("sword_primary", 0.0)), 20.0, 0.001,
		"sumy źródeł pokazują rzeczywistą utratę HP")
	NemoraxTest.assert_eq(Juice.damage_events.back()["source"], "sword_primary", "zdarzenie ma nazwę źródła")
	NemoraxTest.assert_almost_eq(Juice.apply_hit(target, 10.0, 0.0, false, "sword_primary", false), 0.0, 0.001,
		"martwy cel nie daje nowych obrażeń")
	root.remove_child(target)
	target.queue_free()
	Juice.reset_damage_metrics()

func test_same_attack_counts_only_one_primary_hit_per_target(root: Node) -> void:
	var player: Player = load("res://entities/player.tscn").instantiate()
	root.add_child(player)
	var target := DummyTarget.new()
	root.add_child(target)
	player.mana = 0.0
	player.on_hit_confirmed(target, 5.0, "wand", 20.0, 77)
	player.on_hit_confirmed(target, 5.0, "wand", 15.0, 77)
	NemoraxTest.assert_almost_eq(player.mana, player.mana_regen_per_hit, 0.001,
		"kilka pocisków jednej salwy nie zwraca many wielokrotnie")
	NemoraxTest.assert_eq(player.get_heal_charge_hits(), 1,
		"kilka pocisków jednej salwy nie ładuje leczenia wielokrotnie")
	player.on_hit_confirmed(target, 5.0, "wand", 10.0, 78)
	NemoraxTest.assert_eq(player.get_heal_charge_hits(), 2, "nowy atak może znowu naliczyć trafienie")
	root.remove_child(target)
	target.queue_free()
	root.remove_child(player)
	player.queue_free()

func test_invulnerable_boss_gives_no_damage_mana_or_heal(root: Node) -> void:
	Juice.reset_damage_metrics()
	var player: Player = load("res://entities/player.tscn").instantiate()
	root.add_child(player)
	player.mana = 0.0
	var boss: Boss = load("res://entities/boss.tscn").instantiate()
	root.add_child(boss)
	boss._invulnerable = true
	var bolt: Node2D = load("res://entities/projectile.tscn").instantiate()
	bolt.shooter = player
	bolt.attack_id = 91
	bolt.damage = 30.0
	bolt.global_position = boss.global_position
	root.add_child(bolt)
	bolt._check_hit()
	NemoraxTest.assert_almost_eq(player.mana, 0.0, 0.001, "faza nietykalna nie oddaje many")
	NemoraxTest.assert_eq(player.get_heal_charge_hits(), 0, "faza nietykalna nie ładuje leczenia")
	NemoraxTest.assert_true(Juice.damage_totals_snapshot().is_empty(), "odrzucony pocisk nie jest DPS")
	root.remove_child(bolt)
	bolt.queue_free()
	root.remove_child(boss)
	boss.queue_free()
	root.remove_child(player)
	player.queue_free()
	Juice.reset_damage_metrics()

func test_split_volley_hits_large_boss_but_rewards_one_primary_hit(root: Node) -> void:
	var previous_reduce_flashing := Palette.reduce_flashing
	Palette.reduce_flashing = true
	Juice.reset_damage_metrics()
	var player: Player = load("res://entities/player.tscn").instantiate()
	root.add_child(player)
	player.skill_ranks["wand_split_bolt"] = 1
	player.mana = 0.0
	var boss: Boss = load("res://entities/boss.tscn").instantiate()
	root.add_child(boss)
	var health_before := boss.health
	for i in range(2):
		var bolt: Node2D = load("res://entities/projectile.tscn").instantiate()
		bolt.shooter = player
		bolt.damage = 8.0
		bolt.volley_id = 41
		bolt.volley_base_damage = 8.0
		bolt.attack_id = 41
		bolt.global_position = boss.global_position
		root.add_child(bolt)
		bolt._check_hit()
		root.remove_child(bolt)
		bolt.queue_free()
	NemoraxTest.assert_almost_eq(boss.health, health_before - 14.4, 0.01,
		"dwa pociski z jednej salwy zadają obrażenia, ale przestrzegają limitu 1,8x")
	NemoraxTest.assert_almost_eq(player.mana, player.mana_regen_per_hit, 0.01,
		"duży hitbox nie daje podwójnego zwrotu many z jednej salwy")
	NemoraxTest.assert_eq(player.get_heal_charge_hits(), 1,
		"duży hitbox nie nabija dwóch trafień leczenia z jednej salwy")
	NemoraxTest.assert_almost_eq(float(Juice.damage_totals_snapshot().get("wand_primary", 0.0)), 14.4, 0.01,
		"diagnostyka liczy oba rzeczywiste trafienia, niezależnie od jednego zwrotu zasobów")
	root.remove_child(boss)
	boss.queue_free()
	root.remove_child(player)
	player.queue_free()
	Juice.reset_damage_metrics()
	Palette.reduce_flashing = previous_reduce_flashing

func test_phase_transition_logs_only_hp_left_in_old_phase(root: Node) -> void:
	Juice.reset_damage_metrics()
	var boss: Boss = load("res://entities/boss.tscn").instantiate()
	root.add_child(boss)
	boss.health = 5.0
	var dealt: float = Juice.apply_hit(boss, 30.0, 0.0, false, "sword_primary", false)
	NemoraxTest.assert_almost_eq(dealt, 5.0, 0.001, "przejście fazy nie liczy nadmiaru z 30 obrażeń")
	NemoraxTest.assert_eq(boss.phase_index, 1, "boss przeszedł do kolejnej fazy")
	NemoraxTest.assert_almost_eq(float(Juice.damage_totals_snapshot().get("sword_primary", 0.0)), 5.0, 0.001,
		"raport DPS nie myli nowej puli HP ze starą")
	NemoraxTest.assert_eq(Juice.damage_events.back()["phase"], 0, "zdarzenie należy do fazy przed przejściem")
	root.remove_child(boss)
	boss.queue_free()
	Juice.reset_damage_metrics()

## A6 / Paczka 2: podwójny i trzeci cios na dużym hitboksie bossa to efekty
## wtórne — obrażenia liczone osobno, ale bez drugiego trafienia pierwotnego
## (mana, leczenie) i bez kaskady proców.
func test_twin_and_third_cut_on_boss_are_secondary_without_cascade(root: Node) -> void:
	var previous_reduce_flashing := Palette.reduce_flashing
	Palette.reduce_flashing = true
	Juice.reset_damage_metrics()
	var player: Player = load("res://entities/player.tscn").instantiate()
	root.add_child(player)
	player.skill_ranks["blade_sunder"] = 2
	player.mana = 0.0
	var boss: Boss = load("res://entities/boss.tscn").instantiate()
	root.add_child(boss)
	var dealt: float = Juice.apply_hit(boss, 10.0, 0.0, false, "sword_primary", false)
	player.on_hit_confirmed(boss, dealt, "sword", boss.health + dealt, 501)
	# Rangi dopiero teraz: inaczej on_hit_confirmed zaplanowałby prawdziwe cięcie
	# timerem, które odpaliłoby po usunięciu gracza z drzewa.
	player.skill_ranks["blade_twin_cut"] = 2
	player._fire_twin_cut(boss, dealt, player.global_position, 501)
	player.skill_ranks["blade_third_cut"] = 1
	player._fire_third_cut(boss, dealt, player.global_position, 501)
	var totals := Juice.damage_totals_snapshot()
	NemoraxTest.assert_almost_eq(float(totals.get("twin_cut", 0.0)), 7.0, 0.01, "podwójny cios rangi 2 = 70% pierwszego")
	# 35% pierwszego = 3,5, ale limit Paczki 4: wszystkie bonusy <= sam cios (10 - 7 = 3).
	NemoraxTest.assert_almost_eq(float(totals.get("third_cut", 0.0)), 3.0, 0.01, "trzeci cios przycięty limitem: bonusy razem nie przekraczają ciosu")
	NemoraxTest.assert_eq(player.get_heal_charge_hits(), 1, "trzy cięcia jednego ataku = jedno trafienie pierwotne dla leczenia")
	NemoraxTest.assert_almost_eq(player.mana, player.mana_regen_per_hit, 0.01, "i jeden zwrot many")
	NemoraxTest.assert_true(not totals.has("sunder"), "cięcia wtórne nie nabijają licznika Łamacza pancerza (brak kaskady)")
	root.remove_child(boss)
	boss.queue_free()
	root.remove_child(player)
	player.queue_free()
	Juice.reset_damage_metrics()
	Palette.reduce_flashing = previous_reduce_flashing
