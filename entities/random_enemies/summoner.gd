extends Incarnation
class_name Summoner
## Archetyp 9/12: Summoner (dokument sekcja 6.1) — przywołuje słabsze dodatki
## (reużyty Chaser, apply_difficulty_scale() w dół zamiast nowej klasy
## "fragile minion" — dokument: "reuse before rebuild"). Dodatki są dziećmi
## POKOJU (get_parent()), nie tego wroga, i ich `died` NIE jest podpięte pod
## room.gd._on_incarnation_died — dokument: "summoned units default to 0 XP",
## co osiąga się tu za darmo (nikt nie słucha ich sygnału, więc śmierć dodatku
## nie liczy się do wyczyszczenia pokoju ani nie daje XP). Grafika: TYMCZASOWO Zha'Ruun.

const TEX_WALK := preload("res://assets/sprites/wcielenia/zha_ruun/zha-ruun_walk.png")
const TEX_WALK_BACK := preload("res://assets/sprites/wcielenia/zha_ruun/zha-ruun_walk_back.png")
const TEX_WALK_SIDE := preload("res://assets/sprites/wcielenia/zha_ruun/zha-ruun_walk_side.png")
const TEX_TELEGRAPH := preload("res://assets/sprites/wcielenia/zha_ruun/zha-ruun_telegraph.png")
const TEX_PULSE := preload("res://assets/sprites/wcielenia/zha_ruun/zha-ruun_cast-pulse.png")
const TEX_HIT := preload("res://assets/sprites/wcielenia/zha_ruun/zha-ruun_hit.png")
const TEX_DEATH := preload("res://assets/sprites/wcielenia/zha_ruun/zha-ruun_death.png")

const ChaserScene := preload("res://entities/random_enemies/chaser.tscn")

@export var summon_count: int = 2
@export var summon_strength_fraction: float = 0.5 ## dokument: "fragile minions"

func _ready() -> void:
	max_health = 58.0
	drift_speed = 75.0
	contact_damage = 6.0
	attack_interval = 5.5 ## dokument: "summon CD 5.5"
	telegraph_duration = 1.20 ## dokument: "channel"
	knockback_resistance = 0.20
	keep_distance_range = 250.0 ## dokument: "retreats from player, seeks 200-300 range"
	super._ready()
	current_color = Color("#B23A6B")
	fragment_name = "Summoner"
	_skills = [_skill_summon]
	_sprite_textures = {
		"walk": {"front": TEX_WALK, "back": TEX_WALK_BACK, "side": TEX_WALK_SIDE},
		"telegraph": TEX_TELEGRAPH, "pulse": TEX_PULSE, "hit": TEX_HIT, "death": TEX_DEATH,
	}

func _skill_summon() -> void:
	_set_skill_pose("pulse")
	for i in range(summon_count):
		var add: Incarnation = ChaserScene.instantiate()
		var offset := Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)).normalized() * 60.0
		get_parent().add_child(add)
		add.arena_rect = arena_rect
		add.global_position = _clamp_to_arena(global_position + offset)
		add.apply_difficulty_scale(summon_strength_fraction)
