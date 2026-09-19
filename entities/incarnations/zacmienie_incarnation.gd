extends Incarnation
class_name ZacmienieIncarnation
## Wcielenie fazy Zaćmienie — pochłania światło. Umiejętność: znika (niewidzialna
## i nietykalna), po chwili pojawia się tuż przy graczu i uderza (LORE_I_ASSETY.md 2.6).

@export var vanish_duration: float = 0.4
@export var reappear_range: float = 150.0
@export var strike_speed: float = 400.0
@export var strike_duration: float = 0.3

var _intangible: bool = false

func _ready() -> void:
	super._ready()
	current_color = Color("#C9C2B4")
	fragment_name = "Zaćmienie"

func _perform_signature_skill() -> void:
	_intangible = true
	visible = false
	await get_tree().create_timer(vanish_duration).timeout
	if is_dead:
		return
	var offset := Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)).normalized() * reappear_range
	global_position = _clamp_to_arena(player.global_position + offset)
	visible = true
	_intangible = false
	_lunge_toward_player(strike_speed, strike_duration)

func _check_contact() -> void:
	if _intangible:
		return
	super._check_contact()

func take_damage(amount: float) -> void:
	if _intangible:
		return
	super.take_damage(amount)
