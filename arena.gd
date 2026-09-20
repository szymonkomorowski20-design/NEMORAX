extends Node2D
## Scena główna — ściany, spawn gracza i bossa, oraz "referee": reaguje na sygnały
## bossa (zmiana fazy, śmierć) i dopina do gracza modyfikatory z sekcji 7, bo to
## jedyne miejsce, które zna oboje naraz. Licznik prób/zgonów/zwycięstw (sekcja 8)
## też mieszka tutaj, razem z ekranami śmierci/zwycięstwa.

const ARENA_RECT := Rect2(90, 60, 1100, 600) # wyśrodkowana 1100x600 w oknie 1280x720
const WALL_THICKNESS := 20.0
var SAVE_PATH := "user://progress.json" ## var (nie const) tylko po to, żeby test mógł podmienić ścieżkę na tymczasową

const BossScene := preload("res://entities/boss.tscn")

# Brak dedykowanej tekstury dla areny Nemoraxa w katalogu (PROMPTY_FINALNE_WSZYSTKO.md
# ma D1-D15 na sześć pokoi + ołtarz + tło, ale nie na samą arenę finałową) —
# tymczasowo reużywam wygląd ołtarza (spójny tematycznie, "sala rytualna"),
# do podmiany jeśli/gdy powstanie dedykowana grafika.
const VOID_BACKGROUND := preload("res://assets/sprites/pokoje/tekstury/void_background.png")
const FLOOR_TEXTURE := preload("res://assets/sprites/pokoje/tekstury/altar_floor.png")
const WALL_TEXTURE := preload("res://assets/sprites/pokoje/tekstury/altar_wall.png")

@export var body_fade_duration: float = 2.0 ## s, ekran gaśnie po "śmierci" dużej formy (sekcja 8)
@export var finale_taunt_duration: float = 4.0 ## s, jak długo wisi pytanie finałowe
@export var eclipse_radius: float = 160.0 ## px, promień widoczności wokół gracza w Zaćmieniu

@onready var player: Player = $Player
@onready var ui: GameUI = $UILayer/UI
@onready var eclipse_rect: ColorRect = $EclipseLayer/EclipseRect
@onready var pause_menu: PauseMenu = $PauseLayer/PauseMenu

var boss: Boss

var deaths: int = 0
var wins: int = 0

var _battle_time: float = 0.0
var _battle_over: bool = false
var _game_over_kind: String = "" # "", "death" albo "victory"
var _eclipse_active: bool = false
var _eclipse_material: ShaderMaterial

func _ready() -> void:
	# Wyciszenie z fazy Cisza jest globalnym stanem silnika, więc świeży start
	# (restart po śmierci) musi je jawnie zdjąć — inaczej zostałoby z poprzedniej próby.
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), false)

	_load_progress()
	_build_walls()
	_setup_eclipse_overlay()

	player.global_position = ARENA_RECT.get_center() + Vector2(0, 150)
	player.died.connect(_on_player_died)

	boss = BossScene.instantiate() as Boss
	boss.arena_rect = ARENA_RECT
	add_child(boss)
	boss.global_position = ARENA_RECT.get_center() - Vector2(0, 150)
	boss.phase_changed.connect(_on_boss_phase_changed)
	boss.died.connect(_on_boss_died)

	ui.player = player
	ui.boss = boss

func _process(delta: float) -> void:
	if not _battle_over:
		_battle_time += delta
	if _eclipse_active:
		_eclipse_material.set_shader_parameter("center", player.global_position)
	if _game_over_kind != "":
		_handle_game_over_input()

## Escape poza ekranami game-over pauzuje/wznawia — ekran zwycięstwa już
## używa Escape (ui_cancel) do wyjścia z gry (_handle_game_over_input), więc
## pauza musi być wyłączona w tym stanie, inaczej dwa różne działania
## walczyłyby o ten sam klawisz.
func _unhandled_input(event: InputEvent) -> void:
	if _game_over_kind != "":
		return
	if event.is_action_pressed("ui_cancel"):
		pause_menu.toggle()

func _build_walls() -> void:
	Walls.build_void_background(self, get_viewport_rect().size, VOID_BACKGROUND)
	Walls.build_floor(self, ARENA_RECT, FLOOR_TEXTURE)
	Walls.build(self, ARENA_RECT, WALL_THICKNESS, WALL_TEXTURE)

