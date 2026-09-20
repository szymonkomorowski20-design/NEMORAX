extends CharacterBody2D
class_name Player
## Gracz (sekcja 3). Ruch i dash trzymane są w prostym enumie stanu; atak (miecz
## lub różdżka) jest CELOWO niezależny od stanu ruchu — na życzenie autora da się
## machnąć/strzelić w dowolnym momencie dasha, więc trzyma się osobno przez
## _attack_phase i leci równolegle, niezależnie od tego, czy gracz właśnie dashuje.
## Broń (miecz/różdżka), blok i leczenie to dodatki na życzenie autora, poza dokumentem.

signal died

enum State { NORMAL, DASHING, DEAD }

const ProjectileScene := preload("res://entities/projectile.tscn")

# --- Sprite'y (zamiast dawnego _draw()) ---
const TEX_BASE := preload("res://assets/sprites/gracz/player_base.png")
const TEX_WALK := preload("res://assets/sprites/gracz/player_walk.png")
const TEX_DASH := preload("res://assets/sprites/gracz/player_dash.png")
const TEX_SWORD_WINDUP := preload("res://assets/sprites/gracz/player_sword_windup.png")
const TEX_SWORD_ACTIVE := preload("res://assets/sprites/gracz/player_sword_active.png")
const TEX_WAND_WINDUP := preload("res://assets/sprites/gracz/player_wand_windup.png")
const TEX_WAND_FIRE := preload("res://assets/sprites/gracz/player_wand_fire.png")
const TEX_BLOCK := preload("res://assets/sprites/gracz/player_block.png")
const TEX_HEAL := preload("res://assets/sprites/gracz/player_heal.png")
const TEX_HIT := preload("res://assets/sprites/gracz/player_hit.png")
const TEX_DEATH := preload("res://assets/sprites/gracz/player_death.png")
const TEX_SLASH_ARC := preload("res://assets/sprites/ekwipunek/sword_slash_arc.png")
const TEX_WAND_CHARGE := preload("res://assets/sprites/ekwipunek/wand_charge.png")
const TEX_DASH_TRAIL := preload("res://assets/sprites/ekwipunek/player_dash_trail.png")

# --- Dźwięki (P20/P21 — ból/śmierć gracza — jeszcze nie wygenerowane, brak na razie) ---
const SND_DASH_START := preload("res://assets/audio/sfx/gracz/P01_dash_start.wav")
const SND_DASH_DENIED := preload("res://assets/audio/sfx/gracz/P02_dash_denied.wav")
const SND_DASH_VOID_LOCKED := preload("res://assets/audio/sfx/gracz/P03_dash_void_locked.wav")
const SND_WEAPON_SWITCH := preload("res://assets/audio/sfx/gracz/P04_weapon_switch.wav")
const SND_ATTACK_DENIED := preload("res://assets/audio/sfx/gracz/P05_attack_denied.wav")
const SND_SWORD_SWING := preload("res://assets/audio/sfx/gracz/P07_sword_swing.wav")
const SND_SWORD_HIT := preload("res://assets/audio/sfx/gracz/P08_sword_hit.wav")
const SND_SWORD_MISS := preload("res://assets/audio/sfx/gracz/P09_sword_miss.wav")
const SND_WAND_CHARGE := preload("res://assets/audio/sfx/gracz/P10_wand_charge.wav")
const SND_WAND_FIRE := preload("res://assets/audio/sfx/gracz/P11_wand_fire.wav")
const SND_BLOCK_RAISE := preload("res://assets/audio/sfx/gracz/P13_block_raise.wav")
const SND_BLOCK_PUSH_HIT := preload("res://assets/audio/sfx/gracz/P14_block_push_hit.wav")
const SND_HEAL_USE := preload("res://assets/audio/sfx/gracz/P16_heal_use.wav")
const SND_HEAL_CHARGE_TICK := preload("res://assets/audio/sfx/gracz/P18_heal_charge_tick.wav")
const SND_HEAL_READY := preload("res://assets/audio/sfx/gracz/P19_heal_ready.wav")
const SND_KNOCKBACK := preload("res://assets/audio/sfx/gracz/P22_player_knockback.wav")

