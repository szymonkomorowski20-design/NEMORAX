extends Node2D
## Pokój 7 — Ołtarz (rozszerzenie poza dokument bazowy, patrz LORE_I_ASSETY.md).
## Dotarcie tutaj oznacza, że gracz ma już wszystkie 6 fragmentów (liniowa
## progresja przez GameFlow), więc ołtarz tylko odgrywa rytuał i czeka, aż
## gracz podejdzie do środka, żeby przywołać Nemoraxa.

const ARENA_RECT := Rect2(90, 60, 1100, 600)
const WALL_THICKNESS := 20.0
const ALTAR_RADIUS := 60.0
const SOCKET_COLORS := [
	Color("#F0447A"), Color("#9B4DFF"), Color("#C44FD6"),
	Color("#6C63FF"), Color("#E8524A"), Color("#8C9AC2"),
]

const VOID_BACKGROUND := preload("res://assets/sprites/pokoje/tekstury/void_background.png")
const FLOOR_TEXTURE := preload("res://assets/sprites/pokoje/tekstury/altar_floor.png")
const WALL_TEXTURE := preload("res://assets/sprites/pokoje/tekstury/altar_wall.png")
const SOCKET_TEXTURE := preload("res://assets/sprites/pokoje/obiekty/altar_socket.png")
const SOCKET_SPRITE_SCALE := 0.054

@export var summon_trigger_radius: float = 50.0 ## px, jak blisko środka musi podejść gracz
@export var summon_delay: float = 2.0 ## s, opóźnienie między dotarciem do ołtarza a przejściem do walki

@onready var player: Player = $Player
@onready var ui: GameUI = $UILayer/UI

var _triggered: bool = false

func _ready() -> void:
	Walls.build_void_background(self, get_viewport_rect().size, VOID_BACKGROUND)
	Walls.build_floor(self, ARENA_RECT, FLOOR_TEXTURE)
	Walls.build(self, ARENA_RECT, WALL_THICKNESS, WALL_TEXTURE)
	_spawn_sockets()
	player.global_position = ARENA_RECT.get_center() + Vector2(0, 200)
	ui.player = player
	ui.show_taunt(
		"Wszystkie fragmenty duszy zebrane.\nPodejdź do ołtarza, aby przywołać Nemoraxa.",
		4.0
	)

## Sześć gniazd w kręgu wokół pedestału — sam obrazek jest neutralny, więc
## każde gniazdo dostaje kolor swojego wcielenia przez modulate (patrz
## PROMPTY_FINALNE_WSZYSTKO.md C2/C3 — jedna grafika, tintowana w silniku).
func _spawn_sockets() -> void:
	var center := ARENA_RECT.get_center()
	for i in range(SOCKET_COLORS.size()):
		var angle := TAU * float(i) / float(SOCKET_COLORS.size())
		var socket := Sprite2D.new()
		socket.texture = SOCKET_TEXTURE
		socket.scale = Vector2(SOCKET_SPRITE_SCALE, SOCKET_SPRITE_SCALE)
		socket.modulate = SOCKET_COLORS[i]
		socket.position = center + Vector2(cos(angle), sin(angle)) * (ALTAR_RADIUS + 40.0)
		add_child(socket)

func _physics_process(_delta: float) -> void:
	if _triggered:
		return
	if player.global_position.distance_to(ARENA_RECT.get_center()) <= summon_trigger_radius:
		_triggered = true
		_summon_nemorax()

func _summon_nemorax() -> void:
	ui.show_taunt("Nemorax powstaje...", summon_delay)
	await get_tree().create_timer(summon_delay).timeout
	GameFlow.complete_altar()

## Sam centralny pedestał nie ma dedykowanej grafiki w katalogu (tylko gniazda
## dookoła) — zostaje rysowany kodem.
func _draw() -> void:
	draw_circle(ARENA_RECT.get_center(), ALTAR_RADIUS, Palette.ARENA_WALL)
