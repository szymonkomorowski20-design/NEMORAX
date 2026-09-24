extends Node2D
class_name RoomTerrain
## Paczka 5 (AUDYT E2/D) — teren pokoju RANDOM: przeszkody układu, akcent
## motywu i pilotażowy pokój pułapek. Jeden węzeł w grupie "room_terrain",
## o który pytają pociski (projectile_step) — wrogowie dostają przeszkody i
## płyciznę bezpośrednio (Incarnation.obstacles / slow_zones).
##
## Wszystko rysuje się POD postaciami (z_index -3), więc teren nigdy nie
## zasłania gracza ani telegrafów.

const SND_PRESS_TELEGRAPH := preload("res://assets/audio/sfx/swiat/W10_trap_press_warn.mp3")
const SND_PRESS_SLAM := preload("res://assets/audio/sfx/swiat/W11_trap_press_slam.mp3")
const SND_SHELF_FALL := preload("res://assets/audio/sfx/nemorax/N14_body_contact.wav")
const SND_BOUNCE := preload("res://assets/audio/sfx/p0/ENEMY_HIT_2.wav")

const OBSTACLE_TOP := Color(0.62, 0.60, 0.66, 1.0)
const OBSTACLE_SIDE := Color(0.24, 0.22, 0.28, 1.0)
const SHELF_TOP := Color(0.46, 0.33, 0.22, 1.0)
const SHELF_SIDE := Color(0.22, 0.14, 0.09, 1.0)
const WATER := Color(0.20, 0.42, 0.52, 0.42)
const WATER_RIPPLE := Color(0.62, 0.84, 0.92, 0.35)
const CRYSTAL := Color(0.55, 0.92, 1.0, 0.55)
const PLATE_IDLE := Color(0.30, 0.24, 0.20, 0.55)
const PLATE_WARN := Color(0.96, 0.62, 0.20, 0.95) ## pomarańcz rdzy — strefa pod nogami, nieblokowalna
const PLATE_ACTIVE := Color(1.0, 0.86, 0.55, 0.95)

var play_rect: Rect2
var layout: String = "open"
var accent: String = ""
var obstacles: Array[Rect2] = []
var slow_lane := Rect2()
var bounce_walls := false
var plates: Array[Dictionary] = []
var wall_texture: Texture2D ## mur motywu pokoju — ustawiany przez room.gd

## Pułapka: ujemny czas = łaska po wejściu, pierwszy pełny cykl = podgląd
## bez obrażeń ("pokazać cykl przed pierwszym trafieniem").
const TRAP_START_GRACE := 1.2
var trap_time: float = -TRAP_START_GRACE
var _last_phase := {0: "idle", 1: "idle"}
var _activation := {0: 0, 1: 0}
var _enemy_hit_activation := {} ## instance_id -> "grupa:aktywacja", jedno trafienie wroga na slam

var _shelf_fall: float = 1.0 ## 0 = regał stoi, 1 = przewrócony (biblioteka)
var shelves_already_fallen := false ## ustawiane przez room.gd dla wyczyszczonego pokoju
var _time: float = 0.0
var _sfx: AudioStreamPlayer2D

func setup(rect: Rect2, room_layout: String, theme: int, trap: bool) -> void:
	play_rect = rect
	layout = room_layout
	accent = "press_plates" if trap else str(EncounterPlan.THEME_ACCENT.get(theme, ""))
	if accent == "press_plates" and not trap:
		accent = "" # prasy tylko w wyznaczonym pokoju pułapek
	obstacles = EncounterPlan.layout_obstacles(layout, play_rect)
	match accent:
		"slow_lane":
			slow_lane = EncounterPlan.slow_lane_rect(play_rect)
		"single_bounce":
			bounce_walls = true
			_build_crystals()
		"press_plates":
			plates = EncounterPlan.trap_plates(play_rect)
		"projectile_cover":
			_shelf_fall = 0.0

