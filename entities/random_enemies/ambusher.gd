extends Incarnation
class_name Ambusher
## Archetyp 7/12: Ambusher (dokument sekcja 6.1) — test reakcji: czai się na
## dystansie, ledwo widoczny, ujawnia się przy telegrafie i uderza. Brak
## prawdziwej niewidzialności w silniku — przygaszona przezroczystość podczas
## czajenia to najbliższe uczciwe przybliżenie "hidden" bez nowego systemu
## renderowania tylko dla jednego archetypu. Grafika: dedykowany base art z GPT
## (jeden statyczny obraz na wszystkie pozy na razie).

const TEX_BASE := preload("res://assets/sprites/random_enemies/ambusher/ambusher_base.png")

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
	super._ready()
	current_color = Color("#8A7EA6")
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
	_lunge_toward_player(strike_speed, strike_range / strike_speed)
