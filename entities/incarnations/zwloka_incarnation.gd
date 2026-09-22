extends Incarnation
class_name ZwlokaIncarnation
## Wcielenie fazy Zwłoka — czas wokół niej się zacina (LORE_I_ASSETY.md 2.3). Trzy
## umiejętności: spóźnione echo (podwójny impuls), zacinający się wypad (dwa wypady
## z przerwą), szarpnięcie w tył czasu (przyciągnięcie bez ciosu).

@export var pulse_radius: float = 80.0
@export var pulse_damage: float = 10.0
@export var echo_delay: float = 0.35 ## s, opóźnienie drugiego echa — motyw "zwłoki"
@export var stutter_speed: float = 380.0
@export var stutter_duration: float = 0.22
@export var stutter_gap: float = 0.25 ## s "zacięcia" między dwoma wypadami
@export var rewind_pull_strength: float = 450.0

const TEX_WALK := preload("res://assets/sprites/wcielenia/zha_ruun/zha-ruun_walk.png")
const TEX_WALK_FRONT_STRIDE := preload("res://assets/sprites/wcielenia/zha_ruun/zha-ruun_walk_front_stride.png")
const TEX_WALK_FRONT_DIAGONAL := preload("res://assets/sprites/wcielenia/zha_ruun/zha-ruun_walk_front_diagonal.png")
const TEX_WALK_FRONT_DIAGONAL_STRIDE := preload("res://assets/sprites/wcielenia/zha_ruun/zha-ruun_walk_front_diagonal_stride.png")
const TEX_WALK_SIDE := preload("res://assets/sprites/wcielenia/zha_ruun/zha-ruun_walk_side.png")
const TEX_WALK_SIDE_STRIDE := preload("res://assets/sprites/wcielenia/zha_ruun/zha-ruun_walk_side_stride.png")
const TEX_WALK_BACK_DIAGONAL := preload("res://assets/sprites/wcielenia/zha_ruun/zha-ruun_walk_back_diagonal.png")
const TEX_WALK_BACK_DIAGONAL_STRIDE := preload("res://assets/sprites/wcielenia/zha_ruun/zha-ruun_walk_back_diagonal_stride.png")
const TEX_WALK_BACK := preload("res://assets/sprites/wcielenia/zha_ruun/zha-ruun_walk_back.png")
const TEX_WALK_BACK_STRIDE := preload("res://assets/sprites/wcielenia/zha_ruun/zha-ruun_walk_back_stride.png")
const TEX_TELEGRAPH := preload("res://assets/sprites/wcielenia/zha_ruun/zha-ruun_telegraph.png")
const TEX_TELEGRAPH_FRONT_DIAGONAL := preload("res://assets/sprites/wcielenia/zha_ruun/zha-ruun_telegraph_front_diagonal.png")
const TEX_TELEGRAPH_SIDE := preload("res://assets/sprites/wcielenia/zha_ruun/zha-ruun_telegraph_side.png")
const TEX_TELEGRAPH_BACK_DIAGONAL := preload("res://assets/sprites/wcielenia/zha_ruun/zha-ruun_telegraph_back_diagonal.png")
const TEX_TELEGRAPH_BACK := preload("res://assets/sprites/wcielenia/zha_ruun/zha-ruun_telegraph_back.png")
const TEX_LUNGE := preload("res://assets/sprites/wcielenia/zha_ruun/zha-ruun_lunge.png")
const TEX_LUNGE_FRONT_DIAGONAL := preload("res://assets/sprites/wcielenia/zha_ruun/zha-ruun_lunge_front_diagonal.png")
const TEX_LUNGE_SIDE := preload("res://assets/sprites/wcielenia/zha_ruun/zha-ruun_lunge_side.png")
const TEX_LUNGE_BACK_DIAGONAL := preload("res://assets/sprites/wcielenia/zha_ruun/zha-ruun_lunge_back_diagonal.png")
const TEX_LUNGE_BACK := preload("res://assets/sprites/wcielenia/zha_ruun/zha-ruun_lunge_back.png")
const TEX_PULSE := preload("res://assets/sprites/wcielenia/zha_ruun/zha-ruun_cast-pulse.png")
const TEX_PULSE_FRONT_DIAGONAL := preload("res://assets/sprites/wcielenia/zha_ruun/zha-ruun_cast-pulse_front_diagonal.png")
const TEX_PULSE_SIDE := preload("res://assets/sprites/wcielenia/zha_ruun/zha-ruun_cast-pulse_side.png")
const TEX_PULSE_BACK_DIAGONAL := preload("res://assets/sprites/wcielenia/zha_ruun/zha-ruun_cast-pulse_back_diagonal.png")
const TEX_PULSE_BACK := preload("res://assets/sprites/wcielenia/zha_ruun/zha-ruun_cast-pulse_back.png")
const TEX_PULL := preload("res://assets/sprites/wcielenia/zha_ruun/zha-ruun_pull.png")
const TEX_PULL_FRONT_DIAGONAL := preload("res://assets/sprites/wcielenia/zha_ruun/zha-ruun_pull_front_diagonal.png")
const TEX_PULL_SIDE := preload("res://assets/sprites/wcielenia/zha_ruun/zha-ruun_pull_side.png")
const TEX_PULL_BACK_DIAGONAL := preload("res://assets/sprites/wcielenia/zha_ruun/zha-ruun_pull_back_diagonal.png")
const TEX_PULL_BACK := preload("res://assets/sprites/wcielenia/zha_ruun/zha-ruun_pull_back.png")
const TEX_HIT := preload("res://assets/sprites/wcielenia/zha_ruun/zha-ruun_hit.png")
const TEX_HIT_FRONT_DIAGONAL := preload("res://assets/sprites/wcielenia/zha_ruun/zha-ruun_hit_front_diagonal.png")
const TEX_HIT_SIDE := preload("res://assets/sprites/wcielenia/zha_ruun/zha-ruun_hit_side.png")
const TEX_HIT_BACK_DIAGONAL := preload("res://assets/sprites/wcielenia/zha_ruun/zha-ruun_hit_back_diagonal.png")
const TEX_HIT_BACK := preload("res://assets/sprites/wcielenia/zha_ruun/zha-ruun_hit_back.png")
const TEX_DEATH := preload("res://assets/sprites/wcielenia/zha_ruun/zha-ruun_death.png")
const TEX_DEATH_FRONT_DIAGONAL := preload("res://assets/sprites/wcielenia/zha_ruun/zha-ruun_death_front_diagonal.png")
const TEX_DEATH_SIDE := preload("res://assets/sprites/wcielenia/zha_ruun/zha-ruun_death_side.png")
const TEX_DEATH_BACK_DIAGONAL := preload("res://assets/sprites/wcielenia/zha_ruun/zha-ruun_death_back_diagonal.png")
const TEX_DEATH_BACK := preload("res://assets/sprites/wcielenia/zha_ruun/zha-ruun_death_back.png")
const TEX_ECHO_PULSE := preload("res://assets/sprites/wcielenia/zha_ruun/zha-ruun_echo-pulse.png")
const TEX_ECHO_PULSE_FRONT_DIAGONAL := preload("res://assets/sprites/wcielenia/zha_ruun/zha-ruun_echo-pulse_front_diagonal.png")
const TEX_ECHO_PULSE_SIDE := preload("res://assets/sprites/wcielenia/zha_ruun/zha-ruun_echo-pulse_side.png")
const TEX_ECHO_PULSE_BACK_DIAGONAL := preload("res://assets/sprites/wcielenia/zha_ruun/zha-ruun_echo-pulse_back_diagonal.png")
const TEX_ECHO_PULSE_BACK := preload("res://assets/sprites/wcielenia/zha_ruun/zha-ruun_echo-pulse_back.png")

