extends Node2D
## Jedna, generyczna scena pomieszczenia — rozszerzenie poza dokument bazowy
## (patrz LORE_I_ASSETY.md). Ta sama scena jest przeładowywana dla każdego z sześciu
## pokoi; GameFlow.current_room_index mówi, które wcielenie zespawnować.
##
## Przebieg: gracz startuje w pustym przedsionku -> podchodzi do drzwi (próg) ->
## wcielenie się pojawia -> po jego pokonaniu wypada dusza -> gracz podnosi ją
## klawiszem F -> pojawiają się nowe drzwi dalej -> przejście do GameFlow
## (kolejny pokój albo ołtarz), z zachowaniem statystyk gracza.

const ARENA_RECT := Rect2(90, 60, 1100, 600) # ta sama wyśrodkowana arena co w arena.tscn
const WALL_THICKNESS := 20.0

const DoorScene := preload("res://rooms/door.tscn")
const SoulScene := preload("res://rooms/soul.tscn")

@export var player_start_offset: Vector2 = Vector2(0.0, 220.0) ## względem środka areny
@export var start_door_offset: Vector2 = Vector2(0.0, 60.0)
@export var incarnation_spawn_offset: Vector2 = Vector2(0.0, -150.0)
@export var exit_door_offset: Vector2 = Vector2(0.0, -250.0)

@onready var player: Player = $Player
@onready var ui: GameUI = $UILayer/UI

var incarnation: Incarnation
var _game_over_kind: String = "" # "" albo "death"

func _ready() -> void:
	Walls.build(self, ARENA_RECT, WALL_THICKNESS)

	var center := ARENA_RECT.get_center()
	player.global_position = center + player_start_offset
	player.died.connect(_on_player_died)
	GameFlow.apply_player_state(player) # ta sama migawka co przy wejściu do tego pokoju

	ui.player = player

	_spawn_door(center + start_door_offset, _on_start_door_entered)

func _process(_delta: float) -> void:
	if _game_over_kind != "":
		_handle_game_over_input()

func _spawn_door(pos: Vector2, on_entered: Callable) -> void:
	var door: Door = DoorScene.instantiate()
	door.player = player
	door.global_position = pos
	door.entered.connect(on_entered)
	add_child(door)

func _on_start_door_entered() -> void:
	var scene: PackedScene = load(GameFlow.current_incarnation_scene_path())
	incarnation = scene.instantiate() as Incarnation
	incarnation.arena_rect = ARENA_RECT
	incarnation.global_position = ARENA_RECT.get_center() + incarnation_spawn_offset
	incarnation.died.connect(_on_incarnation_died)
	add_child(incarnation)
	ui.boss = incarnation

func _on_incarnation_died(fragment_name: String) -> void:
	var soul: Soul = SoulScene.instantiate()
	soul.color = incarnation.current_color
	soul.player = player
	soul.global_position = incarnation.global_position
	soul.collected.connect(_on_soul_collected.bind(fragment_name))
	add_child(soul)

func _on_soul_collected(fragment_name: String) -> void:
	ui.show_taunt("Zdobyto fragment duszy: %s" % fragment_name, 2.0)
	_spawn_door(ARENA_RECT.get_center() + exit_door_offset, _on_exit_door_entered)

func _on_exit_door_entered() -> void:
	GameFlow.capture_player_state(player)
	GameFlow.complete_current_room()

func _on_player_died() -> void:
	ui.show_overlay("Zginąłeś\n\nSpacja, aby spróbować ponownie")
	_game_over_kind = "death"

func _handle_game_over_input() -> void:
	if _game_over_kind == "death" and Input.is_action_just_pressed("ui_accept"):
		get_tree().reload_current_scene()

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, get_viewport_rect().size), Palette.BACKGROUND, true)
	draw_rect(ARENA_RECT, Palette.ARENA_FLOOR, true)
	var r := ARENA_RECT.grow(WALL_THICKNESS * 0.5)
	draw_rect(r, Palette.ARENA_WALL, false, WALL_THICKNESS)
