extends Node
## Odczucia z walki (sekcja 4 dokumentu) — hitstop i trzęsienie ekranu.
## Błysk trafienia NIE mieszka tutaj: to czysto wizualny stan pojedynczego
## obiektu (2 klatki na biało), więc każdy `_draw()` robi to sam u siebie —
## robienie z tego wspólnego systemu byłoby przedwczesną abstrakcją.
##
## Dźwięki UI (paczka P0, wrzesień 2026) mieszkają tu, a nie po jednym
## komplecie w każdym z menu.gd/pause_menu.gd/options_screen.gd/
## keybind_screen.gd/stats_screen.gd — to te same dźwięki, identycznie użyte
## w pięciu miejscach, więc jeden wspólny zestaw obok już istniejącego
## play_sfx_at() zamiast pięciokrotnie tego samego preload+AudioStreamPlayer.

@export var boss_hit_hitstop: float = 0.05 ## s, zatrzymanie gry gdy gracz trafia bossa
@export var player_hit_hitstop: float = 0.08 ## s, zatrzymanie gry gdy gracz dostaje obrażenia (górna granica zakresu 0.03-0.08s, PLAN_PROFESSIONAL_GAME_FEEL_DLA_CLAUDE.md sekcja 2C — było 0.10s, poza zakresem)
@export var shake_amplitude: float = 4.0 ## px, maksymalne przesunięcie ekranu przy trzęsieniu
@export var shake_duration: float = 0.12 ## s, jak długo trwa trzęsienie ekranu

var _hitstop_active := false
var _shake_time_left := 0.0

## Diagnostyka balansu (Paczka 2): rzeczywiste obrażenia, nie nominalna siła
## efektu. Sumy obejmują całą próbę od ostatniego resetu; lista zachowuje
## tylko ostatnie trafienia, żeby długi run nie zużywał pamięci bez końca.
const DAMAGE_EVENT_LIMIT := 512
var damage_totals: Dictionary = {}
var damage_events: Array[Dictionary] = []

## Audyt nagrania 24.09 (P0.2): log KAŻDEGO ciosu, który doszedł do gracza —
## także zatrzymanego przez dash, nietykalność czy tarczę. Jedno źródło: wpisy
## dopisuje wyłącznie Player.take_damage(). Widoczny w nakładce debug (F3 /
## toggle_debug); z włączoną nakładką każdy wpis idzie też na konsolę.
const PLAYER_HITS_CAP := 200
var player_hits: Array[Dictionary] = []

func log_player_hit(entry: Dictionary) -> void:
	entry["time"] = GameFlow.run_time if GameFlow.run_time > 0.0 else Time.get_ticks_msec() / 1000.0
	player_hits.append(entry)
	if player_hits.size() > PLAYER_HITS_CAP:
		player_hits.pop_front()
	if debug_visible:
		print("[HIT] " + format_player_hit(entry))

static func format_player_hit(e: Dictionary) -> String:
	var parts: Array[String] = [
		"%6.1fs" % float(e.get("time", 0.0)),
		str(e.get("source", "?")),
		str(e.get("kind", "?")) + (" (" + str(e["skill"]) + ")" if str(e.get("skill", "")) != "" else ""),
		"%s: %.0f" % [e.get("outcome", "?"), float(e.get("damage", 0.0))],
		"HP %.0f→%.0f" % [float(e.get("hp_before", 0.0)), float(e.get("hp_after", 0.0))],
		"st %.0f→%.0f" % [float(e.get("stamina_before", 0.0)), float(e.get("stamina_after", 0.0))],
	]
	var flags: Array[String] = []
	if e.get("shield", false):
		flags.append("tarcza")
	if e.get("dashing", false):
		flags.append("dash")
	if float(e.get("iframe", 0.0)) > 0.0:
		flags.append("i-frame %.2f" % float(e["iframe"]))
	parts.append("[" + ", ".join(flags) + "]" if not flags.is_empty() else "[—]")
	var p: Vector2 = e.get("pos", Vector2.ZERO)
	parts.append("(%d, %d)" % [int(p.x), int(p.y)])
	return "  ".join(parts)

func reset_damage_metrics() -> void:
	damage_totals.clear()
	damage_events.clear()
	player_hits.clear()

func damage_totals_snapshot() -> Dictionary:
	return damage_totals.duplicate()

