extends Node2D
class_name Incarnation
## Wspólny szkielet dla sześciu wcieleń hybrydy — rozszerzenie poza dokument
## bazowy, patrz LORE_I_ASSETY.md. Każde wcielenie to mała podklasa, która
## nadpisuje TYLKO _perform_signature_skill() (i ustawia current_color/fragment_name
## oraz _sprite_textures w swoim _ready()) — reszta (zdrowie, dryfowanie, kontakt,
## telegraf, umieranie, sprite/dźwięk) jest wspólna, żeby nie kopiować tego sześć razy.
##
## _sprite_textures to słownik wypełniany przez podklasę: klucze "walk", "telegraph",
## "pulse", "pull", "lunge", "hit", "death" (uniwersalne, patrz POZY_ANIMACJI.md) plus
## dowolne dodatkowe klucze na unikalną umiejętność (np. "teleport", "vanish") — podklasa
## sama wywołuje _set_skill_pose() z właściwym kluczem w swojej sygnaturalnej umiejętności.

signal died(fragment_name: String)

@export var max_health: float = 160.0
@export var radius: float = 95.0 ## dopasowane do widocznej sylwetki sprite'a (~250-270px), nie starego kółka-placeholdera
@export var drift_speed: float = 90.0
@export var contact_damage: float = 8.0
@export var contact_knockback: float = 300.0 ## px/s, odepchnięcie gracza przy dotyku
@export var attack_interval: float = 2.2 ## s, odstęp między użyciami umiejętności
@export var telegraph_duration: float = 0.5 ## s, wspólna zapowiedź przed umiejętnością
@export var knockback_friction: float = 2000.0 ## px/s^2, jak szybko wytraca się odepchnięcie od bloku gracza
@export var sprite_scale: float = 0.27 ## wcielenia wobec oryginalnych plików ~1024-1254px (cel: 200-300px, LORE_I_ASSETY.md)
@export var skill_pose_duration: float = 0.4 ## s, jak długo trzyma się poza umiejętności po jej użyciu

const SND_TELEGRAPH := preload("res://assets/audio/sfx/wcielenia/I01_telegraph.wav")
const SND_DAMAGE_PULSE := preload("res://assets/audio/sfx/wcielenia/I02_damage_pulse.wav")
const SND_LUNGE_START := preload("res://assets/audio/sfx/wcielenia/I04_lunge_start.wav")
const SND_CONTACT_HIT := preload("res://assets/audio/sfx/wcielenia/I05_contact_hit.wav")
const SND_HURT := preload("res://assets/audio/sfx/wcielenia/I07_incarnation_hurt.wav")
const SND_DEATH := preload("res://assets/audio/sfx/wcielenia/I08_incarnation_death.wav")

@onready var sprite: Sprite2D = $Sprite
@onready var sfx: AudioStreamPlayer2D = $Sfx

var current_color: Color = Color.WHITE ## ustawiane przez podklasę
var fragment_name: String = "" ## ustawiane przez podklasę — nazwa fragmentu duszy
var _sprite_textures: Dictionary = {} ## wypełniane przez podklasę w _ready()
var _facing_direction: Vector2 = Vector2.ZERO ## kierunek do gracza — pilotaż 360° (patrz Facing.resolve)
var _skill_pose_name: String = "walk"
var _skill_pose_timer: float = 0.0

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

## Cykl chodu (PLAN_ANIMACJE_KIERUNKOWE.md, Faza 1b) — patrz player.gd,
## identyczny mechanizm. Cykluje TYLKO podczas zwykłego dryfowania w stronę
## gracza (drift_speed jest stały, więc ratio to zawsze 0 albo 1, bez rozpędzania).
@export var walk_cycle_speed: float = 6.0 ## pełnych cykli/s
var _walk_cycle_phase: float = 0.0

## Skalowanie trudności dla pokoi z losowymi przeciwnikami (nie wcieleniami z
## duszami, które mają ręcznie dobrane, stałe statystyki na życzenie autora) —
## mnożnik rośnie z numerem pokoju w GameFlow, patrz room.gd._spawn_random_enemy().
## Wywoływane PO add_child() — health jest już ustawione przez _ready() na
## bazowe max_health, więc trzeba je tutaj jawnie przeliczyć na nowo.
func apply_difficulty_scale(multiplier: float) -> void:
	max_health *= multiplier
	health = max_health
	contact_damage *= multiplier

func _ready() -> void:
	health = max_health
	add_to_group("hittable") # dzięki temu miecz/różdżka gracza trafiają bez zmian w player.gd
	player = get_tree().get_first_node_in_group("player") as Player
	_attack_timer = attack_interval
	sprite.scale = Vector2(sprite_scale, sprite_scale)

