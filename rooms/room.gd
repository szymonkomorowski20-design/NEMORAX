extends Node2D
## Jedna, generyczna scena pomieszczenia — rozszerzenie poza dokument bazowy
## (patrz LORE_I_ASSETY.md). Ta sama scena jest przeładowywana dla każdego z 30
## pokoi (6 rozdziałów × [4 losowe pokoje + 1 wcielenie], patrz game_flow.gd) —
## GameFlow.is_random_enemy_room() mówi, który typ przeciwnika zespawnować.
##
## Przebieg: gracz startuje w pustym przedsionku -> podchodzi do drzwi (próg) ->
## przeciwnik się pojawia -> po jego pokonaniu (wcielenie: wypada dusza, gracz
## podnosi ją klawiszem F; losowy przeciwnik: bez duszy, od razu drzwi dalej)
## -> nowe drzwi -> przejście do GameFlow (kolejny pokój albo ołtarz), z
## zachowaniem statystyk gracza.

const ARENA_RECT := Rect2(90, 60, 1100, 600) # ta sama wyśrodkowana arena co w arena.tscn
const WALL_THICKNESS := 20.0

const DoorScene := preload("res://rooms/door.tscn")
const SoulScene := preload("res://rooms/soul.tscn")

const VOID_BACKGROUND := preload("res://assets/sprites/pokoje/tekstury/void_background.png")
# W kolejności GameFlow.INCARNATION_SCENES (Vhar'Nokh...Orryx) — indeksowane przez current_room_index.
const ROOM_FLOOR_TEXTURES: Array[Texture2D] = [
	preload("res://assets/sprites/pokoje/tekstury/vhar_nokh_floor.png"),
	preload("res://assets/sprites/pokoje/tekstury/mordrath_floor.png"),
	preload("res://assets/sprites/pokoje/tekstury/zha_ruun_floor.png"),
	preload("res://assets/sprites/pokoje/tekstury/nekravor_floor.png"),
	preload("res://assets/sprites/pokoje/tekstury/thal_gor_floor.png"),
	preload("res://assets/sprites/pokoje/tekstury/orryx_floor.png"),
]
const ROOM_WALL_TEXTURES: Array[Texture2D] = [
	preload("res://assets/sprites/pokoje/tekstury/vhar_nokh_wall.png"),
	preload("res://assets/sprites/pokoje/tekstury/mordrath_wall.png"),
	preload("res://assets/sprites/pokoje/tekstury/zha_ruun_wall.png"),
	preload("res://assets/sprites/pokoje/tekstury/nekravor_wall.png"),
	preload("res://assets/sprites/pokoje/tekstury/thal_gor_wall.png"),
	preload("res://assets/sprites/pokoje/tekstury/orryx_wall.png"),
]

# Na życzenie autora: losowy utwór z tej puli przy KAŻDYM wejściu do pokoju
# (nie stały przydział pokój->utwór) — scena się przeładowuje między
# wcieleniami, więc losowanie w _ready() samo daje inny utwór za każdym razem.
const ROOM_MUSIC_TRACKS: Array[AudioStream] = [
	preload("res://assets/audio/music/MUS_room_synth_1.wav"),
	preload("res://assets/audio/music/MUS_room_synth_2.wav"),
	preload("res://assets/audio/music/MUS_room_synth_3.wav"),
	preload("res://assets/audio/music/MUS_room_synth_4.wav"),
	preload("res://assets/audio/music/MUS_room_chase_1.wav"),
	preload("res://assets/audio/music/MUS_room_chase_2.wav"),
	preload("res://assets/audio/music/MUS_room_melody_1.wav"),
	preload("res://assets/audio/music/MUS_room_melody_2.wav"),
	preload("res://assets/audio/music/MUS_room_melody_3.wav"),
	preload("res://assets/audio/music/MUS_room_melody_4.wav"),
]

@export var player_start_offset: Vector2 = Vector2(0.0, 220.0) ## względem środka areny
@export var incarnation_spawn_offset: Vector2 = Vector2(0.0, -150.0)
## Drzwi zawsze dokładnie na ścianie (Walls.wall_point), nie na dowolnym
## przesunięciu od środka — poprzednio floated na otwartej podłodze zamiast
## tkwić w ścianie, na życzenie autora poprawione.
const START_DOOR_WALL := "bottom"
const EXIT_DOOR_WALL := "top"

@onready var player: Player = $Player
@onready var ui: GameUI = $UILayer/UI
@onready var pause_menu: PauseMenu = $PauseLayer/PauseMenu
@onready var stats_screen: StatsScreen = $StatsLayer/StatsScreen
@onready var music: AudioStreamPlayer = $Music

var incarnation: Incarnation
var _game_over_kind: String = "" # "" albo "death"

