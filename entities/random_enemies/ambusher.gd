extends Incarnation
class_name Ambusher
## Archetyp 7/12: Ambusher (dokument sekcja 6.1) — test reakcji: czai się na
## dystansie, ledwo widoczny, ujawnia się przy telegrafie i uderza. Brak
## prawdziwej niewidzialności w silniku — przygaszona przezroczystość podczas
## czajenia to najbliższe uczciwe przybliżenie "hidden" bez nowego systemu
## renderowania tylko dla jednego archetypu. Grafika: TYMCZASOWO Vhar'Nokh.

const TEX_WALK := preload("res://assets/sprites/wcielenia/vhar_nokh/vhar-nokh_walk.png")
const TEX_WALK_BACK := preload("res://assets/sprites/wcielenia/vhar_nokh/vhar-nokh_walk_back.png")
const TEX_WALK_SIDE := preload("res://assets/sprites/wcielenia/vhar_nokh/vhar-nokh_walk_side.png")
const TEX_TELEGRAPH := preload("res://assets/sprites/wcielenia/vhar_nokh/vhar-nokh_telegraph.png")
const TEX_LUNGE := preload("res://assets/sprites/wcielenia/vhar_nokh/vhar-nokh_lunge.png")
const TEX_HIT := preload("res://assets/sprites/wcielenia/vhar_nokh/vhar-nokh_hit.png")
const TEX_DEATH := preload("res://assets/sprites/wcielenia/vhar_nokh/vhar-nokh_death.png")

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
		"walk": {"front": TEX_WALK, "back": TEX_WALK_BACK, "side": TEX_WALK_SIDE},
		"telegraph": TEX_TELEGRAPH, "lunge": TEX_LUNGE, "hit": TEX_HIT, "death": TEX_DEATH,
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
