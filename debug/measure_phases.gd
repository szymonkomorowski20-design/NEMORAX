extends SceneTree
## Tempo faz Nemoraksa (drugi audyt 24.09, B1): dla każdej z 6 faz i małej
## formy — czas aktywnej walki, ile razy padł KAŻDY wzorzec fazy (i czy faza
## pokazała wszystkie przed śmiercią), ciosy przyjęte/zadane, leczenia, HP /
## stamina / mana na wejściu i wyjściu. Bot NIE jest nietykalny (dolewka HP
## poniżej 25% = „tu człowiek by zginął”), stoi przy bossie, bez uników.
## Ziarno wzorców stałe (seed), więc przebiegi buildów są porównywalne.
## Użycie: Godot --headless --fixed-fps 60 --path <projekt> --script res://debug/measure_phases.gd -- <build> [ziarno]
## Buildy: jak measure_boss_fight.gd oraz "kontra" (defensywny: tarcza/przetrwanie).

const BossMeasure := preload("res://debug/measure_boss_fight.gd")
const STEP := 1.0 / 60.0
const TIMEOUT := 900.0
const KONTRA := {"level": 10, "stats": {"health": 8, "stamina": 6, "damage": 6},
	"skills": {"guard_counterbrand": 2, "guard_iron_skin": 3, "guard_quickstep": 1, "guard_battle_rhythm": 2, "guard_second_breath": 1, "blade_twin_cut": 1},
	"relics": ["iron_heart", "last_resolve", "momentum"], "weapon": "sword"}
const PHASE_PATTERNS := {
	0: ["M1_dash_only", "M2_dash_and_strike", "M3_dash_through_return"],
	1: ["F1_wide_strike", "F2_radial_warning", "F3_advance_pressure"],
	2: ["I1_reposition_strike", "I2_feint", "I3_quick_strike"],
	3: ["D1_zone", "D2_projectile_fan", "D3_summon", "D4_zone_and_fan", "D5_void_lock"],
	4: ["R1_dash_cleave", "R2_chain_followup", "R3_pursuit_strike"],
	5: ["S1_motion_force", "S2_instinct_ruin", "S3_dominion_motion", "S4_crown_sequence"],
}
const PHASE_LABELS := ["Ruch", "Siła", "Instynkt", "Dominium", "Ruina", "Władza", "mała forma"]

var juice: Node
var boss
var player

