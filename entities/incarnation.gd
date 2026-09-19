extends Node2D
class_name Incarnation
## Wspólny szkielet dla sześciu wcieleń hybrydy — rozszerzenie poza dokument
## bazowy, patrz LORE_I_ASSETY.md. Każde wcielenie to mała podklasa, która
## nadpisuje TYLKO _perform_signature_skill() (i ustawia current_color/fragment_name
## w swoim _ready()) — reszta (zdrowie, dryfowanie, kontakt, telegraf, umieranie)
## jest wspólna, żeby nie kopiować tego sześć razy.
## Rysowane na razie kołem w current_color — do podmiany na sprite'y później.

signal died(fragment_name: String)

@export var max_health: float = 160.0
@export var radius: float = 36.0
@export var drift_speed: float = 90.0
@export var contact_damage: float = 8.0
@export var contact_knockback: float = 300.0 ## px/s, odepchnięcie gracza przy dotyku
@export var attack_interval: float = 2.2 ## s, odstęp między użyciami umiejętności
@export var telegraph_duration: float = 0.5 ## s, wspólna zapowiedź przed umiejętnością
@export var knockback_friction: float = 2000.0 ## px/s^2, jak szybko wytraca się odepchnięcie od bloku gracza

var current_color: Color = Color.WHITE ## ustawiane przez podklasę
var fragment_name: String = "" ## ustawiane przez podklasę — nazwa fragmentu duszy

var health: float
var is_dead: bool = false
var player: Player = null
var arena_rect: Rect2 ## ustawiane z zewnątrz przez room.gd po zespawnowaniu

## Pula umiejętności — każda podklasa wypełnia to w swoim _ready() (po super._ready())
## co najmniej trzema Callable. Losowane bez powtórzenia tej samej dwa razy pod rząd,
## tak samo jak ataki Nemoraxa w boss.gd.
var _skills: Array[Callable] = []
var _last_skill_index: int = -1

var _attack_timer: float = 0.0
var _telegraph_active: bool = false
var _flash_frames: int = 0

# Wspólne "surowce" do budowania umiejętności sygnaturalnych w podklasach.
var _lunge_active: bool = false
var _lunge_timer: float = 0.0
var _lunge_direction: Vector2 = Vector2.ZERO
var _lunge_speed: float = 0.0

var _knockback_velocity: Vector2 = Vector2.ZERO ## ustawiane z zewnątrz przez blok gracza (PPM)

func _ready() -> void:
	health = max_health
	add_to_group("hittable") # dzięki temu miecz/różdżka gracza trafiają bez zmian w player.gd
	player = get_tree().get_first_node_in_group("player") as Player
	_attack_timer = attack_interval

func _physics_process(delta: float) -> void:
	if is_dead or player == null:
		return

	_check_contact()

	if _knockback_velocity.length() > 1.0:
		# Odepchnięcie od bloku gracza chwilowo zastępuje dryfowanie/wypad —
		# ta sama logika co u Nemoraxa w boss.gd.
		global_position = _clamp_to_arena(global_position + _knockback_velocity * delta)
		_knockback_velocity = _knockback_velocity.move_toward(Vector2.ZERO, knockback_friction * delta)
	elif _lunge_active:
		_process_lunge(delta)
	else:
		_drift_towards_player(delta)
		_attack_timer -= delta
		if _attack_timer <= 0.0:
			_attack_timer = attack_interval
			_start_telegraph()

	if _flash_frames > 0:
		_flash_frames -= 1
	queue_redraw()

## Wywoływane z zewnątrz (blok gracza pod PPM) — odpycha wcielenie na chwilę.
func apply_knockback(impulse: Vector2) -> void:
	_knockback_velocity = impulse

func _drift_towards_player(delta: float) -> void:
	var to_player: Vector2 = player.global_position - global_position
	if to_player.length() > 1.0:
		global_position += to_player.normalized() * drift_speed * delta

## Dotyk ciała zawsze rani (ta sama konwencja co Nemorax) — throttlowane przez
## nietykalność gracza po trafieniu.
func _check_contact() -> void:
	if player.is_invulnerable():
		return
	if global_position.distance_to(player.global_position) > radius + player.radius:
		return
	player.take_damage(contact_damage)
	var dir: Vector2 = player.global_position - global_position
	player.apply_knockback((dir.normalized() if dir.length() > 0.01 else Vector2.RIGHT) * contact_knockback)

func _start_telegraph() -> void:
	_telegraph_active = true
	await get_tree().create_timer(telegraph_duration).timeout
	_telegraph_active = false
	if not is_dead:
		_perform_random_skill()

## Losuje jedną z umiejętności podklasy (bez powtórzenia poprzedniej) i ją wywołuje.
func _perform_random_skill() -> void:
	if _skills.is_empty():
		return
	var index := randi() % _skills.size()
	if _skills.size() > 1:
		while index == _last_skill_index:
			index = randi() % _skills.size()
	_last_skill_index = index
	_skills[index].call()

# --- Wspólne prymitywy, z których podklasy budują swoje umiejętności ---

## Zwraca true, jeśli gracz był w zasięgu i faktycznie oberwał (przydatne np.
## do leczenia się kosztem trafienia, patrz GlodIncarnation).
func _damage_pulse(pulse_radius: float, damage: float) -> bool:
	if player.is_invulnerable():
		return false
	if global_position.distance_to(player.global_position) > pulse_radius:
		return false
	player.take_damage(damage)
	return true

func _pull_player(strength: float) -> void:
	var dir: Vector2 = global_position - player.global_position
	if dir.length() > 1.0:
		player.apply_knockback(dir.normalized() * strength)

func _lunge_toward_player(speed: float, duration: float) -> void:
	_lunge_active = true
	_lunge_timer = duration
	_lunge_speed = speed
	var dir: Vector2 = player.global_position - global_position
	_lunge_direction = dir.normalized() if dir.length() > 0.01 else Vector2.RIGHT

func _process_lunge(delta: float) -> void:
	_lunge_timer -= delta
	global_position = _clamp_to_arena(global_position + _lunge_direction * _lunge_speed * delta)
	if _lunge_timer <= 0.0:
		_lunge_active = false

func _clamp_to_arena(pos: Vector2) -> Vector2:
	var r := arena_rect
	return Vector2(
		clamp(pos.x, r.position.x + radius, r.position.x + r.size.x - radius),
		clamp(pos.y, r.position.y + radius, r.position.y + r.size.y - radius)
	)

func take_damage(amount: float) -> void:
	if is_dead:
		return
	health -= amount
	if health <= 0.0:
		health = 0.0
		is_dead = true
		died.emit(fragment_name)

func flash_white() -> void:
	_flash_frames = 2

func _draw() -> void:
	var color := Palette.HIT_FLASH if _flash_frames > 0 else current_color
	draw_circle(Vector2.ZERO, radius, color)
	if _telegraph_active:
		draw_arc(Vector2.ZERO, radius + 6.0, 0.0, TAU, 24, Color(Palette.DANGER, 0.8), 3.0)
