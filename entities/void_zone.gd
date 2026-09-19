extends Node2D
## Atak 2 — Ząb Zera (sekcja 5). Nie zadaje obrażeń, tylko blokuje dash.
## Celowo nie jest żółta (sekcja 2, punkt 2) — kontur bierze kolor aktualnej
## formy bossa, żeby jasno różnić się od wszystkiego, co faktycznie rani.

@export var void_radius: float = 130.0
@export var void_telegraph: float = 0.4 ## s, zapowiedź przed aktywacją
@export var void_duration: float = 5.0 ## s, jak długo strefa jest aktywna
@export var void_dash_lock: float = 10.0 ## s blokady dasha po wejściu w strefę

var player: Player = null
var boss: Boss = null ## do odczytania boss.current_color (kontur strefy)

var _telegraph_timer: float
var _active_timer: float = 0.0
var _is_active: bool = false

func _ready() -> void:
	_telegraph_timer = void_telegraph

func _physics_process(delta: float) -> void:
	if not _is_active:
		_telegraph_timer -= delta
		if _telegraph_timer <= 0.0:
			_is_active = true
			_active_timer = void_duration
	else:
		_active_timer -= delta
		if player and global_position.distance_to(player.global_position) <= void_radius:
			player.lock_dash(void_dash_lock)
		if _active_timer <= 0.0:
			queue_free()
			return
	queue_redraw()

func _draw() -> void:
	var contour: Color = boss.current_color if boss else Palette.DANGER
	# Domyślenie: podczas zapowiedzi kontur jest przygaszony, w pełni widoczny dopiero
	# gdy strefa realnie działa — dokument nie precyzuje wyglądu samej zapowiedzi tej strefy.
	var alpha := 1.0 if _is_active else 0.5
	draw_circle(Vector2.ZERO, void_radius, Palette.VOID_INTERIOR)
	draw_arc(Vector2.ZERO, void_radius, 0.0, TAU, 32, Color(contour, alpha), 2.0)
