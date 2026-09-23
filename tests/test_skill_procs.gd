extends RefCounted

class DummyEnemy extends Node2D:
	var health: float = 1000.0
	var is_dead: bool = false
	var radius: float = 20.0
	func take_damage(amount: float) -> void:
		health -= amount
		is_dead = health <= 0.0
	func flash_white() -> void:
		pass

func _fresh_player(root: Node) -> Player:
	var player: Player = load("res://entities/player.tscn").instantiate()
	root.add_child(player)
	return player

func _enemy(root: Node, pos: Vector2) -> DummyEnemy:
	var target := DummyEnemy.new()
	target.global_position = pos
	root.add_child(target)
	target.add_to_group("hittable")
	return target

func _finish(player: Player, enemies: Array, root: Node) -> void:
	for enemy in enemies:
		root.remove_child(enemy)
		enemy.queue_free()
	root.remove_child(player)
	player.queue_free()

func test_bleed_ticks_without_generating_extra_heal_charge(root: Node) -> void:
	Juice.reset_damage_metrics()
	var player := _fresh_player(root)
	var target := _enemy(root, Vector2(100, 100))
	player.skill_ranks["blade_bleed"] = 1
	player._skill_procs.on_primary_hit(target, 100.0, "sword", 1000.0, 1)
	var charges := player.get_heal_charge_hits()
	player._skill_procs._tick_bleeds(1.0)
	NemoraxTest.assert_almost_eq(target.health, 988.0, 0.01, "krwawienie rangi 1 zadaje 12% obrażeń na sekundę")
	NemoraxTest.assert_eq(player.get_heal_charge_hits(), charges, "DoT nie nabija leczenia")
	NemoraxTest.assert_almost_eq(float(Juice.damage_totals_snapshot().get("bleed", 0.0)), 12.0, 0.01,
		"krwawienie jest liczone osobno od pierwotnego ciosu")
	_finish(player, [target], root)
	Juice.reset_damage_metrics()

func test_sunder_procs_on_fourth_primary_hit(root: Node) -> void:
	var old_reduce := Palette.reduce_flashing
	Palette.reduce_flashing = true
	var player := _fresh_player(root)
	var target := _enemy(root, Vector2(100, 100))
	player.skill_ranks["blade_sunder"] = 1
	for i in range(3):
		player._skill_procs.on_primary_hit(target, 100.0, "sword", 1000.0, i + 1)
	NemoraxTest.assert_almost_eq(target.health, 1000.0, 0.01, "pierwsze trzy trafienia nie dają premii Łamacza")
	player._skill_procs.on_primary_hit(target, 100.0, "sword", 1000.0, 4)
	NemoraxTest.assert_almost_eq(target.health, 925.0, 0.01, "czwarte trafienie dodaje 75%")
	_finish(player, [target], root)
	Palette.reduce_flashing = old_reduce

func test_wave_on_every_third_swing_and_rhythm_after_three_hits(root: Node) -> void:
	var old_reduce := Palette.reduce_flashing
	Palette.reduce_flashing = true
	var player := _fresh_player(root)
	player.global_position = Vector2(100, 100)
	var target := _enemy(root, Vector2(200, 100))
	player.skill_ranks["blade_wave"] = 1
	player.skill_ranks["guard_battle_rhythm"] = 1
	player._skill_procs.on_sword_active(Vector2.RIGHT, 100.0, 1)
	player._skill_procs.on_sword_active(Vector2.RIGHT, 100.0, 2)
	NemoraxTest.assert_almost_eq(target.health, 1000.0, 0.01, "dwa zamachy jeszcze bez fali")
	player._skill_procs.on_sword_active(Vector2.RIGHT, 100.0, 3)
	NemoraxTest.assert_almost_eq(target.health, 950.0, 0.01, "trzeci zamach emituje falę za 50%")
	for i in range(3):
		player._skill_procs.on_primary_hit(target, 10.0, "sword", 950.0, i + 4)
	NemoraxTest.assert_almost_eq(player._attack_speed_multiplier(), 1.12, 0.01, "po 3 trafieniach tempo +12%")
	player._skill_procs.on_damage_taken()
	NemoraxTest.assert_almost_eq(player._attack_speed_multiplier(), 1.0, 0.01, "otrzymany cios zrywa rytm")
	_finish(player, [target], root)
	Palette.reduce_flashing = old_reduce

func test_weapon_weave_boosts_only_opposite_weapon(root: Node) -> void:
	var player := _fresh_player(root)
	var target := _enemy(root, Vector2(100, 100))
	player.skill_ranks["guard_weapon_weave"] = 1
	player._skill_procs.on_primary_hit(target, 10.0, "sword", 1000.0, 1)
	player._swing_weapon = "wand"
	NemoraxTest.assert_almost_eq(player._compute_attack_start_damage(), player.wand_damage * 1.15, 0.01, "trafienie mieczem wzmacnia różdżkę")
	NemoraxTest.assert_almost_eq(player._compute_attack_start_damage(), player.wand_damage, 0.01, "premia zużywa się raz")
	_finish(player, [target], root)

func test_bonus_damage_is_capped_per_attack_target(root: Node) -> void:
	var old_reduce := Palette.reduce_flashing
	Palette.reduce_flashing = true
	var player := _fresh_player(root)
	var target := _enemy(root, Vector2(100, 100))
	player.apply_skill_bonus(target, 100.0, 5, 100.0)
	player.apply_skill_bonus(target, 100.0, 5, 100.0)
	NemoraxTest.assert_almost_eq(target.health, 900.0, 0.01, "bonusy razem nie mogą przekroczyć samego ciosu (cały atak <= 2x)")
	_finish(player, [target], root)
	Palette.reduce_flashing = old_reduce