func _initialize() -> void:
	await process_frame
	var args := OS.get_cmdline_user_args()
	var build_name := args[0] if args.size() > 0 else "medium"
	var seed_value := int(args[1]) if args.size() > 1 else 4242
	var build: Dictionary = KONTRA if build_name == "kontra" else BossMeasure.BUILDS[build_name]
	seed(seed_value)
	var gf: Node = root.get_node("GameFlow")
	juice = root.get_node("Juice")
	gf.SAVE_PATH = "user://measure_run.json"
	gf.PERSISTENT_SAVE_PATH = "user://measure_persistent.json"
	gf.mark_prolog_seen()
	gf.reset_run(seed_value)
	root.get_node("Palette").reduce_flashing = true
	var arena: Node = load("res://arena.tscn").instantiate()
	arena.SAVE_PATH = "user://measure_arena.json"
	root.add_child(arena)
	await process_frame
	player = arena.player
	boss = arena.boss
	player.level = build["level"]
	for key in build["stats"]:
		player.stat_points[key] = build["stats"][key]
	player._recompute_effective_stats()
	player.health = player.max_health
	player.stamina = player.max_stamina
	player.mana = player.max_mana
	for id in build["skills"]:
		player.skill_ranks[id] = build["skills"][id]
	for id in build["relics"]:
		player.acquire_upgrade(id)
	player.current_weapon = "wand" if build["weapon"] == "wand" else "sword"
	juice.reset_damage_metrics()
	var phases: Array = []
	var cur := _new_phase(0)
	var t := 0.0
	var frame := 0
	var last_pattern := ""
	var last_stacks: int = player.get_heal_stacks()
	var hits_seen := 0
	var last_boss_hp: float = boss.health
	var last_key := 0
	while t < TIMEOUT and not (boss.is_dead and boss.is_final_phase):
		await physics_frame
		if paused:
			paused = false
			continue
		if arena.cutscene.visible:
			arena.cutscene._skip_all_requested = true
		var key: int = 6 if boss.is_final_phase else boss.phase_index
		if key != cur["key"]:
			_close(cur, t)
			phases.append(cur)
			cur = _new_phase(key)
			last_pattern = ""
		t += STEP
		frame += 1
		cur["time"] += STEP
		if boss._last_pattern_name != "" and boss._last_pattern_name != last_pattern:
			cur["patterns"][boss._last_pattern_name] = int(cur["patterns"].get(boss._last_pattern_name, 0)) + 1
		last_pattern = boss._last_pattern_name
		for e in juice.player_hits.slice(hits_seen):
			if e["outcome"] in ["trafienie", "przełamanie gardy", "poza tarczą — bok", "poza tarczą — tył", "nieblokowalny"]:
				cur["hits_taken"] += 1
				cur["taken"] += float(e["damage"])
		hits_seen = juice.player_hits.size()
		# Spadki HP bossa klatka po klatce (Juice.damage_events ma limit wpisów).
		if key == last_key and boss.health < last_boss_hp:
			cur["dealt"] += last_boss_hp - boss.health
		last_boss_hp = boss.health
		last_key = key
		var stacks: int = player.get_heal_stacks()
		if stacks < last_stacks:
			cur["heals"] += last_stacks - stacks
		last_stacks = stacks
		if player.health < player.max_health * 0.25:
			player.health = player.max_health
			cur["refills"] += 1
		if player.health < player.max_health * 0.5 and stacks > 0 and frame % 30 == 0:
			Input.action_press("heal")
		else:
			Input.action_release("heal")
		if build["weapon"] == "hybrid":
			player.current_weapon = "wand" if player.mana >= player._wand_mana_cost() else "sword"
		var wand: bool = player.current_weapon == "wand"
		var aim_dir: Vector2 = (player.get_global_mouse_position() - player.global_position).normalized()
		if aim_dir == Vector2.ZERO:
			aim_dir = Vector2.LEFT
		var inner: Rect2 = arena.ARENA_RECT.grow(-player.radius)
		player.global_position = (boss.global_position - aim_dir * (260.0 if wand else boss.radius + 30.0)).clamp(inner.position, inner.end)
		if frame % 2 == 0:
			Input.action_press("attack")
		else:
			Input.action_release("attack")
		if cur["hp_in"] < 0.0:
			cur["hp_in"] = player.health
			cur["st_in"] = player.stamina
			cur["mana_in"] = player.mana
	Input.action_release("attack")
	_close(cur, t)
	phases.append(cur)
	_report(build_name, seed_value, phases, t, boss.is_dead and boss.is_final_phase)
	quit(0)

func _new_phase(key: int) -> Dictionary:
	return {"key": key, "time": 0.0, "patterns": {}, "hits_taken": 0, "taken": 0.0, "dealt": 0.0,
		"heals": 0, "refills": 0, "hp_in": -1.0, "st_in": 0.0, "mana_in": 0.0}

func _close(p: Dictionary, _t: float) -> void:
	p["hp_out"] = player.health
	p["st_out"] = player.stamina
	p["mana_out"] = player.mana

func _report(build_name: String, seed_value: int, phases: Array, total: float, won: bool) -> void:
	print("=== FAZY: build %s, ziarno %d, %s w %.1f s aktywnej walki ===" % [build_name, seed_value, "wygrana" if won else "NIE UKOŃCZONA", total])
	print("  %-10s %6s  %-9s %-44s %5s %6s %6s %4s %4s  %s" % ["faza", "czas", "wzorce", "cykle (nazwa×ile)", "ciosy", "przyj.", "zadane", "lecz", "dolew", "HP/st/mana wej→wyj"])
	for p in phases:
		var own: Array = PHASE_PATTERNS.get(p["key"], [])
		var seen := 0
		for n in own:
			if p["patterns"].has(n):
				seen += 1
		var full := "%d/%d" % [seen, own.size()] if not own.is_empty() else "—"
		var names: Array[String] = []
		for n in p["patterns"]:
			names.append("%s×%d" % [str(n).split("_")[0], p["patterns"][n]])
		print("  %-10s %5.1fs  %-9s %-44s %5d %6.0f %6.0f %4d %4d  %.0f/%.0f/%.0f → %.0f/%.0f/%.0f" % [
			PHASE_LABELS[p["key"]], p["time"], full, " ".join(names), p["hits_taken"], p["taken"], p["dealt"], p["heals"], p["refills"],
			p["hp_in"], p["st_in"], p["mana_in"], p["hp_out"], p["st_out"], p["mana_out"]])