func _ready() -> void:
	add_to_group("room_terrain")
	z_index = -3
	texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED # tekstura muru kafelkowana na przeszkodach
	_sfx = AudioStreamPlayer2D.new()
	_sfx.bus = &"SFX"
	add_child(_sfx)
	for r in obstacles:
		var body := StaticBody2D.new()
		body.collision_layer = 1
		body.collision_mask = 0
		body.position = r.get_center()
		var shape := CollisionShape2D.new()
		var rect_shape := RectangleShape2D.new()
		rect_shape.size = r.size
		shape.shape = rect_shape
		body.add_child(shape)
		add_child(body)
	if accent == "projectile_cover":
		# Regały przewracają się chwilę po wejściu — od tej pory to osłona.
		# Powrót do wyczyszczonej biblioteki: upadek już się wydarzył.
		if shelves_already_fallen:
			_shelf_fall = 1.0
			return
		var tw := create_tween()
		tw.tween_interval(0.6)
		tw.tween_callback(func(): _play(SND_SHELF_FALL, play_rect.get_center()))
		tw.tween_property(self, "_shelf_fall", 1.0, 0.35).set_ease(Tween.EASE_IN)

func _physics_process(delta: float) -> void:
	_time += delta
	for c in _crystals:
		c["glow"] = maxf(0.0, float(c["glow"]) - CRYSTAL_FADE * delta)
	if not plates.is_empty() and trap_running:
		_tick_trap(delta)
	queue_redraw()

# --- Pociski ---

## Wołane przez pociski co klatkę. "blocked" = pocisk ma zniknąć,
## "bounced" = kierunek zmieniony (kryształowa grota, raz na pocisk).
func projectile_step(p: Node2D) -> String:
	var pos := p.global_position
	if _shelf_fall >= 0.99:
		for r in obstacles:
			if r.has_point(pos):
				return "blocked"
	if bounce_walls and not play_rect.has_point(pos) and not p.has_meta("terrain_bounced"):
		var d: Vector2 = p.get("direction")
		if pos.x < play_rect.position.x or pos.x > play_rect.end.x:
			d.x = -d.x
		if pos.y < play_rect.position.y or pos.y > play_rect.end.y:
			d.y = -d.y
		p.set("direction", d)
		p.global_position = pos.clamp(play_rect.position, play_rect.end)
		p.set_meta("terrain_bounced", true)
		_crystal_glow_near(p.global_position, 1.0)
		_play(SND_BOUNCE, p.global_position)
		return "bounced"
	if bounce_walls and not p.has_meta("terrain_bounced") and not play_rect.grow(-CRYSTAL_NEAR).has_point(pos):
		_crystal_glow_near(pos, 0.45) # zapowiedź: pocisk zbliża się do kryształowej ściany
	return "ok"

# --- Pułapka ---

var trap_running := true

## Po oczyszczeniu pokoju prasy stają (płyty zostają widoczne, bez cyklu).
func stop_trap() -> void:
	trap_running = false

func is_trap_preview() -> bool:
	return trap_time < EncounterPlan.TRAP_PERIOD

func plate_phase(group: int) -> String:
	if trap_time < 0.0 or not trap_running:
		return "idle"
	return EncounterPlan.trap_phase(group, trap_time)

func _tick_trap(delta: float) -> void:
	trap_time += delta
	for group in [0, 1]:
		var phase := plate_phase(group)
		if phase != _last_phase[group]:
			if phase == "telegraph":
				_play(SND_PRESS_TELEGRAPH, play_rect.get_center())
			elif phase == "active":
				_activation[group] += 1
				_play(SND_PRESS_SLAM, play_rect.get_center())
			_last_phase[group] = phase
		if phase == "active" and not is_trap_preview():
			_apply_plate_damage(group)

func _apply_plate_damage(group: int) -> void:
	var player := get_tree().get_first_node_in_group("player") as Player
	for plate in plates:
		if int(plate["group"]) != group:
			continue
		var rect: Rect2 = plate["rect"]
		if player != null and rect.grow(-4.0).has_point(player.global_position):
			player.take_damage(EncounterPlan.TRAP_DAMAGE, rect.get_center(), false, self)
		for enemy in get_tree().get_nodes_in_group("hittable"):
			if enemy.get("is_dead") == true or not (enemy is Node2D):
				continue
			var key := "%d:%d" % [group, _activation[group]]
			if _enemy_hit_activation.get(enemy.get_instance_id(), "") == key:
				continue
			if rect.has_point((enemy as Node2D).global_position):
				_enemy_hit_activation[enemy.get_instance_id()] = key
				Juice.apply_hit(enemy, EncounterPlan.TRAP_DAMAGE * 1.5, 0.0, true, "trap")

