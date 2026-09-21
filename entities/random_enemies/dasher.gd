extends Incarnation
class_name Dasher
## Archetyp 6/12: Dasher (dokument sekcja 6.1) — krótki, gwałtowny wypad z
## umiarkowanego dystansu ("stalk"), inaczej niż Charger (długa ładunkowa
## linia) czy Striker (bliski dystans). Grafika: dedykowany base art z GPT
## (jeden statyczny obraz na wszystkie pozy na razie).

const TEX_BASE := preload("res://assets/sprites/random_enemies/dasher/dasher_base.png")

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
		"walk": TEX_BASE, "telegraph": TEX_BASE, "lunge": TEX_BASE, "hit": TEX_BASE, "death": TEX_BASE,
	}

func _skill_dash() -> void:
	_lunge_toward_player(dash_speed, dash_distance / dash_speed)
