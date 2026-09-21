extends Incarnation
class_name Chaser
## Archetyp 1/12: Chaser (CLAUDE_CODE_GAME_CONTENT_BIBLE.md sekcja 6.1) —
## uporczywy pościg, podstawowa presja. Wręcz (keep_distance_range domyślne,
## zawsze idzie do kontaktu), jedyna umiejętność to bliski zasięg ataku.
## Grafika: TYMCZASOWO reużyty zestaw Vhar'Nokha (PROMPTY_WROGOW_LOSOWYCH_I_SKRZYNI.md
## sekcja A1 ma docelowy prompt) — do podmiany, gdy grafika wróci z GPT.

const TEX_WALK := preload("res://assets/sprites/wcielenia/vhar_nokh/vhar-nokh_walk.png")
const TEX_WALK_BACK := preload("res://assets/sprites/wcielenia/vhar_nokh/vhar-nokh_walk_back.png")
const TEX_WALK_SIDE := preload("res://assets/sprites/wcielenia/vhar_nokh/vhar-nokh_walk_side.png")
const TEX_TELEGRAPH := preload("res://assets/sprites/wcielenia/vhar_nokh/vhar-nokh_telegraph.png")
const TEX_PULSE := preload("res://assets/sprites/wcielenia/vhar_nokh/vhar-nokh_cast-pulse.png")
const TEX_HIT := preload("res://assets/sprites/wcielenia/vhar_nokh/vhar-nokh_hit.png")
const TEX_DEATH := preload("res://assets/sprites/wcielenia/vhar_nokh/vhar-nokh_death.png")

@export var swipe_range: float = 42.0 ## dokument: "engage 42"

func _ready() -> void:
	max_health = 30.0
	drift_speed = 105.0
	contact_damage = 8.0
	attack_interval = 1.2
	telegraph_duration = 0.30
	knockback_resistance = 0.10
	super._ready()
	current_color = Color("#8FBF6B")
	fragment_name = "Chaser"
	_skills = [_skill_swipe]
	_sprite_textures = {
		"walk": {"front": TEX_WALK, "back": TEX_WALK_BACK, "side": TEX_WALK_SIDE},
		"telegraph": TEX_TELEGRAPH, "pulse": TEX_PULSE, "hit": TEX_HIT, "death": TEX_DEATH,
	}

func _skill_swipe() -> void:
	_damage_pulse(swipe_range, contact_damage)
