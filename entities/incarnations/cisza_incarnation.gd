extends Incarnation
class_name CiszaIncarnation
## Wcielenie fazy Cisza — pochłania dźwięk (LORE_I_ASSETY.md 2.2). Trzy umiejętności:
## impuls ciszy, wciągnięcie w ciszę (przyciągnięcie + impuls), cichy pościg (wypad).

@export var pulse_radius: float = 90.0
@export var pulse_damage: float = 14.0
@export var pull_strength: float = 380.0
@export var pull_followup_delay: float = 0.2
@export var rush_speed: float = 360.0
@export var rush_duration: float = 0.4

func _ready() -> void:
	super._ready()
	current_color = Color("#FF8A3D")
	fragment_name = "Mordrath Bez-Wymiaru" # patrz LORE_I_ASSETY.md
	_skills = [_skill_silence_pulse, _skill_muffling_pull, _skill_silent_rush]

func _skill_silence_pulse() -> void:
	_damage_pulse(pulse_radius, pulse_damage)

func _skill_muffling_pull() -> void:
	_pull_player(pull_strength)
	await get_tree().create_timer(pull_followup_delay).timeout
	if not is_dead:
		_damage_pulse(pulse_radius, pulse_damage)

func _skill_silent_rush() -> void:
	_lunge_toward_player(rush_speed, rush_duration)
