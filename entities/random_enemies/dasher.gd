extends Incarnation
class_name Dasher
## Archetyp 6/12: Dasher (dokument sekcja 6.1) — krótki, gwałtowny wypad z
## umiarkowanego dystansu ("stalk"), inaczej niż Charger (długa ładunkowa
## linia) czy Striker (bliski dystans). Grafika: dedykowany base art z GPT
## (jeden statyczny obraz na wszystkie pozy na razie).

const TEX_BASE := preload("res://assets/sprites/random_enemies/dasher/dasher_base.png")
const VFX_ATTACK := preload("res://assets/sprites/enemy_vfx/dasher_attack.png")
const VFX_SKILL := preload("res://assets/sprites/enemy_vfx/dasher_skill.png")

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
	sprite_scale = 0.075 # KIERUNEK_WIZUALNY_REFERENCJE.md: mały wróg 0.65-0.85 gracza (player.sprite_scale=0.10)
	radius = 26.0 # przeliczone proporcjonalnie do nowej sprite_scale (patrz chaser.gd)
	super._ready()
	current_color = Color("#9B6BF0")
	hit_material = Palette.HitMaterial.MAGIC
	fragment_name = "Dasher"
	_skills = [_skill_dash]
	_sprite_textures = {
		"walk": TEX_BASE, "telegraph": TEX_BASE, "lunge": TEX_BASE, "hit": TEX_BASE, "death": TEX_BASE,
	}

func _skill_dash() -> void:
	var dir: Vector2 = player.global_position - global_position
	var angle := dir.angle() if dir.length() > 0.01 else 0.0
	# Znacznik lądowania (skill) na docelowej pozycji wypadu, cios (attack) przy sobie.
	AttackVfx.spawn(get_parent(), VFX_SKILL, global_position + dir.normalized() * dash_distance, 0.35, 0.3)
	AttackVfx.spawn(get_parent(), VFX_ATTACK, global_position, 0.3, 0.3, angle)
	_lunge_toward_player(dash_speed, dash_distance / dash_speed)