## Opcje — Grafika: "screen shake" (włącz/wyłącz). `var`, ustawiane z
## ui/options_screen.gd i zapisywane w user://settings.json.
var shake_enabled: bool = true

## Podgląd na żywo (sekcja Debug Mode) — F3, dotąd nic takiego nie istniało.
## Czysto tekstowy odczyt, nie edytor "na żywo": tabelka liczb do tuningu
## (stamina/mana/cooldowny/timery bufora/hitstop/shake) zamiast zgadywania z
## samego patrzenia na ekran. Mieszka na Juice, bo to już właściciel
## hitstopu/trzęsienia, i CanvasLayer tutaj (jak fade w game_flow.gd) przeżywa
## reload/zmianę sceny, więc F3 działa identycznie w pokoju/ołtarzu/arenie.
var debug_visible: bool = false
var _debug_label: Label

const SND_UI_NAVIGATE := [
	preload("res://assets/audio/sfx/p0/UI_NAVIGATE__1.wav"),
	preload("res://assets/audio/sfx/p0/UI_NAVIGATE_2.wav"),
	preload("res://assets/audio/sfx/p0/UI_NAVIGATE_3.wav"),
]
const SND_UI_CONFIRM := [
	preload("res://assets/audio/sfx/p0/UI_CONFIRM_1.wav"),
	preload("res://assets/audio/sfx/p0/UI_CONFIRM_2.wav"),
]
const SND_UI_BACK := [
	preload("res://assets/audio/sfx/p0/UI_BACK_1.wav"),
	preload("res://assets/audio/sfx/p0/UI_BACK_2.wav"),
]
const SND_UI_ERROR := preload("res://assets/audio/sfx/p0/UI_ERROR.wav")
const SND_UI_LEVEL_UP := preload("res://assets/audio/sfx/p0/UI_LEVEL_UP.wav")

func _ready() -> void:
	_setup_debug_overlay()

func _setup_debug_overlay() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 101 # nad zaciemnieniem przejść (100, patrz game_flow.gd)
	_debug_label = Label.new()
	_debug_label.add_theme_color_override("font_color", Color.WHITE)
	_debug_label.add_theme_color_override("font_outline_color", Color.BLACK)
	_debug_label.add_theme_constant_override("outline_size", 3)
	_debug_label.position = Vector2(8.0, 8.0)
	_debug_label.visible = false
	layer.add_child(_debug_label)
	add_child(layer)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_debug"):
		debug_visible = not debug_visible
		_debug_label.visible = debug_visible

func _update_debug_label() -> void:
	var lines: Array[String] = [
		"FPS: %d   time_scale: %.2f   hitstop: %s   shake_left: %.3f" % [
			Engine.get_frames_per_second(), Engine.time_scale, _hitstop_active, _shake_time_left,
		],
	]
	var player := get_tree().get_first_node_in_group("player")
	if player != null:
		lines.append("player.state: %s   attack_phase: %s   weapon: %s" % [
			Player.State.keys()[player.state],
			player._attack_phase if player._attack_phase != "" else "-",
			player.current_weapon,
		])
		lines.append("hp: %.0f/%.0f   stamina: %.0f/%.0f   mana: %.0f/%.0f" % [
			player.health, player.max_health, player.stamina, player.max_stamina, player.mana, player.max_mana,
		])
		lines.append("dash_cooldown: %.2f   buffered_dash: %.2f   buffered_attack: %.2f   heal_stacks: %d" % [
			player._dash_cooldown_timer, player._buffered_dash_timer, player._buffered_attack_timer, player.get_heal_stacks(),
		])
	var window_start := Time.get_ticks_msec() - 5000
	var recent_damage := 0.0
	for event in damage_events:
		if int(event["time_msec"]) >= window_start:
			recent_damage += float(event["damage"])
	lines.append("damage DPS/5s: %.1f   totals: %s" % [recent_damage / 5.0, str(damage_totals)])
	if not player_hits.is_empty():
		lines.append("ostatnie ciosy w gracza:")
		for e in player_hits.slice(maxi(0, player_hits.size() - 6)):
			lines.append("  " + format_player_hit(e))
	_debug_label.text = "\n".join(lines)

