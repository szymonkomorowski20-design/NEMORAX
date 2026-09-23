extends RefCounted
class_name EncounterPlan
## Paczka 5 (AUDYT E2/D): przepisy spotkań, układy geometrii i pokój pułapek —
## PILOTAŻ (3 przepisy, 3 układy, 1 pułapka, 4 motywy z akcentem). Czysta
## logika bez sceny: room.gd pyta tu, KOGO i GDZIE postawić, game_flow.gd — co
## wylosować przy generowaniu mapy, a testy sprawdzają reguły bezpieczeństwa.
##
## Indeksy wrogów = GameFlow.RANDOM_ENEMY_SCENES:
## 0 chaser, 1 striker, 2 shooter, 3 charger, 4 orbiter, 5 dasher,
## 6 ambusher, 7 zoner, 8 summoner, 9 tank, 10 support.

## Kategoria walki — do reguły "bez trzech podobnych walk pod rząd".
const ENEMY_CATEGORY := ["melee", "melee", "ranged", "control", "ranged", "melee", "melee", "control", "control", "control", "control"]

## Koszt presji jednego wroga. Limit rośnie z postępem (pressure_limit()).
const ENEMY_PRESSURE := [2, 2, 2, 3, 2, 2, 2, 3, 3, 3, 1]

## Przepisy grupowe. "front" staje bliżej środka, "back" głębiej — zawsze po
## stronie pokoju przeciwnej do wejścia gracza.
const RECIPES := {
	"kowadlo": {"name": "Młot i kowadło", "members": [[9, "front"], [2, "back"]], "min_progress": 3},
	"wsparcie": {"name": "Wzmocniony nóż", "members": [[1, "front"], [10, "back"]], "min_progress": 3},
	"sfora": {"name": "Sfora", "members": [[0, "front"], [0, "front"], [5, "back"]], "min_progress": 8},
}

## Motywy RANDOM (kolejność = room.gd RANDOM_THEME_SLUGS).
const THEME_FLOODED := 0
const THEME_LIBRARY := 1
const THEME_CRYSTAL := 6
const THEME_RUSTED := 7
const THEME_COUNT := 8

## Akcent mechaniczny pilotażowych motywów (E2) — reszta motywów bez akcentu.
const THEME_ACCENT := {
	THEME_FLOODED: "slow_lane",
	THEME_LIBRARY: "projectile_cover",
	THEME_CRYSTAL: "single_bounce",
	THEME_RUSTED: "press_plates",
}
const ACCENT_LABEL := {
	"slow_lane": "Płycizna spowalnia",
	"projectile_cover": "Regały zatrzymują pociski",
	"single_bounce": "Kryształ odbija pocisk raz",
	"press_plates": "Prasy w rytmie",
}

## Bezpieczeństwo (D, E2).
const MIN_GAP := 130.0 ## najwęższe przejście: średnica największego losowego wroga (Tank 49) x2 + zapas
const MIN_SPAWN_DISTANCE_FROM_ENTRY := 330.0 ## wróg nigdy nie staje przy wejściu gracza
const DOOR_CLEARANCE := 120.0 ## wokół drzwi nic nie stoi
const PLAYER_RADIUS := 18.0
const SPAWN_OBSTACLE_CLEARANCE := 70.0 ## >= MIN_GAP/2 — spawn nigdy nie wpada w wąskie przejście

static func pressure_limit(rooms_cleared: int) -> int:
	return mini(3 + rooms_cleared / 3, 7)

static func recipe_pressure(recipe_id: String) -> int:
	var total := 0
	for m in RECIPES[recipe_id]["members"]:
		total += ENEMY_PRESSURE[int(m[0])]
	return total

static func recipes_allowed(rooms_cleared: int) -> Array[String]:
	var out: Array[String] = []
	for id in RECIPES:
		if rooms_cleared >= int(RECIPES[id]["min_progress"]) and recipe_pressure(id) <= pressure_limit(rooms_cleared):
			out.append(id)
	return out

## Podpis walki do reguły różnorodności: przepis grupowy albo kategoria
## pojedynczego wroga.
static func signature(recipe_id: String, enemy_index: int) -> String:
	if recipe_id != "":
		return "recipe:" + recipe_id
	return "single:" + ENEMY_CATEGORY[enemy_index]

## Trzeci taki sam podpis z rzędu jest zabroniony.
static func would_repeat_three(recent: Array, sig: String) -> bool:
	return recent.size() >= 2 and recent[-1] == sig and recent[-2] == sig

## Deterministyczny zastępca pojedynczego wroga z INNEJ kategorii.
static func alternative_enemy(enemy_index: int, salt: int) -> int:
	var category: String = ENEMY_CATEGORY[enemy_index]
	var options: Array[int] = []
	for i in ENEMY_CATEGORY.size():
		if ENEMY_CATEGORY[i] != category:
			options.append(i)
	return options[absi(salt) % options.size()]

# --- Pozycje ---