@onready var sprite: Sprite2D = $Sprite
@onready var slash_arc: Sprite2D = $SlashArc
@onready var wand_charge_sprite: Sprite2D = $WandCharge
@onready var sfx: AudioStreamPlayer2D = $Sfx

# --- Ruch ---
@export var max_speed: float = 300.0 ## px/s, maksymalna prędkość biegu
@export var acceleration: float = 2600.0 ## px/s^2, jak szybko gracz rozpędza się do max_speed
@export var friction: float = 2500.0 ## px/s^2, jak szybko gracz hamuje bez wejścia
@export var radius: float = 14.0 ## px, promień koła gracza (też kolizji)

# --- Wygląd (dostrojenie sprite'ów wobec oryginalnych plików 1024-1254px) ---
@export var sprite_scale: float = 0.08 ## postać gracza
@export var slash_arc_scale: float = 0.14 ## wycinek ataku mieczem
@export var wand_charge_scale: float = 0.05 ## kula ładowania różdżki
@export var trail_ghost_scale: float = 0.08 ## kopie śladu dasha

# --- Dash ---
@export var dash_speed: float = 900.0 ## px/s, prędkość w trakcie dasha
@export var dash_duration: float = 0.18 ## s, jak długo trwa dash
@export var dash_cooldown: float = 0.6 ## s, odnowienie dasha (mnożone x2 w fazie Zwłoka)
@export var dash_trail_count: int = 5 ## liczba zanikających kopii śladu na jeden dash
@export var dash_trail_lifetime: float = 0.25 ## s, jak długo blaknie pojedyncza kopia śladu

# --- Atak ---
@export var attack_windup: float = 0.08 ## s, zamach przed trafieniem (telegraf)
@export var attack_active: float = 0.10 ## s, okno, w którym atak faktycznie trafia
@export var attack_recovery: float = 0.22 ## s, bezwładność po ataku
@export var attack_range: float = 70.0 ## px, zasięg wycinka koła ataku
@export var attack_angle_degrees: float = 100.0 ## stopnie, szerokość wycinka ataku
@export var attack_damage: float = 10.0 ## obrażenia zadawane trafionemu celowi
@export var attack_move_speed_fraction: float = 0.75 ## ułamek max_speed w trakcie ataku — spowolnienie, nie zatrzymanie

# --- Różdżka (broń 2, atak na dystans) ---
@export var wand_windup: float = 0.10 ## s, zamach przed strzałem (telegraf)
@export var wand_active: float = 0.06 ## s, moment wystrzału pocisku
@export var wand_recovery: float = 0.30 ## s, bezwładność po strzale
@export var wand_damage: float = 8.0 ## obrażenia zadawane przez trafiony pocisk
@export var wand_projectile_speed: float = 600.0 ## px/s, prędkość lotu pocisku
@export var wand_projectile_lifetime: float = 1.0 ## s, po tylu sekundach pocisk znika sam

# --- Życie ---
@export var max_health: float = 100.0
@export var damage_invulnerability: float = 0.5 ## s nietykalności po otrzymaniu obrażeń

# --- Stamina (miecz + dash) i mana (różdżka) — dodane na życzenie autora, poza dokumentem ---
@export var max_stamina: float = 100.0
@export var stamina_regen_rate: float = 30.0 ## /s, regeneracja gdy nie atakuję mieczem ani nie dashuję
@export var sword_stamina_cost: float = 20.0
@export var dash_stamina_cost: float = 25.0
@export var max_mana: float = 100.0
@export var wand_mana_cost: float = 25.0
@export var mana_regen_per_hit: float = 15.0 ## mana nie regeneruje się z czasem — wyłącznie za trafienia wroga

