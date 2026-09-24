extends SceneTree
## Pakt Mordratha w finale (audyt nagrania 24.09, P1.11): ta sama walka
## z Nemoraksem przy „Oczyść ciszę” i „Zwiąż ciszę”. Bot NIE jest nietykalny
## (dolewka HP poniżej 25% = „tu człowiek by zginął”), bez uników — GÓRNA
## granica przyjętych obrażeń. Mierzy fazę Siła (indeks 1): czas, wzorce,
## przyjęte obrażenia wg rodzaju, dolewki, oraz odmowy staminy w całej walce.
## Użycie: Godot --headless --fixed-fps 60 --path <projekt> --script res://debug/measure_pact.gd -- <oczysc|zwiaz|zwiaz220> <build> [atak|tarcza]
## Tryb „tarcza” (drugi audyt B4): bot cyklicznie 0,30 s atakuje i 0,45 s trzyma
## tarczę w stronę bossa — część ciosów trafia w okno parowania, więc widać
## wartość pola ciszy (boss.silence opóźnia jego następny atak).

const BossMeasure := preload("res://debug/measure_boss_fight.gd")
const STEP := 1.0 / 60.0
const TIMEOUT := 600.0

func _initialize() -> void:
	await process_frame
	var args := OS.get_cmdline_user_args()
	var pact := args[0] if args.size() > 0 else "oczysc"
	var style := args[2] if args.size() > 2 else "atak"
	if pact == "zwiaz220":
		pact = "zwiaz"
		load("res://entities/pact_catalog.gd").test_bind_boost = true
	var build_name := args[1] if args.size() > 1 else "medium"
	var build: Dictionary = BossMeasure.BUILDS[build_name]
	seed(4242) # te same wzorce bossa we wszystkich wariantach
	var gf: Node = root.get_node("GameFlow")
	var juice: Node = root.get_node("Juice")
	gf.SAVE_PATH = "user://measure_run.json"
	gf.PERSISTENT_SAVE_PATH = "user://measure_persistent.json"
	gf.mark_prolog_seen()
	gf.reset_run(4242)
	gf.pacts = {"1": pact}
	root.get_node("Palette").reduce_flashing = true
	var arena: Node = load("res://arena.tscn").instantiate()
	arena.SAVE_PATH = "user://measure_arena.json"
	root.add_child(arena)
	await process_frame
	var player = arena.player
	var boss = arena.boss
	player.level = build["level"]
	for key in build["stats"]:
		player.stat_points[key] = build["stats"][key]
	player._recompute_effective_stats()
	player.health = player.max_health
	player.stamina = player.max_stamina
	for id in build["skills"]:
		player.skill_ranks[id] = build["skills"][id]
	for id in build["relics"]:
		player.acquire_upgrade(id)
	var denied := {"stamina": 0}
	player.resource_denied.connect(func(kind): denied[kind] = int(denied.get(kind, 0)) + 1)
	juice.player_hits.clear()
	var t := 0.0
	var frame := 0
	var refills := {0: 0, 1: 0}
	var phase1 := {"time": 0.0, "patterns": 0, "taken": 0.0, "kinds": {}}
	var last_pattern := ""
	var hits_seen := 0
	var outcomes := {}
	while t < TIMEOUT and not (boss.is_dead and boss.is_final_phase):
		await physics_frame
		if paused:
			paused = false
		if arena.cutscene.visible:
			arena.cutscene._skip_all_requested = true
		t += STEP
		frame += 1
		var in_force: bool = boss.phase_index == 1 and not boss.is_final_phase
		if in_force:
			phase1["time"] += STEP
			if boss._last_pattern_name != "" and boss._last_pattern_name != last_pattern:
				phase1["patterns"] += 1
		last_pattern = boss._last_pattern_name
		for e in juice.player_hits.slice(hits_seen):
			outcomes[e["outcome"]] = int(outcomes.get(e["outcome"], 0)) + 1
			if e["outcome"] in ["trafienie", "przełamanie gardy", "poza tarczą — bok", "poza tarczą — tył", "nieblokowalny"] and in_force:
				phase1["taken"] += float(e["damage"])
				var k := "%s (%s)" % [e["kind"], e["skill"]] if str(e["skill"]) != "" else str(e["kind"])
				phase1["kinds"][k] = float(phase1["kinds"].get(k, 0.0)) + float(e["damage"])
		hits_seen = juice.player_hits.size()
		if player.health < player.max_health * 0.25:
			player.health = player.max_health
			refills[1 if in_force else 0] += 1
		var aim_dir: Vector2 = (player.get_global_mouse_position() - player.global_position).normalized()
		if aim_dir == Vector2.ZERO:
			aim_dir = Vector2.LEFT
		var inner: Rect2 = arena.ARENA_RECT.grow(-player.radius)
		player.global_position = (boss.global_position - aim_dir * (boss.radius + 30.0)).clamp(inner.position, inner.end)
		var shield_phase := style == "tarcza" and fmod(t, 0.75) >= 0.30
		player.debug_aim_point = boss.global_position
		if shield_phase:
			Input.action_release("attack")
			Input.action_press("block")
		else:
			Input.action_release("block")
			if frame % 2 == 0:
				Input.action_press("attack")
			else:
				Input.action_release("attack")
	Input.action_release("attack")
	Input.action_release("block")
	print("=== PAKT %s%s, build %s, styl %s ===" % [pact, " (220 px / 1,6 s)" if load("res://entities/pact_catalog.gd").test_bind_boost else "", build_name, style])
	print("  cała walka %.1f s (%s), dolewki poza fazą Siła %d, odmowy staminy %d, maks. stamina %.0f" % [t, "wygrana" if boss.is_dead else "NIE UKOŃCZONA", refills[0], denied["stamina"], player.max_stamina])
	print("  faza Siła: %.1f s, wzorce %d, przyjęte %.0f HP, dolewki %d" % [phase1["time"], phase1["patterns"], phase1["taken"], refills[1]])
	print("    wg rodzaju: %s" % str(phase1["kinds"]))
	print("  wyniki ciosów w całej walce: %s" % str(outcomes))
	quit(0)
