extends Incarnation
class_name Shooter
## Archetyp 3/12: Shooter (dokument sekcja 6.1) — presja dystansowa, trzyma
## się z dala i strzela. Pierwszy archetyp korzystający z keep_distance_range
## (patrz PLAN_LOSOWYCH_POKOI.md, uwaga o przeciwnikach dystansowych) zamiast
## nadpisywać _drift_towards_player ręcznie. Grafika: dedykowany base art z GPT
## (jeden statyczny obraz na wszystkie pozy na razie).

const TEX_BASE := preload("res://assets/sprites/random_enemies/shooter/shooter_base.png")

const EnemyProjectileScene := preload("res://entities/enemy_projectile.tscn")
const VFX_SKILL := preload("res://assets/sprites/enemy_vfx/shooter_skill.png") # "attack" (bone_arrow) to sam EnemyProjectile, patrz entities/enemy_projectile.gd

@export var projectile_damage: float = 9.0
@export var projectile_speed: float = 260.0
@export var projectile_lifetime: float = 2.5

func _ready() -> void:
	max_health = 28.0
	drift_speed = 80.0
	contact_damage = 6.0 ## dokument nie podaje osobno — niskie, bo to nie jest jego rola
	attack_interval = 1.8
	telegraph_duration = 0.65
	knockback_resistance = 0.05
	keep_distance_range = 270.0 ## dokument: "seeks 220-320 distance"
	sprite_scale = 0.075 # KIERUNEK_WIZUALNY_REFERENCJE.md: mały wróg 0.65-0.85 gracza (player.sprite_scale=0.10)
	super._ready()
	current_color = Color("#C9D96B")
	fragment_name = "Shooter"
	_skills = [_skill_fire]
	_sprite_textures = {
		"walk": TEX_BASE, "telegraph": TEX_BASE, "pulse": TEX_BASE, "hit": TEX_BASE, "death": TEX_BASE,
	}

func _skill_fire() -> void:
	_set_skill_pose("pulse") # brak dedykowanej pozy strzału — reużyty "pulse" jako "coś wystrzelono"
	var to_player: Vector2 = player.global_position - global_position
	var direction := to_player.normalized() if to_player.length() > 0.01 else Vector2.RIGHT
	AttackVfx.spawn(get_parent(), VFX_SKILL, global_position, 0.3, 0.3, direction.angle())
	var projectile := EnemyProjectileScene.instantiate()
	projectile.direction = direction
	projectile.damage = projectile_damage
	projectile.speed = projectile_speed
	projectile.lifetime = projectile_lifetime
	projectile.global_position = global_position + direction * (radius + 6.0)
	get_parent().add_child(projectile)
