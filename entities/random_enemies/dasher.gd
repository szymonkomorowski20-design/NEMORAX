extends Incarnation
class_name Dasher
## Archetyp 6/12: Dasher (dokument sekcja 6.1) — krótki, gwałtowny wypad z
## umiarkowanego dystansu ("stalk"), inaczej niż Charger (długa ładunkowa
## linia) czy Striker (bliski dystans). Grafika: TYMCZASOWO Orryx.

const TEX_WALK := preload("res://assets/sprites/wcielenia/orryx/orryx_walk.png")
const TEX_WALK_BACK := preload("res://assets/sprites/wcielenia/orryx/orryx_walk_back.png")
const TEX_WALK_SIDE := preload("res://assets/sprites/wcielenia/orryx/orryx_walk_side.png")
const TEX_TELEGRAPH := preload("res://assets/sprites/wcielenia/orryx/orryx_telegraph.png")
const TEX_LUNGE := preload("res://assets/sprites/wcielenia/orryx/orryx_lunge.png")
const TEX_HIT := preload("res://assets/sprites/wcielenia/orryx/orryx_hit.png")
const TEX_DEATH := preload("res://assets/sprites/wcielenia/orryx/orryx_death.png")

@export var dash_speed: float = 350.0
@export var dash_distance: float = 130.0 ## dokument: "dash 130"

func _ready() -> void:
	max_health = 46.0
	drift_speed = 105.0
	contact_damage = 13.0
	attack_interval = 2.2
	telegraph_duration = 0.48
	knockback_resistance = 0.20
	keep_distance_range = 150.0 ## "stalk" — umiarkowany dystans przed wypadem, nie wręcz
	super._ready()
	current_color = Color("#9B6BF0")
	fragment_name = "Dasher"
	_skills = [_skill_dash]
	_sprite_textures = {
		"walk": {"front": TEX_WALK, "back": TEX_WALK_BACK, "side": TEX_WALK_SIDE},
		"telegraph": TEX_TELEGRAPH, "lunge": TEX_LUNGE, "hit": TEX_HIT, "death": TEX_DEATH,
	}

func _skill_dash() -> void:
	_lunge_toward_player(dash_speed, dash_distance / dash_speed)
