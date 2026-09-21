extends Incarnation
class_name Orbiter
## Archetyp 5/12: Orbiter (dokument sekcja 6.1) — presja kątowa, krąży
## stycznie wokół gracza zamiast podchodzić/uciekać po prostej (orbit_mode,
## patrz entities/incarnation.gd). Kierunek krążenia losowany raz, żeby różne
## instancje nie kręciły się identycznie. Grafika: dedykowany base art z GPT
## (jeden statyczny obraz na wszystkie pozy na razie).

const TEX_BASE := preload("res://assets/sprites/random_enemies/orbiter/orbiter_base.png")
const VFX_ATTACK := preload("res://assets/sprites/enemy_vfx/orbiter_attack.png")
const VFX_SKILL := preload("res://assets/sprites/enemy_vfx/orbiter_skill.png")

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
	sprite_scale = 0.0875 # KIERUNEK_WIZUALNY_REFERENCJE.md: średni wróg 0.80-0.95 gracza (player.sprite_scale=0.10)
	super._ready()
	orbit_direction = 1.0 if randf() < 0.5 else -1.0
	current_color = Color("#4FA6A0")
	fragment_name = "Orbiter"
	_skills = [_skill_arc_shot]
	_sprite_textures = {
		"walk": TEX_BASE, "telegraph": TEX_BASE, "pulse": TEX_BASE, "hit": TEX_BASE, "death": TEX_BASE,
	}

func _skill_arc_shot() -> void:
	AttackVfx.spawn(get_parent(), VFX_SKILL, global_position, 0.4, 0.35)
	_damage_pulse(arc_shot_radius, contact_damage)
	AttackVfx.spawn(get_parent(), VFX_ATTACK, global_position, 0.3, 0.22)
