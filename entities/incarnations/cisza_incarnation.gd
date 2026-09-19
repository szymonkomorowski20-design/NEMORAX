extends Incarnation
class_name CiszaIncarnation
## Wcielenie fazy Cisza — pochłania dźwięk. Umiejętność: pojedynczy impuls
## ciszy zadający obrażenia w promieniu (LORE_I_ASSETY.md 2.2).

@export var pulse_radius: float = 90.0
@export var pulse_damage: float = 14.0

func _ready() -> void:
	super._ready()
	current_color = Color("#FF8A3D")
	fragment_name = "Cisza"

func _perform_signature_skill() -> void:
	_damage_pulse(pulse_radius, pulse_damage)
