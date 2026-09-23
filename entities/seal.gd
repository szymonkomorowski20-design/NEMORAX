extends Node2D
## Pojedyncza pieczęć z Ataku 1 — Szósty Rytm (sekcja 5). Boss decyduje ile ich jest
## i jak są rozstawione w czasie (patrz boss.gd); ta pieczęć zna tylko siebie.

const TEX_SEAL := preload("res://assets/sprites/ataki_bossa/sixth_rhythm_seal.png")
const SND_EXPLOSION := preload("res://assets/audio/sfx/nemorax/N04_seal_explosion.wav")
const SEAL_CONTENT_SIZE := 882.0 ## zmierzona średnia zawartość na płótnie 1024 (dopasowana pod seal_radius)

@export var seal_radius: float = 70.0
@export var seal_telegraph: float = 0.35 ## s, zapowiedź przed wybuchem
@export var seal_damage: float = 20.0

@onready var sprite: Sprite2D = $Sprite

var player: Player = null
var stagger_delay: float = 0.0 ## ustawiane przez boss.gd — dodatkowa zwłoka, żeby pieczęci
                                ## wybuchały po kolei w odstępach seal_interval

var _timer: float
var _total_time: float

func _ready() -> void:
	_total_time = seal_telegraph + stagger_delay
	_timer = _total_time
	sprite.texture = TEX_SEAL
	var seal_scale: float = (seal_radius * 2.0) / SEAL_CONTENT_SIZE
	sprite.scale = Vector2(seal_scale, seal_scale)

func _physics_process(delta: float) -> void:
	_timer -= delta
	# Zbliżanie się do wybuchu = coraz bardziej widoczna — sama grafika ma już
	# footprint dopasowany do seal_radius, więc nie trzeba osobnego konturu.
	sprite.modulate.a = 0.4 + 0.6 * (1.0 - clamp(_timer / _total_time, 0.0, 1.0))
	if _timer <= 0.0:
		_explode()
		return

func _explode() -> void:
	if player and global_position.distance_to(player.global_position) <= seal_radius:
		player.take_damage(seal_damage, global_position, false) # wybuch z podłoża — tarcza nie pomaga
	Juice.play_sfx_at(SND_EXPLOSION, global_position)
	queue_free()