# --- Blok (prawy przycisk myszy) — dodane na życzenie autora, poza dokumentem ---
@export var block_stamina_cost_fraction: float = 0.75 ## ułamek MAX staminy zużywany na blok
@export var block_range: float = 90.0 ## px, zasięg odepchnięcia wroga blokiem
@export var block_knockback_strength: float = 500.0 ## px/s, siła odepchnięcia wroga blokiem
@export var block_invuln_duration: float = 0.3 ## s nietykalności przy bloku
@export var block_visual_duration: float = 0.15 ## s, jak długo pokazuje się poza bloku

# --- Leczenie (E) — dodane na życzenie autora, poza dokumentem ---
@export var heal_hits_required: int = 40 ## ile celnych trafień wroga ładuje jedno leczenie
@export var heal_amount_fraction: float = 0.5 ## ułamek MAX zdrowia odzyskiwany leczeniem
@export var heal_visual_duration: float = 0.4 ## s, jak długo pokazuje się poza leczenia

# --- Odepchnięcie (dodane na życzenie autora) ---
@export var knockback_recovery_duration: float = 0.15 ## s, jak długo po odepchnięciu nie steruje się ruchem

var stamina: float
var mana: float
var _heal_charge_hits: int = 0
var _heal_visual_timer: float = 0.0
var _knockback_timer: float = 0.0

var health: float
var state: State = State.NORMAL

var _dash_cooldown_timer: float = 0.0
var _void_dash_lock_timer: float = 0.0 ## ustawiane z zewnątrz przez Ząb Zera
var _dash_timer: float = 0.0
var _dash_direction: Vector2 = Vector2.DOWN
var _last_move_direction: Vector2 = Vector2.DOWN

var current_weapon: String = "sword" ## "sword" albo "wand" — przełączane klawiszami 1/2
var _swing_weapon: String = "sword" ## broń "zamrożona" na czas trwającego zamachu

var _attack_phase: String = ""
var _attack_timer: float = 0.0
var _attack_direction: Vector2 = Vector2.RIGHT
var _attack_hit_targets: Array = []

var _invuln_timer: float = 0.0 ## nietykalność po obrażeniach (miganie)
var _flash_frames: int = 0 ## błysk trafienia — ile klatek jeszcze pokazywać poze trafienia
var _block_visual_timer: float = 0.0

var _trail_spawn_timer: float = 0.0

# Faza Ciężar: stałe przyciąganie w stronę bossa. Ustawiane z zewnątrz (arena/boss),
# gracz sam sobie dolicza to do prędkości, żeby zostać jedynym właścicielem `velocity`.
var pull_source: Node2D = null
var pull_strength: float = 0.0

# Faza finałowa, reguła siódma: wektor wejścia obrócony o 90 stopni.
var input_reversed: bool = false

func _ready() -> void:
	health = max_health
	stamina = max_stamina
	mana = max_mana
	add_to_group("player")
	collision_layer = 2
	collision_mask = 1
	sprite.scale = Vector2(sprite_scale, sprite_scale)
	slash_arc.scale = Vector2(slash_arc_scale, slash_arc_scale)
	slash_arc.texture = TEX_SLASH_ARC
	wand_charge_sprite.texture = TEX_WAND_CHARGE
	_update_visuals()

func _physics_process(delta: float) -> void:
	if state == State.DEAD:
		_update_visuals()
		return

	_tick_timers(delta)
	_handle_weapon_switch()
	_handle_dash_input()
	_handle_attack_input() # niezależne od stanu ruchu — da się zacząć w trakcie dasha
	_handle_block_input()
	_handle_heal_input()

	match state:
		State.DASHING:
			_process_dash(delta)
		_:
			_process_normal_movement(delta)

	if _attack_phase != "":
		_process_attack_phase(delta) # leci równolegle, niezależnie od ruchu/dasha

	_tick_stamina_regen(delta)
	move_and_slide()
	_update_trail(delta)
	_update_visuals()

func _tick_timers(delta: float) -> void:
	_dash_cooldown_timer = max(0.0, _dash_cooldown_timer - delta)
	_void_dash_lock_timer = max(0.0, _void_dash_lock_timer - delta)
	_invuln_timer = max(0.0, _invuln_timer - delta)
	_block_visual_timer = max(0.0, _block_visual_timer - delta)
	_heal_visual_timer = max(0.0, _heal_visual_timer - delta)
	if _flash_frames > 0:
		_flash_frames -= 1

