extends Incarnation
class_name Ambusher
## Archetyp 7/12: Ambusher (dokument sekcja 6.1) — test reakcji: czai się na
## dystansie, ledwo widoczny, ujawnia się przy telegrafie i uderza. Brak
## prawdziwej niewidzialności w silniku — przygaszona przezroczystość podczas
## czajenia to najbliższe uczciwe przybliżenie "hidden" bez nowego systemu
## renderowania tylko dla jednego archetypu. Grafika: dedykowany base art z GPT
## (jeden statyczny obraz na wszystkie pozy na razie).

const TEX_BASE := preload("res://assets/sprites/random_enemies/ambusher/ambusher_base.png")
const VFX_ATTACK := preload("res://assets/sprites/enemy_vfx/ambusher_attack.png")
const VFX_SKILL := preload("res://assets/sprites/enemy_vfx/ambusher_skill.png")

@export var strike_speed: float = 380.0
@export var strike_range: float = 95.0 ## dokument: "strike range 95"
@export var hidden_alpha: float = 0.4

func _ready() -> void:
	max_health = 38.0
	drift_speed = 100.0
	contact_damage = 14.0
	attack_interval = 2.6
	telegraph_duration = 0.70
	knockback_resistance = 0.10
	keep_distance_range = 150.0
	sprite_scale = 0.0875 # KIERUNEK_WIZUALNY_REFERENCJE.md: średni wróg 0.80-0.95 gracza (player.sprite_scale=0.10)
	radius = 31.0 # przeliczone proporcjonalnie do nowej sprite_scale (patrz chaser.gd)
	super._ready()
	current_color = Color("#8A7EA6")
	hit_material = Palette.HitMaterial.BONE
	fragment_name = "Ambusher"
	_skills = [_skill_strike]
	_sprite_textures = {
		"walk": TEX_BASE, "telegraph": TEX_BASE, "lunge": TEX_BASE, "hit": TEX_BASE, "death": TEX_BASE,
	}

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if is_dead:
		return
	# Widoczny w pełni podczas zapowiedzi/wypadu/trafienia (musi być czytelny
	# jako zagrożenie — a trafienie oczywiście zdradza pozycję), przygaszony
	# tylko w trakcie czajenia się na dystansie.
	sprite.modulate.a = 1.0 if (_telegraph_active or _lunge_active or _flash_frames > 0) else hidden_alpha

func _skill_strike() -> void:
	var dir: Vector2 = player.global_position - global_position
	var angle := dir.angle() if dir.length() > 0.01 else 0.0
	# Znacznik ujawnienia (skill) w miejscu docelowym wypadu, cios (attack) przy sobie.
	AttackVfx.spawn(get_parent(), VFX_SKILL, global_position + dir.normalized() * strike_range, 0.3, 0.3)
	AttackVfx.spawn(get_parent(), VFX_ATTACK, global_position, 0.25, 0.3, angle)
	_lunge_toward_player(strike_speed, strike_range / strike_speed)
