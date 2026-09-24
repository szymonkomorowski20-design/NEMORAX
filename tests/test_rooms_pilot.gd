extends RefCounted
## Paczka 5 (AUDYT E2/D): ziarno próby, przepisy spotkań, układy, pokój
## pułapek i akcenty motywów. Warunki odbioru z audytu: "20-pokojowa seria
## seedów bez układów niemożliwych, test bez obrażeń w pokoju pułapek, test
## szerokości drzwi".

const PLAY := Rect2(127, 108, 1025, 507) # ≈ IntegratedRoomVisual.play_rect(room.ARENA_RECT)

func _play_rect() -> Rect2:
	return IntegratedRoomVisual.play_rect(Rect2(90, 60, 1100, 600))

func _snapshot() -> Dictionary:
	var out := {}
	for pos in GameFlow.room_map:
		var d: Dictionary = GameFlow.room_map[pos]
		out[pos] = [d["type"], d["chapter"], d["enemy_index"], d.get("theme", -1), d.get("layout", ""), d.get("trap", false), d.get("has_chest", false)]
	return out

func _with_seed(seed_value: int) -> void:
	GameFlow.reset_run(seed_value)

func _restore() -> void:
	GameFlow.reset_run()

func test_same_seed_gives_same_run(root: Node) -> void:
	_with_seed(4242)
	var a := _snapshot()
	_with_seed(4242)
	var b := _snapshot()
	_with_seed(4243)
	var c := _snapshot()
	NemoraxTest.assert_eq(a, b, "ten sam seed = ta sama mapa, motywy, układy i pułapka")
	NemoraxTest.assert_true(a != c, "inny seed = inna próba")
	_restore()

func test_each_run_has_exactly_one_trap_room_away_from_start(root: Node) -> void:
	for s in 20:
		_with_seed(1000 + s)
		var traps := 0
		for pos in GameFlow.room_map:
			var d: Dictionary = GameFlow.room_map[pos]
			if d.get("trap", false):
				traps += 1
				NemoraxTest.assert_true(absi(pos.x) + absi(pos.y) >= 2, "pułapka nie w pierwszym pokoju za startem (seed %d)" % (1000 + s))
				NemoraxTest.assert_eq(d["theme"], EncounterPlan.THEME_RUSTED, "pułapka = rdzawa hala")
				NemoraxTest.assert_true(int(d["enemy_index"]) in EncounterPlan.TRAP_ENEMIES, "przy pułapce tylko proste role")
			elif d["type"] == GameFlow.RoomType.RANDOM:
				NemoraxTest.assert_true(int(d["theme"]) != EncounterPlan.THEME_RUSTED, "rdzawa hala tylko jako pokój pułapek")
		NemoraxTest.assert_eq(traps, 1, "dokładnie jeden pokój pułapek w próbie (seed %d)" % (1000 + s))
	_restore()

## 20 seedów × każdy pokój RANDOM × 4 wejścia × każdy możliwy skład walki:
## przejścia >= MIN_GAP, nic przy drzwiach, wróg daleko od wejścia.
func test_twenty_seeds_have_no_impossible_layouts(root: Node) -> void:
	var play := _play_rect()
	var compositions: Array = [[["front"]]]
	for id in EncounterPlan.RECIPES:
		var ranks: Array = []
		for m in EncounterPlan.RECIPES[id]["members"]:
			ranks.append(m[1])
		compositions.append([ranks])
	var checked := 0
	for s in 20:
		_with_seed(2000 + s)
		for pos in GameFlow.room_map:
			var d: Dictionary = GameFlow.room_map[pos]
			if d["type"] != GameFlow.RoomType.RANDOM:
				continue
			var obstacles := EncounterPlan.layout_obstacles(str(d["layout"]), play)
			for entry in GameFlow.DIRECTIONS:
				var entry_pt := EncounterPlan.entry_point(play, entry)
				for comp in compositions:
					var points := EncounterPlan.spawn_points(play, entry, comp[0])
					var pushed: Array[Vector2] = []
					for p in points:
						var q := EncounterPlan.push_out_of(obstacles, p, EncounterPlan.SPAWN_OBSTACLE_CLEARANCE)
						pushed.append(q)
						NemoraxTest.assert_true(q.distance_to(entry_pt) >= EncounterPlan.MIN_SPAWN_DISTANCE_FROM_ENTRY - 1.0,
							"wróg %s za blisko wejścia %s (seed %d, układ %s)" % [q, entry, 2000 + s, d["layout"]])
					var problem := EncounterPlan.validate_layout(play, obstacles, pushed)
					NemoraxTest.assert_eq(problem, "", "seed %d, pokój %s, układ %s, wejście %s" % [2000 + s, pos, d["layout"], entry])
					checked += 1
	NemoraxTest.assert_true(checked > 1000, "sprawdzono realnie dużo kombinacji (%d)" % checked)
	_restore()

