extends Node2D
class_name DamageZone
## Strefa okresowych obrażeń — Zoner (CLAUDE_CODE_GAME_CONTENT_BIBLE.md sekcja
## 6). Ani entities/seal.gd (jednorazowy wybuch), ani entities/void_zone.gd
## (blokuje dash, nie rani) nie pasują do "tick obrażeń co jakiś czas przez
## czas trwania" — stąd nowa, mała scena zamiast naciągania jednej z tamtych
## pod coś, do czego nie została zaprojektowana.

const TEX_ZONE := preload("res://assets/sprites/ataki_bossa/sixth_rhythm_seal.png") # TYMCZASOWE: brak dedykowanej grafiki strefy Zonera
const ZONE_CONTENT_SIZE := 882.0 ## ten sam plik/pomiar co entities/seal.gd

@export var zone_radius: float = 64.0
@export var telegraph_duration: float = 0.9
@export var duration: float = 3.5
@export var tick_damage: float = 5.0
@export var tick_interval: float = 0.5

@onready var sprite: Sprite2D = $Sprite

var _telegraph_timer: float
var _active_timer: float = 0.0
var _tick_timer: float = 0.0
var _is_active: bool = false

func _ready() -> void:
	_telegraph_timer = telegraph_duration
	sprite.texture = TEX_ZONE
	var zone_scale: float = (zone_radius * 2.0) / ZONE_CONTENT_SIZE
	sprite.scale = Vector2(zone_scale, zone_scale)
	sprite.modulate = Color(Palette.DANGER.r, Palette.DANGER.g, Palette.DANGER.b, 0.3)

func _physics_process(delta: float) -> void:
	if not _is_active:
		_telegraph_timer -= delta
		sprite.modulate.a = 0.3 + 0.4 * (1.0 - clamp(_telegraph_timer / telegraph_duration, 0.0, 1.0))
		if _telegraph_timer <= 0.0:
			_is_active = true
			_active_timer = duration
			_tick_timer = 0.0
			sprite.modulate.a = 0.7
		return

	_active_timer -= delta
	_tick_timer -= delta
	if _tick_timer <= 0.0:
		_tick_timer = tick_interval
		_try_damage_player()
	if _active_timer <= 0.0:
		queue_free()

func _try_damage_player() -> void:
	var player := get_tree().get_first_node_in_group("player") as Player
	if player == null or player.is_invulnerable():
		return
	if global_position.distance_to(player.global_position) > zone_radius:
		return
	player.take_damage(tick_damage)
