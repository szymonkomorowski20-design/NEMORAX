extends Node2D
## Laboratorium dźwięku (audyt nagrania 24.09, P2.14) — odtwarzalne sceny do
## odsłuchu w słuchawkach, nie część gry. Uruchom w edytorze (F6 na audio_lab.tscn).
##   1 — telegraf wcielenia (z muzyką; M przełącza muzykę, żeby porównać),
##   2 — fala 10 pocisków uderzających w ścianę w 0,3 s,
##   3 — blok → parowanie → przełamanie gardy pod rząd.
## Na ekranie: poziom muzyki (ściszenie pod telegrafem), bieżąca i szczytowa
## liczba jednoczesnych efektów. Słuchacz ma bez napisu rozpoznać telegraf
## i przełamanie, bez skoku głośności i „ściany dźwięku”.
## Tryb automatyczny (log bez odsłuchu): `-- auto` przy uruchomieniu sceny.

const ROOM_TRACK := preload("res://assets/audio/music/MUS_room_synth_1.wav")
const SND_TELEGRAPH := preload("res://assets/audio/sfx/wcielenia/I01_telegraph.wav")
const SND_IMPACT := preload("res://assets/audio/sfx/wcielenia/I05_contact_hit.wav")
const FONT := preload("res://assets/fonts/EBGaramond-Medium.woff")

var music: AudioStreamPlayer
var player: Player
var label: Label
var peak_sfx := 0
var min_music_db := 0.0
var scene_name := "—"
var auto := false
var _log: Array[String] = []

func _ready() -> void:
	auto = OS.get_cmdline_user_args().has("auto")
	RenderingServer.set_default_clear_color(Color(0.07, 0.06, 0.09))
	music = AudioStreamPlayer.new()
	music.stream = ROOM_TRACK
	music.bus = &"Music"
	add_child(music)
	music.add_to_group(Juice.MUSIC_GROUP)
	music.play()
	player = load("res://entities/player.tscn").instantiate()
	add_child(player)
	player.global_position = Vector2(640, 420)
	var layer := CanvasLayer.new()
	add_child(layer)
	label = Label.new()
	label.position = Vector2(20, 12)
	label.add_theme_font_override("font", FONT)
	label.add_theme_font_size_override("font_size", 18)
	label.add_theme_color_override("font_color", Color("#EDE3CF"))
	layer.add_child(label)
	if auto:
		_run_auto()

func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventKey and event.pressed and not event.echo):
		return
	match event.physical_keycode:
		KEY_1:
			_scene_telegraph()
		KEY_2:
			_scene_volley()
		KEY_3:
			_scene_guard_sequence()
		KEY_M:
			music.stream_paused = not music.stream_paused

func _begin(name: String) -> void:
	scene_name = name
	peak_sfx = 0
	min_music_db = 0.0

func _scene_telegraph() -> void:
	_begin("1 — telegraf wcielenia")
	Juice.play_sfx_at(SND_TELEGRAPH, player.global_position + Vector2(200, 0))
	Juice.duck_music(0.9)

func _scene_volley() -> void:
	_begin("2 — fala 10 pocisków")
	for i in 10:
		Juice.play_sfx_at(SND_IMPACT, Vector2(300 + i * 60, 200))
		await get_tree().create_timer(0.03).timeout

func _scene_guard_sequence() -> void:
	_begin("3 — blok → parowanie → przełamanie")
	player.debug_aim_point = player.global_position + Vector2(200, 0)
	var src := player.global_position + Vector2(90, 0)
	for step in [["blok", 0.6, 100.0], ["parowanie", 0.08, 100.0], ["przełamanie", 0.6, 5.0]]:
		Input.action_press("block")
		await get_tree().create_timer(float(step[1])).timeout
		player.stamina = float(step[2])
		player._invuln_timer = 0.0
		player.take_damage(18.0, src, true, self, "lab")
		Input.action_release("block")
		player.health = player.max_health
		await get_tree().create_timer(0.9).timeout

func _active_sfx() -> int:
	var n := 0
	for c in get_children():
		if c is AudioStreamPlayer2D and c.playing:
			n += 1
	if player.sfx.playing:
		n += 1
	return n

func _process(_delta: float) -> void:
	var now := _active_sfx()
	peak_sfx = maxi(peak_sfx, now)
	min_music_db = minf(min_music_db, Juice.music_duck_db)
	label.text = "\n".join([
		"LABORATORIUM DŹWIĘKU   (1 telegraf · 2 fala pocisków · 3 blok/parowanie/przełamanie · M muzyka)",
		"Scena: %s" % scene_name,
		"Muzyka: %s   ściszenie teraz %.1f dB, najniżej w scenie %.1f dB" % ["gra" if not music.stream_paused else "wyłączona", Juice.music_duck_db, min_music_db],
		"Jednoczesne efekty: teraz %d, szczyt w scenie %d (limit tego samego dźwięku: %d)" % [now, peak_sfx, Juice.MAX_SAME_SFX],
	])

func _run_auto() -> void:
	await get_tree().create_timer(0.5).timeout
	for s in [["telegraf", _scene_telegraph], ["fala", _scene_volley], ["tarcza", _scene_guard_sequence]]:
		(s[1] as Callable).call()
		await get_tree().create_timer(3.2).timeout
		_log.append("%s: szczyt efektów %d, muzyka najniżej %.1f dB" % [s[0], peak_sfx, min_music_db])
	for line in _log:
		print("[AUDIO] " + line)
	for e in Juice.player_hits:
		print("[HIT] " + Juice.format_player_hit(e))
	get_tree().quit(0)
