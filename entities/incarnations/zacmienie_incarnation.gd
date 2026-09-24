extends Incarnation
class_name ZacmienieIncarnation
## Wcielenie fazy Zaćmienie — pochłania światło (LORE_I_ASSETY.md 2.6). Trzy
## umiejętności: zniknięcie i uderzenie z zaskoczenia, migotliwy impuls (chwila
## nietykalności + cios), wciągnięcie w ciemność (przyciągnięcie + impuls).

@export var vanish_duration: float = 0.4
@export var reappear_range: float = 150.0
@export var strike_speed: float = 400.0
@export var strike_duration: float = 0.3
@export var flicker_duration: float = 0.25
@export var flicker_radius: float = 90.0
@export var flicker_damage: float = 14.0
@export var pull_strength: float = 400.0
@export var pull_followup_radius: float = 75.0
@export var pull_followup_damage: float = 14.0

var _intangible: bool = false

const TEX_WALK := preload("res://assets/sprites/wcielenia/orryx/orryx_walk.png")
const TEX_WALK_FRONT_STRIDE := preload("res://assets/sprites/wcielenia/orryx/orryx_walk_front_stride.png")
const TEX_WALK_FRONT_DIAGONAL := preload("res://assets/sprites/wcielenia/orryx/orryx_walk_front_diagonal.png")
const TEX_WALK_FRONT_DIAGONAL_STRIDE := preload("res://assets/sprites/wcielenia/orryx/orryx_walk_front_diagonal_stride.png")
const TEX_WALK_SIDE := preload("res://assets/sprites/wcielenia/orryx/orryx_walk_side.png")
const TEX_WALK_SIDE_STRIDE := preload("res://assets/sprites/wcielenia/orryx/orryx_walk_side_stride.png")
const TEX_WALK_BACK_DIAGONAL := preload("res://assets/sprites/wcielenia/orryx/orryx_walk_back_diagonal.png")
const TEX_WALK_BACK_DIAGONAL_STRIDE := preload("res://assets/sprites/wcielenia/orryx/orryx_walk_back_diagonal_stride.png")
const TEX_WALK_BACK := preload("res://assets/sprites/wcielenia/orryx/orryx_walk_back.png")
const TEX_WALK_BACK_STRIDE := preload("res://assets/sprites/wcielenia/orryx/orryx_walk_back_stride.png")
const TEX_TELEGRAPH := preload("res://assets/sprites/wcielenia/orryx/orryx_telegraph.png")
const TEX_TELEGRAPH_FRONT_DIAGONAL := preload("res://assets/sprites/wcielenia/orryx/orryx_telegraph_front_diagonal.png")
const TEX_TELEGRAPH_SIDE := preload("res://assets/sprites/wcielenia/orryx/orryx_telegraph_side.png")
const TEX_TELEGRAPH_BACK_DIAGONAL := preload("res://assets/sprites/wcielenia/orryx/orryx_telegraph_back_diagonal.png")
const TEX_TELEGRAPH_BACK := preload("res://assets/sprites/wcielenia/orryx/orryx_telegraph_back.png")
const TEX_LUNGE := preload("res://assets/sprites/wcielenia/orryx/orryx_lunge.png")
const TEX_LUNGE_FRONT_DIAGONAL := preload("res://assets/sprites/wcielenia/orryx/orryx_lunge_front_diagonal.png")
const TEX_LUNGE_SIDE := preload("res://assets/sprites/wcielenia/orryx/orryx_lunge_side.png")
const TEX_LUNGE_BACK_DIAGONAL := preload("res://assets/sprites/wcielenia/orryx/orryx_lunge_back_diagonal.png")
const TEX_LUNGE_BACK := preload("res://assets/sprites/wcielenia/orryx/orryx_lunge_back.png")
const TEX_PULSE := preload("res://assets/sprites/wcielenia/orryx/orryx_cast-pulse.png")
const TEX_PULSE_FRONT_DIAGONAL := preload("res://assets/sprites/wcielenia/orryx/orryx_cast-pulse_front_diagonal.png")
const TEX_PULSE_SIDE := preload("res://assets/sprites/wcielenia/orryx/orryx_cast-pulse_side.png")
const TEX_PULSE_BACK_DIAGONAL := preload("res://assets/sprites/wcielenia/orryx/orryx_cast-pulse_back_diagonal.png")
const TEX_PULSE_BACK := preload("res://assets/sprites/wcielenia/orryx/orryx_cast-pulse_back.png")
const TEX_PULL := preload("res://assets/sprites/wcielenia/orryx/orryx_pull.png")
const TEX_PULL_FRONT_DIAGONAL := preload("res://assets/sprites/wcielenia/orryx/orryx_pull_front_diagonal.png")
const TEX_PULL_SIDE := preload("res://assets/sprites/wcielenia/orryx/orryx_pull_side.png")
const TEX_PULL_BACK_DIAGONAL := preload("res://assets/sprites/wcielenia/orryx/orryx_pull_back_diagonal.png")
const TEX_PULL_BACK := preload("res://assets/sprites/wcielenia/orryx/orryx_pull_back.png")
const TEX_HIT := preload("res://assets/sprites/wcielenia/orryx/orryx_hit.png")
const TEX_HIT_FRONT_DIAGONAL := preload("res://assets/sprites/wcielenia/orryx/orryx_hit_front_diagonal.png")
const TEX_HIT_SIDE := preload("res://assets/sprites/wcielenia/orryx/orryx_hit_side.png")
const TEX_HIT_BACK_DIAGONAL := preload("res://assets/sprites/wcielenia/orryx/orryx_hit_back_diagonal.png")
const TEX_HIT_BACK := preload("res://assets/sprites/wcielenia/orryx/orryx_hit_back.png")
const TEX_DEATH := preload("res://assets/sprites/wcielenia/orryx/orryx_death.png")
const TEX_DEATH_FRONT_DIAGONAL := preload("res://assets/sprites/wcielenia/orryx/orryx_death_front_diagonal.png")
const TEX_DEATH_SIDE := preload("res://assets/sprites/wcielenia/orryx/orryx_death_side.png")
const TEX_DEATH_BACK_DIAGONAL := preload("res://assets/sprites/wcielenia/orryx/orryx_death_back_diagonal.png")
const TEX_DEATH_BACK := preload("res://assets/sprites/wcielenia/orryx/orryx_death_back.png")
const TEX_VANISH := preload("res://assets/sprites/wcielenia/orryx/orryx_vanish.png")
const TEX_VANISH_FRONT_DIAGONAL := preload("res://assets/sprites/wcielenia/orryx/orryx_vanish_front_diagonal.png")
const TEX_VANISH_SIDE := preload("res://assets/sprites/wcielenia/orryx/orryx_vanish_side.png")
const TEX_VANISH_BACK_DIAGONAL := preload("res://assets/sprites/wcielenia/orryx/orryx_vanish_back_diagonal.png")
const TEX_VANISH_BACK := preload("res://assets/sprites/wcielenia/orryx/orryx_vanish_back.png")
const TEX_REAPPEAR := preload("res://assets/sprites/wcielenia/orryx/orryx_reappear.png")
const TEX_REAPPEAR_FRONT_DIAGONAL := preload("res://assets/sprites/wcielenia/orryx/orryx_reappear_front_diagonal.png")
const TEX_REAPPEAR_SIDE := preload("res://assets/sprites/wcielenia/orryx/orryx_reappear_side.png")
const TEX_REAPPEAR_BACK_DIAGONAL := preload("res://assets/sprites/wcielenia/orryx/orryx_reappear_back_diagonal.png")
const TEX_REAPPEAR_BACK := preload("res://assets/sprites/wcielenia/orryx/orryx_reappear_back.png")

