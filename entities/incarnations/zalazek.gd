extends Incarnation
class_name ZalazekIncarnation
## Wcielenie fazy "bez formy" — chaotyczny, niedokończony kształt (LORE_I_ASSETY.md 2.1).
## Trzy umiejętności, losowane bez powtórzeń, wszystkie w duchu "braku wzorca":
## nieprzewidywalny teleport, niestabilny wybuch o losowym zasięgu, podwójny wypad.

@export var teleport_range: float = 220.0 ## px, jak blisko gracza się teleportuje
@export var lunge_speed: float = 420.0
@export var lunge_duration: float = 0.3
@export var unstable_min_radius: float = 50.0
@export var unstable_max_radius: float = 130.0
@export var unstable_damage: float = 12.0
@export var double_blink_gap: float = 0.15 ## s, przerwa między dwoma wypadami

const TEX_WALK := preload("res://assets/sprites/wcielenia/vhar_nokh/vhar-nokh_walk.png")
const TEX_WALK_BACK := preload("res://assets/sprites/wcielenia/vhar_nokh/vhar-nokh_walk_back.png")
const TEX_WALK_SIDE := preload("res://assets/sprites/wcielenia/vhar_nokh/vhar-nokh_walk_side.png")
const TEX_TELEGRAPH := preload("res://assets/sprites/wcielenia/vhar_nokh/vhar-nokh_telegraph.png")
const TEX_LUNGE := preload("res://assets/sprites/wcielenia/vhar_nokh/vhar-nokh_lunge.png")
const TEX_PULSE := preload("res://assets/sprites/wcielenia/vhar_nokh/vhar-nokh_cast-pulse.png")
const TEX_PULL := preload("res://assets/sprites/wcielenia/vhar_nokh/vhar-nokh_pull.png")
const TEX_HIT := preload("res://assets/sprites/wcielenia/vhar_nokh/vhar-nokh_hit.png")
const TEX_DEATH := preload("res://assets/sprites/wcielenia/vhar_nokh/vhar-nokh_death.png")
const TEX_TELEPORT := preload("res://assets/sprites/wcielenia/vhar_nokh/vhar-nokh_teleport.png")

func _ready() -> void:
	super._ready()
	current_color = Color("#F0447A")
	fragment_name = "Vhar’Nokh, Wygnany z Otchłani" # patrz LORE_I_ASSETY.md
	_skills = [_skill_teleport_strike, _skill_unstable_burst, _skill_double_blink]
	_sprite_textures = {
		"walk": {"front": TEX_WALK, "back": TEX_WALK_BACK, "side": TEX_WALK_SIDE},
		"telegraph": TEX_TELEGRAPH, "lunge": TEX_LUNGE,
		"pulse": TEX_PULSE, "pull": TEX_PULL, "hit": TEX_HIT, "death": TEX_DEATH,
		"teleport": TEX_TELEPORT,
	}

func _skill_teleport_strike() -> void:
	_teleport_near_player()
	_lunge_toward_player(lunge_speed, lunge_duration)

func _skill_unstable_burst() -> void:
	_damage_pulse(randf_range(unstable_min_radius, unstable_max_radius), unstable_damage)

func _skill_double_blink() -> void:
	_teleport_near_player()
	_lunge_toward_player(lunge_speed, lunge_duration)
	await get_tree().create_timer(lunge_duration + double_blink_gap).timeout
	if not is_dead:
		_teleport_near_player()
		_lunge_toward_player(lunge_speed, lunge_duration)

func _teleport_near_player() -> void:
	_set_skill_pose("teleport")
	var offset := Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)).normalized() * teleport_range
	global_position = _clamp_to_arena(player.global_position + offset)