# --- Rysowanie ---

func _draw() -> void:
	if slow_lane.has_area():
		_draw_water()
	if bounce_walls:
		_draw_crystals()
	for plate in plates:
		_draw_plate(plate["rect"], int(plate["group"]))
	for r in obstacles:
		_draw_obstacle(r)

# --- Zalana katakumba (audyt nagrania P1.7): miękkie wejście w wodę, mokry
# kamień przy brzegu, ciągła linia brzegu i kręgi fal u stóp stojących w wodzie.
# Granica obszaru (spowolnienie) pozostaje dokładnie na krawędzi slow_lane.

const WATER_DEEP := Color(0.16, 0.36, 0.46, 0.46)
const WATER_EDGE_BAND := 24.0 ## px łagodnego przejścia wewnątrz pasa
const WET_STONE := Color(0.02, 0.05, 0.07, 0.30) ## ciemniejszy, mokry kamień tuż za brzegiem

func _draw_water() -> void:
	var r := slow_lane
	var band := WATER_EDGE_BAND
	# Mokry kamień: nieregularny ciemny pas po obu stronach brzegu.
	for side in [-1.0, 1.0]:
		var y_edge := r.position.y if side < 0.0 else r.end.y
		var x := r.position.x
		while x < r.end.x:
			var next_x := minf(x + 24.0, r.end.x)
			var w0 := maxf(1.0, 5.0 + 4.0 * sin(x * 0.043 + side * 1.7) + 3.0 * sin(x * 0.11))
			var w1 := maxf(1.0, 5.0 + 4.0 * sin(next_x * 0.043 + side * 1.7) + 3.0 * sin(next_x * 0.11))
			# Wąskie, wypukłe czworokąty nie przecinają własnej krawędzi.
			draw_colored_polygon(PackedVector2Array([
				Vector2(x, y_edge), Vector2(next_x, y_edge),
				Vector2(next_x, y_edge + side * w1), Vector2(x, y_edge + side * w0)
			]), WET_STONE)
			x = next_x
	# Tafla: pasy z gradientem na brzegach zamiast twardego prostokąta.
	# Drugi audyt (C2): przejście jest WYŚRODKOWANE na granicy spowolnienia —
	# na samej krawędzi slow_lane woda jest już w połowie widoczna, więc
	# spowolnienie nigdy nie zaczyna się na „suchym” kamieniu.
	var half := band * 0.5
	for k in 8:
		var a0 := float(k) / 8.0
		var y_top := r.position.y - half + band * a0
		var y_bot := r.end.y + half - band * a0
		var col := Color(WATER_DEEP, WATER_DEEP.a * (a0 + 0.0625))
		draw_rect(Rect2(Vector2(r.position.x, y_top), Vector2(r.size.x, band / 8.0)), col, true)
		draw_rect(Rect2(Vector2(r.position.x, y_bot - band / 8.0), Vector2(r.size.x, band / 8.0)), col, true)
	draw_rect(Rect2(Vector2(r.position.x, r.position.y + half), Vector2(r.size.x, r.size.y - band)), WATER_DEEP, true)
	# Linia brzegu: jedna ciągła, lekko falująca krawędź (nie przerywane kreski).
	for y_edge in [r.position.y, r.end.y]: # dokładnie na granicy spowolnienia
		var line := PackedVector2Array()
		var x2 := r.position.x
		while x2 <= r.end.x + 0.1:
			line.append(Vector2(x2, y_edge + 2.0 * sin(_time * 1.6 + x2 * 0.035)))
			x2 += 16.0
		draw_polyline(line, Color(WATER_RIPPLE, 0.45), 1.5, true)
	# Nurt: kilka długich, bladych smug.
	for i in 5:
		var sx := r.position.x + fposmod(_time * 32.0 + i * r.size.x / 5.0, r.size.x)
		var sy := r.position.y + r.size.y * (0.28 + 0.44 * float(i % 2)) + 4.0 * sin(_time + i)
		draw_line(Vector2(sx, sy), Vector2(minf(sx + 60.0, r.end.x), sy), Color(WATER_RIPPLE, 0.18), 2.0, true)
	# Kręgi fal u stóp postaci w wodzie — widać, że stoją W wodzie.
	for body in _bodies_in_water():
		var feet: Vector2 = body.global_position - global_position + Vector2(0.0, float(body.get("radius") if body.get("radius") != null else 20.0) * 0.8)
		for k in 2:
			var phase := fposmod(_time * 1.2 + k * 0.5, 1.0)
			var rad := 18.0 + 26.0 * phase
			draw_set_transform(feet, 0.0, Vector2(1.0, 0.38))
			draw_arc(Vector2.ZERO, rad, 0.0, TAU, 28, Color(WATER_RIPPLE, 0.5 * (1.0 - phase)), 2.0, true)
			draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _bodies_in_water() -> Array:
	var out: Array = []
	var candidates: Array = get_tree().get_nodes_in_group("hittable")
	var player := get_tree().get_first_node_in_group("player")
	if player != null:
		candidates.append(player)
	for b in candidates:
		if b is Node2D and b.get("is_dead") != true and slow_lane.has_point((b as Node2D).global_position):
			out.append(b)
	return out

