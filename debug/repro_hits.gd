extends SceneTree
# Odtworzenie walki z wcieleniem i log ciosów w gracza (audyt nagrania 24.09, P0.2).
# Użycie: --headless --fixed-fps 60 --script res://debug/repro_hits.gd -- <rozdział> <melee|kite> [pokoje]   (tarcza: debug/shield_lab.tscn — w headless mysz nie celuje)

const BossMeasure := preload("res://debug/measure_boss_fight.gd")
const DURATION := 45.0

func _initialize() -> void:
	await process_frame
	var args := OS.get_cmdline_user_args()
	var chapter := int(args[0])
	var style := args[1]
	var rooms := int(args[2]) if args.size() > 2 else 6
	var gf: Node = root.get_node("GameFlow")
	gf.SAVE_PATH = "user://measure_run.json"
	gf.PERSISTENT_SAVE_PATH = "user://measure_persistent.json"
	gf.mark_prolog_seen()
	gf.reset_run(11)
	gf.rooms_cleared_count = rooms
	gf.room_map = {Vector2i.ZERO: {"type": gf.RoomType.SOUL, "chapter": chapter, "enemy_index": 0, "cleared": false}}
	gf.current_room_pos = Vector2i.ZERO
	var room: Node2D = load("res://rooms/room.tscn").instantiate()
	root.add_child(room)
	await process_frame
	var player = room.player
	var enemy = room.incarnation
	var build: Dictionary = BossMeasure.BUILDS["early"]
	player.level = 4
	for key in build["stats"]:
		player.stat_points[key] = build["stats"][key]
	player._recompute_effective_stats()
	player.health = player.max_health
	var juice: Node = root.get_node("Juice")
	juice.player_hits.clear()
	var rect: Rect2 = room._play_rect.grow(-player.radius)
	var t := 0.0
	var frame := 0
	var refills := 0
	var angle := 0.0
	while t < DURATION and not enemy.is_dead:
		await physics_frame
		t += 1.0 / 60.0
		frame += 1
		if player.health < player.max_health * 0.2:
			player.health = player.max_health
			refills += 1
		var to_enemy: Vector2 = enemy.global_position - player.global_position
		var dir := to_enemy.normalized() if to_enemy.length() > 0.01 else Vector2.RIGHT
		match style:
			"melee":
				player.global_position = (enemy.global_position - dir * (enemy.radius + 30.0)).clamp(rect.position, rect.end)
				if frame % 2 == 0:
					Input.action_press("attack")
				else:
					Input.action_release("attack")
			"kite":
				angle += 0.6 / 60.0
				player.global_position = (enemy.global_position + Vector2.from_angle(angle) * 320.0).clamp(rect.position, rect.end)
			"shield":
				player.global_position = (enemy.global_position - dir * (enemy.radius + 60.0)).clamp(rect.position, rect.end)
				player._shield_up = true
				player._shield_dir = dir
				player._shield_time = 1.0
	Input.action_release("attack")
	var by_kind := {}
	for e in juice.player_hits:
		var key := "%s / %s / %s" % [e["kind"], e["skill"] if e["skill"] != "" else "-", e["outcome"]]
		if not by_kind.has(key):
			by_kind[key] = [0, 0.0]
		by_kind[key][0] += 1
		if e["outcome"] in ["trafienie", "przełamanie gardy", "tarcza w złą stronę", "nieblokowalny"]:
			by_kind[key][1] += float(e["damage"])
	print("=== ROZDZIAŁ %d (%s), styl %s, %.0f s, dolewki HP: %d, wróg %s ===" % [chapter, gf.INCARNATION_NAMES[chapter], style, t, refills, "pokonany" if enemy.is_dead else "żyje"])
	for key in by_kind:
		print("  %-60s x%-3d  HP -%.0f" % [key, by_kind[key][0], by_kind[key][1]])
	print("--- pierwsze 12 wpisów ---")
	for e in juice.player_hits.slice(0, 12):
		print("  " + juice.format_player_hit(e))
	quit(0)
