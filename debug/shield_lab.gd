extends Node2D
## Laboratorium tarczy (audyt nagrania 24.09, P0.3) — scena do sprawdzenia
## czytelności bloku, nie część gry. Uruchom w edytorze (F6 na shield_lab.tscn).
## Kukła po kolei uderza: z przodu, w oknie parowania, z boku, z tyłu, ciosem
## nieblokowalnym i przy pustej staminie. Na ekranie: czego się spodziewać,
## log z Juice.player_hits (ten sam co w grze) i stan staminy.
## Sterowanie: WASD ruch, PPM tarcza (celuj myszą w kukłę), 1–6 wybór próby,
## Spacja — pauza sekwencji, R — pełne HP i stamina.
## Tryb automatyczny (zrzuty + log): --script nie jest potrzebny, wystarczy
## `-- auto <katalog>` przy uruchomieniu sceny z linii poleceń.

const STEPS := [
	{"name": "Przód — zwykły blok", "angle": 0.0, "blockable": true, "raise_before": 0.6, "stamina": -1.0,
		"expect": "Blok: HP bez zmian, stamina spada o koszt bloku."},
	{"name": "Przód — parowanie", "angle": 0.0, "blockable": true, "raise_before": 0.08, "stamina": -1.0,
		"expect": "Podnieś tarczę tuż przed ciosem: „Parowanie!”, pierścień, bez kosztu staminy."},
	{"name": "Bok", "angle": 95.0, "blockable": true, "raise_before": 0.6, "stamina": -1.0,
		"expect": "Cios poza łukiem tarczy: „Z boku — poza tarczą”, zgrzyt, pełne obrażenia."},
	{"name": "Tył", "angle": 180.0, "blockable": true, "raise_before": 0.6, "stamina": -1.0,
		"expect": "„Z tyłu — poza tarczą”, pełne obrażenia."},
	{"name": "Nieblokowalny", "angle": 0.0, "blockable": false, "raise_before": 0.6, "stamina": -1.0,
		"expect": "„Nie do zablokowania” — tarcza nie pomaga, trzeba zejść z linii."},
	{"name": "Przełamanie gardy", "angle": 0.0, "blockable": true, "raise_before": 0.6, "stamina": 8.0,
		"expect": "Za mało staminy: pęknięty łuk, niski dźwięk, pełne obrażenia, stamina 0."},
]
const HIT_DAMAGE := 18.0
const TELEGRAPH := 0.8
const CYCLE := 2.6
const DUMMY_DISTANCE := 150.0
const FONT := preload("res://assets/fonts/EBGaramond-Medium.woff")

var player: Player
var step := 0
var timer := 0.0
var paused_sequence := false
var auto_dir := ""
var shots: Array[String] = []
var _label: Label
var _dummy_pos := Vector2.ZERO
var _hit_done := false

func _ready() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() >= 2 and args[0] == "auto":
		auto_dir = args[1]
	RenderingServer.set_default_clear_color(Color(0.07, 0.06, 0.09))
	player = load("res://entities/player.tscn").instantiate()
	add_child(player)
	player.global_position = Vector2(640, 400)
	Walls.build(self, Rect2(120, 120, 1040, 520), 40.0)
	var layer := CanvasLayer.new()
	add_child(layer)
	_label = Label.new()
	_label.position = Vector2(20, 12)
	_label.add_theme_font_override("font", FONT)
	_label.add_theme_font_size_override("font_size", 18)
	_label.add_theme_color_override("font_color", Color("#EDE3CF"))
	layer.add_child(_label)
	Juice.player_hits.clear()
	_start_step(0)

func _start_step(i: int) -> void:
	step = i % STEPS.size()
	timer = 0.0
	_hit_done = false
	player.health = player.max_health
	player.stamina = player.max_stamina if float(STEPS[step]["stamina"]) < 0.0 else float(STEPS[step]["stamina"])
	player._invuln_timer = 0.0

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.physical_keycode >= KEY_1 and event.physical_keycode <= KEY_6:
			_start_step(event.physical_keycode - KEY_1)
		elif event.physical_keycode == KEY_SPACE:
			paused_sequence = not paused_sequence
		elif event.physical_keycode == KEY_R:
			_start_step(step)

## Kierunek „przodu” = kierunek tarczy (mysz); kukła staje pod kątem od niego.
func _front() -> Vector2:
	var aim := player.debug_aim_point if player.debug_aim_point != Vector2.INF else get_global_mouse_position()
	var d := aim - player.global_position
	return d.normalized() if d.length() > 1.0 else Vector2.RIGHT

func _process(delta: float) -> void:
	var s: Dictionary = STEPS[step]
	if auto_dir != "":
		player.debug_aim_point = player.global_position + Vector2.RIGHT * 200.0
		if timer >= TELEGRAPH - float(s["raise_before"]) and not _hit_done:
			Input.action_press("block")
		else:
			Input.action_release("block")
	if not _hit_done:
		_dummy_pos = player.global_position + _front().rotated(deg_to_rad(float(s["angle"]))) * DUMMY_DISTANCE
	if not paused_sequence:
		timer += delta
	if timer >= TELEGRAPH and not _hit_done:
		_hit_done = true
		player.take_damage(HIT_DAMAGE, _dummy_pos, bool(s["blockable"]), self, "cios kukły")
		if auto_dir != "":
			_capture_after_hit()
	if timer >= CYCLE:
		if auto_dir != "" and step == STEPS.size() - 1:
			_finish_auto()
			return
		_start_step(step + 1)
	queue_redraw()
	_update_label()

func _capture_after_hit() -> void:
	for i in 3:
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var path := "%s/shield_%d.png" % [auto_dir, step + 1]
	get_viewport().get_texture().get_image().save_png(path)
	shots.append(path)

func _finish_auto() -> void:
	Input.action_release("block")
	for e in Juice.player_hits:
		print("[HIT] " + Juice.format_player_hit(e))
	print("SHOTS=%d" % shots.size())
	get_tree().quit(0)

func _update_label() -> void:
	var s: Dictionary = STEPS[step]
	var lines: Array[String] = [
		"LABORATORIUM TARCZY   (1–6 próba · Spacja pauza · R od nowa · PPM tarcza)",
		"Próba %d/%d: %s" % [step + 1, STEPS.size(), s["name"]],
		"Oczekiwane: %s" % s["expect"],
		"HP %.0f/%.0f   stamina %.0f/%.0f   tarcza: %s" % [player.health, player.max_health, player.stamina, player.max_stamina, "w górze" if player.is_shield_up() else "opuszczona"],
		"",
	]
	for e in Juice.player_hits.slice(maxi(0, Juice.player_hits.size() - 6)):
		lines.append(Juice.format_player_hit(e))
	_label.text = "\n".join(lines)

func _draw() -> void:
	var s: Dictionary = STEPS[step]
	var hit_color := Palette.DANGER if bool(s["blockable"]) else Color("#D9534F")
	draw_circle(_dummy_pos, 26.0, Color(0.35, 0.32, 0.4))
	draw_arc(_dummy_pos, 26.0, 0.0, TAU, 24, Color(0.8, 0.75, 0.85), 2.0)
	if not _hit_done:
		var k := clampf(timer / TELEGRAPH, 0.0, 1.0)
		draw_line(_dummy_pos, _dummy_pos.lerp(player.global_position, k), Color(hit_color, 0.4 + 0.5 * k), 4.0 + 4.0 * k)