func _ready() -> void:
	super._ready()
	current_color = Color("#8C9AC2") # dopasowane do dostarczonej grafiki (chłodny błękit, nie ciepły beż)
	hit_material = Palette.HitMaterial.MAGIC
	is_miniboss = true
	fragment_name = "Orryx Cień-Nicości" # patrz LORE_I_ASSETY.md
	_skills = [_skill_vanish_strike, _skill_flicker_pulse, _skill_dark_pull, _pattern_pull_and_vanish_strike]
	_sprite_textures = {
		"walk": {
			"front": [TEX_WALK, TEX_WALK_FRONT_STRIDE],
			"front_diagonal": [TEX_WALK_FRONT_DIAGONAL, TEX_WALK_FRONT_DIAGONAL_STRIDE],
			"side": [TEX_WALK_SIDE, TEX_WALK_SIDE_STRIDE],
			"back_diagonal": [TEX_WALK_BACK_DIAGONAL, TEX_WALK_BACK_DIAGONAL_STRIDE],
			"back": [TEX_WALK_BACK, TEX_WALK_BACK_STRIDE],
		},
		"telegraph": {"front": TEX_TELEGRAPH, "front_diagonal": TEX_TELEGRAPH_FRONT_DIAGONAL, "side": TEX_TELEGRAPH_SIDE, "back_diagonal": TEX_TELEGRAPH_BACK_DIAGONAL, "back": TEX_TELEGRAPH_BACK},
		"lunge": {"front": TEX_LUNGE, "front_diagonal": TEX_LUNGE_FRONT_DIAGONAL, "side": TEX_LUNGE_SIDE, "back_diagonal": TEX_LUNGE_BACK_DIAGONAL, "back": TEX_LUNGE_BACK},
		"pulse": {"front": TEX_PULSE, "front_diagonal": TEX_PULSE_FRONT_DIAGONAL, "side": TEX_PULSE_SIDE, "back_diagonal": TEX_PULSE_BACK_DIAGONAL, "back": TEX_PULSE_BACK},
		"pull": {"front": TEX_PULL, "front_diagonal": TEX_PULL_FRONT_DIAGONAL, "side": TEX_PULL_SIDE, "back_diagonal": TEX_PULL_BACK_DIAGONAL, "back": TEX_PULL_BACK},
		"hit": {"front": TEX_HIT, "front_diagonal": TEX_HIT_FRONT_DIAGONAL, "side": TEX_HIT_SIDE, "back_diagonal": TEX_HIT_BACK_DIAGONAL, "back": TEX_HIT_BACK},
		"death": {"front": TEX_DEATH, "front_diagonal": TEX_DEATH_FRONT_DIAGONAL, "side": TEX_DEATH_SIDE, "back_diagonal": TEX_DEATH_BACK_DIAGONAL, "back": TEX_DEATH_BACK},
		"vanish": {"front": TEX_VANISH, "front_diagonal": TEX_VANISH_FRONT_DIAGONAL, "side": TEX_VANISH_SIDE, "back_diagonal": TEX_VANISH_BACK_DIAGONAL, "back": TEX_VANISH_BACK},
		"reappear": {"front": TEX_REAPPEAR, "front_diagonal": TEX_REAPPEAR_FRONT_DIAGONAL, "side": TEX_REAPPEAR_SIDE, "back_diagonal": TEX_REAPPEAR_BACK_DIAGONAL, "back": TEX_REAPPEAR_BACK},
	}