## Zatrzymuje grę na `duration` sekund w czasie rzeczywistym. Kolejne wywołanie
## w trakcie trwającego hitstopu jest ignorowane (sekcja 4: „nie mogą się nakładać").
## Opcje — Dostępność: "redukcja migotania" pomija hitstop całkowicie — nagłe
## zerwanie płynności ruchu na każde trafienie jest tym samym rodzajem
## bodźca, którego ta opcja ma unikać, nawet jeśli to nie dosłowny "flash".
func hitstop(duration: float) -> void:
	if _hitstop_active or Palette.reduce_flashing:
		return
	_hitstop_active = true
	Engine.time_scale = 0.0
	# Zwykły create_timer nigdy by nie wypalił przy time_scale == 0 — czwarty
	# argument (ignore_time_scale) każe mu liczyć w czasie rzeczywistym.
	await get_tree().create_timer(duration, true, false, true).timeout
	Engine.time_scale = 1.0
	_hitstop_active = false

## Uruchamia (lub przedłuża) trzęsienie ekranu na `shake_duration` s.
func screen_shake() -> void:
	if not shake_enabled:
		return
	_shake_time_left = shake_duration

## Wspólne "trafienie wroga" — ujednolica take_damage+flash_white+hitstop,
## które inaczej trzeba by powtarzać w każdym miejscu, skąd gracz może zadać
## obrażenia (miecz w player.gd, pocisk w projectile.gd), a każde kolejne
## miejsce byłoby kolejną kopią do rozjechania się przy następnej zmianie.
## NIE obejmuje register_hit_on_enemy() (mana/stacki leczenia) ani dźwięku
## trafienia — to zależy od konkretnej broni, nie jest uniwersalną reakcją celu.
## Faza 2C (PLAN_PROFESSIONAL_GAME_FEEL_DLA_CLAUDE.md): BEZ screen_shake() tutaj
## — to najczęstsza ścieżka trafienia w grze (każde cięcie mieczem, każdy
## pocisk), a dokument wprost zastrzega trzęsienie kamery WYŁĄCZNIE dla
## ciężkich ataków (patrz np. boss.gd._start_transform_invulnerability(),
## gdzie zostaje wywołane bezpośrednio dla konkretnego, rzadkiego momentu).
func apply_hit(target: Node, damage: float, hitstop_duration: float = boss_hit_hitstop, is_bonus_hit: bool = false, source: String = "secondary", show_feedback: bool = true) -> float:
	if not is_instance_valid(target) or not target.has_method("take_damage") or damage <= 0.0:
		return 0.0
	var health_before = target.get("health")
	var phase_before = target.get("phase_index")
	var reported = target.take_damage(damage)
	var dealt := 0.0
	if typeof(reported) in [TYPE_FLOAT, TYPE_INT]:
		dealt = maxf(0.0, float(reported))
	elif typeof(health_before) in [TYPE_FLOAT, TYPE_INT]:
		var health_after = target.get("health")
		if typeof(health_after) in [TYPE_FLOAT, TYPE_INT]:
			dealt = maxf(0.0, float(health_before) - float(health_after))
	else:
		dealt = damage
	if dealt <= 0.0:
		return 0.0
	damage_totals[source] = float(damage_totals.get(source, 0.0)) + dealt
	damage_events.append({
		"time_msec": Time.get_ticks_msec(), "target_id": target.get_instance_id(),
		"target_name": target.name, "phase": phase_before, "source": source, "damage": dealt,
	})
	if damage_events.size() > DAMAGE_EVENT_LIMIT:
		damage_events.pop_front()
	if not show_feedback:
		return dealt
	if target.has_method("flash_white"):
		target.flash_white()
	if target is Node2D:
		var parent: Node = target.get_parent() if target.get_parent() != null else get_tree().current_scene
		DamageNumber.spawn(parent, target.global_position, dealt, Palette.DANGER, is_bonus_hit)
	hitstop(hitstop_duration)
	return dealt

