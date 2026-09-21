extends Incarnation
class_name Charger
## Archetyp 4/12: Charger (dokument sekcja 6.1) — zagrożenie liniowe, odsuwa
## się na dystans, potem ładuje po prostej z dużą prędkością. Grafika:
## dedykowany base art z GPT (jeden statyczny obraz na wszystkie pozy na razie).

const TEX_BASE := preload("res://assets/sprites/random_enemies/charger/charger_base.png")

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
	sprite_scale = 0.096 # KIERUNEK_WIZUALNY_REFERENCJE.md: ciężki wróg 1.05-1.35 gracza (player.sprite_scale=0.08)
	super._ready()
	current_color = Color("#C4453A")
	fragment_name = "Charger"
	_skills = [_skill_charge]
	_sprite_textures = {
		"walk": TEX_BASE, "telegraph": TEX_BASE, "lunge": TEX_BASE, "hit": TEX_BASE, "death": TEX_BASE,
	}

func _skill_charge() -> void:
	_lunge_toward_player(charge_speed, charge_duration)
