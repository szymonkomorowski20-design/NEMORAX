extends Incarnation
class_name Charger
## Archetyp 4/12: Charger (dokument sekcja 6.1) — zagrożenie liniowe, odsuwa
## się na dystans, potem ładuje po prostej z dużą prędkością. Grafika:
## TYMCZASOWO Nekravor.

const TEX_WALK := preload("res://assets/sprites/wcielenia/nekravor/nekravor_walk.png")
const TEX_WALK_BACK := preload("res://assets/sprites/wcielenia/nekravor/nekravor_walk_back.png")
const TEX_WALK_SIDE := preload("res://assets/sprites/wcielenia/nekravor/nekravor_walk_side.png")
const TEX_TELEGRAPH := preload("res://assets/sprites/wcielenia/nekravor/nekravor_telegraph.png")
const TEX_LUNGE := preload("res://assets/sprites/wcielenia/nekravor/nekravor_lunge.png")
const TEX_HIT := preload("res://assets/sprites/wcielenia/nekravor/nekravor_hit.png")
const TEX_DEATH := preload("res://assets/sprites/wcielenia/nekravor/nekravor_death.png")

@export var charge_speed: float = 300.0
@export var charge_duration: float = 0.8

func _ready() -> void:
	max_health = 52.0
	drift_speed = 75.0
	contact_damage = 15.0
	attack_interval = 2.8
	telegraph_duration = 0.80
	knockback_resistance = 0.35
	keep_distance_range = 270.0 ## dokument: "repositions to 180-360 range before charge"
	super._ready()
	current_color = Color("#C4453A")
	fragment_name = "Charger"
	_skills = [_skill_charge]
	_sprite_textures = {
		"walk": {"front": TEX_WALK, "back": TEX_WALK_BACK, "side": TEX_WALK_SIDE},
		"telegraph": TEX_TELEGRAPH, "lunge": TEX_LUNGE, "hit": TEX_HIT, "death": TEX_DEATH,
	}

func _skill_charge() -> void:
	_lunge_toward_player(charge_speed, charge_duration)