## Punkt spawnu wroga: po drugiej stronie pokoju względem wejścia,
## "back" głębiej niż "front". Bez wejścia (pokój startowy) — góra pokoju.
static func spawn_points(play_rect: Rect2, entry_direction: Vector2i, ranks: Array) -> Array[Vector2]:
	var center := play_rect.get_center()
	# Gracz wchodzi PRZEZ ścianę naprzeciw kierunku ruchu, więc wrogowie stoją
	# w stronę tego ruchu (entry_direction wskazuje w głąb pokoju).
	var into := Vector2(entry_direction) if entry_direction != Vector2i.ZERO else Vector2(0, -1)
	var side := Vector2(-into.y, into.x)
	var half_depth := (play_rect.size.x if absf(into.x) > 0.5 else play_rect.size.y) * 0.5
	var half_width := (play_rect.size.y if absf(into.x) > 0.5 else play_rect.size.x) * 0.5
	# Wejście stoi (half_depth - 70) za środkiem; front musi być >= MIN_SPAWN
	# od niego także w niskim pokoju (wejście z północy/południa).
	var front_depth := maxf(half_depth * 0.2, MIN_SPAWN_DISTANCE_FROM_ENTRY - (half_depth - 70.0))
	var back_depth := minf(maxf(half_depth * 0.62, front_depth + 50.0), half_depth - 60.0)
	var fronts := 0
	var backs := 0
	var out: Array[Vector2] = []
	for rank in ranks:
		var depth: float
		var lateral: float
		if rank == "back":
			depth = back_depth
			# Tylna linia z boku — nie za plecami frontu (nachodziliby na siebie).
			lateral = [0.4, -0.4, 0.0][backs % 3] * half_width
			backs += 1
		else:
			depth = front_depth
			lateral = [0.0, -0.5, 0.5][fronts % 3] * half_width
			fronts += 1
		out.append(center + into * depth + side * lateral)
	return out

## Wejście gracza (jak room.gd._player_spawn_position): 70 px od ściany, którą wszedł.
static func entry_point(play_rect: Rect2, entry_direction: Vector2i) -> Vector2:
	var center := play_rect.get_center()
	if entry_direction == Vector2i.ZERO:
		return center
	var into := Vector2(entry_direction)
	var half := Vector2(play_rect.size.x * 0.5, play_rect.size.y * 0.5)
	return center - into * (half * into.abs()).length() + into * 70.0

static func door_points(play_rect: Rect2) -> Array[Vector2]:
	var c := play_rect.get_center()
	return [Vector2(c.x, play_rect.position.y), Vector2(c.x, play_rect.end.y), Vector2(play_rect.position.x, c.y), Vector2(play_rect.end.x, c.y)]

# --- Układy (E2) ---

const LAYOUTS := ["open", "dwa_filary", "oslona", "kolumnada"]

## Prostokąty przeszkód w układzie — względem środka pokoju.
static func layout_obstacles(layout: String, play_rect: Rect2) -> Array[Rect2]:
	var c := play_rect.get_center()
	var out: Array[Rect2] = []
	match layout:
		"dwa_filary":
			for off in [Vector2(-250, -95), Vector2(250, 95)]:
				out.append(Rect2(c + off - Vector2(45, 45), Vector2(90, 90)))
		"oslona":
			for off in [Vector2(-200, 0), Vector2(200, 0)]:
				out.append(Rect2(c + off - Vector2(80, 20), Vector2(160, 40)))
		"kolumnada":
			for off in [Vector2(-300, -125), Vector2(300, -125), Vector2(-300, 125), Vector2(300, 125)]:
				out.append(Rect2(c + off - Vector2(35, 35), Vector2(70, 70)))
	return out

## Walidacja układu: nic przy drzwiach, każde przejście >= MIN_GAP (siatka
## punktów z zapasem MIN_GAP/2 od przeszkód i ścian musi łączyć wszystkie drzwi
## i wszystkie punkty spawnu). Zwraca "" gdy OK, inaczej opis problemu.
static func validate_layout(play_rect: Rect2, obstacles: Array[Rect2], extra_points: Array[Vector2] = []) -> String:
	for door in door_points(play_rect):
		for r in obstacles:
			if _rect_distance(r, door) < DOOR_CLEARANCE:
				return "przeszkoda przy drzwiach %s" % door
	var clearance := MIN_GAP * 0.5
	var step := 10.0
	var cols := int(play_rect.size.x / step)
	var rows := int(play_rect.size.y / step)
	var free := {}
	for ix in cols + 1:
		for iy in rows + 1:
			var p := play_rect.position + Vector2(ix * step, iy * step)
			var ok := true
			for r in obstacles:
				if _rect_distance(r, p) < clearance:
					ok = false
					break
			if ok:
				free[Vector2i(ix, iy)] = true
	# Punkty kontrolne: drzwi przesunięte do środka o zapas + dodatkowe (spawny).
	var targets: Array[Vector2] = []
	var c := play_rect.get_center()
	for door in door_points(play_rect):
		targets.append(door + (c - door).normalized() * (clearance + 5.0))
	targets.append_array(extra_points)
	var cells: Array[Vector2i] = []
	for t in targets:
		var cell := Vector2i(roundi((t.x - play_rect.position.x) / step), roundi((t.y - play_rect.position.y) / step))
		if not free.has(cell):
			return "punkt %s zablokowany przez przeszkodę" % t
		cells.append(cell)
	# Flood fill od pierwszego punktu.
	var seen := {cells[0]: true}
	var queue: Array[Vector2i] = [cells[0]]
	while not queue.is_empty():
		var cur: Vector2i = queue.pop_back()
		for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
			var n: Vector2i = cur + d
			if free.has(n) and not seen.has(n):
				seen[n] = true
				queue.append(n)
	for i in cells.size():
		if not seen.has(cells[i]):
			return "punkt %s odcięty (przejście węższe niż %d px)" % [targets[i], int(MIN_GAP)]
	return ""

