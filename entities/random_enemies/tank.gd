extends Incarnation
class_name Tank
## Archetyp 10/12: Tank (dokument sekcja 6.1) — kotwica/blokada, nie gąbka na
## obrażenia: wysokie HP i odporność na odepchnięcie, ale wolny i z czytelnym
## telegrafem przed uderzeniem obszarowym. Wręcz (keep_distance domyślne).
## Grafika: TYMCZASOWO Nekravor.

const TEX_WALK := preload("res://assets/sprites/wcielenia/nekravor/nekravor_walk.png")
const TEX_WALK_BACK := preload("res://assets/sprites/wcielenia/nekravor/nekravor_walk_back.png")
const TEX_WALK_SIDE := preload("res://assets/sprites/wcielenia/nekravor/nekravor_walk_side.png")
const TEX_TELEGRAPH := preload("res://assets/sprites/wcielenia/nekravor/nekravor_telegraph.png")
const TEX_PULSE := preload("res://assets/sprites/wcielenia/nekravor/nekravor_cast-pulse.png")
const TEX_HIT := preload("res://assets/sprites/wcielenia/nekravor/nekravor_hit.png")
const TEX_DEATH := preload("res://assets/sprites/wcielenia/nekravor/nekravor_death.png")

@export var slam_range: float = 72.0 ## dokument: "range 72"

func _ready() -> void:
	max_health = 120.0
	drift_speed = 55.0
	contact_damage = 18.0
	attack_interval = 2.4
	telegraph_duration = 0.75
	knockback_resistance = 0.75
	radius = 110.0 ## większy niż domyślne 95 — Tank powinien czuć się fizycznie większy
	super._ready()
	current_color = Color("#B8622E")
	fragment_name = "Tank"
	_skills = [_skill_slam]
	_sprite_textures = {
		"walk": {"front": TEX_WALK, "back": TEX_WALK_BACK, "side": TEX_WALK_SIDE},
		"telegraph": TEX_TELEGRAPH, "pulse": TEX_PULSE, "hit": TEX_HIT, "death": TEX_DEATH,
	}

func _skill_slam() -> void:
	_damage_pulse(slam_range, contact_damage)