func _physics_process(delta: float) -> void:
	if player == null:
		return
	if is_dead:
		_update_sprite_state() # inaczej poza śmierci nigdy by się nie pokazała
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
		_walk_cycle_phase += delta * walk_cycle_speed
		_attack_timer -= delta
		if _attack_timer <= 0.0:
			_attack_timer = attack_interval
			_start_telegraph()

	if _flash_frames > 0:
		_flash_frames -= 1
	if _skill_pose_timer > 0.0:
		_skill_pose_timer -= delta
	_update_sprite_state()

func _walk_cycle_frame() -> int:
	return int(_walk_cycle_phase) % 2

## Wywoływane z zewnątrz (blok gracza pod PPM) — odpycha wcielenie na chwilę.
func apply_knockback(impulse: Vector2) -> void:
	_knockback_velocity = impulse

func _drift_towards_player(delta: float) -> void:
	var to_player: Vector2 = player.global_position - global_position
	if to_player.length() > 1.0:
		_facing_direction = to_player
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
	_play_sfx(SND_CONTACT_HIT)

func _start_telegraph() -> void:
	_telegraph_active = true
	_play_sfx(SND_TELEGRAPH)
	await get_tree().create_timer(telegraph_duration).timeout
	_telegraph_active = false
	if not is_dead:
		_perform_random_skill()

## Wydzielone dla testowalności — czysta logika losowania indeksu bez
## wywoływania samej umiejętności (Callable), więc test nie musi jej wykonać.
func _choose_skill_index(count: int, previous: int) -> int:
	var index := randi() % count
	if count > 1:
		while index == previous:
			index = randi() % count
	return index

## Losuje jedną z umiejętności podklasy (bez powtórzenia poprzedniej) i ją wywołuje.
func _perform_random_skill() -> void:
	if _skills.is_empty():
		return
	var index := _choose_skill_index(_skills.size(), _last_skill_index)
	_last_skill_index = index
	_skills[index].call()

# --- Wspólne prymitywy, z których podklasy budują swoje umiejętności ---

## Zwraca true, jeśli gracz był w zasięgu i faktycznie oberwał (przydatne np.
## do leczenia się kosztem trafienia, patrz GlodIncarnation).
func _damage_pulse(pulse_radius: float, damage: float) -> bool:
	_set_skill_pose("pulse")
	_play_sfx(SND_DAMAGE_PULSE)
	if player.is_invulnerable():
		return false
	if global_position.distance_to(player.global_position) > pulse_radius:
		return false
	player.take_damage(damage)
	return true

func _pull_player(strength: float) -> void:
	_set_skill_pose("pull")
	var dir: Vector2 = global_position - player.global_position
	if dir.length() > 1.0:
		player.apply_knockback(dir.normalized() * strength)

## Poza "lunge" trzyma się cały czas trwania wypadu przez _lunge_active w
## _update_sprite_state(), nie przez _skill_pose_timer jak pulse/pull.
func _lunge_toward_player(speed: float, duration: float) -> void:
	_play_sfx(SND_LUNGE_START)
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
		_play_sfx(SND_DEATH)
		died.emit(fragment_name)
	else:
		_play_sfx(SND_HURT)

func flash_white() -> void:
	_flash_frames = 2

func _set_skill_pose(pose_name: String) -> void:
	_skill_pose_name = pose_name
	_skill_pose_timer = skill_pose_duration

func _play_sfx(stream: AudioStream) -> void:
	sfx.stream = stream
	sfx.play()

## Zastępuje dawny _draw() — wybiera teksturę wg priorytetu stanu. Świeżo
## ustawiona poza umiejętności (_skill_pose_timer) ma priorytet NAD "lunge",
## żeby np. teleport/vanish zdążyły się pokazać, zanim wypad, który zaraz po
## nich startuje w tej samej klatce, nie przejął sprite'a na "lunge" w 0 klatek —
## bez dotykania faktycznego czasu trwania samego wypadu (_lunge_active).
func _update_sprite_state() -> void:
	var pose := "walk"
	if is_dead:
		pose = "death"
	elif _flash_frames > 0:
		pose = "hit"
	elif _telegraph_active:
		pose = "telegraph"
	elif _skill_pose_timer > 0.0:
		pose = _skill_pose_name
	elif _lunge_active:
		pose = "lunge"
	var entry = _sprite_textures.get(pose, _sprite_textures.get("walk"))
	if entry != null:
		var frame := _walk_cycle_frame() if pose == "walk" else 0
		var facing := Facing.resolve(entry, _facing_direction, frame)
		sprite.texture = facing["texture"]
		sprite.flip_h = facing["flip_h"]
