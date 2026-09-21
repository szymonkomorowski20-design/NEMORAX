extends Node2D
class_name EnemyProjectile
## Prosty pocisk wroga losowego — Shooter (CLAUDE_CODE_GAME_CONTENT_BIBLE.md
## sekcja 6). Prościej niż entities/projectile.gd (pocisk gracza): brak haków
## do ulepszeń (tylko gracz je ma, patrz player.gd sekcja 8), leci po prostej
## i rani WYŁĄCZNIE gracza — nie skanuje grupy "hittable", bo to grupa CELÓW
## gracza, nie zagrożeń DLA gracza.

const TEX_PROJECTILE := preload("res://assets/sprites/ekwipunek/player_wand_projectile.png") # TYMCZASOWE: brak dedykowanego pocisku wroga, patrz PROMPTY_WROGOW_LOSOWYCH_I_SKRZYNI.md
const SND_IMPACT := preload("res://assets/audio/sfx/wcielenia/I05_contact_hit.wav")

@export var speed: float = 260.0
@export var lifetime: float = 2.5
@export var damage: float = 9.0
@export var radius: float = 8.0
@export var sprite_scale: float = 0.04

var direction: Vector2 = Vector2.RIGHT
var _life_timer: float = 0.0

@onready var sprite: Sprite2D = $Sprite

func _ready() -> void:
	sprite.texture = TEX_PROJECTILE
	sprite.scale = Vector2(sprite_scale, sprite_scale)
	sprite.rotation = direction.angle()
	sprite.modulate = Palette.DANGER # odróżnia od niebiesko-białego pocisku gracza

func _physics_process(delta: float) -> void:
	_life_timer += delta
	if _life_timer >= lifetime:
		queue_free()
		return
	global_position += direction * speed * delta
	_check_hit()

func _check_hit() -> void:
	var player := get_tree().get_first_node_in_group("player") as Player
	if player == null or player.is_invulnerable():
		return
	if global_position.distance_to(player.global_position) > radius + player.radius:
		return
	player.take_damage(damage)
	Juice.play_sfx_at(SND_IMPACT, global_position)
	queue_free()