static func _rect_distance(r: Rect2, p: Vector2) -> float:
	var dx := maxf(maxf(r.position.x - p.x, 0.0), p.x - r.end.x)
	var dy := maxf(maxf(r.position.y - p.y, 0.0), p.y - r.end.y)
	return Vector2(dx, dy).length()

## Wypchnięcie okręgu z prostokątów (wrogowie nie mają fizyki — incarnation.gd
## przepuszcza przez to każdy ruch, patrz _clamp_to_arena).
static func push_out_of(obstacles: Array[Rect2], pos: Vector2, radius: float) -> Vector2:
	var p := pos
	for r in obstacles:
		var closest := Vector2(clampf(p.x, r.position.x, r.end.x), clampf(p.y, r.position.y, r.end.y))
		var d := p - closest
		var dist := d.length()
		if dist >= radius:
			continue
		if dist > 0.01:
			p = closest + d / dist * radius
		else:
			# Środek w środku prostokąta — wypchnij najkrótszą drogą.
			var left := p.x - r.position.x
			var right := r.end.x - p.x
			var top := p.y - r.position.y
			var bottom := r.end.y - p.y
			var m := minf(minf(left, right), minf(top, bottom))
			if m == left: p.x = r.position.x - radius
			elif m == right: p.x = r.end.x + radius
			elif m == top: p.y = r.position.y - radius
			else: p.y = r.end.y + radius
	return p

# --- Pokój pułapek (D1, pilotaż: rdzawa hala) ---

const TRAP_SAFE_BORDER := 115.0 ## pas przy ścianach bez płyt — trasa bez obrażeń i bez dasha
const TRAP_PLATE_SIZE := 110.0
const TRAP_TELEGRAPH := 0.8 ## >= 0,6 s z audytu
const TRAP_ACTIVE := 0.45
const TRAP_PERIOD := 2.6 ## pełny cykl: grupa A (telegraf+aktywna), przerwa, grupa B, przerwa
const TRAP_DAMAGE := 10.0
const TRAP_ENEMIES := [0, 1, 2, 4] ## tylko proste role — bez szarży/strefy/przyzwań obok pułapki

## Płyty w środkowej części pokoju, szachownica kolumn: grupa 0 i 1 na
## zmianę. Nic w pasie przy ścianach ani przy drzwiach.
static func trap_plates(play_rect: Rect2) -> Array[Dictionary]:
	var inner := play_rect.grow(-TRAP_SAFE_BORDER)
	var cols := int(inner.size.x / TRAP_PLATE_SIZE)
	var rows := int(inner.size.y / TRAP_PLATE_SIZE)
	var origin := inner.position + (inner.size - Vector2(cols, rows) * TRAP_PLATE_SIZE) * 0.5
	var out: Array[Dictionary] = []
	for ix in cols:
		for iy in rows:
			var rect := Rect2(origin + Vector2(ix, iy) * TRAP_PLATE_SIZE, Vector2.ONE * TRAP_PLATE_SIZE).grow(-6.0)
			out.append({"rect": rect, "group": ix % 2})
	return out

## Faza grupy płyt w chwili t (s od startu cyklu): "idle" / "telegraph" / "active".
static func trap_phase(group: int, t: float) -> String:
	var local := fposmod(t - group * TRAP_PERIOD * 0.5, TRAP_PERIOD)
	if local < TRAP_TELEGRAPH:
		return "telegraph"
	if local < TRAP_TELEGRAPH + TRAP_ACTIVE:
		return "active"
	return "idle"

# --- Płycizna (zalana katakumba) ---

const SLOW_LANE_HEIGHT := 95.0
const SLOW_LANE_MULTIPLIER := 0.65

static func slow_lane_rect(play_rect: Rect2) -> Rect2:
	var c := play_rect.get_center()
	return Rect2(Vector2(play_rect.position.x, c.y + 120.0 - SLOW_LANE_HEIGHT * 0.5), Vector2(play_rect.size.x, SLOW_LANE_HEIGHT))
