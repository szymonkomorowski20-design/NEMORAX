extends SceneTree
## Deterministyczny pomiar walki z Nemoraksem (AUDYT, Paczka 2 / 4).
## Użycie: Godot --headless --fixed-fps 60 --path <projekt> --script res://debug/measure_boss_fight.gd -- <build>
## build: naked | early | medium | sword | wand | hybrid
## Bot: nietykalny, zawsze w zasięgu, atakuje bez przerwy — GÓRNA granica
## ofensywy (idealne pozycjonowanie), nie odtworzenie rundy człowieka.
## Zapis izolowany: nic nie dotyka prawdziwego postępu gracza.

const STEP := 1.0 / 60.0
const TIMEOUT_S := 600.0

const BUILDS := {
	"naked": {"level": 1, "stats": {}, "skills": {}, "relics": [], "weapon": "sword"},
	"sword": {"level": 10, "stats": {"damage": 10, "stamina": 5, "stamina_regen": 5},
		"skills": {"blade_twin_cut": 2, "blade_third_cut": 1, "blade_sunder": 2, "blade_bleed": 2, "blade_wave": 2, "blade_long_edge": 1},
		"relics": ["blood_edge", "second_impact", "hunters_mark", "momentum", "razor_wind"], "weapon": "sword"},
	"wand": {"level": 10, "stats": {"damage": 10, "mana": 6, "health": 4},
		"skills": {"wand_split_bolt": 2, "wand_echo_volley": 2, "wand_rapid_cast": 3, "wand_mana_weave": 3},
		"relics": ["blood_edge", "second_impact", "hunters_mark", "momentum", "soul_echo"], "weapon": "wand"},
	"hybrid": {"level": 10, "stats": {"damage": 6, "health": 6, "stamina": 4, "mana": 4},
		"skills": {"blade_twin_cut": 1, "wand_split_bolt": 1, "guard_battle_rhythm": 1, "guard_weapon_weave": 1, "void_rupture": 1,
			"guard_iron_skin": 2, "guard_fleetfoot": 1, "blade_long_edge": 1, "wand_rapid_cast": 1},
		"relics": ["iron_heart", "second_impact", "momentum"], "weapon": "hybrid"},
	# Paczka 4: realistyczny średni build — poziom 7, rozproszone punkty,
	# mniej rang i tylko 2 relikwie (hybryda wyżej ma pełny poziom 10).
	"medium": {"level": 7, "stats": {"damage": 5, "health": 6, "stamina": 3},
		"skills": {"blade_twin_cut": 1, "blade_bleed": 1, "blade_long_edge": 1, "guard_iron_skin": 2, "guard_fleetfoot": 1},
		"relics": ["iron_heart", "momentum"], "weapon": "sword"},
	# Gracz z ~4 wyczyszczonymi pokojami (poziom 3) — do pomiaru wcześnie
	# spotkanego wcielenia (measure_incarnation.gd).
	"early": {"level": 3, "stats": {"damage": 2, "stamina": 2},
		"skills": {"blade_twin_cut": 1, "blade_bleed": 1}, "relics": [], "weapon": "sword"},
}

var arena: Node
var player
var boss
var build: Dictionary
var build_name: String
var active_time := 0.0
var frame := 0
var phase_log: Array = []
var phase_start := 0.0
var patterns_in_phase := 0
var last_pattern := ""
var boss_damage_by_source: Dictionary = {}
var adds_damage := 0.0
var denied := {"stamina": 0, "mana": 0, "heal": 0}
var heal_stacks_gained := 0
var last_heal_stacks := 0
var last_heal_hits := 0
var primary_hits := 0
var mana_empty_time := 0.0
var done := false

func _initialize() -> void:
	await process_frame
	var args := OS.get_cmdline_user_args()
	build_name = args[0] if args.size() > 0 else "naked"
	build = BUILDS[build_name]
	var game_flow: Node = root.get_node("GameFlow")
	game_flow.SAVE_PATH = "user://measure_run.json"
	game_flow.PERSISTENT_SAVE_PATH = "user://measure_persistent.json"
	game_flow.mark_prolog_seen()
	game_flow.reset_run()
	# Hitstop zamraża time_scale w czasie rzeczywistym — spowalnia pomiar i
	# zawyżałby licznik klatek. Na same obrażenia nie wpływa.
	root.get_node("Palette").reduce_flashing = true
	arena = load("res://arena.tscn").instantiate()
	arena.SAVE_PATH = "user://measure_arena.json"
	root.add_child(arena)
	await process_frame
	player = arena.player
	boss = arena.boss
	_apply_build()
	root.get_node("Juice").reset_damage_metrics()
	boss.phase_changed.connect(_on_phase_changed)
	boss.died.connect(_on_boss_died)
	player.resource_denied.connect(func(kind): denied[kind] = int(denied.get(kind, 0)) + 1)
	physics_frame.connect(_tick)

