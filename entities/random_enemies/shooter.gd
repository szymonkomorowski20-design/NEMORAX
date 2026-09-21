extends Incarnation
class_name Shooter
## Archetyp 3/12: Shooter (dokument sekcja 6.1) — presja dystansowa, trzyma
## się z dala i strzela. Pierwszy archetyp korzystający z keep_distance_range
## (patrz PLAN_LOSOWYCH_POKOI.md, uwaga o przeciwnikach dystansowych) zamiast
## nadpisywać _drift_towards_player ręcznie. Grafika: TYMCZASOWO Zha'Ruun.

const TEX_WALK := preload("res://assets/sprites/wcielenia/zha_ruun/zha-ruun_walk.png")
const TEX_WALK_BACK := preload("res://assets/sprites/wcielenia/zha_ruun/zha-ruun_walk_back.png")
const TEX_WALK_SIDE := preload("res://assets/sprites/wcielenia/zha_ruun/zha-ruun_walk_side.png")
const TEX_TELEGRAPH := preload("res://assets/sprites/wcielenia/zha_ruun/zha-ruun_telegraph.png")
const TEX_PULSE := preload("res://assets/sprites/wcielenia/zha_ruun/zha-ruun_cast-pulse.png")
const TEX_HIT := preload("res://assets/sprites/wcielenia/zha_ruun/zha-ruun_hit.png")
const TEX_DEATH := preload("res://assets/sprites/wcielenia/zha_ruun/zha-ruun_death.png")

const EnemyProjectileScene := preload("res://entities/enemy_projectile.tscn")

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
	super._ready()
	current_color = Color("#C9D96B")
	fragment_name = "Shooter"
	_skills = [_skill_fire]
	_sprite_textures = {
		"walk": {"front": TEX_WALK, "back": TEX_WALK_BACK, "side": TEX_WALK_SIDE},
		"telegraph": TEX_TELEGRAPH, "pulse": TEX_PULSE, "hit": TEX_HIT, "death": TEX_DEATH,
	}

func _skill_fire() -> void:
	_set_skill_pose("pulse") # brak dedykowanej pozy strzału — reużyty "pulse" jako "coś wystrzelono"
	var to_player: Vector2 = player.global_position - global_position
	var direction := to_player.normalized() if to_player.length() > 0.01 else Vector2.RIGHT
	var projectile := EnemyProjectileScene.instantiate()
	projectile.direction = direction
	projectile.damage = projectile_damage
	projectile.speed = projectile_speed
	projectile.lifetime = projectile_lifetime
	projectile.global_position = global_position + direction * (radius + 6.0)
	get_parent().add_child(projectile)
