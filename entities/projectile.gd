extends Node2D
## Pocisk różdżki (broń 2 gracza — dodatek na życzenie autora, poza dokumentem).
## Leci po prostej, znika po trafieniu, po czasie życia albo poza areną.

const TEX_PROJECTILE := preload("res://assets/sprites/ekwipunek/player_wand_projectile.png")
const SND_IMPACT := preload("res://assets/audio/sfx/gracz/P12_wand_impact.wav")

@export var radius: float = 6.0
@export var speed: float = 600.0
@export var lifetime: float = 1.0
@export var damage: float = 8.0
@export var sprite_scale: float = 0.03

var direction: Vector2 = Vector2.RIGHT
var shooter: Player = null ## żeby oddać manę strzelcowi za trafienie
var _life_timer: float = 0.0

@onready var sprite: Sprite2D = $Sprite

func _ready() -> void:
	sprite.texture = TEX_PROJECTILE
	sprite.scale = Vector2(sprite_scale, sprite_scale)
	sprite.rotation = direction.angle()

func _physics_process(delta: float) -> void:
	_life_timer += delta
	if _life_timer >= lifetime:
		queue_free()
		return
	global_position += direction * speed * delta
	_check_hit()

func _check_hit() -> void:
	for target in get_tree().get_nodes_in_group("hittable"):
		var target_radius: float = target.get("radius") if target.get("radius") != null else 0.0
		if global_position.distance_to(target.global_position) > radius + target_radius:
			continue
		if target.has_method("take_damage"):
			target.take_damage(damage)
		if target.has_method("flash_white"):
			target.flash_white()
		if shooter != null:
			shooter.register_hit_on_enemy()
		Juice.hitstop(Juice.boss_hit_hitstop)
		Juice.screen_shake()
		Juice.play_sfx_at(SND_IMPACT, global_position)
		queue_free()
		return