# --- Kryształowa grota (audyt nagrania P1.5): nieregularne kępy kryształu
# osadzone u stóp muru zamiast równych trójkątów. Spoczynek (przygaszone) →
# zapowiedź (pocisk blisko ściany: rozjarzenie) → aktywacja (odbicie: błysk) →
# wygaszenie. Odbija dokładnie krawędź play_rect — tam, gdzie stoją kępy.

const CRYSTAL_NEAR := 90.0 ## px od ściany, od których kępa się rozjarza
const CRYSTAL_FADE := 1.6 ## 1/s wygasania rozjarzenia
var _crystals: Array[Dictionary] = []

func _build_crystals() -> void:
	_crystals.clear()
	var rng := RandomNumberGenerator.new()
	rng.seed = hash([int(play_rect.position.x), int(play_rect.size.x), int(play_rect.size.y)])
	var edges := [
		[play_rect.position, Vector2(play_rect.end.x, play_rect.position.y), Vector2.DOWN],
		[Vector2(play_rect.position.x, play_rect.end.y), play_rect.end, Vector2.UP],
		[play_rect.position, Vector2(play_rect.position.x, play_rect.end.y), Vector2.RIGHT],
		[Vector2(play_rect.end.x, play_rect.position.y), play_rect.end, Vector2.LEFT],
	]
	for e in edges:
		var a: Vector2 = e[0]
		var b: Vector2 = e[1]
		var length := a.distance_to(b)
		var t := rng.randf_range(30.0, 70.0)
		while t < length - 30.0:
			var shards: Array = []
			for s in rng.randi_range(2, 4):
				shards.append([rng.randf_range(10.0, 26.0), rng.randf_range(4.0, 7.0), rng.randf_range(-0.55, 0.55), rng.randf_range(-7.0, 7.0)])
			_crystals.append({"pos": a.lerp(b, t / length), "in": e[2], "shards": shards, "glow": 0.0})
			t += rng.randf_range(80.0, 150.0)

func _crystal_glow_near(pos: Vector2, amount: float) -> void:
	var best := -1
	var best_d := INF
	for i in _crystals.size():
		var d: float = (_crystals[i]["pos"] as Vector2).distance_to(pos)
		if d < best_d:
			best_d = d
			best = i
	if best >= 0 and best_d < 160.0:
		_crystals[best]["glow"] = maxf(float(_crystals[best]["glow"]), amount)

func _draw_crystals() -> void:
	for c in _crystals:
		var base: Vector2 = c["pos"]
		var inward: Vector2 = c["in"]
		var along := inward.orthogonal()
		var glow := float(c["glow"])
		var shimmer := 0.06 * sin(_time * 1.3 + base.x * 0.02 + base.y * 0.03)
		for s in c["shards"]:
			var tip_dir := inward.rotated(float(s[2]))
			var root_pos := base + along * float(s[3])
			var tip := root_pos + tip_dir * float(s[0]) * (1.0 + 0.25 * glow)
			var side := tip_dir.orthogonal() * float(s[1])
			var body := Color(0.30, 0.55, 0.66, 0.55 + shimmer + 0.35 * glow)
			var edge := Color(0.70, 0.93, 1.0, 0.35 + 0.6 * glow)
			draw_colored_polygon(PackedVector2Array([root_pos - side, tip, root_pos + side]), body)
			draw_line(root_pos, tip, edge, 1.5, true)
		if glow > 0.02:
			draw_circle(base + inward * 10.0, 14.0 + 18.0 * glow, Color(CRYSTAL, 0.25 * glow))

