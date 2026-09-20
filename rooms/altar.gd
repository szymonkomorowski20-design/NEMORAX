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

@export var summon_trigger_radius: float = 50.0 ## px, jak blisko środka musi podejść gracz
@export var summon_delay: float = 2.0 ## s, opóźnienie między dotarciem do ołtarza a przejściem do walki

@onready var player: Player = $Player
@onready var ui: GameUI = $UILayer/UI

var _triggered: bool = false

func _ready() -> void:
	Walls.build(self, ARENA_RECT, WALL_THICKNESS)
	player.global_position = ARENA_RECT.get_center() + Vector2(0, 200)
	ui.player = player
	ui.show_taunt(
		"Wszystkie fragmenty duszy zebrane.\nPodejdź do ołtarza, aby przywołać Nemoraxa.",
		4.0
	)

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

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, get_viewport_rect().size), Palette.BACKGROUND, true)
	draw_rect(ARENA_RECT, Palette.ARENA_FLOOR, true)
	var r := ARENA_RECT.grow(WALL_THICKNESS * 0.5)
	draw_rect(r, Palette.ARENA_WALL, false, WALL_THICKNESS)

	var center := ARENA_RECT.get_center()
	draw_circle(center, ALTAR_RADIUS, Palette.ARENA_WALL)
	for i in range(SOCKET_COLORS.size()):
		var angle := TAU * float(i) / float(SOCKET_COLORS.size())
		var socket_pos := center + Vector2(cos(angle), sin(angle)) * (ALTAR_RADIUS + 40.0)
		draw_circle(socket_pos, 14.0, SOCKET_COLORS[i])
