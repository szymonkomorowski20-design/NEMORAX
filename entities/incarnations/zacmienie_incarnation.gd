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

func _ready() -> void:
	super._ready()
	current_color = Color("#C9C2B4")
	fragment_name = "Orryx Cień-Nicości" # patrz LORE_I_ASSETY.md
	_skills = [_skill_vanish_strike, _skill_flicker_pulse, _skill_dark_pull]

func _skill_vanish_strike() -> void:
	_intangible = true
	visible = false
	await get_tree().create_timer(vanish_duration).timeout
	if is_dead:
		return
	var offset := Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)).normalized() * reappear_range
	global_position = _clamp_to_arena(player.global_position + offset)
	visible = true
	_intangible = false
	_lunge_toward_player(strike_speed, strike_duration)

func _skill_flicker_pulse() -> void:
	_intangible = true
	visible = false
	await get_tree().create_timer(flicker_duration).timeout
	visible = true
	_intangible = false
	if not is_dead:
		_damage_pulse(flicker_radius, flicker_damage)

func _skill_dark_pull() -> void:
	_pull_player(pull_strength)
	if not is_dead:
		_damage_pulse(pull_followup_radius, pull_followup_damage)

func _check_contact() -> void:
	if _intangible:
		return
	super._check_contact()

func take_damage(amount: float) -> void:
	if _intangible:
		return
	super.take_damage(amount)
