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

const TEX_WALK := preload("res://assets/sprites/wcielenia/mordrath/mordrath_walk.png")
const TEX_TELEGRAPH := preload("res://assets/sprites/wcielenia/mordrath/mordrath_telegraph.png")
const TEX_LUNGE := preload("res://assets/sprites/wcielenia/mordrath/mordrath_lunge.png")
const TEX_PULSE := preload("res://assets/sprites/wcielenia/mordrath/mordrath_cast-pulse.png")
const TEX_PULL := preload("res://assets/sprites/wcielenia/mordrath/mordrath_pull.png")
const TEX_HIT := preload("res://assets/sprites/wcielenia/mordrath/mordrath_hit.png")
const TEX_DEATH := preload("res://assets/sprites/wcielenia/mordrath/mordrath_death.png")
const TEX_SILENCE_PULSE := preload("res://assets/sprites/wcielenia/mordrath/mordrath_silence-pulse.png")

func _ready() -> void:
	super._ready()
	current_color = Color("#9B4DFF") # dopasowane do dostarczonej grafiki (fioletowa, nie pomarańczowa)
	fragment_name = "Mordrath Bez-Wymiaru" # patrz LORE_I_ASSETY.md
	_skills = [_skill_silence_pulse, _skill_muffling_pull, _skill_silent_rush]
	_sprite_textures = {
		"walk": TEX_WALK, "telegraph": TEX_TELEGRAPH, "lunge": TEX_LUNGE,
		"pulse": TEX_PULSE, "pull": TEX_PULL, "hit": TEX_HIT, "death": TEX_DEATH,
		"silence_pulse": TEX_SILENCE_PULSE,
	}

## Sygnaturalna umiejętność Mordratha — pokazuje unikalną, "stłumioną" pozę
## zamiast generycznego wybuchu (nadpisuje pose ustawioną przez _damage_pulse()).
func _skill_silence_pulse() -> void:
	_damage_pulse(pulse_radius, pulse_damage)
	_set_skill_pose("silence_pulse")

func _skill_muffling_pull() -> void:
	_pull_player(pull_strength)
	await get_tree().create_timer(pull_followup_delay).timeout
	if not is_dead:
		_damage_pulse(pulse_radius, pulse_damage)

func _skill_silent_rush() -> void:
	_lunge_toward_player(rush_speed, rush_duration)