func test_layout_validator_rejects_blocked_door_and_narrow_gap(root: Node) -> void:
	var play := _play_rect()
	var c := play.get_center()
	var at_door: Array[Rect2] = [Rect2(Vector2(c.x - 40, play.position.y), Vector2(80, 60))]
	NemoraxTest.assert_true(EncounterPlan.validate_layout(play, at_door) != "", "przeszkoda przy drzwiach musi być odrzucona")
	# Ściana w poprzek pokoju ze szczeliną 80 px < MIN_GAP.
	var wall: Array[Rect2] = [Rect2(Vector2(c.x - 20, play.position.y + 140), Vector2(40, play.size.y - 140 - 80))]
	NemoraxTest.assert_true(EncounterPlan.validate_layout(play, wall) != "", "za wąskie przejście musi być odrzucone")

func test_pressure_limit_grows_and_recipes_unlock(root: Node) -> void:
	NemoraxTest.assert_true(EncounterPlan.recipes_allowed(0).is_empty(), "na starcie trasy bez grup")
	NemoraxTest.assert_true(EncounterPlan.recipes_allowed(3).size() >= 1, "po 3 pokojach pierwsze przepisy")
	NemoraxTest.assert_true("sfora" in EncounterPlan.recipes_allowed(12), "sfora później")
	for id in EncounterPlan.RECIPES:
		NemoraxTest.assert_true(EncounterPlan.recipe_pressure(id) <= EncounterPlan.pressure_limit(30), "przepis %s mieści się w limicie presji" % id)

func test_no_three_similar_fights_in_a_row_rule(root: Node) -> void:
	NemoraxTest.assert_true(EncounterPlan.would_repeat_three(["single:melee", "single:melee"], "single:melee"), "trzeci taki sam podpis zabroniony")
	NemoraxTest.assert_true(not EncounterPlan.would_repeat_three(["single:ranged", "single:melee"], "single:melee"), "dwa pod rząd są dozwolone")
	for i in EncounterPlan.ENEMY_CATEGORY.size():
		var alt := EncounterPlan.alternative_enemy(i, 7 + i)
		NemoraxTest.assert_true(EncounterPlan.ENEMY_CATEGORY[alt] != EncounterPlan.ENEMY_CATEGORY[i], "zastępca %d ma inną kategorię" % i)

# --- Pokój pułapek ---

func _trap_terrain(root: Node) -> RoomTerrain:
	var terrain := RoomTerrain.new()
	terrain.setup(_play_rect(), "open", EncounterPlan.THEME_RUSTED, true)
	root.add_child(terrain)
	return terrain

func test_trap_leaves_safe_route_along_walls_and_doors(root: Node) -> void:
	var play := _play_rect()
	var plates := EncounterPlan.trap_plates(play)
	NemoraxTest.assert_true(plates.size() >= 8, "pilotaż ma realną liczbę płyt (%d)" % plates.size())
	var ring := play.grow(-60.0) # tor gracza 60 px od ściany
	for plate in plates:
		var r: Rect2 = plate["rect"]
		NemoraxTest.assert_true(play.grow(-EncounterPlan.TRAP_SAFE_BORDER + 1.0).encloses(r), "płyta w pasie przy ścianie")
		for door in EncounterPlan.door_points(play):
			NemoraxTest.assert_true(EncounterPlan._rect_distance(r, door) >= EncounterPlan.DOOR_CLEARANCE, "płyta przy drzwiach")
		for t in 200:
			var f := t / 200.0
			for p in [ring.position.lerp(Vector2(ring.end.x, ring.position.y), f), ring.position.lerp(Vector2(ring.position.x, ring.end.y), f),
					ring.end.lerp(Vector2(ring.end.x, ring.position.y), f), ring.end.lerp(Vector2(ring.position.x, ring.end.y), f)]:
				NemoraxTest.assert_true(not r.grow(EncounterPlan.PLAYER_RADIUS).has_point(p), "trasa przy ścianach wolna od płyt")

