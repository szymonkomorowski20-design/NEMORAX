extends Incarnation
class_name Charger
## Archetyp 4/12: Charger (dokument sekcja 6.1) — zagrożenie liniowe, odsuwa
## się na dystans, potem ładuje po prostej z dużą prędkością. Grafika:
## dedykowany base art z GPT (jeden statyczny obraz na wszystkie pozy na razie).

const TEX_BASE := preload("res://assets/sprites/random_enemies/charger/charger_base.png")
const VFX_ATTACK := preload("res://assets/sprites/enemy_vfx/charger_attack.png")
const VFX_SKILL := preload("res://assets/sprites/enemy_vfx/charger_skill.png")

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
	sprite_scale = 0.12 # KIERUNEK_WIZUALNY_REFERENCJE.md: ciężki wróg 1.05-1.35 gracza (player.sprite_scale=0.10)
	radius = 42.0 # przeliczone proporcjonalnie do nowej sprite_scale (patrz chaser.gd)
	super._ready()
	current_color = Color("#C4453A")
	hit_material = Palette.HitMaterial.STONE
	fragment_name = "Charger"
	_skills = [_skill_charge]
	_sprite_textures = {
		"walk": TEX_BASE, "telegraph": TEX_BASE, "lunge": TEX_BASE, "hit": TEX_BASE, "death": TEX_BASE,
	}

func _skill_charge() -> void:
	var dir: Vector2 = player.global_position - global_position
	var angle := dir.angle() if dir.length() > 0.01 else 0.0
	# Tor ładowania (skill) narysowany wzdłuż kierunku szarży, trwa tyle co sam wypad.
	AttackVfx.spawn(get_parent(), VFX_SKILL, global_position + dir.normalized() * 120.0, charge_duration, 0.45, angle)
	AttackVfx.spawn(get_parent(), VFX_ATTACK, global_position, 0.3, 0.35, angle)
	_lunge_toward_player(charge_speed, charge_duration)