func _ready() -> void:
	Walls.build_void_background(self, get_viewport_rect().size, VOID_BACKGROUND)
	var floor_tex: Texture2D
	var wall_tex: Texture2D
	if GameFlow.is_random_enemy_room():
		# TYMCZASOWE: docelowo 8 par podłoga/ściana dedykowanych pokojom z
		# losowymi przeciwnikami (patrz PLAN_LOSOWYCH_POKOI.md) — reużywam na
		# razie tekstury pokoi wcieleń (po current_room_index), żeby 30-pokojowy
		# przebieg był grywalny, zanim te 16 assetów powstanie.
		var theme_index := GameFlow.current_room_index % ROOM_FLOOR_TEXTURES.size()
		floor_tex = ROOM_FLOOR_TEXTURES[theme_index]
		wall_tex = ROOM_WALL_TEXTURES[theme_index]
	else:
		floor_tex = ROOM_FLOOR_TEXTURES[GameFlow.current_chapter_index()]
		wall_tex = ROOM_WALL_TEXTURES[GameFlow.current_chapter_index()]
	Walls.build_floor(self, ARENA_RECT, floor_tex)
	Walls.build(self, ARENA_RECT, WALL_THICKNESS, wall_tex)

	var track: AudioStreamWAV = ROOM_MUSIC_TRACKS[randi() % ROOM_MUSIC_TRACKS.size()]
	# Ustawiane w kodzie, nie tylko w .import — headless `--import` (używane w
	# tej sesji do generowania .import przy nowych plikach) niezawodnie nie
	# zapisuje edit/loop_mode do faktycznego cache'owanego zasobu, sprawdzone
	# bezpośrednim testem (loop_mode wychodził 0 mimo poprawnego .import).
	track.loop_mode = AudioStreamWAV.LOOP_FORWARD
	music.stream = track
	music.play()

	var center := ARENA_RECT.get_center()
	player.global_position = center + player_start_offset
	player.died.connect(_on_player_died)
	GameFlow.apply_player_state(player) # ta sama migawka co przy wejściu do tego pokoju

	ui.player = player
	ui.show_minimap = true

	_spawn_door(Walls.wall_point(ARENA_RECT, START_DOOR_WALL), _on_start_door_entered)

func _process(_delta: float) -> void:
	if _game_over_kind != "":
		_handle_game_over_input()

## Escape poza ekranem game-over pauzuje/wznawia — w trakcie game-over Spacja
## (ui_accept) już obsługuje retry, nie ma tam czego pauzować.
## Ten handler nie musi sam pilnować wykluczania z pause_menu/stats_screen —
## oba pauzują drzewo, kiedy są otwarte, a wtedy TEN węzeł (domyślny
## process_mode) w ogóle przestaje dostawać input, więc się nie zdublują.
func _unhandled_input(event: InputEvent) -> void:
	if _game_over_kind != "":
		return
	if event.is_action_pressed("ui_cancel"):
		pause_menu.toggle()
	elif event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_TAB:
		stats_screen.open(player)

func _spawn_door(pos: Vector2, on_entered: Callable) -> void:
	var door: Door = DoorScene.instantiate()
	door.player = player
	door.global_position = pos
	door.entered.connect(on_entered)
	add_child(door)

func _on_start_door_entered() -> void:
	var is_random := GameFlow.is_random_enemy_room()
	var scene_path := GameFlow.choose_random_enemy_scene_path() if is_random else GameFlow.current_incarnation_scene_path()
	var scene: PackedScene = load(scene_path)
	incarnation = scene.instantiate() as Incarnation
	incarnation.arena_rect = ARENA_RECT
	incarnation.global_position = ARENA_RECT.get_center() + incarnation_spawn_offset
	incarnation.died.connect(_on_incarnation_died)
	add_child(incarnation)
	if is_random:
		# Rosnąca trudność losowych przeciwników z numerem pokoju (ustalone z
		# autorem) — wcielenia z duszami zachowują swoje ręcznie dobrane,
		# stałe statystyki, więc ta gałąź ich nie dotyczy.
		incarnation.apply_difficulty_scale(1.0 + GameFlow.current_room_index * GameFlow.RANDOM_ENEMY_DIFFICULTY_STEP)
	ui.boss = incarnation

func _on_incarnation_died(fragment_name: String) -> void:
	player.gain_xp() # 1 XP za każdego pokonanego przeciwnika, losowego i wcielenie jednakowo
	if GameFlow.is_random_enemy_room():
		# Losowi przeciwnicy nie dają fragmentów/dusz do podniesienia (ustalone
		# z autorem) — od razu nowe drzwi dalej, bez kroku z podnoszeniem duszy.
		_spawn_door(Walls.wall_point(ARENA_RECT, EXIT_DOOR_WALL), _on_exit_door_entered)
		return
	var soul: Soul = SoulScene.instantiate()
	soul.color = incarnation.current_color
	soul.player = player
	soul.global_position = incarnation.global_position
	soul.collected.connect(_on_soul_collected.bind(fragment_name))
	add_child(soul)

func _on_soul_collected(fragment_name: String) -> void:
	ui.show_taunt("Zdobyto fragment duszy: %s" % fragment_name, 2.0)
	_spawn_door(Walls.wall_point(ARENA_RECT, EXIT_DOOR_WALL), _on_exit_door_entered)

func _on_exit_door_entered() -> void:
	GameFlow.capture_player_state(player)
	GameFlow.complete_current_room()

func _on_player_died() -> void:
	ui.show_overlay("Zginąłeś\n\nSpacja, aby spróbować ponownie")
	_game_over_kind = "death"

func _handle_game_over_input() -> void:
	if _game_over_kind == "death" and Input.is_action_just_pressed("ui_accept"):
		get_tree().reload_current_scene()