func test_trap_rhythm_is_readable(root: Node) -> void:
	NemoraxTest.assert_true(EncounterPlan.TRAP_TELEGRAPH >= 0.6, "telegraf >= 0,6 s")
	var t := 0.0
	while t < EncounterPlan.TRAP_PERIOD * 2.0:
		var a := EncounterPlan.trap_phase(0, t) == "active"
		var b := EncounterPlan.trap_phase(1, t) == "active"
		NemoraxTest.assert_true(not (a and b), "nigdy obie grupy naraz (t=%.2f)" % t)
		t += 0.02

func test_trap_first_cycle_is_a_harmless_preview(root: Node) -> void:
	var player: Player = load("res://entities/player.tscn").instantiate()
	root.add_child(player)
	var terrain := _trap_terrain(root)
	var plate: Dictionary = terrain.plates[0]
	player.global_position = (plate["rect"] as Rect2).get_center()
	var hp := player.health
	var saw_active := false
	var steps := int((RoomTerrain.TRAP_START_GRACE + EncounterPlan.TRAP_PERIOD) / 0.05) - 1
	for i in steps:
		terrain._physics_process(0.05)
		if terrain.plate_phase(int(plate["group"])) == "active":
			saw_active = true
	NemoraxTest.assert_true(saw_active, "podgląd pokazuje pełny cykl (także uderzenie)")
	NemoraxTest.assert_almost_eq(player.health, hp, 0.01, "wejście i pierwszy cykl bez obrażeń")
	for i in int(EncounterPlan.TRAP_PERIOD / 0.05) + 2:
		player._invuln_timer = 0.0
		terrain._physics_process(0.05)
	NemoraxTest.assert_true(player.health < hp, "po podglądzie prasa rani (nieblokowalnie)")
	terrain.stop_trap()
	var after := player.health
	for i in 80:
		player._invuln_timer = 0.0
		terrain._physics_process(0.05)
	NemoraxTest.assert_almost_eq(player.health, after, 0.01, "po oczyszczeniu pokoju prasy stoją")
	root.remove_child(terrain)
	terrain.queue_free()
	root.remove_child(player)
	player.queue_free()

# --- Akcenty motywów i przeszkody ---

func test_cover_blocks_projectiles_and_crystal_bounces_once(root: Node) -> void:
	var cover := RoomTerrain.new()
	cover.setup(_play_rect(), "oslona", EncounterPlan.THEME_LIBRARY, false)
	cover._shelf_fall = 1.0
	var probe := Node2D.new()
	probe.set_meta("dummy", true)
	root.add_child(probe)
	probe.global_position = cover.obstacles[0].get_center()
	NemoraxTest.assert_eq(cover.projectile_step(probe), "blocked", "regał-osłona zatrzymuje pocisk")
	cover.free()
	var projectile = load("res://entities/enemy_projectile.tscn").instantiate()
	root.add_child(projectile)
	var crystal := RoomTerrain.new()
	crystal.setup(_play_rect(), "open", EncounterPlan.THEME_CRYSTAL, false)
	root.add_child(crystal)
	projectile.direction = Vector2.RIGHT
	projectile.global_position = Vector2(_play_rect().end.x + 5.0, _play_rect().get_center().y)
	NemoraxTest.assert_eq(crystal.projectile_step(projectile), "bounced", "kryształowa ściana odbija")
	NemoraxTest.assert_eq(projectile.direction, Vector2.LEFT, "w drugą stronę")
	projectile.global_position = Vector2(_play_rect().position.x - 5.0, _play_rect().get_center().y)
	NemoraxTest.assert_eq(crystal.projectile_step(projectile), "ok", "ale tylko raz")
	root.remove_child(crystal)
	crystal.queue_free()
	root.remove_child(projectile)
	projectile.queue_free()
	root.remove_child(probe)
	probe.queue_free()

