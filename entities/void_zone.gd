extends Node2D
## Atak 2 — Ząb Zera (sekcja 5). Nie zadaje obrażeń, tylko blokuje dash.
## Celowo nie jest żółta (sekcja 2, punkt 2) — sprite bierze kolor aktualnej
## formy bossa (modulate), żeby jasno różnić się od wszystkiego, co faktycznie rani.

const TEX_VOID_ZONE := preload("res://assets/sprites/ataki_bossa/tooth_of_zero.png")
const SND_LOCK := preload("res://assets/audio/sfx/nemorax/N06_void_lock.wav")
const VOID_CONTENT_SIZE := 879.0 ## zmierzona średnia zawartość na płótnie 1024 (dopasowana pod void_radius)

@export var void_radius: float = 130.0
@export var void_telegraph: float = 0.4 ## s, zapowiedź przed aktywacją
@export var void_duration: float = 5.0 ## s, jak długo strefa jest aktywna
@export var void_dash_lock: float = 10.0 ## s blokady dasha po wejściu w strefę

@onready var sprite: Sprite2D = $Sprite

var player: Player = null
var boss: Boss = null ## do odczytania boss.current_color (barwa sprite'a)

var _telegraph_timer: float
var _active_timer: float = 0.0
var _is_active: bool = false

func _ready() -> void:
	_telegraph_timer = void_telegraph
	sprite.texture = TEX_VOID_ZONE
	var zone_scale: float = (void_radius * 2.0) / VOID_CONTENT_SIZE
	sprite.scale = Vector2(zone_scale, zone_scale)
	_update_modulate()

func _physics_process(delta: float) -> void:
	if not _is_active:
		_telegraph_timer -= delta
		if _telegraph_timer <= 0.0:
			_is_active = true
			_active_timer = void_duration
			_update_modulate()
			Juice.play_sfx_at(SND_LOCK, global_position)
	else:
		_active_timer -= delta
		if player and global_position.distance_to(player.global_position) <= void_radius:
			player.lock_dash(void_dash_lock)
		if _active_timer <= 0.0:
			queue_free()
			return

func _update_modulate() -> void:
	var contour: Color = boss.current_color if boss else Palette.DANGER
	# Domyślenie: podczas zapowiedzi sprite jest przygaszony, w pełni widoczny dopiero
	# gdy strefa realnie działa — dokument nie precyzuje wyglądu samej zapowiedzi tej strefy.
	var alpha := 1.0 if _is_active else 0.5
	sprite.modulate = Color(contour.r, contour.g, contour.b, alpha)
