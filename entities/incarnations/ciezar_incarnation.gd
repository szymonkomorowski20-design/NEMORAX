extends Incarnation
class_name CiezarIncarnation
## Wcielenie fazy Ciężar — zakrzywia przestrzeń wokół siebie (LORE_I_ASSETY.md 2.4).
## Trzy umiejętności: przyciągnięcie + cios, sam druzgocący wybuch (większy zasięg,
## bez przyciągania), przyciągnięcie i natychmiastowy wypad (podwójne dociążenie).

@export var pull_strength: float = 500.0
@export var followup_delay: float = 0.2
@export var followup_radius: float = 70.0
@export var followup_damage: float = 16.0
@export var crush_radius: float = 110.0
@export var crush_damage: float = 20.0
@export var lunge_speed: float = 360.0
@export var lunge_duration: float = 0.3

const TEX_WALK := preload("res://assets/sprites/wcielenia/nekravor/nekravor_walk.png")
const TEX_WALK_FRONT_STRIDE := preload("res://assets/sprites/wcielenia/nekravor/nekravor_walk_front_stride.png")
const TEX_WALK_FRONT_DIAGONAL := preload("res://assets/sprites/wcielenia/nekravor/nekravor_walk_front_diagonal.png")
const TEX_WALK_FRONT_DIAGONAL_STRIDE := preload("res://assets/sprites/wcielenia/nekravor/nekravor_walk_front_diagonal_stride.png")
const TEX_WALK_SIDE := preload("res://assets/sprites/wcielenia/nekravor/nekravor_walk_side.png")
const TEX_WALK_SIDE_STRIDE := preload("res://assets/sprites/wcielenia/nekravor/nekravor_walk_side_stride.png")
const TEX_WALK_BACK_DIAGONAL := preload("res://assets/sprites/wcielenia/nekravor/nekravor_walk_back_diagonal.png")
const TEX_WALK_BACK_DIAGONAL_STRIDE := preload("res://assets/sprites/wcielenia/nekravor/nekravor_walk_back_diagonal_stride.png")
const TEX_WALK_BACK := preload("res://assets/sprites/wcielenia/nekravor/nekravor_walk_back.png")
const TEX_WALK_BACK_STRIDE := preload("res://assets/sprites/wcielenia/nekravor/nekravor_walk_back_stride.png")
const TEX_TELEGRAPH := preload("res://assets/sprites/wcielenia/nekravor/nekravor_telegraph.png")
const TEX_LUNGE := preload("res://assets/sprites/wcielenia/nekravor/nekravor_lunge.png")
const TEX_PULSE := preload("res://assets/sprites/wcielenia/nekravor/nekravor_cast-pulse.png")
const TEX_PULL := preload("res://assets/sprites/wcielenia/nekravor/nekravor_pull.png")
const TEX_HIT := preload("res://assets/sprites/wcielenia/nekravor/nekravor_hit.png")
const TEX_DEATH := preload("res://assets/sprites/wcielenia/nekravor/nekravor_death.png")
const TEX_CRUSH := preload("res://assets/sprites/wcielenia/nekravor/nekravor_crush.png")

func _ready() -> void:
	super._ready()
	current_color = Color("#6C63FF")
	fragment_name = "Nekravor, Ten Którego Odrzucono" # patrz LORE_I_ASSETY.md
	_skills = [_skill_gravity_pull, _skill_crush_pulse, _skill_gravity_lunge, _pattern_lunge_and_crush]
	_sprite_textures = {
		"walk": {
			"front": [TEX_WALK, TEX_WALK_FRONT_STRIDE],
			"front_diagonal": [TEX_WALK_FRONT_DIAGONAL, TEX_WALK_FRONT_DIAGONAL_STRIDE],
			"side": [TEX_WALK_SIDE, TEX_WALK_SIDE_STRIDE],
			"back_diagonal": [TEX_WALK_BACK_DIAGONAL, TEX_WALK_BACK_DIAGONAL_STRIDE],
			"back": [TEX_WALK_BACK, TEX_WALK_BACK_STRIDE],
		},
		"telegraph": TEX_TELEGRAPH, "lunge": TEX_LUNGE,
		"pulse": TEX_PULSE, "pull": TEX_PULL, "hit": TEX_HIT, "death": TEX_DEATH,
		"crush": TEX_CRUSH,
	}

func _skill_gravity_pull() -> void:
	_pull_player(pull_strength)
	await get_tree().create_timer(followup_delay).timeout
	if not is_dead:
		_damage_pulse(followup_radius, followup_damage)

func _skill_crush_pulse() -> void:
	_damage_pulse(crush_radius, crush_damage)
	_set_skill_pose("crush")

func _skill_gravity_lunge() -> void:
	_pull_player(pull_strength * 0.6)
	_lunge_toward_player(lunge_speed, lunge_duration)

## "Grupa wzorców" (dokument sekcja 11) — wciąga wypadem, po chwili miażdży.
func _pattern_lunge_and_crush() -> void:
	_skill_gravity_lunge()
	await get_tree().create_timer(lunge_duration + 0.2).timeout
	if not is_dead:
		_skill_crush_pulse()
