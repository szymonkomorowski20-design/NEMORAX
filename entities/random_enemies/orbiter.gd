extends Incarnation
class_name Orbiter
## Archetyp 5/12: Orbiter (dokument sekcja 6.1) — presja kątowa, krąży
## stycznie wokół gracza zamiast podchodzić/uciekać po prostej (orbit_mode,
## patrz entities/incarnation.gd). Kierunek krążenia losowany raz, żeby różne
## instancje nie kręciły się identycznie. Grafika: TYMCZASOWO Thal'Gor.

const TEX_WALK := preload("res://assets/sprites/wcielenia/thal_gor/thal-gor_walk.png")
const TEX_WALK_BACK := preload("res://assets/sprites/wcielenia/thal_gor/thal-gor_walk_back.png")
const TEX_WALK_SIDE := preload("res://assets/sprites/wcielenia/thal_gor/thal-gor_walk_side.png")
const TEX_TELEGRAPH := preload("res://assets/sprites/wcielenia/thal_gor/thal-gor_telegraph.png")
const TEX_PULSE := preload("res://assets/sprites/wcielenia/thal_gor/thal-gor_cast-pulse.png")
const TEX_HIT := preload("res://assets/sprites/wcielenia/thal_gor/thal-gor_hit.png")
const TEX_DEATH := preload("res://assets/sprites/wcielenia/thal_gor/thal-gor_death.png")

@export var arc_shot_radius: float = 90.0

func _ready() -> void:
	max_health = 42.0
	drift_speed = 115.0 ## dokument: "tangential speed 115"
	contact_damage = 9.0
	attack_interval = 1.7
	telegraph_duration = 0.50
	knockback_resistance = 0.15
	keep_distance_range = 185.0 ## dokument: "preferred range 185"
	orbit_mode = true
	super._ready()
	orbit_direction = 1.0 if randf() < 0.5 else -1.0
	current_color = Color("#4FA6A0")
	fragment_name = "Orbiter"
	_skills = [_skill_arc_shot]
	_sprite_textures = {
		"walk": {"front": TEX_WALK, "back": TEX_WALK_BACK, "side": TEX_WALK_SIDE},
		"telegraph": TEX_TELEGRAPH, "pulse": TEX_PULSE, "hit": TEX_HIT, "death": TEX_DEATH,
	}

func _skill_arc_shot() -> void:
	_damage_pulse(arc_shot_radius, contact_damage)
