extends Node2D
class_name EnemyProjectile
## Prosty pocisk wroga losowego — Shooter (CLAUDE_CODE_GAME_CONTENT_BIBLE.md
## sekcja 6). Prościej niż entities/projectile.gd (pocisk gracza): brak haków
## do ulepszeń (tylko gracz je ma, patrz player.gd sekcja 8), leci po prostej
## i rani WYŁĄCZNIE gracza — nie skanuje grupy "hittable", bo to grupa CELÓW
## gracza, nie zagrożeń DLA gracza.

const TEX_PROJECTILE := preload("res://assets/sprites/enemy_vfx/shooter_attack.png") # dedykowany pocisk Shootera, zastępuje reużyty pocisk gracza (KIERUNEK_WIZUALNY_REFERENCJE.md: "nie używaj efektów gracza jako zastępstwa dla efektów wroga")
const SND_IMPACT := preload("res://assets/audio/sfx/wcielenia/I05_contact_hit.wav")

@export var speed: float = 260.0
@export var lifetime: float = 2.5
@export var damage: float = 9.0
@export var radius: float = 8.0
@export var sprite_scale: float = 0.12

var direction: Vector2 = Vector2.RIGHT
var _life_timer: float = 0.0
var _reflected: bool = false
const REFLECT_DAMAGE_MULTIPLIER := 2.0 ## odbity pocisk: obrażenia wobec wrogów

@onready var sprite: Sprite2D = $Sprite

func _ready() -> void:
	sprite.texture = TEX_PROJECTILE
	sprite.scale = Vector2(sprite_scale, sprite_scale)
	sprite.rotation = direction.angle()

func _physics_process(delta: float) -> void:
	_life_timer += delta
	if _life_timer >= lifetime:
		queue_free()
		return
	global_position += direction * speed * delta
	var terrain := get_tree().get_first_node_in_group("room_terrain")
	if terrain != null:
		var step: String = terrain.projectile_step(self)
		if step == "blocked":
			Juice.play_sfx_at(SND_IMPACT, global_position)
			queue_free()
			return
		if step == "bounced":
			sprite.rotation = direction.angle()
	if _reflected:
		_check_reflected_hit()
	else:
		_check_hit()

func _check_hit() -> void:
	var player := get_tree().get_first_node_in_group("player") as Player
	if player == null:
		return
	if global_position.distance_to(player.global_position) > radius + player.radius:
		return
	if player.is_invulnerable():
		queue_free()
		return
	# Źródło = skąd leci pocisk (nie jego środek, który już siedzi w graczu).
	player.take_damage(damage, global_position - direction * 100.0, true, self)
	Juice.play_sfx_at(SND_IMPACT, global_position)
	if _reflected:
		return # sparowany — leci z powrotem, patrz on_parried()
	queue_free()

## Parowanie tarczą (decyzja autora 23.09): pocisk zawraca i od teraz rani
## wrogów zamiast gracza — ze świeżym czasem życia.
func on_parried(_by: Node) -> void:
	_reflected = true
	direction = -direction
	_life_timer = 0.0
	sprite.rotation = direction.angle()
	sprite.modulate = Palette.PLAYER_BODY

func _check_reflected_hit() -> void:
	for target in get_tree().get_nodes_in_group("hittable"):
		if target.get("is_dead") == true:
			continue
		var target_radius: float = target.get("radius") if target.get("radius") != null else 0.0
		if global_position.distance_to(target.global_position) <= radius + target_radius:
			Juice.apply_hit(target, damage * REFLECT_DAMAGE_MULTIPLIER, 0.0, true, "parry_reflect")
			Juice.play_sfx_at(SND_IMPACT, global_position)
			queue_free()
			return
