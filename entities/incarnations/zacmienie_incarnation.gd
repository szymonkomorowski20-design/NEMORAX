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
const TEX_WALK_BACK := preload("res://assets/sprites/wcielenia/orryx/orryx_walk_back.png")
const TEX_WALK_SIDE := preload("res://assets/sprites/wcielenia/orryx/orryx_walk_side.png")
const TEX_TELEGRAPH := preload("res://assets/sprites/wcielenia/orryx/orryx_telegraph.png")
const TEX_LUNGE := preload("res://assets/sprites/wcielenia/orryx/orryx_lunge.png")
const TEX_PULSE := preload("res://assets/sprites/wcielenia/orryx/orryx_cast-pulse.png")
const TEX_PULL := preload("res://assets/sprites/wcielenia/orryx/orryx_pull.png")
const TEX_HIT := preload("res://assets/sprites/wcielenia/orryx/orryx_hit.png")
const TEX_DEATH := preload("res://assets/sprites/wcielenia/orryx/orryx_death.png")
const TEX_VANISH := preload("res://assets/sprites/wcielenia/orryx/orryx_vanish.png")
const TEX_REAPPEAR := preload("res://assets/sprites/wcielenia/orryx/orryx_reappear.png")

func _ready() -> void:
	super._ready()
	current_color = Color("#8C9AC2") # dopasowane do dostarczonej grafiki (chłodny błękit, nie ciepły beż)
	fragment_name = "Orryx Cień-Nicości" # patrz LORE_I_ASSETY.md
	_skills = [_skill_vanish_strike, _skill_flicker_pulse, _skill_dark_pull, _pattern_pull_and_vanish_strike]
	_sprite_textures = {
		"walk": {"front": TEX_WALK, "back": TEX_WALK_BACK, "side": TEX_WALK_SIDE},
		"telegraph": TEX_TELEGRAPH, "lunge": TEX_LUNGE,
		"pulse": TEX_PULSE, "pull": TEX_PULL, "hit": TEX_HIT, "death": TEX_DEATH,
		"vanish": TEX_VANISH, "reappear": TEX_REAPPEAR,
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
	_lunge_toward_player(strike_speed, strike_duration)

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

func take_damage(amount: float) -> void:
	if _intangible:
		return
	super.take_damage(amount)
