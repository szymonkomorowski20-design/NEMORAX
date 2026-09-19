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

func _ready() -> void:
	super._ready()
	current_color = Color("#C44FD6")
	fragment_name = "Rozkładnik" # nazwa własna (dawniej "Zwłoka", patrz LORE_I_ASSETY.md)
	_skills = [_skill_echo_pulse, _skill_stutter_lunge, _skill_rewind_pull]

func _skill_echo_pulse() -> void:
	_damage_pulse(pulse_radius, pulse_damage)
	await get_tree().create_timer(echo_delay).timeout
	if not is_dead:
		_damage_pulse(pulse_radius, pulse_damage)

func _skill_stutter_lunge() -> void:
	_lunge_toward_player(stutter_speed, stutter_duration)
	await get_tree().create_timer(stutter_duration + stutter_gap).timeout
	if not is_dead:
		_lunge_toward_player(stutter_speed, stutter_duration)

func _skill_rewind_pull() -> void:
	_pull_player(rewind_pull_strength)