## Stamina regeneruje się, gdy nie dashuję i nie macham mieczem (mana NIE regeneruje
## się z czasem w ogóle — wyłącznie za trafienia, patrz register_hit_on_enemy()).
func _tick_stamina_regen(delta: float) -> void:
	var is_spending_stamina := state == State.DASHING or (_attack_phase != "" and _swing_weapon == "sword")
	if not is_spending_stamina:
		stamina = min(max_stamina, stamina + stamina_regen_rate * delta)

func _is_dash_ready() -> bool:
	return _dash_cooldown_timer <= 0.0 and _void_dash_lock_timer <= 0.0 and stamina >= dash_stamina_cost

func _handle_weapon_switch() -> void:
	# Wolno przełączać w dowolnym momencie — trwający zamach i tak trzyma się
	# broni złapanej w _start_attack() przez _swing_weapon, więc się nie zepsuje.
	if Input.is_action_just_pressed("weapon_sword"):
		current_weapon = "sword"
		_play_sfx(SND_WEAPON_SWITCH)
	elif Input.is_action_just_pressed("weapon_wand"):
		current_weapon = "wand"
		_play_sfx(SND_WEAPON_SWITCH)

func _handle_dash_input() -> void:
	if state == State.DASHING or state == State.DEAD:
		return
	if not Input.is_action_just_pressed("dash"):
		return
	if not _is_dash_ready():
		_play_sfx(SND_DASH_VOID_LOCKED if _void_dash_lock_timer > 0.0 else SND_DASH_DENIED)
		return
	# Atak NIE jest już przerywany dashem (na życzenie autora) — leci dalej
	# niezależnie, patrz _attack_phase i _process_attack_phase().
	var input_dir := _read_input_vector()
	_dash_direction = input_dir if input_dir.length() > 0.01 else _last_move_direction
	state = State.DASHING
	stamina -= dash_stamina_cost
	_dash_timer = dash_duration
	_dash_cooldown_timer = dash_cooldown
	_trail_spawn_timer = 0.0
	_play_sfx(SND_DASH_START)

func _process_dash(delta: float) -> void:
	_dash_timer -= delta
	velocity = _dash_direction.normalized() * dash_speed
	if _dash_timer <= 0.0:
		state = State.NORMAL
		velocity = Vector2.ZERO

func _process_normal_movement(delta: float) -> void:
	if _knockback_timer > 0.0:
		# Odepchnięcie chwilowo odbiera sterowanie — prędkość tylko wytraca się
		# tarciem, żeby kopnięcie faktycznie było czuć, a nie znikało w 1 klatkę.
		_knockback_timer -= delta
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
		return

	var input_dir := _read_input_vector()
	if input_dir.length() > 0.01:
		_last_move_direction = input_dir

	var target_speed := max_speed
	if _attack_phase != "":
		target_speed = max_speed * attack_move_speed_fraction

	var target_velocity := input_dir * target_speed

	# Faza Ciężar (sekcja 7): stały "prąd" w stronę bossa. Dolicza się do docelowej
	# prędkości (nie do velocity wprost), żeby tarcie/przyspieszenie go ograniczały —
	# inaczej narastałby bez końca zamiast dawać stałe 120 px/s przyciągania.
	if pull_source != null and pull_strength > 0.0:
		var to_source: Vector2 = pull_source.global_position - global_position
		if to_source.length() > 1.0:
			target_velocity += to_source.normalized() * pull_strength

	var rate := acceleration if input_dir.length() > 0.01 else friction
	velocity = velocity.move_toward(target_velocity, rate * delta)

func _can_afford_attack() -> bool:
	if current_weapon == "wand":
		return mana >= wand_mana_cost
	return stamina >= sword_stamina_cost