func _skill_vanish_strike() -> void:
	_set_skill_pose("vanish") # widoczne na klatce tuż przed zniknięciem
	_intangible = true
	visible = false
	await get_tree().create_timer(vanish_duration).timeout
	if is_dead:
		return
	var offset := Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)).normalized() * reappear_range
	global_position = _clamp_to_arena(player.global_position + offset)
	visible = true
	_intangible = false
	_set_skill_pose("reappear")
	_lunge_after_arrival(strike_speed, strike_duration) # P0.2: zapowiedź po powrocie z cienia

func _skill_flicker_pulse() -> void:
	_set_skill_pose("vanish")
	_intangible = true
	visible = false
	await get_tree().create_timer(flicker_duration).timeout
	visible = true
	_intangible = false
	_set_skill_pose("reappear")
	if not is_dead:
		_damage_pulse(flicker_radius, flicker_damage)

func _skill_dark_pull() -> void:
	_pull_player(pull_strength)
	if not is_dead:
		_damage_pulse(pull_followup_radius, pull_followup_damage)

## "Grupa wzorców" (dokument sekcja 11) — wciąga w cień, potem znika i uderza.
func _pattern_pull_and_vanish_strike() -> void:
	_skill_dark_pull()
	await get_tree().create_timer(0.3).timeout
	if not is_dead:
		_skill_vanish_strike()

func _check_contact() -> void:
	if _intangible:
		return
	super._check_contact()

func take_damage(amount: float) -> float:
	if _intangible:
		return 0.0
	return super.take_damage(amount)
