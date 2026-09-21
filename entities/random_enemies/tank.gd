extends Incarnation
class_name Tank
## Archetyp 10/12: Tank (dokument sekcja 6.1) — kotwica/blokada, nie gąbka na
## obrażenia: wysokie HP i odporność na odepchnięcie, ale wolny i z czytelnym
## telegrafem przed uderzeniem obszarowym. Wręcz (keep_distance domyślne).
## Grafika: dedykowany base art z GPT (jeden statyczny obraz na wszystkie pozy
## na razie).

const TEX_BASE := preload("res://assets/sprites/random_enemies/tank/tank_base.png")
const VFX_ATTACK := preload("res://assets/sprites/enemy_vfx/tank_attack.png")
const VFX_SKILL := preload("res://assets/sprites/enemy_vfx/tank_skill.png")

@export var slam_range: float = 72.0 ## dokument: "range 72"

func _ready() -> void:
	max_health = 120.0
	drift_speed = 55.0
	contact_damage = 18.0
	attack_interval = 2.4
	telegraph_duration = 0.75
	knockback_resistance = 0.75
	radius = 110.0 ## większy niż domyślne 95 — Tank powinien czuć się fizycznie większy
	sprite_scale = 0.12 # KIERUNEK_WIZUALNY_REFERENCJE.md: ciężki wróg 1.05-1.35 gracza (player.sprite_scale=0.10)
	super._ready()
	current_color = Color("#B8622E")
	fragment_name = "Tank"
	_skills = [_skill_slam]
	_sprite_textures = {
		"walk": TEX_BASE, "telegraph": TEX_BASE, "pulse": TEX_BASE, "hit": TEX_BASE, "death": TEX_BASE,
	}

func _skill_slam() -> void:
	AttackVfx.spawn(get_parent(), VFX_SKILL, global_position, 0.4, 0.4)
	_damage_pulse(slam_range, contact_damage)
	AttackVfx.spawn(get_parent(), VFX_ATTACK, global_position, 0.3, 0.32)
