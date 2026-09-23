extends Node2D
class_name RoomTerrain
## Paczka 5 (AUDYT E2/D) — teren pokoju RANDOM: przeszkody układu, akcent
## motywu i pilotażowy pokój pułapek. Jeden węzeł w grupie "room_terrain",
## o który pytają pociski (projectile_step) — wrogowie dostają przeszkody i
## płyciznę bezpośrednio (Incarnation.obstacles / slow_zones).
##
## Wszystko rysuje się POD postaciami (z_index -3), więc teren nigdy nie
## zasłania gracza ani telegrafów.

const SND_PRESS_TELEGRAPH := preload("res://assets/audio/sfx/p0/ENEMY_TELEGRAPH_2.wav")
const SND_PRESS_SLAM := preload("res://assets/audio/sfx/nemorax/N04_seal_explosion.wav")
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
var _bounce_flashes: Array[Dictionary] = []
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
		var tw := create_tween()
		tw.tween_interval(0.6)
		tw.tween_callback(func(): _play(SND_SHELF_FALL, play_rect.get_center()))
		tw.tween_property(self, "_shelf_fall", 1.0, 0.35).set_ease(Tween.EASE_IN)

func _physics_process(delta: float) -> void:
	_time += delta
	for f in _bounce_flashes:
		f["t"] = float(f["t"]) - delta
	_bounce_flashes = _bounce_flashes.filter(func(f): return float(f["t"]) > 0.0)
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
		_bounce_flashes.append({"pos": p.global_position, "t": 0.25})
		_play(SND_BOUNCE, p.global_position)
		return "bounced"
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
		draw_rect(slow_lane, WATER, true)
		# Brzegi płycizny — kształt granicy, nie sam kolor.
		for y in [slow_lane.position.y, slow_lane.end.y]:
			var x0 := slow_lane.position.x
			while x0 < slow_lane.end.x:
				draw_line(Vector2(x0, y), Vector2(x0 + 22.0, y + 3.0 * sin(_time * 2.0 + x0 * 0.05)), WATER_RIPPLE, 2.0)
				x0 += 30.0
		for i in 6:
			var x := slow_lane.position.x + fposmod(_time * 40.0 + i * slow_lane.size.x / 6.0, slow_lane.size.x)
			var y := slow_lane.position.y + slow_lane.size.y * (0.3 + 0.4 * float(i % 2))
			draw_line(Vector2(x, y), Vector2(x + 46.0, y), WATER_RIPPLE, 2.0)
	if bounce_walls:
		# Kryształowe krawędzie: ściana odbija (kształt: zęby kryształu, nie tylko kolor).
		var step := 64.0
		var x := play_rect.position.x
		while x < play_rect.end.x:
			for y in [play_rect.position.y, play_rect.end.y]:
				var inward := 1.0 if y == play_rect.position.y else -1.0
				draw_colored_polygon(PackedVector2Array([Vector2(x, y), Vector2(x + 14.0, y), Vector2(x + 7.0, y + 16.0 * inward)]), CRYSTAL)
			x += step
		var y2 := play_rect.position.y
		while y2 < play_rect.end.y:
			for xx in [play_rect.position.x, play_rect.end.x]:
				var inward := 1.0 if xx == play_rect.position.x else -1.0
				draw_colored_polygon(PackedVector2Array([Vector2(xx, y2), Vector2(xx, y2 + 14.0), Vector2(xx + 16.0 * inward, y2 + 7.0)]), CRYSTAL)
			y2 += step
		for f in _bounce_flashes:
			draw_circle(f["pos"], 22.0 * (1.0 - float(f["t"]) / 0.25) + 6.0, Color(CRYSTAL, float(f["t"]) * 3.0))
	for plate in plates:
		_draw_plate(plate["rect"], plate_phase(int(plate["group"])))
	for r in obstacles:
		_draw_obstacle(r)

func _draw_plate(rect: Rect2, phase: String) -> void:
	draw_rect(rect, PLATE_IDLE, true)
	draw_rect(rect, Color(0.12, 0.09, 0.08, 0.9), false, 2.0)
	if phase == "telegraph":
		# Forma + rytm: kreskowanie "pod nogami" + kurczący się kwadrat odliczania.
		var hatch := 18.0
		var i := -rect.size.y
		while i < rect.size.x:
			var a := rect.position + Vector2(maxf(i, 0.0), maxf(-i, 0.0))
			var b := rect.position + Vector2(minf(i + rect.size.y, rect.size.x), minf(rect.size.x - i, rect.size.y))
			draw_line(a, b, Color(PLATE_WARN, 0.55), 2.0)
			i += hatch
		var local := fposmod(trap_time, EncounterPlan.TRAP_PERIOD * 0.5)
		var k := clampf(1.0 - local / EncounterPlan.TRAP_TELEGRAPH, 0.0, 1.0)
		draw_rect(Rect2(rect.get_center() - rect.size * 0.5 * k, rect.size * k), PLATE_WARN, false, 3.0)
		draw_rect(rect, PLATE_WARN, false, 3.0)
	elif phase == "active":
		draw_rect(rect, PLATE_ACTIVE, true)
		draw_rect(rect.grow(-rect.size.x * 0.3), Color(0.35, 0.22, 0.12, 0.9), true) # głowica prasy

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
		# Stojący regał: wysoki, cienki — dopiero po upadku zajmuje prostokąt osłony.
		var standing := Rect2(Vector2(r.position.x, r.end.y - r.size.y * (1.0 + 2.0 * (1.0 - _shelf_fall))), Vector2(r.size.x, r.size.y * (1.0 + 2.0 * (1.0 - _shelf_fall))))
		draw_rect(standing, side, true)
		draw_rect(standing.grow(-4.0), top, false, 2.0)
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
