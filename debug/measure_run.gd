extends SceneTree
## Deterministyczna pełna próba (audyt nagrania 24.09, P1.9): ziarno → minimalna
## trasa do 6 dusz → finał. Bot NIE jest nietykalny: każdy cios trafia do
## Juice.player_hits (ten sam log co w grze). Gdy HP < 25%, bot „dolewa” HP
## i to liczymy jako moment, w którym człowiek najpewniej by zginął.
## Polityka rozwoju:
##   spend — punkty statystyk (obrażenia/zdrowie na zmianę) i runy od razu,
##   skip  — nic nie wydaje (jak w nagraniu: długo wisiały „[R] Runa do wyboru”
##           i niewydane punkty).
## Bot stoi przy celu i bije bez uników — GÓRNA granica obrażeń przyjętych,
## DOLNA granica czasu. To porównanie wariantów, nie odtworzenie człowieka.
## Użycie: Godot --headless --fixed-fps 60 --path <projekt> --script res://debug/measure_run.gd -- <ziarno> <spend|skip>

const STEP := 1.0 / 60.0
const ROOM_TIMEOUT := 150.0
const BOSS_TIMEOUT := 600.0
const REFILL_BELOW := 0.25
const SILENCE_RADIUS := 160.0 ## = PactCatalog.ZWIAZ_SILENCE_RADIUS (klasa zależy od autoloadu, w --script się nie kompiluje)

var gf: Node
var juice: Node
var policy := "spend"
var refills := 0
var heals_used := 0
var _last_stacks := 0
var report: Array = []
var silence_reach: Array[int] = [] ## P1.11: ilu wrogów objęłoby pole ciszy przy każdym blokowalnym ciosie

func _initialize() -> void:
	await process_frame
	var args := OS.get_cmdline_user_args()
	var seed_value := int(args[0]) if args.size() > 0 else 5000
	policy = args[1] if args.size() > 1 else "spend"
	gf = root.get_node("GameFlow")
	juice = root.get_node("Juice")
	gf.SAVE_PATH = "user://measure_run.json"
	gf.PERSISTENT_SAVE_PATH = "user://measure_persistent.json"
	gf.mark_prolog_seen()
	root.get_node("Palette").reduce_flashing = true
	gf.reset_run(seed_value)
	gf.set_run_intent("ostrze")
	var route := _minimal_route()
	var total_time := 0.0
	for pos in route:
		var r := await _fight_room(pos)
		report.append(r)
		total_time += float(r["time"])
	var boss := await _fight_boss()
	_print_report(seed_value, route.size(), total_time, boss)
	quit(0)

## Pokoje potrzebne do 6 dusz (jak measure_route), w kolejności odległości od startu.
func _minimal_route() -> Array:
	var dist := {Vector2i.ZERO: 0}
	var parent := {}
	var queue: Array[Vector2i] = [Vector2i.ZERO]
	while not queue.is_empty():
		var cur: Vector2i = queue.pop_front()
		for d in gf.DIRECTIONS:
			var nb: Vector2i = cur + d
			if gf.room_map.has(nb) and not dist.has(nb):
				dist[nb] = dist[cur] + 1
				parent[nb] = cur
				queue.append(nb)
	var needed := {}
	for pos in gf.room_map:
		if gf.room_map[pos]["type"] == gf.RoomType.SOUL:
			var p: Vector2i = pos
			while parent.has(p):
				needed[p] = true
				p = parent[p]
	var out := needed.keys().filter(func(p): return gf.room_map[p]["type"] in [gf.RoomType.RANDOM, gf.RoomType.SOUL] and not gf.room_map[p].get("rest", false))
	out.sort_custom(func(a, b): return dist[a] < dist[b])
	return out

func _develop(player) -> void:
	if policy != "spend":
		return
	var toggle := 0
	while player.unspent_stat_points > 0:
		player.spend_stat_point("damage" if toggle % 2 == 0 else "health")
		toggle += 1
	while player.pending_skill_choices > 0 and not player.ensure_skill_offer().is_empty():
		player.choose_skill(player.ensure_skill_offer()[0])