## Odtwarza jednorazowy dźwięk w danym miejscu świata i sam się sprząta po
## zakończeniu — do obiektów, które znikają (queue_free()) w tej samej klatce,
## w której powinien zabrzmieć ich dźwięk (pocisk, pieczęć, dusza itd.), więc
## własny AudioStreamPlayer2D obiektu zniknąłby razem z dźwiękiem.
## Paczka 10 (A16): liczne źródła tego samego dźwięku (fala pocisków, kilku
## wrogów ginących naraz) nie sumują się w hałas — najwyżej MAX_SAME_SFX
## kopii naraz, każda kolejna ciszej o SAME_SFX_STEP_DB.
const MAX_SAME_SFX := 3
const SAME_SFX_STEP_DB := -3.0
var _active_sfx: Dictionary = {}

func play_sfx_at(stream: AudioStream, world_position: Vector2, bus: String = "SFX") -> void:
	var playing := int(_active_sfx.get(stream, 0))
	if playing >= MAX_SAME_SFX:
		return
	_active_sfx[stream] = playing + 1
	var player := AudioStreamPlayer2D.new()
	player.stream = stream
	player.bus = bus
	player.volume_db = SAME_SFX_STEP_DB * playing
	player.tree_exiting.connect(_release_sfx.bind(stream))
	player.global_position = world_position
	# current_scene może być null (np. testy bez realnej sceny, albo w trakcie
	# przejścia między scenami) — root jako zapasowy rodzic zamiast crasha.
	var parent: Node = get_tree().current_scene if get_tree().current_scene != null else get_tree().root
	parent.add_child(player)
	player.finished.connect(player.queue_free)
	player.play()

func _release_sfx(stream: AudioStream) -> void:
	var left := int(_active_sfx.get(stream, 1)) - 1
	if left <= 0:
		_active_sfx.erase(stream)
	else:
		_active_sfx[stream] = left

## Jak play_sfx_at(), ale bez pozycji w świecie i na busie "UI" zamiast "SFX"
## — do menu/pauzy/opcji/ekranu klawiszy/ekranu statystyk, gdzie nie ma
## sensownego world_position (część z tych ekranów pauzuje samo drzewo, patrz
## get_tree().root jako rodzic zamiast current_scene: przeżywa pauzę tak samo
## jak same te ekrany, PROCESS_MODE_ALWAYS).
func play_ui_sfx(stream: AudioStream) -> void:
	var player := AudioStreamPlayer.new()
	player.stream = stream
	player.bus = "UI"
	get_tree().root.add_child(player)
	player.finished.connect(player.queue_free)
	player.play()

## Losowy wybór z puli wariantów (UI_NAVIGATE/UI_CONFIRM/UI_BACK mają po 2-3
## nagrania) — mikro-urozmaicenie zamiast identycznego sampla przy każdym
## pojedynczym ruchu kursora.
func play_ui_sfx_variant(streams: Array) -> void:
	play_ui_sfx(streams[randi() % streams.size()])

## Paczka 10 (A16): muzyka ustępuje zapowiedzi ataku — krótkie ściszenie
## odtwarzaczy muzyki (grupa MUSIC_GROUP), by telegraf był słyszalny. Na
## poziomie WĘZŁA, nie busa: głośność busa to ustawienie gracza (options_screen
## ją zapisuje), więc nie wolno jej tu ruszać.
const MUSIC_GROUP := "music"
const MUSIC_DUCK_DB := -8.0
var _duck_tween: Tween = null
var music_duck_db: float = 0.0:
	set(value):
		music_duck_db = value
		for m in get_tree().get_nodes_in_group(MUSIC_GROUP):
			m.volume_db = value

func duck_music(hold: float = 0.6) -> void:
	if get_tree().get_nodes_in_group(MUSIC_GROUP).is_empty():
		return
	if _duck_tween != null and _duck_tween.is_valid():
		_duck_tween.kill()
	_duck_tween = create_tween()
	_duck_tween.tween_property(self, "music_duck_db", MUSIC_DUCK_DB, 0.08)
	_duck_tween.tween_interval(hold)
	_duck_tween.tween_property(self, "music_duck_db", 0.0, 0.5)

func _process(delta: float) -> void:
	if debug_visible:
		_update_debug_label()
	if _shake_time_left <= 0.0:
		return
	_shake_time_left -= delta
	var camera := get_viewport().get_camera_2d()
	if camera == null:
		return
	if _shake_time_left <= 0.0:
		camera.offset = Vector2.ZERO
	else:
		camera.offset = Vector2(
			randf_range(-shake_amplitude, shake_amplitude),
			randf_range(-shake_amplitude, shake_amplitude)
		)