## Niezależne od stanu ruchu (sekcja o broni: da się atakować w dowolnym
## momencie dasha, mieczem albo różdżką) — jedyny warunek to brak trwającego
## już zamachu i śmierć.
func _handle_attack_input() -> void:
	if state == State.DEAD:
		return
	if _attack_phase != "":
		return
	if not Input.is_action_just_pressed("attack"):
		return
	if not _can_afford_attack():
		_play_sfx(SND_ATTACK_DENIED)
		return
	_start_attack()

## Blok (PPM) — dodane na życzenie autora: koszt 3/4 max staminy, odpycha
## wszystko dookoła w zasięgu i daje krótką nietykalność (stąd "blok").
func _handle_block_input() -> void:
	if state == State.DEAD:
		return
	if not Input.is_action_just_pressed("block"):
		return
	var cost := max_stamina * block_stamina_cost_fraction
	if stamina < cost:
		_play_sfx(SND_ATTACK_DENIED)
		return
	stamina -= cost
	_invuln_timer = max(_invuln_timer, block_invuln_duration)
	_block_visual_timer = block_visual_duration
	_play_sfx(SND_BLOCK_RAISE)
	_perform_block_push()

func _perform_block_push() -> void:
	var pushed_something := false
	for target in get_tree().get_nodes_in_group("hittable"):
		var to_target: Vector2 = target.global_position - global_position
		var target_radius: float = target.get("radius") if target.get("radius") != null else 0.0
		if to_target.length() > block_range + target_radius:
			continue
		if target.has_method("apply_knockback"):
			var dir := to_target.normalized() if to_target.length() > 0.01 else Vector2.RIGHT
			target.apply_knockback(dir * block_knockback_strength)
			pushed_something = true
	if pushed_something:
		_play_sfx(SND_BLOCK_PUSH_HIT)

## Leczenie (E) — ładuje się samo za 40 celnych trafień wroga (patrz
## register_hit_on_enemy), zużywa cały ładunek i oddaje połowę MAX zdrowia.
func _handle_heal_input() -> void:
	if state == State.DEAD:
		return
	if not Input.is_action_just_pressed("heal"):
		return
	if _heal_charge_hits < heal_hits_required:
		_play_sfx(SND_ATTACK_DENIED)
		return
	_heal_charge_hits = 0
	_heal_visual_timer = heal_visual_duration
	health = min(max_health, health + max_health * heal_amount_fraction)
	_play_sfx(SND_HEAL_USE)

func is_heal_ready() -> bool:
	return _heal_charge_hits >= heal_hits_required

func heal_charge_ratio() -> float:
	return float(_heal_charge_hits) / float(heal_hits_required)

## Do przenoszenia stanu gracza między pokojami (GameFlow) — patrz room.gd.
func get_heal_charge_hits() -> int:
	return _heal_charge_hits

func set_heal_charge_hits(value: int) -> void:
	_heal_charge_hits = clampi(value, 0, heal_hits_required)

## Wywoływane z zewnątrz (bossa/void_zone itd.) — odpycha gracza i na chwilę
## odbiera mu sterowanie, żeby kopnięcie było wyczuwalne (patrz _process_normal_movement).
func apply_knockback(impulse: Vector2) -> void:
	velocity = impulse
	_knockback_timer = knockback_recovery_duration
	_play_sfx(SND_KNOCKBACK)

func _start_attack() -> void:
	_swing_weapon = current_weapon # broń "zamrożona" na czas tego zamachu
	if _swing_weapon == "wand":
		mana -= wand_mana_cost
		_play_sfx(SND_WAND_CHARGE)
	else:
		stamina -= sword_stamina_cost
	_attack_phase = "windup"
	_attack_timer = wand_windup if _swing_weapon == "wand" else attack_windup
	_attack_direction = (get_global_mouse_position() - global_position).normalized()
	_attack_hit_targets.clear()

