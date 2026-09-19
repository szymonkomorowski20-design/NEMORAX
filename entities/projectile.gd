extends Node2D
## Pocisk różdżki (broń 2 gracza — dodatek na życzenie autora, poza dokumentem).
## Leci po prostej, znika po trafieniu, po czasie życia albo poza areną.

@export var radius: float = 6.0
@export var speed: float = 600.0
@export var lifetime: float = 1.0
@export var damage: float = 8.0

var direction: Vector2 = Vector2.RIGHT
var shooter: Player = null ## żeby oddać manę strzelcowi za trafienie
var _life_timer: float = 0.0

func _physics_process(delta: float) -> void:
	_life_timer += delta
	if _life_timer >= lifetime:
		queue_free()
		return
	global_position += direction * speed * delta
	_check_hit()
	queue_redraw()

func _check_hit() -> void:
	for target in get_tree().get_nodes_in_group("hittable"):
		var target_radius: float = target.get("radius") if target.get("radius") != null else 0.0
		if global_position.distance_to(target.global_position) > radius + target_radius:
			continue
		if target.has_method("take_damage"):
			target.take_damage(damage)
		if target.has_method("flash_white"):
			target.flash_white()
		if shooter != null:
			shooter.register_hit_on_enemy()
		Juice.hitstop(Juice.boss_hit_hitstop)
		Juice.screen_shake()
		queue_free()
		return

func _draw() -> void:
	# Żółty, bo zadaje obrażenia (sekcja 2, punkt 2) — niezależnie od tego, że
	# to atak gracza, nie bossa; reguła koloru jest uniwersalna.
	draw_circle(Vector2.ZERO, radius, Palette.DANGER)