## Zaćmienie (faza 6, sekcja 7): ekran ciemnieje poza kręgiem wokół gracza. Godot 2D
## nie ma wbudowanego "otworu" w wypełnieniu, więc prościej jest o mały shader niż
## ręcznie sklejać wielokąt z dziurą — to wciąż kod, nie plik graficzny.
func _setup_eclipse_overlay() -> void:
	var shader := Shader.new()
	shader.code = """
shader_type canvas_item;

uniform vec2 center;
uniform float radius = 260.0;
uniform vec4 darkness_color : source_color = vec4(0.102, 0.063, 0.149, 1.0);

void fragment() {
	float d = distance(FRAGCOORD.xy, center);
	if (d < radius) {
		COLOR = vec4(0.0, 0.0, 0.0, 0.0);
	} else {
		COLOR = darkness_color;
	}
}
"""
	_eclipse_material = ShaderMaterial.new()
	_eclipse_material.shader = shader
	_eclipse_material.set_shader_parameter("radius", eclipse_radius)
	_eclipse_material.set_shader_parameter("darkness_color", Palette.BACKGROUND)
	eclipse_rect.material = _eclipse_material
	eclipse_rect.visible = false

func _on_boss_phase_changed(phase_index: int, _color: Color, rule_name: String) -> void:
	if rule_name != "":
		ui.show_form_name(rule_name)
	match phase_index:
		1: # Cisza — dźwięk wyciszony do końca walki
			AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), true)
		2: # Zwłoka — dash_cooldown x2
			player.dash_cooldown *= 2.0
		3: # Ciężar — stałe przyciąganie w stronę bossa
			player.pull_source = boss
			player.pull_strength = boss.gravity_pull_strength
		5: # Zaćmienie — ciemność poza kręgiem wokół gracza
			_eclipse_active = true
			eclipse_rect.visible = true

func _on_boss_died(is_final: bool) -> void:
	if is_final:
		_finish_victory()
	else:
		_play_big_form_death()

## Duża forma spadła do 0 HP — to jeszcze nie koniec (sekcja 8): ciało "znika",
## po 2 s wraca mała forma z pytaniem finałowym, zanim zdąży zaatakować.
func _play_big_form_death() -> void:
	# Duża forma jest is_dead=true w tym oknie — boss.gd sam pokazuje pozę
	# "kolaps" (nemorax_large-form-collapse.png) przez _update_sprite_state(),
	# więc nie trzeba już chować sprite'a na ślepo.
	await get_tree().create_timer(body_fade_duration).timeout

	boss.start_final_phase()
	boss.global_position = ARENA_RECT.get_center()
	boss.delay_next_attack(finale_taunt_duration)
	boss.show_taunt_pose(finale_taunt_duration)

	player.input_reversed = true # reguła siódma: Odwrócenie
	ui.hide_all = true # interfejs znika w całości w fazie finałowej

	ui.show_taunt(
		"Czy pamiętasz, ile razy już mnie pokonałeś?\n\n%d" % deaths,
		finale_taunt_duration
	)

func _finish_victory() -> void:
	_battle_over = true
	wins += 1
	_save_progress()
	# Wygrana to prawdziwy koniec przebiegu (endgame) — zostaje jako ekran
	# końcowy, bez pętli z powrotem do pokoju 1.
	ui.show_overlay(
		"Zwycięstwo\n\nPodejście: %d\nUkończeń: %d\nCzas walki: %s\n\nEscape, aby wyjść" %
		[_attempts(), wins, _format_time(_battle_time)],
		"victory"
	)
	_game_over_kind = "victory"

func _on_player_died() -> void:
	_battle_over = true
	deaths += 1
	_save_progress()
	ui.show_overlay("Zginąłeś\n\nPróba: %d\n\nSpacja, aby zacząć od nowa" % _attempts())
	_game_over_kind = "death"

func _handle_game_over_input() -> void:
	match _game_over_kind:
		"death":
			# Przegrana z Nemoraksem = koniec całego przebiegu, nie tylko tej
			# walki — wraca się do pokoju 1 na czysto (nowe fragmenty, świeży gracz).
			if Input.is_action_just_pressed("ui_accept"):
				GameFlow.reset_run()
				get_tree().change_scene_to_file(GameFlow.ROOM_SCENE)
		"victory":
			if Input.is_action_just_pressed("ui_cancel"):
				get_tree().quit()

func _attempts() -> int:
	return deaths + 1

func _format_time(seconds: float) -> String:
	var total := int(seconds)
	@warning_ignore("integer_division") # celowe dzielenie całkowite — liczymy pełne minuty
	var minutes := total / 60
	return "%d:%02d" % [minutes, total % 60]

func _load_progress() -> void:
	deaths = 0
	wins = 0
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		push_warning("Arena: nie udało się otworzyć zapisu do odczytu (%s), błąd %d" % [SAVE_PATH, FileAccess.get_open_error()])
		return
	var data = JSON.parse_string(file.get_as_text())
	if typeof(data) == TYPE_DICTIONARY:
		deaths = int(data.get("deaths", 0))
		wins = int(data.get("wins", 0))

func _save_progress() -> void:
	var data := {"deaths": deaths, "wins": wins}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_warning("Arena: nie udało się zapisać postępu (%s), błąd %d" % [SAVE_PATH, FileAccess.get_open_error()])
		return
	file.store_string(JSON.stringify(data))
