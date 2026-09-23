extends RefCounted
## Paczka 9 (AUDYT E5/A17): ekrany końca z historią próby i radą, Kronika,
## trwały zapis bez nadpisywania prologu, Komnata Echa bez wpływu na próbę,
## Pętla Otchłani I z jawną nową regułą.

func _cleanup(nodes: Array, root: Node) -> void:
	for n in nodes:
		if is_instance_valid(n) and n.get_parent() == root:
			root.remove_child(n)
			n.queue_free()

func test_arena_save_keeps_prolog_flag(root: Node) -> void:
	GameFlow.mark_prolog_seen()
	var arena = load("res://arena.tscn").instantiate()
	arena.SAVE_PATH = GameFlow.PERSISTENT_SAVE_PATH
	root.add_child(arena)
	arena.wins = 1
	arena._save_progress()
	NemoraxTest.assert_true(GameFlow.has_seen_prolog(), "zapis areny nie kasuje 'widziano prolog' (dawny błąd)")
	NemoraxTest.assert_true(GameFlow.loop_unlocked(), "zwycięstwo odblokowuje Pętlę Otchłani")
	root.get_tree().paused = false
	_cleanup([arena], root)
	GameFlow.merge_json_dict(GameFlow.PERSISTENT_SAVE_PATH, {"loop_unlocked": false, "wins": 0})

func test_death_summary_names_cause_stage_and_advice(root: Node) -> void:
	var p: Player = load("res://entities/player.tscn").instantiate()
	root.add_child(p)
	var seal = load("res://entities/seal.tscn").instantiate()
	root.add_child(seal)
	p.take_damage(5.0, seal.global_position, false, seal)
	NemoraxTest.assert_eq(p.last_hit_source, "pieczęć Nemoraksa", "gracz pamięta sprawcę ciosu")
	var e := RunSummary.build(p, "death", "Nemorax — faza Force (40% HP)", 1)
	var text := "\n".join(RunSummary.screen_lines(e))
	NemoraxTest.assert_true("Ostatni cios: pieczęć Nemoraksa" in text, "ekran pokazuje przyczynę")
	NemoraxTest.assert_true("faza Force" in text, "i etap")
	NemoraxTest.assert_true("Następnym razem:" in text and "pieczęci" in text.to_lower(), "i konkretną radę")
	NemoraxTest.assert_true("Ziarno próby" in text, "i ziarno do powtórki")
	_cleanup([p, seal], root)

func test_advice_for_random_enemy_uses_its_role(_root: Node) -> void:
	NemoraxTest.assert_true("osłony" in RunSummary.advice("death", "Strzelec").to_lower(), "strzelec → rada o osłonach/parowaniu")
	NemoraxTest.assert_true("tarcz" in RunSummary.advice("death", "Ścigacz").to_lower(), "wręcz → rada o tarczy")
	NemoraxTest.assert_true(RunSummary.advice("death", "Nekravor").begins_with("Nekravor"), "wcielenie → jego lekcja")

func test_chronicle_keeps_latest_runs(_root: Node) -> void:
	GameFlow.merge_json_dict(GameFlow.PERSISTENT_SAVE_PATH, {"chronicle": []})
	for i in GameFlow.CHRONICLE_LIMIT + 3:
		GameFlow.add_chronicle_entry({"seed": i, "result": "death"})
	var list := GameFlow.chronicle()
	NemoraxTest.assert_eq(list.size(), GameFlow.CHRONICLE_LIMIT, "Kronika ma limit")
	NemoraxTest.assert_eq(int(list[0]["seed"]), GameFlow.CHRONICLE_LIMIT + 2, "najnowsza próba na górze")
	GameFlow.merge_json_dict(GameFlow.PERSISTENT_SAVE_PATH, {"chronicle": []})

func test_echo_training_leaves_the_run_untouched(root: Node) -> void:
	GameFlow.reset_run(99)
	GameFlow.rooms_cleared_count = 11
	GameFlow.fragments_collected.assign(["A", "B"])
	var map_before := GameFlow.room_map.duplicate(true)
	var save_path := GameFlow.SAVE_PATH
	GameFlow.begin_training(3)
	NemoraxTest.assert_true(GameFlow.training and GameFlow.SAVE_PATH != save_path, "trening pisze gdzie indziej")
	var room = load("res://rooms/room.tscn").instantiate()
	root.add_child(room)
	var xp_before: float = room.player.xp
	var lvl_before: int = room.player.level
	room.incarnation.take_damage(99999.0)
	NemoraxTest.assert_eq(room.player.level, lvl_before, "trening nie daje poziomu")
	NemoraxTest.assert_almost_eq(room.player.xp, xp_before, 0.01, "ani XP")
	NemoraxTest.assert_eq(room._game_over_kind, "training", "koniec treningu, nie fragment duszy")
	root.remove_child(room)
	room.queue_free()
	GameFlow.end_training()
	NemoraxTest.assert_true(not GameFlow.training, "wyjście z Komnaty")
	NemoraxTest.assert_eq(GameFlow.SAVE_PATH, save_path, "ścieżka zapisu wraca")
	NemoraxTest.assert_eq(GameFlow.rooms_cleared_count, 11, "postęp próby nietknięty")
	NemoraxTest.assert_eq(GameFlow.fragments_collected.size(), 2, "fragmenty nietknięte")
	NemoraxTest.assert_eq(GameFlow.room_map, map_before, "mapa nietknięta")
	GameFlow.reset_run()

func test_loop_one_changes_rules(root: Node) -> void:
	GameFlow.loop_level = 1
	var holder := Node2D.new()
	root.add_child(holder)
	var e: Incarnation = load("res://entities/random_enemies/chaser.tscn").instantiate()
	holder.add_child(e)
	e.take_damage(99999.0)
	var zones := 0
	for c in holder.get_children():
		if c.get("zone_radius") != null:
			zones += 1
	NemoraxTest.assert_eq(zones, 1, "poległy wróg zostawia strefę Otchłani")
	var p: Player = load("res://entities/player.tscn").instantiate()
	root.add_child(p)
	var chest: Chest = load("res://rooms/chest.tscn").instantiate()
	root.add_child(chest)
	chest.player = p
	var offers: Array = []
	chest.selection_requested.connect(func(ids: Array[String]): offers.assign(ids))
	chest._open()
	NemoraxTest.assert_eq(offers.size(), 4, "Pętla: 4 relikwie w skrzyni")
	GameFlow.loop_level = 0
	_cleanup([holder, p, chest], root)