# --- Hala: moduły prasy (audyt nagrania P1.6). Spoczynek: osadzona w posadzce
# metalowa płyta ze szczeliną, śrubami i głowicą (niska jasność). Zapowiedź:
# świecące fugi + odliczający kwadrat, kreskowanie tylko jako warstwa
# ostrzegawcza. Aktywacja: jasna głowica i fala pyłu. Wygaszenie: stygnące fugi.

const PLATE_METAL := Color(0.19, 0.18, 0.17, 0.92)
const PLATE_SLOT := Color(0.03, 0.03, 0.03, 0.9)
const PLATE_BEVEL_LIGHT := Color(0.52, 0.48, 0.42, 0.45)
const PLATE_BOLT := Color(0.40, 0.36, 0.30, 0.95)
const PLATE_COOL := 0.4 ## s stygnięcia fug po uderzeniu

func _plate_local(group: int) -> float:
	return fposmod(trap_time - group * EncounterPlan.TRAP_PERIOD * 0.5, EncounterPlan.TRAP_PERIOD)

func _draw_plate(rect: Rect2, group: int) -> void:
	var phase := plate_phase(group)
	var local := _plate_local(group)
	# Szczelina wokół modułu i sam moduł (lekko zapadnięty).
	draw_rect(rect.grow(3.0), PLATE_SLOT, true)
	draw_rect(rect, PLATE_METAL, true)
	draw_line(rect.position + Vector2(0, rect.size.y), rect.end, PLATE_BEVEL_LIGHT, 2.0)
	draw_line(Vector2(rect.end.x, rect.position.y), rect.end, PLATE_BEVEL_LIGHT, 2.0)
	draw_line(rect.position, Vector2(rect.end.x, rect.position.y), Color(0, 0, 0, 0.55), 3.0)
	draw_line(rect.position, Vector2(rect.position.x, rect.end.y), Color(0, 0, 0, 0.55), 3.0)
	for corner in [Vector2(10, 10), Vector2(rect.size.x - 10, 10), Vector2(10, rect.size.y - 10), rect.size - Vector2(10, 10)]:
		draw_circle(rect.position + corner, 3.5, PLATE_BOLT)
		draw_circle(rect.position + corner + Vector2(-1, -1), 1.2, Color(0.8, 0.75, 0.65, 0.5))
	var head := rect.grow(-rect.size.x * 0.28)
	var seam_glow := 0.0
	if phase == "telegraph":
		seam_glow = 0.35 + 0.65 * clampf(local / EncounterPlan.TRAP_TELEGRAPH, 0.0, 1.0)
	elif phase == "idle" and trap_running and trap_time >= 0.0:
		var since := local - EncounterPlan.TRAP_TELEGRAPH - EncounterPlan.TRAP_ACTIVE
		if since >= 0.0 and since < PLATE_COOL:
			seam_glow = 0.6 * (1.0 - since / PLATE_COOL)
	if phase == "active":
		# Głowica w dół: jasny metal, fala pyłu na zewnątrz.
		draw_rect(rect, Color(PLATE_ACTIVE, 0.85), true)
		draw_rect(head, Color(0.42, 0.30, 0.18, 0.95), true)
		var k := clampf((local - EncounterPlan.TRAP_TELEGRAPH) / EncounterPlan.TRAP_ACTIVE, 0.0, 1.0)
		draw_rect(rect.grow(6.0 + 18.0 * k), Color(PLATE_ACTIVE, 0.45 * (1.0 - k)), false, 3.0)
	else:
		draw_rect(head, Color(0.13, 0.12, 0.11, 0.95), true)
		draw_rect(head, Color(0, 0, 0, 0.6), false, 2.0)
	if seam_glow > 0.0:
		draw_rect(rect.grow(1.5), Color(PLATE_WARN, seam_glow), false, 3.0)
	if phase == "telegraph":
		# Warstwa ostrzegawcza tylko w zapowiedzi: rzadkie kreskowanie + odliczanie.
		var hatch := 26.0
		var i := -rect.size.y
		while i < rect.size.x:
			var a := rect.position + Vector2(maxf(i, 0.0), maxf(-i, 0.0))
			var b := rect.position + Vector2(minf(i + rect.size.y, rect.size.x), minf(rect.size.x - i, rect.size.y))
			draw_line(a, b, Color(PLATE_WARN, 0.22 * seam_glow), 2.0)
			i += hatch
		var kk := clampf(1.0 - local / EncounterPlan.TRAP_TELEGRAPH, 0.0, 1.0)
		draw_rect(Rect2(rect.get_center() - rect.size * 0.5 * kk, rect.size * kk), Color(PLATE_WARN, 0.85), false, 2.5)

