extends Incarnation
class_name ZalazekIncarnation
## Wcielenie fazy "bez formy" — chaotyczny, niedokończony kształt. Umiejętność:
## nieprzewidywalny teleport blisko gracza i natychmiastowy wypad (LORE_I_ASSETY.md 2.1).
## Zapowiedź (z klasy bazowej) pojawia się w STARYM miejscu — sam teleport jest
## celowo zaskakujący, bo "brak formy" oznacza brak przewidywalnego wzorca.

@export var teleport_range: float = 220.0 ## px, jak blisko gracza się teleportuje
@export var lunge_speed: float = 420.0
@export var lunge_duration: float = 0.3

func _ready() -> void:
	super._ready()
	current_color = Color("#F0447A")
	fragment_name = "Zalążek"

func _perform_signature_skill() -> void:
	var offset := Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)).normalized() * teleport_range
	global_position = _clamp_to_arena(player.global_position + offset)
	_lunge_toward_player(lunge_speed, lunge_duration)
