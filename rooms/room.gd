extends Node2D
## Jedna, generyczna scena pomieszczenia z wcieleniem — rozszerzenie poza dokument
## bazowy (patrz LORE_I_ASSETY.md). Ta sama scena jest przeładowywana dla każdego
## z sześciu pokoi; GameFlow.current_room_index mówi, które wcielenie zespawnować.
## Po pokonaniu wcielenia przekazuje sterowanie do GameFlow (kolejny pokój albo ołtarz).

const ARENA_RECT := Rect2(90, 60, 1100, 600) # ta sama wyśrodkowana arena co w arena.tscn
const WALL_THICKNESS := 20.0

@export var fragment_display_duration: float = 2.0 ## s, jak długo wisi napis o zdobytym fragmencie

@onready var player: Player = $Player
@onready var ui: GameUI = $UILayer/UI

var incarnation: Incarnation
var _game_over_kind: String = "" # "" albo "death"

func _ready() -> void:
	Walls.build(self, ARENA_RECT, WALL_THICKNESS)

	player.global_position = ARENA_RECT.get_center() + Vector2(0, 150)
	player.died.connect(_on_player_died)

	var scene: PackedScene = load(GameFlow.current_incarnation_scene_path())
	incarnation = scene.instantiate() as Incarnation
	incarnation.arena_rect = ARENA_RECT
	add_child(incarnation)
	incarnation.global_position = ARENA_RECT.get_center() - Vector2(0, 150)
	incarnation.died.connect(_on_incarnation_died)

	ui.player = player
	ui.boss = incarnation

func _process(_delta: float) -> void:
	if _game_over_kind != "":
		_handle_game_over_input()

func _on_incarnation_died(fragment_name: String) -> void:
	ui.show_taunt("Zdobyto fragment duszy: %s" % fragment_name, fragment_display_duration)
	await get_tree().create_timer(fragment_display_duration).timeout
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
