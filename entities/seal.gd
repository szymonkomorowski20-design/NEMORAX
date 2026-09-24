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
## Paczka 8 (F4, pakt "Zwiąż ciszę"): inny telegraf niż zwykła pieczęć —
## jasny, przerywany pierścień zasięgu, żeby wzorzec był odrębny formą.
var ring_variant: bool = false

## Drugi audyt (A3): brzeg DOKŁADNIE na promieniu wybuchu, wypełniany od środka
## w czasie zapowiedzi („zaraz uderzy”), rozbłysk po wybuchu (FLASH_TIME, bez
## obrażeń — „już było”). Dawniej pieczęć znikała w klatce wybuchu.
const FLASH_TIME := 0.25
var _flash: float = -1.0

func _draw() -> void:
	if _flash >= 0.0:
		var f := clampf(_flash / FLASH_TIME, 0.0, 1.0)
		draw_circle(Vector2.ZERO, seal_radius, Color(1.0, 0.92, 0.75, 0.35 * f))
		draw_arc(Vector2.ZERO, seal_radius + 14.0 * (1.0 - f), 0.0, TAU, 40, Color(1.0, 0.9, 0.7, 0.8 * f), 3.0, true)
		return
	var k: float = 1.0 - clampf(_timer / maxf(_total_time, 0.01), 0.0, 1.0)
	draw_circle(Vector2.ZERO, seal_radius * k, Color(Palette.DANGER, 0.12 + 0.1 * k))
	draw_arc(Vector2.ZERO, seal_radius, 0.0, TAU, 40, Color(Palette.DANGER, 0.35 + 0.55 * k), 2.0 + 1.5 * k, true)
	if not ring_variant:
		return
	var col := Color(0.85, 0.80, 1.0, 0.45 + 0.5 * k)
	for i in 12:
		var a0 := TAU * i / 12.0
		draw_arc(Vector2.ZERO, seal_radius, a0, a0 + TAU / 24.0, 6, col, 3.0, true)

func _ready() -> void:
	_total_time = seal_telegraph + stagger_delay
	_timer = _total_time
	sprite.texture = TEX_SEAL
	sprite.show_behind_parent = true # brzeg i wypełnienie (_draw) nad teksturą
	var seal_scale: float = (seal_radius * 2.0) / SEAL_CONTENT_SIZE
	sprite.scale = Vector2(seal_scale, seal_scale)

func _physics_process(delta: float) -> void:
	if _flash >= 0.0:
		_flash -= delta
		queue_redraw()
		if _flash <= 0.0:
			queue_free()
		return
	_timer -= delta
	queue_redraw()
	# Zbliżanie się do wybuchu = coraz bardziej widoczna — sama grafika ma już
	# footprint dopasowany do seal_radius, więc nie trzeba osobnego konturu.
	sprite.modulate.a = 0.4 + 0.6 * (1.0 - clamp(_timer / _total_time, 0.0, 1.0))
	if ring_variant:
		queue_redraw()
	if _timer <= 0.0:
		_explode()
		return

func _explode() -> void:
	if player and global_position.distance_to(player.global_position) <= seal_radius:
		player.take_damage(seal_damage, global_position, false, self) # wybuch z podłoża — tarcza nie pomaga
	Juice.play_sfx_at(SND_EXPLOSION, global_position)
	_flash = FLASH_TIME
	sprite.visible = false