func _draw_obstacle(r: Rect2) -> void:
	var is_shelf := accent == "projectile_cover"
	var top := SHELF_TOP if is_shelf else OBSTACLE_TOP
	var side := SHELF_SIDE if is_shelf else OBSTACLE_SIDE
	draw_rect(Rect2(r.position + Vector2(6, 10), r.size), Color(0, 0, 0, 0.35), true) # cień
	if wall_texture != null and not (is_shelf and _shelf_fall < 0.99):
		# Ten sam materiał co mur pokoju — przeszkoda jest częścią świata, nie naklejką.
		draw_texture_rect(wall_texture, Rect2(r.position + Vector2(0, 8), r.size), true, Color(0.42, 0.40, 0.46) * (Color(1.0, 0.8, 0.6) if is_shelf else Color.WHITE))
		draw_texture_rect(wall_texture, r, true, Color(0.95, 0.92, 1.0) * (Color(1.0, 0.78, 0.55) if is_shelf else Color.WHITE))
		draw_rect(r, Color(0.05, 0.04, 0.07, 0.9), false, 2.0)
		draw_line(r.position + Vector2(2, 2), Vector2(r.end.x - 2, r.position.y + 2), Color(1, 1, 1, 0.18), 2.0)
		if is_shelf:
			for i in range(1, 4):
				var x := r.position.x + r.size.x * i / 4.0
				draw_line(Vector2(x, r.position.y + 4), Vector2(x, r.end.y - 4), Color(0.12, 0.07, 0.04, 0.9), 2.0)
		return
	if is_shelf and _shelf_fall < 0.99:
		# Stojący regał: wysoki front z półkami, ten sam materiał co po upadku
		# (audyt nagrania P1.8 — nie płaski prostokąt koloru).
		var h := r.size.y * (1.0 + 2.0 * (1.0 - _shelf_fall))
		var standing := Rect2(Vector2(r.position.x, r.end.y - h), Vector2(r.size.x, h))
		draw_rect(Rect2(standing.position + Vector2(6, 10), standing.size), Color(0, 0, 0, 0.35), true)
		if wall_texture != null:
			draw_texture_rect(wall_texture, standing, true, Color(0.95, 0.92, 1.0) * Color(1.0, 0.78, 0.55))
		else:
			draw_rect(standing, side, true)
		var shelf_y := standing.position.y + 14.0
		while shelf_y < standing.end.y - 4.0:
			draw_line(Vector2(standing.position.x + 3, shelf_y), Vector2(standing.end.x - 3, shelf_y), Color(0.12, 0.07, 0.04, 0.9), 2.0)
			shelf_y += 16.0
		draw_rect(standing, Color(0.05, 0.04, 0.07, 0.9), false, 2.0)
		return
	draw_rect(Rect2(r.position + Vector2(0, 8), r.size), side, true)
	draw_rect(r, top, true)
	draw_rect(r, side, false, 2.0)
	if is_shelf:
		for i in range(1, 4):
			var x := r.position.x + r.size.x * i / 4.0
			draw_line(Vector2(x, r.position.y + 4), Vector2(x, r.end.y - 4), side, 2.0)

func _play(stream: AudioStream, at: Vector2) -> void:
	_sfx.global_position = at
	_sfx.stream = stream
	_sfx.play()
