extends Incarnation
class_name Chaser
## Archetyp 1/12: Chaser (CLAUDE_CODE_GAME_CONTENT_BIBLE.md sekcja 6.1) —
## uporczywy pościg, podstawowa presja. Wręcz (keep_distance_range domyślne,
## zawsze idzie do kontaktu), jedyna umiejętność to bliski zasięg ataku.
## Grafika: dedykowany base art z GPT (na razie jeden statyczny obraz na
## wszystkie pozy — pełny zestaw kierunkowy/pozowy jeszcze nie wygenerowany).

const TEX_BASE := preload("res://assets/sprites/random_enemies/chaser/chaser_base.png")

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
		"walk": TEX_BASE, "telegraph": TEX_BASE, "pulse": TEX_BASE, "hit": TEX_BASE, "death": TEX_BASE,
	}

func _skill_swipe() -> void:
	_damage_pulse(swipe_range, contact_damage)