func _bot_step(player, target: Node2D, rect: Rect2, frame: int) -> void:
	if player.health < player.max_health * REFILL_BELOW:
		player.health = player.max_health
		refills += 1
	var stacks: int = player.get_heal_stacks()
	if stacks < _last_stacks:
		heals_used += _last_stacks - stacks # zużyty zapas = faktyczne leczenie
	_last_stacks = stacks
	if player.health < player.max_health * 0.5 and stacks > 0 and frame % 30 == 0:
		Input.action_press("heal")
	else:
		Input.action_release("heal")
	var aim_dir: Vector2 = (player.get_global_mouse_position() - player.global_position).normalized()
	if aim_dir == Vector2.ZERO:
		aim_dir = Vector2.LEFT
	var reach: float = float(target.get("radius") if target.get("radius") != null else 30.0) + 26.0
	var inner := rect.grow(-player.radius)
	player.global_position = (target.global_position - aim_dir * reach).clamp(inner.position, inner.end)
	if frame % 2 == 0:
		Input.action_press("attack")
	else:
		Input.action_release("attack")

func _fight_room(pos: Vector2i) -> Dictionary:
	gf.current_room_pos = pos
	gf.entry_direction = Vector2i(0, -1)
	var data: Dictionary = gf.room_map[pos]
	var room: Node2D = load("res://rooms/room.tscn").instantiate()
	root.add_child(room)
	await process_frame
	var player = room.player
	var hits_before: int = juice.player_hits.size()
	var hits_now: int = juice.player_hits.size()
	var refills_before := refills
	var t := 0.0
	var frame := 0
	while t < ROOM_TIMEOUT:
		await physics_frame
		if paused:
			paused = false
		var alive: Array = room._active_enemies.filter(func(e): return is_instance_valid(e) and not e.is_dead)
		if alive.is_empty() and bool(data.get("cleared", false)):
			break
		t += STEP
		frame += 1
		_develop(player)
		if not alive.is_empty():
			alive.sort_custom(func(a, b): return a.global_position.distance_to(player.global_position) < b.global_position.distance_to(player.global_position))
			_bot_step(player, alive[0], room._play_rect, frame)
			_sample_silence(player, alive, hits_now)
			hits_now = juice.player_hits.size()
	Input.action_release("attack")
	Input.action_release("heal")
	var taken := 0.0
	var kinds := {}
	for e in juice.player_hits.slice(hits_before):
		if e["outcome"] in ["trafienie", "przełamanie gardy", "poza tarczą — bok", "poza tarczą — tył", "nieblokowalny"]:
			taken += float(e["damage"])
			var key := "%s %s" % [e["source"], e["kind"]]
			kinds[key] = float(kinds.get(key, 0.0)) + float(e["damage"])
	gf.capture_player_state(player)
	var r := {
		"pos": pos, "type": "dusza" if data["type"] == gf.RoomType.SOUL else ("elita" if data.get("elite", false) else "pokój"),
		"time": t, "taken": taken, "refills": refills - refills_before, "level": player.level,
		"unspent": player.unspent_stat_points, "runes": player.pending_skill_choices, "kinds": kinds,
		"cleared": bool(data.get("cleared", false)),
	}
	root.remove_child(room)
	room.queue_free()
	await process_frame
	return r

