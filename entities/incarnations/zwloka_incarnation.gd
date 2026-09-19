extends Incarnation
class_name ZwlokaIncarnation
## Wcielenie fazy Zwłoka — czas wokół niej się zacina. Umiejętność: ten sam
## impuls uderza dwa razy z krótkim opóźnieniem, jak spóźnione echo (LORE_I_ASSETY.md 2.3).

@export var pulse_radius: float = 80.0
@export var pulse_damage: float = 10.0
@export var echo_delay: float = 0.35 ## s, opóźnienie drugiego echa — motyw "zwłoki"

func _ready() -> void:
	super._ready()
	current_color = Color("#C44FD6")
	fragment_name = "Zwłoka"

func _perform_signature_skill() -> void:
	_damage_pulse(pulse_radius, pulse_damage)
	await get_tree().create_timer(echo_delay).timeout
	if not is_dead:
		_damage_pulse(pulse_radius, pulse_damage)