func _apply_build() -> void:
	player.level = build["level"]
	for key in build["stats"]:
		player.stat_points[key] = build["stats"][key]
	player._recompute_effective_stats()
	player.health = player.max_health
	player.mana = player.max_mana
	player.stamina = player.max_stamina
	for id in build["skills"]:
		player.skill_ranks[id] = build["skills"][id]
	for id in build["relics"]:
		player.acquire_upgrade(id)
	player.current_weapon = "wand" if build["weapon"] == "wand" else "sword"

func _on_phase_changed(index: int, _color: Color, name: String) -> void:
	_close_phase("phase %d" % (index - 1))

func _close_phase(label: String) -> void:
	phase_log.append({"phase": label, "time": active_time - phase_start, "patterns": patterns_in_phase})
	phase_start = active_time
	patterns_in_phase = 0
	last_pattern = ""

func _on_boss_died(is_final: bool) -> void:
	if is_final:
		_close_phase("mała forma")
		done = true
	else:
		_close_phase("phase 5")

func _tick() -> void:
	if done:
		return
	var juice: Node = root.get_node("Juice")
	for event in juice.damage_events:
		if int(event["target_id"]) == boss.get_instance_id():
			boss_damage_by_source[event["source"]] = float(boss_damage_by_source.get(event["source"], 0.0)) + float(event["damage"])
		else:
			adds_damage += float(event["damage"])
	juice.damage_events.clear()
	var cutscene = arena.cutscene
	if cutscene.visible:
		cutscene._skip_all_requested = true
	while player.pending_skill_choices > 0 and not player.ensure_skill_offer().is_empty(): # wybór odłożony (HUD) — bot bierze pierwszą ofertę
		player.choose_skill(player.ensure_skill_offer()[0])
	if paused:
		return
	active_time += STEP
	frame += 1
	if frame % 600 == 0:
		print("[t=%.0fs] faza %d hp %.0f/%.0f  gracz %s  boss %s  dmg=%s" % [active_time, boss.phase_index, boss.health, boss.max_health, player.global_position, boss.global_position, str(boss_damage_by_source)])
	if active_time > TIMEOUT_S:
		_close_phase("TIMEOUT")
		done = true
		return
	if boss._last_pattern_name != "" and boss._last_pattern_name != last_pattern:
		last_pattern = boss._last_pattern_name
		patterns_in_phase += 1
	var heal_hits: int = player.get_heal_charge_hits()
	var stacks: int = player.get_heal_stacks()
	if stacks > last_heal_stacks:
		heal_stacks_gained += stacks - last_heal_stacks
	if heal_hits != last_heal_hits or stacks > last_heal_stacks:
		primary_hits += 1 if heal_hits != last_heal_hits or stacks != last_heal_stacks else 0
	last_heal_hits = heal_hits
	last_heal_stacks = stacks
	if player.mana < player._wand_mana_cost():
		mana_empty_time += STEP
	player._invuln_timer = 1.0
	player.health = player.max_health
	if build["weapon"] == "hybrid":
		player.current_weapon = "wand" if player.mana >= player._wand_mana_cost() else "sword"
	var wand: bool = player.current_weapon == "wand"
	var dist: float = 260.0 if wand else boss.radius + 30.0
	var aim_dir: Vector2 = (player.get_global_mouse_position() - player.global_position).normalized()
	if aim_dir == Vector2.ZERO:
		aim_dir = Vector2.LEFT
	player.global_position = boss.global_position - aim_dir * dist
	if frame % 2 == 0:
		Input.action_press("attack")
	else:
		Input.action_release("attack")

func _process(_delta: float) -> bool:
	if done:
		_report()
		return true
	return false

func _report() -> void:
	var total := 0.0
	for s in boss_damage_by_source:
		total += boss_damage_by_source[s]
	print("=== BUILD %s ===" % build_name)
	print("czas aktywnej walki: %.1f s   obrażenia bossa: %.0f   DPS: %.1f   (na przyzwańcach: %.0f)" % [active_time, total, total / maxf(active_time, 0.01), adds_damage])
	for p in phase_log:
		print("  %-10s %6.1f s   wzorce bossa: %d" % [p["phase"], p["time"], p["patterns"]])
	var sources := boss_damage_by_source.keys()
	sources.sort_custom(func(a, b): return boss_damage_by_source[a] > boss_damage_by_source[b])
	for s in sources:
		print("  źródło %-16s %7.0f  (%4.1f%%)" % [s, boss_damage_by_source[s], 100.0 * boss_damage_by_source[s] / maxf(total, 0.01)])
	print("  odmowy: stamina %d, mana %d   | czas bez many na strzał: %.1f s" % [denied.get("stamina", 0), denied.get("mana", 0), mana_empty_time])
	print("  zapasy leczenia naładowane: %d   (%.1f / min)" % [heal_stacks_gained, heal_stacks_gained / maxf(active_time / 60.0, 0.01)])
	quit()
