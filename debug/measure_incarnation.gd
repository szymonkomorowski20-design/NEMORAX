extends SceneTree
## Pomiar walki z wcieleniem w prawdziwym pokoju SOUL (AUDYT, Paczka 4).
## Użycie: Godot --headless --fixed-fps 60 --script res://debug/measure_incarnation.gd -- <build> <rozdział 0-5|all> [wyczyszczone_pokoje]
## Buildy jak w measure_boss_fight.gd. Bot nietykalny, zawsze w zasięgu —
## GÓRNA granica ofensywy. Zapis izolowany.

const STEP := 1.0 / 60.0
const TIMEOUT_S := 300.0
const BossMeasure := preload("res://debug/measure_boss_fight.gd")

var build: Dictionary
var build_name: String
var chapters: Array = []
var rooms_cleared := 0
var room: Node
var player
var enemy
var active_time := 0.0
var skills_seen := 0
var last_skill := -1
var results: Array = []
var running := false
var no_stance := false ## 4. argument "nostance" — porównanie prototypu postawy (Paczka 4.3)

func _initialize() -> void:
	await process_frame
	var args := OS.get_cmdline_user_args()
	build_name = args[0] if args.size() > 0 else "medium"
	build = BossMeasure.BUILDS[build_name]
	if args.size() > 1 and args[1] != "all":
		chapters = [int(args[1])]
	else:
		chapters = [0, 1, 2, 3, 4, 5]
	rooms_cleared = int(args[2]) if args.size() > 2 else 0
	no_stance = args.size() > 3 and args[3] == "nostance"
	var game_flow: Node = root.get_node("GameFlow")
	game_flow.SAVE_PATH = "user://measure_run.json"
	game_flow.PERSISTENT_SAVE_PATH = "user://measure_persistent.json"
	game_flow.mark_prolog_seen()
	root.get_node("Palette").reduce_flashing = true
	for chapter in chapters:
		await _fight(chapter)
	_report()

func _fight(chapter: int) -> void:
	var game_flow: Node = root.get_node("GameFlow")
	game_flow.reset_run()
	game_flow.rooms_cleared_count = rooms_cleared
	game_flow.room_map = {Vector2i.ZERO: {"type": game_flow.RoomType.SOUL, "chapter": chapter, "enemy_index": 0, "cleared": false}}
	game_flow.current_room_pos = Vector2i.ZERO
	room = load("res://rooms/room.tscn").instantiate()
	root.add_child(room)
	await process_frame
	player = room.player
	enemy = room.incarnation
	if no_stance:
		enemy.stance_enabled = false
	_apply_build()
	active_time = 0.0
	skills_seen = 0
	last_skill = -1
	var hp: float = enemy.max_health
	running = true
	while running:
		await physics_frame
		_tick()
	results.append({"chapter": chapter, "name": game_flow.INCARNATION_NAMES[chapter], "time": active_time, "hp": hp, "skills": skills_seen, "breaks": enemy.stance_breaks})
	root.remove_child(room)
	room.queue_free()
	await process_frame

func _apply_build() -> void:
	player.level = build["level"]
	for key in build["stats"]:
		player.stat_points[key] = build["stats"][key]
	player._recompute_effective_stats()
	player.health = player.max_health
	player.mana = player.max_mana
	player.stamina = player.max_stamina
	player.skill_ranks.clear()
	for id in build["skills"]:
		player.skill_ranks[id] = build["skills"][id]
	for id in build["relics"]:
		player.acquire_upgrade(id)
	player.current_weapon = "wand" if build["weapon"] == "wand" else "sword"

func _tick() -> void:
	if not is_instance_valid(enemy) or enemy.is_dead:
		running = false
		return
	while player.pending_skill_choices > 0 and not player.ensure_skill_offer().is_empty():
		player.choose_skill(player.ensure_skill_offer()[0])
	if paused:
		return
	active_time += STEP
	if active_time > TIMEOUT_S:
		running = false
		return
	# Zbocze narastające telegrafu = jedna użyta umiejętność.
	var telegraphing: bool = enemy._telegraph_active
	if telegraphing and last_skill == -1:
		skills_seen += 1
	last_skill = 1 if telegraphing else -1
	player._invuln_timer = 1.0
	player.health = player.max_health
	if build["weapon"] == "hybrid":
		player.current_weapon = "wand" if player.mana >= player._wand_mana_cost() else "sword"
	var wand: bool = player.current_weapon == "wand"
	var dist: float = 220.0 if wand else enemy.radius + 26.0
	var aim_dir: Vector2 = (player.get_global_mouse_position() - player.global_position).normalized()
	if aim_dir == Vector2.ZERO:
		aim_dir = Vector2.LEFT
	var inner: Rect2 = room._play_rect.grow(-player.radius) # w pokoju jak prawdziwy gracz (Paczka 11)
	player.global_position = (enemy.global_position - aim_dir * dist).clamp(inner.position, inner.end)
	if Engine.get_physics_frames() % 2 == 0:
		Input.action_press("attack")
	else:
		Input.action_release("attack")

func _report() -> void:
	print("=== WCIELENIA, build %s, wyczyszczone pokoje %d ===" % [build_name, rooms_cleared])
	for r in results:
		print("  %d %-22s HP %4.0f   czas %6.1f s   umiejętności: %d   przełamania postawy: %d" % [r["chapter"], r["name"], r["hp"], r["time"], r["skills"], r["breaks"]])
	quit()
