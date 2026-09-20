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
const TEX_TELEGRAPH := preload("res://assets/sprites/wcielenia/zha_ruun/zha-ruun_telegraph.png")
const TEX_LUNGE := preload("res://assets/sprites/wcielenia/zha_ruun/zha-ruun_lunge.png")
const TEX_PULSE := preload("res://assets/sprites/wcielenia/zha_ruun/zha-ruun_cast-pulse.png")
const TEX_PULL := preload("res://assets/sprites/wcielenia/zha_ruun/zha-ruun_pull.png")
const TEX_HIT := preload("res://assets/sprites/wcielenia/zha_ruun/zha-ruun_hit.png")
const TEX_DEATH := preload("res://assets/sprites/wcielenia/zha_ruun/zha-ruun_death.png")
const TEX_ECHO_PULSE := preload("res://assets/sprites/wcielenia/zha_ruun/zha-ruun_echo-pulse.png")

func _ready() -> void:
	super._ready()
	current_color = Color("#C44FD6")
	fragment_name = "Zha’Ruun, Pożeracz Granic" # patrz LORE_I_ASSETY.md
	_skills = [_skill_echo_pulse, _skill_stutter_lunge, _skill_rewind_pull]
	_sprite_textures = {
		"walk": TEX_WALK, "telegraph": TEX_TELEGRAPH, "lunge": TEX_LUNGE,
		"pulse": TEX_PULSE, "pull": TEX_PULL, "hit": TEX_HIT, "death": TEX_DEATH,
		"echo_pulse": TEX_ECHO_PULSE,
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
