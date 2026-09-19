extends Node2D
## Pojedyncza pieczęć z Ataku 1 — Szósty Rytm (sekcja 5). Boss decyduje ile ich jest
## i jak są rozstawione w czasie (patrz boss.gd); ta pieczęć zna tylko siebie.

@export var seal_radius: float = 70.0
@export var seal_telegraph: float = 0.35 ## s, zapowiedź przed wybuchem
@export var seal_damage: float = 20.0

var player: Player = null
var stagger_delay: float = 0.0 ## ustawiane przez boss.gd — dodatkowa zwłoka, żeby pieczęci
                                ## wybuchały po kolei w odstępach seal_interval

var _timer: float

func _ready() -> void:
	_timer = seal_telegraph + stagger_delay

func _physics_process(delta: float) -> void:
	_timer -= delta
	if _timer <= 0.0:
		_explode()
		return
	queue_redraw()

func _explode() -> void:
	if player and global_position.distance_to(player.global_position) <= seal_radius:
		player.take_damage(seal_damage)
	queue_free()

func _draw() -> void:
	draw_circle(Vector2.ZERO, seal_radius, Color(Palette.DANGER, 0.35))
	draw_arc(Vector2.ZERO, seal_radius, 0.0, TAU, 32, Palette.DANGER, 1.0)
