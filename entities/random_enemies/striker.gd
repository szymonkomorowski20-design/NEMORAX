extends Incarnation
class_name Striker
## Archetyp 2/12: Striker (dokument sekcja 6.1) — burst melee, trzyma dystans
## (70-95px), potem wchodzi wypadem. Grafika: dedykowany base art z GPT
## (jeden statyczny obraz na wszystkie pozy na razie).

const TEX_BASE := preload("res://assets/sprites/random_enemies/striker/striker_base.png")

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
	sprite_scale = 0.075 # KIERUNEK_WIZUALNY_REFERENCJE.md: mały wróg 0.65-0.85 gracza (player.sprite_scale=0.10)
	radius = 26.0 # przeliczone proporcjonalnie do nowej sprite_scale (patrz chaser.gd)
	super._ready()
	current_color = Color("#E8933D")
	fragment_name = "Striker"
	_skills = [_skill_lunge_strike]
	_sprite_textures = {
		"walk": TEX_BASE, "telegraph": TEX_BASE, "lunge": TEX_BASE, "hit": TEX_BASE, "death": TEX_BASE,
	}

func _skill_lunge_strike() -> void:
	_lunge_toward_player(lunge_speed, lunge_distance / lunge_speed)
