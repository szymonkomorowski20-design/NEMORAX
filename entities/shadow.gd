extends Node2D
## Atak 3 — Kradzież Intencji (sekcja 5, wersja uproszczona z dokumentu v2).
## Odtwarza wyłącznie zapisaną trasę pozycji gracza (boss.gd nagrywa ją cały czas).
## Dashe "odtwarzają się" same, bo w trasie są po prostu gwałtownymi skokami pozycji.
## Nie ma własnego ataku ani hitboksu — rani wyłącznie kontaktem z ciałem.

const TEX_SHADOW := preload("res://assets/sprites/gracz/player_base.png") # to kopia gracza — ten sam sprite
const SHADOW_SPRITE_SCALE := 0.08 # ta sama skala co player.gd, żeby kopia wyglądała identycznie z rozmiaru

@export var shadow_lifetime: float = 6.0 ## s, jak długo cień istnieje i się odtwarza
@export var shadow_contact_damage: float = 15.0
@export var radius: float = 14.0 ## px, ten sam rozmiar co gracz — to jego kopia

@onready var sprite: Sprite2D = $Sprite

var player: Player = null
var trace: PackedVector2Array = PackedVector2Array() ## ustawiane przez boss.gd przed add_child

var _frame_index: int = 0
var _life_timer: float = 0.0
var _max_frames: int

func _ready() -> void:
	_max_frames = min(trace.size(), int(shadow_lifetime * Engine.physics_ticks_per_second))
	if trace.size() > 0:
		global_position = trace[0]
	sprite.texture = TEX_SHADOW
	sprite.scale = Vector2(SHADOW_SPRITE_SCALE, SHADOW_SPRITE_SCALE)
	# Cyjan mówi "to jesteś ty" (sekcja 2, punkt 1) — sam modulate na kopii sprite'a
	# gracza, zamiast płaskiego koła jak dawniej.
	sprite.modulate = Color(Palette.PLAYER_BODY, 0.75)

func _physics_process(delta: float) -> void:
	_life_timer += delta
	if _frame_index >= _max_frames or _life_timer >= shadow_lifetime:
		queue_free()
		return
	global_position = trace[_frame_index]
	_frame_index += 1
	_check_contact()
	queue_redraw()

func _check_contact() -> void:
	if player == null:
		return
	if global_position.distance_to(player.global_position) <= radius + player.radius:
		player.take_damage(shadow_contact_damage, global_position, true, self)

## Sparowany cień się rozwiewa (decyzja autora: parowanie ma być nagrodą).
func on_parried(_by: Node) -> void:
	queue_free()

func _draw() -> void:
	# Żółty kontur mówi "to zada obrażenia" (sekcja 2, punkt 2) — obie reguły
	# z sekcji 2 są tu prawdziwe naraz (kontur + cyjan sprite'a). CELOWE.
	draw_arc(Vector2.ZERO, radius, 0.0, TAU, 24, Palette.DANGER, 2.0)
