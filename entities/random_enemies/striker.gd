extends Incarnation
class_name Striker
## Archetyp 2/12: Striker (dokument sekcja 6.1) — burst melee, trzyma dystans
## (70-95px), potem wchodzi wypadem. Grafika: TYMCZASOWO Mordrath.

const TEX_WALK := preload("res://assets/sprites/wcielenia/mordrath/mordrath_walk.png")
const TEX_WALK_BACK := preload("res://assets/sprites/wcielenia/mordrath/mordrath_walk_back.png")
const TEX_WALK_SIDE := preload("res://assets/sprites/wcielenia/mordrath/mordrath_walk_side.png")
const TEX_TELEGRAPH := preload("res://assets/sprites/wcielenia/mordrath/mordrath_telegraph.png")
const TEX_LUNGE := preload("res://assets/sprites/wcielenia/mordrath/mordrath_lunge.png")
const TEX_HIT := preload("res://assets/sprites/wcielenia/mordrath/mordrath_hit.png")
const TEX_DEATH := preload("res://assets/sprites/wcielenia/mordrath/mordrath_death.png")

@export var lunge_speed: float = 400.0
@export var lunge_distance: float = 85.0 ## dokument: "lunge 85"

func _ready() -> void:
	max_health = 40.0
	drift_speed = 95.0
	contact_damage = 12.0
	attack_interval = 1.6
	telegraph_duration = 0.42
	knockback_resistance = 0.20
	keep_distance_range = 82.0 ## dokument: "holds 70-95 range"
	super._ready()
	current_color = Color("#E8933D")
	fragment_name = "Striker"
	_skills = [_skill_lunge_strike]
	_sprite_textures = {
		"walk": {"front": TEX_WALK, "back": TEX_WALK_BACK, "side": TEX_WALK_SIDE},
		"telegraph": TEX_TELEGRAPH, "lunge": TEX_LUNGE, "hit": TEX_HIT, "death": TEX_DEATH,
	}

func _skill_lunge_strike() -> void:
	_lunge_toward_player(lunge_speed, lunge_distance / lunge_speed)