func _fight_boss() -> Dictionary:
	var arena: Node = load("res://arena.tscn").instantiate()
	arena.SAVE_PATH = "user://measure_arena.json" # NIGDY prawdziwy progress.json gracza
	root.add_child(arena)
	await process_frame
	var player = arena.player
	var boss = arena.boss
	var hits_before: int = juice.player_hits.size()
	var refills_before := refills
	var t := 0.0
	var frame := 0
	var phase_times: Array = []
	var phase_start := 0.0
	var last_phase: int = boss.phase_index
	while t < BOSS_TIMEOUT and not (boss.is_dead and boss.is_final_phase):
		await physics_frame
		if paused:
			paused = false
		if arena.cutscene.visible:
			arena.cutscene._skip_all_requested = true
		t += STEP
		frame += 1
		_develop(player)
		if boss.phase_index != last_phase:
			phase_times.append(t - phase_start)
			phase_start = t
			last_phase = boss.phase_index
		_bot_step(player, boss, arena.ARENA_RECT, frame)
	Input.action_release("attack")
	var taken := 0.0
	var kinds := {}
	for e in juice.player_hits.slice(hits_before):
		if e["outcome"] in ["trafienie", "przełamanie gardy", "poza tarczą — bok", "poza tarczą — tył", "nieblokowalny"]:
			taken += float(e["damage"])
			var key := "%s" % e["kind"]
			kinds[key] = float(kinds.get(key, 0.0)) + float(e["damage"])
	return {"time": t, "taken": taken, "refills": refills - refills_before, "phases": phase_times, "kinds": kinds,
		"won": boss.is_dead and boss.is_final_phase, "level": player.level, "unspent": player.unspent_stat_points, "runes": player.pending_skill_choices}

func _print_report(seed_value: int, rooms: int, total: float, boss: Dictionary) -> void:
	print("=== PRÓBA ziarno %d, polityka %s, pokoi na trasie %d ===" % [seed_value, policy, rooms])
	var i := 0
	for r in report:
		i += 1
		print("  %2d %-6s %5.1f s  przyjęte %4.0f  dolewki %d  poz. %d  niewydane pkt %d / runy %d%s" % [
			i, r["type"], r["time"], r["taken"], r["refills"], r["level"], r["unspent"], r["runes"], "" if r["cleared"] else "  [NIE UKOŃCZONY]"])
	var src := {}
	var taken_total := 0.0
	for r in report:
		taken_total += float(r["taken"])
		for k in r["kinds"]:
			src[k] = float(src.get(k, 0.0)) + float(r["kinds"][k])
	print("  RAZEM trasa: %.0f s walki, przyjęte %.0f HP, dolewki %d, leczenia %d" % [total, taken_total, refills - int(boss["refills"]), heals_used])
	var keys := src.keys()
	keys.sort_custom(func(a, b): return src[a] > src[b])
	for k in keys.slice(0, 6):
		print("    %-40s %5.0f HP" % [k, src[k]])
	if not silence_reach.is_empty():
		var hist := {}
		var sum := 0
		for n in silence_reach:
			hist[n] = int(hist.get(n, 0)) + 1
			sum += n
		print("  Pakt Zwiąż — wrogów w zasięgu ciszy przy blokowalnym ciosie: średnio %.2f, rozkład %s (n=%d)" % [float(sum) / silence_reach.size(), str(hist), silence_reach.size()])
	print("  FINAŁ: %s, %.1f s, przyjęte %.0f HP, dolewki %d, poz. %d, niewydane pkt %d / runy %d" % [
		"wygrany" if boss["won"] else "NIE UKOŃCZONY", boss["time"], boss["taken"], boss["refills"], boss["level"], boss["unspent"], boss["runes"]])
	print("    fazy (s): %s" % ", ".join(boss["phases"].map(func(x): return "%.1f" % x)))
	print("    obrażenia wg rodzaju: %s" % str(boss["kinds"]))

## Dla każdego NOWEGO blokowalnego ciosu w tej klatce: ilu żywych wrogów stoi
## w zasięgu fali ciszy (Pakt „Zwiąż”), gdyby gracz go sparował.
func _sample_silence(player, alive: Array, from_index: int) -> void:
	for e in juice.player_hits.slice(from_index):
		if not bool(e.get("blockable", true)):
			continue
		var n := 0
		for enemy in alive:
			var r: float = float(enemy.get("radius") if enemy.get("radius") != null else 0.0)
			if enemy.global_position.distance_to(player.global_position) <= SILENCE_RADIUS + r:
				n += 1
		silence_reach.append(n)
