extends Incarnation
class_name Support
## Archetyp 11/12: Support (dokument sekcja 6.1) — "wzmacniacz sojusznika".
## Każdy RANDOM pokój ma dziś DOKŁADNIE JEDNEGO przeciwnika (żadnych fal
## wieloosobowych, patrz PLAN_LOSOWYCH_POKOI.md) — "link do sojusznika"
## dosłownie z dokumentu nie ma czego zrobić. Uczciwa adaptacja: buffuje SAM
## SIEBIE (prędkość) na czas trwania, zamiast udawać sojusznika, którego nie
## ma. Do rewizji, jeśli kiedyś powstaną wieloosobowe fale w jednym pokoju.
## Grafika: TYMCZASOWO Thal'Gor.

const TEX_WALK := preload("res://assets/sprites/wcielenia/thal_gor/thal-gor_walk.png")
const TEX_WALK_BACK := preload("res://assets/sprites/wcielenia/thal_gor/thal-gor_walk_back.png")
const TEX_WALK_SIDE := preload("res://assets/sprites/wcielenia/thal_gor/thal-gor_walk_side.png")
const TEX_TELEGRAPH := preload("res://assets/sprites/wcielenia/thal_gor/thal-gor_telegraph.png")
const TEX_PULL := preload("res://assets/sprites/wcielenia/thal_gor/thal-gor_pull.png")
const TEX_HIT := preload("res://assets/sprites/wcielenia/thal_gor/thal-gor_hit.png")
const TEX_DEATH := preload("res://assets/sprites/wcielenia/thal_gor/thal-gor_death.png")

@export var buff_move_bonus: float = 0.15 ## dokument: "+15% move"
@export var buff_duration: float = 3.0

var _base_drift_speed: float
var _buff_timer: float = 0.0

func _ready() -> void:
	max_health = 50.0
	drift_speed = 85.0
	contact_damage = 6.0
	attack_interval = 5.0
	telegraph_duration = 0.80
	knockback_resistance = 0.15
	keep_distance_range = 200.0 ## trzyma dystans zamiast wchodzić w zwarcie, jak w dokumencie
	super._ready()
	_base_drift_speed = drift_speed
	current_color = Color("#8ED9C9")
	fragment_name = "Support"
	_skills = [_skill_self_buff]
	_sprite_textures = {
		"walk": {"front": TEX_WALK, "back": TEX_WALK_BACK, "side": TEX_WALK_SIDE},
		"telegraph": TEX_TELEGRAPH, "pull": TEX_PULL, "hit": TEX_HIT, "death": TEX_DEATH,
	}

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if _buff_timer > 0.0:
		_buff_timer -= delta
		if _buff_timer <= 0.0:
			drift_speed = _base_drift_speed

func _skill_self_buff() -> void:
	_set_skill_pose("pull") # brak dedykowanej pozy buffu — reużyta "pull" jako "coś na siebie rzuca"
	drift_speed = _base_drift_speed * (1.0 + buff_move_bonus)
	_buff_timer = buff_duration