## Faza ataku (windup/active/recovery) — CELOWO osobno od ruchu/dasha, żeby dało
## się machnąć mieczem albo strzelić z różdżki w dowolnym momencie dasha.
func _process_attack_phase(delta: float) -> void:
	var is_sword := _swing_weapon == "sword"

	_attack_timer -= delta
	if _attack_timer > 0.0:
		if _attack_phase == "active" and is_sword:
			_check_attack_hits() # miecz sprawdza trafienie co klatkę, dopóki aktywny
		return

	match _attack_phase:
		"windup":
			_attack_phase = "active"
			_attack_timer = attack_active if is_sword else wand_active
			if is_sword:
				_play_sfx(SND_SWORD_SWING)
				_check_attack_hits()
			else:
				_fire_projectile() # różdżka strzela raz, w momencie wystrzału
				_play_sfx(SND_WAND_FIRE)
		"active":
			_attack_phase = "recovery"
			_attack_timer = attack_recovery if is_sword else wand_recovery
			if is_sword and _attack_hit_targets.is_empty():
				_play_sfx(SND_SWORD_MISS)
		_:
			_attack_phase = ""

func _fire_projectile() -> void:
	var projectile = ProjectileScene.instantiate()
	projectile.direction = _attack_direction
	projectile.damage = wand_damage
	projectile.speed = wand_projectile_speed
	projectile.lifetime = wand_projectile_lifetime
	projectile.shooter = self # żeby pocisk mógł oddać manę za trafienie
	projectile.global_position = global_position + _attack_direction * (radius + 6.0)
	get_parent().add_child(projectile)

## Wywoływane za KAŻDE celne trafienie wroga, niezależnie jaką bronią — jedyny
## sposób odzyskania many, a co 40. takie trafienie ładuje leczenie (E).
func register_hit_on_enemy() -> void:
	mana = min(max_mana, mana + mana_regen_per_hit)
	var was_ready := is_heal_ready()
	_heal_charge_hits = min(_heal_charge_hits + 1, heal_hits_required)
	if is_heal_ready() and not was_ready:
		_play_sfx(SND_HEAL_READY)
	else:
		_play_sfx(SND_HEAL_CHARGE_TICK)

func _check_attack_hits() -> void:
	var half_angle := deg_to_rad(attack_angle_degrees) * 0.5
	for target in get_tree().get_nodes_in_group("hittable"):
		if target in _attack_hit_targets:
			continue
		var to_target: Vector2 = target.global_position - global_position
		var distance := to_target.length()
		# Cel liczymy jako koło, nie punkt — inaczej trafienie w sam brzeg dużego
		# kola (np. bossa) nie zaliczałoby się, bo tylko środek byłby "w zasięgu".
		var target_radius: float = target.get("radius") if target.get("radius") != null else 0.0

		if distance > attack_range + target_radius:
			continue

		if distance > target_radius:
			# Gracz nie stoi wewnątrz koła celu — do stożka ataku doliczamy połowę
			# kąta, pod jakim widać krąg celu z pozycji gracza, żeby trafienie
			# w krawędź (środek poza wąskim stożkiem) też się liczyło.
			var angle: float = absf(_attack_direction.angle_to(to_target.normalized()))
			var angular_half_width := asin(clamp(target_radius / max(distance, 0.01), 0.0, 1.0))
			if angle > half_angle + angular_half_width:
				continue

		_attack_hit_targets.append(target)
		if target.has_method("take_damage"):
			target.take_damage(attack_damage)
		if target.has_method("flash_white"):
			target.flash_white()
		register_hit_on_enemy()
		_play_sfx(SND_SWORD_HIT)
		Juice.hitstop(Juice.boss_hit_hitstop)
		Juice.screen_shake()

func _read_input_vector() -> Vector2:
	var v := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if input_reversed:
		v = v.rotated(deg_to_rad(90.0)) # faza finałowa, reguła Odwrócenie
	return v

func _update_trail(delta: float) -> void:
	if state != State.DASHING:
		return
	_trail_spawn_timer -= delta
	if _trail_spawn_timer <= 0.0:
		_trail_spawn_timer = dash_duration / float(max(1, dash_trail_count))
		_spawn_trail_ghost()

