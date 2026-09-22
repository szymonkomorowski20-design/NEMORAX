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
const TEX_WALK_FRONT_STRIDE := preload("res://assets/sprites/wcielenia/mordrath/mordrath_walk_front_stride.png")
const TEX_WALK_FRONT_DIAGONAL := preload("res://assets/sprites/wcielenia/mordrath/mordrath_walk_front_diagonal.png")
const TEX_WALK_FRONT_DIAGONAL_STRIDE := preload("res://assets/sprites/wcielenia/mordrath/mordrath_walk_front_diagonal_stride.png")
const TEX_WALK_SIDE := preload("res://assets/sprites/wcielenia/mordrath/mordrath_walk_side.png")
const TEX_WALK_SIDE_STRIDE := preload("res://assets/sprites/wcielenia/mordrath/mordrath_walk_side_stride.png")
const TEX_WALK_BACK_DIAGONAL := preload("res://assets/sprites/wcielenia/mordrath/mordrath_walk_back_diagonal.png")
const TEX_WALK_BACK_DIAGONAL_STRIDE := preload("res://assets/sprites/wcielenia/mordrath/mordrath_walk_back_diagonal_stride.png")
const TEX_WALK_BACK := preload("res://assets/sprites/wcielenia/mordrath/mordrath_walk_back.png")
const TEX_WALK_BACK_STRIDE := preload("res://assets/sprites/wcielenia/mordrath/mordrath_walk_back_stride.png")
const TEX_TELEGRAPH := preload("res://assets/sprites/wcielenia/mordrath/mordrath_telegraph.png")
const TEX_TELEGRAPH_FRONT_DIAGONAL := preload("res://assets/sprites/wcielenia/mordrath/mordrath_telegraph_front_diagonal.png")
const TEX_TELEGRAPH_SIDE := preload("res://assets/sprites/wcielenia/mordrath/mordrath_telegraph_side.png")
const TEX_TELEGRAPH_BACK_DIAGONAL := preload("res://assets/sprites/wcielenia/mordrath/mordrath_telegraph_back_diagonal.png")
const TEX_TELEGRAPH_BACK := preload("res://assets/sprites/wcielenia/mordrath/mordrath_telegraph_back.png")
const TEX_LUNGE := preload("res://assets/sprites/wcielenia/mordrath/mordrath_lunge.png")
const TEX_LUNGE_FRONT_DIAGONAL := preload("res://assets/sprites/wcielenia/mordrath/mordrath_lunge_front_diagonal.png")
const TEX_LUNGE_SIDE := preload("res://assets/sprites/wcielenia/mordrath/mordrath_lunge_side.png")
const TEX_LUNGE_BACK_DIAGONAL := preload("res://assets/sprites/wcielenia/mordrath/mordrath_lunge_back_diagonal.png")
const TEX_LUNGE_BACK := preload("res://assets/sprites/wcielenia/mordrath/mordrath_lunge_back.png")
const TEX_PULSE := preload("res://assets/sprites/wcielenia/mordrath/mordrath_cast-pulse.png")
const TEX_PULSE_FRONT_DIAGONAL := preload("res://assets/sprites/wcielenia/mordrath/mordrath_cast-pulse_front_diagonal.png")
const TEX_PULSE_SIDE := preload("res://assets/sprites/wcielenia/mordrath/mordrath_cast-pulse_side.png")
const TEX_PULSE_BACK_DIAGONAL := preload("res://assets/sprites/wcielenia/mordrath/mordrath_cast-pulse_back_diagonal.png")
const TEX_PULSE_BACK := preload("res://assets/sprites/wcielenia/mordrath/mordrath_cast-pulse_back.png")
const TEX_PULL := preload("res://assets/sprites/wcielenia/mordrath/mordrath_pull.png")
const TEX_PULL_FRONT_DIAGONAL := preload("res://assets/sprites/wcielenia/mordrath/mordrath_pull_front_diagonal.png")
const TEX_PULL_SIDE := preload("res://assets/sprites/wcielenia/mordrath/mordrath_pull_side.png")
const TEX_PULL_BACK_DIAGONAL := preload("res://assets/sprites/wcielenia/mordrath/mordrath_pull_back_diagonal.png")
const TEX_PULL_BACK := preload("res://assets/sprites/wcielenia/mordrath/mordrath_pull_back.png")
const TEX_HIT := preload("res://assets/sprites/wcielenia/mordrath/mordrath_hit.png")
const TEX_HIT_FRONT_DIAGONAL := preload("res://assets/sprites/wcielenia/mordrath/mordrath_hit_front_diagonal.png")
const TEX_HIT_SIDE := preload("res://assets/sprites/wcielenia/mordrath/mordrath_hit_side.png")
const TEX_HIT_BACK_DIAGONAL := preload("res://assets/sprites/wcielenia/mordrath/mordrath_hit_back_diagonal.png")
const TEX_HIT_BACK := preload("res://assets/sprites/wcielenia/mordrath/mordrath_hit_back.png")
const TEX_DEATH := preload("res://assets/sprites/wcielenia/mordrath/mordrath_death.png")
const TEX_DEATH_FRONT_DIAGONAL := preload("res://assets/sprites/wcielenia/mordrath/mordrath_death_front_diagonal.png")
const TEX_DEATH_SIDE := preload("res://assets/sprites/wcielenia/mordrath/mordrath_death_side.png")
const TEX_DEATH_BACK_DIAGONAL := preload("res://assets/sprites/wcielenia/mordrath/mordrath_death_back_diagonal.png")
const TEX_DEATH_BACK := preload("res://assets/sprites/wcielenia/mordrath/mordrath_death_back.png")
const TEX_SILENCE_PULSE := preload("res://assets/sprites/wcielenia/mordrath/mordrath_silence-pulse.png")
const TEX_SILENCE_PULSE_FRONT_DIAGONAL := preload("res://assets/sprites/wcielenia/mordrath/mordrath_silence-pulse_front_diagonal.png")
const TEX_SILENCE_PULSE_SIDE := preload("res://assets/sprites/wcielenia/mordrath/mordrath_silence-pulse_side.png")
const TEX_SILENCE_PULSE_BACK_DIAGONAL := preload("res://assets/sprites/wcielenia/mordrath/mordrath_silence-pulse_back_diagonal.png")
const TEX_SILENCE_PULSE_BACK := preload("res://assets/sprites/wcielenia/mordrath/mordrath_silence-pulse_back.png")

func _ready() -> void:
	super._ready()
	current_color = Color("#9B4DFF") # dopasowane do dostarczonej grafiki (fioletowa, nie pomarańczowa)
	hit_material = Palette.HitMaterial.MAGIC
	fragment_name = "Mordrath Bez-Wymiaru" # patrz LORE_I_ASSETY.md
	_skills = [_skill_silence_pulse, _skill_muffling_pull, _skill_silent_rush, _pattern_pulse_and_rush]
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
		"silence_pulse": {"front": TEX_SILENCE_PULSE, "front_diagonal": TEX_SILENCE_PULSE_FRONT_DIAGONAL, "side": TEX_SILENCE_PULSE_SIDE, "back_diagonal": TEX_SILENCE_PULSE_BACK_DIAGONAL, "back": TEX_SILENCE_PULSE_BACK},
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

## "Grupa wzorców" (dokument sekcja 11) — pulsuje ciszą, po chwili dobija wypadem.
func _pattern_pulse_and_rush() -> void:
	_skill_silence_pulse()
	await get_tree().create_timer(0.3).timeout
	if not is_dead:
		_skill_silent_rush()
