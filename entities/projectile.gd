extends Node2D
## Pocisk różdżki (broń 2 gracza — dodatek na życzenie autora, poza dokumentem).
## Leci po prostej, znika po trafieniu, po czasie życia albo poza areną.

const TEX_PROJECTILE := preload("res://assets/sprites/ekwipunek/player_wand_projectile.png")
const SND_IMPACT := preload("res://assets/audio/sfx/gracz/P12_wand_impact.wav")

@export var radius: float = 6.0
@export var speed: float = 600.0
@export var lifetime: float = 1.0
@export var damage: float = 8.0
@export var sprite_scale: float = 0.03

var direction: Vector2 = Vector2.RIGHT
var shooter: Player = null ## żeby oddać manę strzelcowi za trafienie
var secondary: bool = false
var pierce_remaining: int = 0
var volley_id: int = 0
var volley_base_damage: float = 0.0
var attack_id: int = -1
var use_split_cap: bool = true
var homing_turn_rate: float = 0.0
var ricochet_remaining: int = 0
var ricochet_original_damage: float = 0.0
var texture_override: Texture2D
var _hit_target_ids: Dictionary = {}
var _life_timer: float = 0.0

@onready var sprite: Sprite2D = $Sprite

func _ready() -> void:
	sprite.texture = texture_override if texture_override != null else TEX_PROJECTILE
	sprite.scale = Vector2(sprite_scale, sprite_scale)
	sprite.rotation = direction.angle()

func _physics_process(delta: float) -> void:
	_life_timer += delta
	if _life_timer >= lifetime:
		queue_free()
		return
	if homing_turn_rate > 0.0:
		var best: Node2D = null
		var best_distance := 260.0 * 260.0
		for target in get_tree().get_nodes_in_group("hittable"):
			if target.get("is_dead") == true or target.get_instance_id() in _hit_target_ids:
				continue
			var distance_value := global_position.distance_squared_to(target.global_position)
			if distance_value < best_distance:
				best = target
				best_distance = distance_value
		if best != null:
			var desired := (best.global_position - global_position).normalized()
			direction = direction.rotated(clampf(direction.angle_to(desired), -homing_turn_rate * delta, homing_turn_rate * delta))
			sprite.rotation = direction.angle()
	global_position += direction * speed * delta
	_check_hit()

func _check_hit() -> void:
	for target in get_tree().get_nodes_in_group("hittable"):
		if target.get_instance_id() in _hit_target_ids or target.get("is_dead") == true:
			continue
		var target_radius: float = target.get("radius") if target.get("radius") != null else 0.0
		if global_position.distance_to(target.global_position) > radius + target_radius:
			continue
		_hit_target_ids[target.get_instance_id()] = true
		var has_shooter := is_instance_valid(shooter)
		var final_damage := shooter.resolve_hit_damage(target, damage) if has_shooter and not secondary else damage
		if has_shooter and use_split_cap:
			final_damage = shooter.cap_volley_damage(target, volley_id, final_damage, volley_base_damage)
		if final_damage > 0.0:
			var health_before: float = target.get("health") if target.get("health") != null else -1.0
			Juice.apply_hit(target, final_damage)
			if has_shooter and not secondary:
				shooter.on_hit_confirmed(target, final_damage, "wand", health_before, attack_id)
		Juice.play_sfx_at(SND_IMPACT, global_position)
		if pierce_remaining > 0:
			pierce_remaining -= 1
			damage *= 0.70
		else:
			if ricochet_remaining > 0 and has_shooter:
				_spawn_ricochet()
			queue_free()
		return

func _spawn_ricochet() -> void:
	var best: Node2D = null
	var best_distance := 180.0 * 180.0
	for target in get_tree().get_nodes_in_group("hittable"):
		if target.get("is_dead") == true or target.get_instance_id() in _hit_target_ids:
			continue
		var distance_value := global_position.distance_squared_to(target.global_position)
		if distance_value < best_distance:
			best = target
			best_distance = distance_value
	if best == null:
		return
	var bolt = preload("res://entities/projectile.tscn").instantiate()
	bolt.secondary = true
	bolt.use_split_cap = false
	bolt.direction = (best.global_position - global_position).normalized()
	bolt.ricochet_original_damage = ricochet_original_damage if ricochet_original_damage > 0.0 else damage
	bolt.damage = bolt.ricochet_original_damage * (0.55 if ricochet_remaining == shooter.skill_rank("wand_ricochet") else 0.40)
	bolt.speed = speed
	bolt.lifetime = minf(0.45, lifetime)
	bolt.shooter = shooter
	bolt.ricochet_remaining = ricochet_remaining - 1
	bolt._hit_target_ids = _hit_target_ids.duplicate()
	bolt.global_position = global_position
	get_parent().add_child(bolt)