func _ready() -> void:
	super._ready()
	current_color = Color("#C44FD6")
	hit_material = Palette.HitMaterial.MAGIC
	fragment_name = "Zha’Ruun, Pożeracz Granic" # patrz LORE_I_ASSETY.md
	_skills = [_skill_echo_pulse, _skill_stutter_lunge, _skill_rewind_pull, _pattern_pull_and_stutter]
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
		"echo_pulse": {"front": TEX_ECHO_PULSE, "front_diagonal": TEX_ECHO_PULSE_FRONT_DIAGONAL, "side": TEX_ECHO_PULSE_SIDE, "back_diagonal": TEX_ECHO_PULSE_BACK_DIAGONAL, "back": TEX_ECHO_PULSE_BACK},
	}

func _skill_echo_pulse() -> void:
	_damage_pulse(pulse_radius, pulse_damage)
	_set_skill_pose("echo_pulse")
	await get_tree().create_timer(echo_delay).timeout
	if not is_dead:
		_damage_pulse(pulse_radius, pulse_damage)
		_set_skill_pose("echo_pulse")

func _skill_stutter_lunge() -> void:
	_lunge_toward_player(stutter_speed, stutter_duration)
	await get_tree().create_timer(stutter_duration + stutter_gap).timeout
	if not is_dead:
		_lunge_toward_player(stutter_speed, stutter_duration)

func _skill_rewind_pull() -> void:
	_pull_player(rewind_pull_strength)

## "Grupa wzorców" (dokument sekcja 11) — wciąga, potem dobija urywanym wypadem.
func _pattern_pull_and_stutter() -> void:
	_skill_rewind_pull()
	await get_tree().create_timer(0.25).timeout
	if not is_dead:
		_skill_stutter_lunge()
