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

func _ready() -> void:
	super._ready()
	current_color = Color("#6C63FF")
	fragment_name = "Nekravor, Ten Którego Odrzucono" # patrz LORE_I_ASSETY.md
	_skills = [_skill_gravity_pull, _skill_crush_pulse, _skill_gravity_lunge]

func _skill_gravity_pull() -> void:
	_pull_player(pull_strength)
	await get_tree().create_timer(followup_delay).timeout
	if not is_dead:
		_damage_pulse(followup_radius, followup_damage)

func _skill_crush_pulse() -> void:
	_damage_pulse(crush_radius, crush_damage)

func _skill_gravity_lunge() -> void:
	_pull_player(pull_strength * 0.6)
	_lunge_toward_player(lunge_speed, lunge_duration)