func test_slow_lane_slows_player_and_enemies(root: Node) -> void:
	var lane := EncounterPlan.slow_lane_rect(_play_rect())
	var player: Player = load("res://entities/player.tscn").instantiate()
	root.add_child(player)
	player.slow_zones = [lane]
	player.global_position = Vector2(lane.get_center().x, _play_rect().position.y + 40.0)
	Input.action_press("move_right")
	for i in 60:
		player._process_normal_movement(1.0 / 60.0)
	var dry := player.velocity.length()
	player.global_position = lane.get_center()
	for i in 60:
		player._process_normal_movement(1.0 / 60.0)
	Input.action_release("move_right")
	NemoraxTest.assert_true(player.velocity.length() < dry * 0.8, "płycizna spowalnia gracza")
	var enemy: Incarnation = load("res://entities/random_enemies/chaser.tscn").instantiate()
	root.add_child(enemy)
	var zones: Array[Rect2] = [lane]
	enemy.slow_zones = zones
	enemy.global_position = lane.get_center()
	NemoraxTest.assert_almost_eq(enemy._terrain_speed_factor(), EncounterPlan.SLOW_LANE_MULTIPLIER, 0.001, "i wrogów tak samo")
	root.remove_child(enemy)
	enemy.queue_free()
	root.remove_child(player)
	player.queue_free()

func test_enemies_are_pushed_out_of_obstacles(root: Node) -> void:
	var play := _play_rect()
	var obstacles := EncounterPlan.layout_obstacles("dwa_filary", play)
	var enemy = load("res://entities/random_enemies/tank.tscn").instantiate()
	root.add_child(enemy)
	enemy.arena_rect = play
	enemy.obstacles = obstacles
	var inside := obstacles[0].get_center()
	var out: Vector2 = enemy._clamp_to_arena(inside)
	NemoraxTest.assert_true(EncounterPlan._rect_distance(obstacles[0], out) >= enemy.radius - 0.5, "wróg nie wchodzi w filar")
	root.remove_child(enemy)
	enemy.queue_free()

## Regresja: seed 378 dawał mapę bez ołtarza (próby nie dało się ukończyć).
func test_every_seed_gives_a_completable_map(_root: Node) -> void:
	for s in 400:
		GameFlow.reset_run(s)
		var souls := 0
		var altars := 0
		for pos in GameFlow.room_map:
			var t: int = GameFlow.room_map[pos]["type"]
			if t == GameFlow.RoomType.SOUL:
				souls += 1
			elif t == GameFlow.RoomType.ALTAR:
				altars += 1
		NemoraxTest.assert_true(souls == 6 and altars == 1, "seed %d: dusze %d, ołtarz %d" % [s, souls, altars])
	GameFlow.reset_run()

## Audyt nagrania 24.09 (P1): kryształy są kępami przy murze, prasy mają stan
## stygnięcia, a powrót do wyczyszczonej biblioteki nie przewraca regałów znowu.
func test_crystal_clusters_and_revisited_library(root: Node) -> void:
	var crystal := RoomTerrain.new()
	crystal.setup(_play_rect(), "open", EncounterPlan.THEME_CRYSTAL, false)
	NemoraxTest.assert_true(crystal._crystals.size() >= 12, "kępy kryształu wzdłuż wszystkich ścian")
	var gaps: Array = []
	for i in range(1, crystal._crystals.size()):
		gaps.append(snappedf((crystal._crystals[i]["pos"] as Vector2).distance_to(crystal._crystals[i - 1]["pos"]), 1.0))
	NemoraxTest.assert_true(gaps.max() != gaps.min(), "odstępy nieregularne, nie równy znacznik co 64 px")
	crystal._crystal_glow_near(crystal._crystals[0]["pos"], 1.0)
	NemoraxTest.assert_almost_eq(float(crystal._crystals[0]["glow"]), 1.0, 0.01, "odbicie rozjarza najbliższą kępę")
	var library := RoomTerrain.new()
	library.setup(_play_rect(), "oslona", EncounterPlan.THEME_LIBRARY, false)
	library.shelves_already_fallen = true
	root.add_child(library)
	NemoraxTest.assert_almost_eq(library._shelf_fall, 1.0, 0.01, "wyczyszczona biblioteka: regały już leżą")
	root.remove_child(library)
	library.queue_free()
	crystal.free()
