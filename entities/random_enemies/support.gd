extends Incarnation
class_name Support
## Archetyp 11/12: Support (dokument sekcja 6.1) — "wzmacniacz sojusznika".
## Każdy RANDOM pokój ma dziś DOKŁADNIE JEDNEGO przeciwnika (żadnych fal
## wieloosobowych, patrz PLAN_LOSOWYCH_POKOI.md) — "link do sojusznika"
## dosłownie z dokumentu nie ma czego zrobić. Uczciwa adaptacja: buffuje SAM
## SIEBIE (prędkość) na czas trwania, zamiast udawać sojusznika, którego nie
## ma. Do rewizji, jeśli kiedyś powstaną wieloosobowe fale w jednym pokoju.
## Grafika: dedykowany base art z GPT (jeden statyczny obraz na wszystkie pozy
## na razie).

const TEX_BASE := preload("res://assets/sprites/random_enemies/support/support_base.png")

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
		"walk": TEX_BASE, "telegraph": TEX_BASE, "pull": TEX_BASE, "hit": TEX_BASE, "death": TEX_BASE,
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
