extends Incarnation
class_name CiezarIncarnation
## Wcielenie fazy Ciężar — zakrzywia przestrzeń wokół siebie. Umiejętność:
## gwałtowny impuls przyciągający gracza bliżej, po chwili domykany uderzeniem
## w zasięgu (LORE_I_ASSETY.md 2.4).

@export var pull_strength: float = 500.0
@export var followup_delay: float = 0.2
@export var followup_radius: float = 70.0
@export var followup_damage: float = 16.0

func _ready() -> void:
	super._ready()
	current_color = Color("#6C63FF")
	fragment_name = "Ciężar"

func _perform_signature_skill() -> void:
	_pull_player(pull_strength)
	await get_tree().create_timer(followup_delay).timeout
	if not is_dead:
		_damage_pulse(followup_radius, followup_damage)