## Zanikająca kopia śladu dasha — osobny top_level Sprite2D zamiast wpisu w
## tablicy do _draw(), żeby została w miejscu spawnu zamiast jechać z graczem.
func _spawn_trail_ghost() -> void:
	var ghost := Sprite2D.new()
	ghost.texture = TEX_DASH_TRAIL
	ghost.scale = Vector2(trail_ghost_scale, trail_ghost_scale)
	ghost.top_level = true
	ghost.global_position = global_position
	ghost.modulate = Color(1.0, 1.0, 1.0, 0.5)
	add_child(ghost)
	var tw := create_tween()
	tw.tween_property(ghost, "modulate:a", 0.0, dash_trail_lifetime)
	tw.tween_callback(ghost.queue_free)

## Wywoływane z zewnątrz (pieczęcie, cień, kontakt) — jedna, wspólna brama obrażeń,
## dzięki której nietykalność po trafieniu działa tak samo niezależnie od źródła.
func take_damage(amount: float) -> void:
	if state == State.DEAD:
		return
	if state == State.DASHING or _invuln_timer > 0.0:
		return
	health -= amount
	_invuln_timer = damage_invulnerability
	_flash_frames = 2
	Juice.hitstop(Juice.player_hit_hitstop)
	Juice.screen_shake()
	if health <= 0.0:
		health = 0.0
		state = State.DEAD
		died.emit()

## Wywoływane przez Ząb Zera przy wejściu gracza w strefę.
func lock_dash(seconds: float) -> void:
	_void_dash_lock_timer = max(_void_dash_lock_timer, seconds)

func is_dash_locked_by_void() -> bool:
	return _void_dash_lock_timer > 0.0

func is_dash_on_cooldown() -> bool:
	return _dash_cooldown_timer > 0.0

## Publiczne, żeby boss mógł nie marnować odepchnięcia w chwili, gdy trafienie
## i tak zostanie zignorowane przez take_damage() (dash / miganie po obrażeniach).
func is_invulnerable() -> bool:
	return state == State.DASHING or _invuln_timer > 0.0

func flash_white() -> void:
	_flash_frames = 2

func _play_sfx(stream: AudioStream) -> void:
	sfx.stream = stream
	sfx.play()

## Zastępuje dawny _draw() — wybiera właściwą teksturę wg priorytetu stanu i
## ustawia VFX ataku (wycinek miecza / kula różdżki) w miejsce dawnych rysowanych kształtów.
func _update_visuals() -> void:
	if state == State.DEAD:
		sprite.texture = TEX_DEATH
	elif _flash_frames > 0:
		sprite.texture = TEX_HIT
	elif _block_visual_timer > 0.0:
		sprite.texture = TEX_BLOCK
	elif _heal_visual_timer > 0.0:
		sprite.texture = TEX_HEAL
	elif state == State.DASHING:
		sprite.texture = TEX_DASH
	elif _attack_phase == "windup":
		sprite.texture = TEX_SWORD_WINDUP if _swing_weapon == "sword" else TEX_WAND_WINDUP
	elif _attack_phase == "active" or _attack_phase == "recovery":
		sprite.texture = TEX_SWORD_ACTIVE if _swing_weapon == "sword" else TEX_WAND_FIRE
	elif velocity.length() > 5.0:
		sprite.texture = TEX_WALK
	else:
		sprite.texture = TEX_BASE

	var blinking_hidden := _invuln_timer > 0.0 and int(_invuln_timer * 20.0) % 2 == 0
	sprite.visible = not blinking_hidden

	var showing_slash := _attack_phase != "" and _swing_weapon == "sword"
	slash_arc.visible = showing_slash
	if showing_slash:
		slash_arc.rotation = _attack_direction.angle()
		slash_arc.position = _attack_direction * (attack_range * 0.5)
		slash_arc.modulate.a = 0.5 if _attack_phase == "windup" else 1.0

	var showing_wand := _attack_phase != "" and _swing_weapon == "wand"
	wand_charge_sprite.visible = showing_wand
	if showing_wand:
		wand_charge_sprite.position = _attack_direction * (radius + 6.0)
		var charge_t: float = 0.6 if _attack_phase == "windup" else 1.0
		wand_charge_sprite.scale = Vector2(wand_charge_scale, wand_charge_scale) * charge_t
