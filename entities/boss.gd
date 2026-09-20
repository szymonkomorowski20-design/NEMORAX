extends Node2D
class_name Boss
## Nemorax (sekcja 5 i 7). Zdrowie, dryfowanie, wybór ataku i przemiany fazowe
## mieszkają razem w jednym skrypcie — to jeden obiekt gry, nie osobny automat stanów.
## Same ataki (pieczęcie / Ząb Zera / cień) są osobnymi scenami, które boss tylko spawnuje.

signal phase_changed(phase_index: int, color: Color, rule_name: String)
signal died(is_final: bool) ## false = duża forma padła (start fazy finałowej), true = koniec walki

const SealScene := preload("res://entities/seal.tscn")
const VoidZoneScene := preload("res://entities/void_zone.tscn")
const ShadowScene := preload("res://entities/shadow.tscn")

# Sześć baz wyglądu, jedna na fazę (kolejność = phase_index 0..5) — zamiast
# jednego generycznego "walk" na cały pojedynek, każda faza ma własny portret,
# tak jak sugerują nazwy plików (PROMPTY_FINALNE_WSZYSTKO.md sekcja A2).
const PHASE_BASE_TEXTURES: Array[Texture2D] = [
	preload("res://assets/sprites/nemorax/nemorax_phase-1_base.png"),
	preload("res://assets/sprites/nemorax/nemorax_phase-2_silence.png"),
	preload("res://assets/sprites/nemorax/nemorax_phase-3_dash-cooldown.png"),
	preload("res://assets/sprites/nemorax/nemorax_phase-4_pull.png"),
	preload("res://assets/sprites/nemorax/nemorax_phase-5_regeneration.png"),
	preload("res://assets/sprites/nemorax/nemorax_phase-6_narrow-vision.png"),
]
const TEX_TELEGRAPH := preload("res://assets/sprites/nemorax/nemorax_telegraph.png")
const TEX_LUNGE := preload("res://assets/sprites/nemorax/nemorax_lunge.png")
const TEX_CAST_PULSE := preload("res://assets/sprites/nemorax/nemorax_cast-pulse.png") # Szósty Rytm
const TEX_PULL := preload("res://assets/sprites/nemorax/nemorax_pull.png") # Kradzież Intencji
const TEX_HIT := preload("res://assets/sprites/nemorax/nemorax_hit.png")
const TEX_PHASE_TRANSFORM := preload("res://assets/sprites/nemorax/nemorax_phase-transform.png")
const TEX_LARGE_FORM_COLLAPSE := preload("res://assets/sprites/nemorax/nemorax_large-form-collapse.png")
const TEX_SMALL_FORM_REBIRTH := preload("res://assets/sprites/nemorax/nemorax_small-form-rebirth.png")
const TEX_SMALL_FORM_TAUNT := preload("res://assets/sprites/nemorax/nemorax_small-form-taunt.png")
const TEX_SMALL_FORM_TRUE_DEATH := preload("res://assets/sprites/nemorax/nemorax_small-form-true-death.png")
const TEX_LUNGE_WARNING := preload("res://assets/sprites/ataki_bossa/claw_dash_warning.png")
const LUNGE_WARNING_CONTENT_HEIGHT := 891.0 ## zmierzona wysokość samej grafiki na płótnie 1024, resztę zajmuje przezroczysty margines

const SND_TRANSFORM_ROAR := preload("res://assets/audio/sfx/nemorax/N01_transform_roar.wav")
const SND_ATTACK_INHALE := preload("res://assets/audio/sfx/nemorax/N02_attack_inhale.wav")
const SND_LUNGE_TELEGRAPH := preload("res://assets/audio/sfx/nemorax/N11_lunge_telegraph.wav")
const SND_LUNGE_CHARGE := preload("res://assets/audio/sfx/nemorax/N12_lunge_charge.wav")
const SND_BODY_CONTACT := preload("res://assets/audio/sfx/nemorax/N14_body_contact.wav")
const SND_HURT := preload("res://assets/audio/sfx/nemorax/N16_nemorax_hurt.wav")
const SND_BIGFORM_COLLAPSE := preload("res://assets/audio/sfx/nemorax/N17_bigform_collapse.wav")
const SND_SMALLFORM_RESURRECT := preload("res://assets/audio/sfx/nemorax/N18_smallform_resurrect.wav")

## Ile HP trzeba zdjąć, żeby przejść do kolejnej fazy — KAŻDA faza ma pełny pasek
## od nowa (na życzenie autora), a nie jeden wspólny pasek 600 HP na całą walkę.
@export var phase_max_health: float = 100.0
@export var radius: float = 44.0
@export var boss_drift_speed: float = 100.0 ## px/s, powolne dryfowanie w stronę gracza
@export var attack_interval: float = 0.9 ## s, odstęp między losowaniem ataków
@export var final_attack_interval: float = 0.6 ## s, odstęp ataków w fazie finałowej
@export var phase_transform_invuln: float = 1.5 ## s nietykalności podczas przemiany
@export var final_health: float = 150.0 ## HP małej formy w fazie finałowej
@export var final_radius: float = 20.0 ## promień małej formy w fazie finałowej

# Faza Ciężar (sekcja 7): stała siła przyciągania gracza, przekazywana graczowi
# bezpośrednio (patrz player.gd — gracz sam dolicza to do swojej prędkości).
@export var gravity_pull_strength: float = 120.0 ## px/s

# Faza Głód: regeneracja, jeśli boss nie był trafiony przez chwilę.
@export var hunger_regen_rate: float = 8.0 ## HP/s
@export var hunger_regen_delay: float = 3.0 ## s bez trafienia, zanim zacznie się regeneracja

# Atak 1 — Szósty Rytm: boss orkiestruje ile pieczęci i jak są rozstawione w czasie;
# sama pieczęć (seal.gd) zna tylko swój promień, zapowiedź i obrażenia.
@export var seal_count: int = 6
@export var seal_min_distance: float = 150.0 ## px, minimalny odstęp między pieczęciami
@export var seal_interval: float = 0.25 ## s, odstęp między kolejnymi wybuchami

@export var shadow_delay: float = 8.0 ## s, jak daleko w przeszłość sięga nagrywanie pozycji gracza

# Atak fizyczny — dodane na życzenie autora, poza pierwotnymi trzema atakami z dokumentu:
# kontakt z ciałem bossa zawsze rani, a "Wypad" to czwarty atak w puli losowania.
@export var body_contact_damage: float = 10.0 ## obrażenia za sam dotyk ciała bossa
@export var lunge_telegraph: float = 0.3 ## s, zapowiedź przed wypadem
@export var lunge_speed: float = 500.0 ## px/s, prędkość ruchu w trakcie wypadu
@export var lunge_duration: float = 0.35 ## s, jak długo trwa sam wypad
@export var lunge_damage: float = 25.0 ## obrażenia przy kontakcie w trakcie wypadu
@export var lunge_double_chance: float = 0.5 ## szansa, że wypad odpali się od razu drugi raz

# Odepchnięcie — dodane na życzenie autora: dotyk ciała i wypad odpychają gracza,
# a blok gracza (PPM) odpycha bossa tym samym mechanizmem w drugą stronę.
@export var knockback_strength: float = 400.0 ## px/s, siła odepchnięcia gracza dotykiem/wypadem
@export var knockback_friction: float = 2000.0 ## px/s^2, jak szybko wytraca się odepchnięcie bossa

@export var sprite_scale: float = 0.28 ## duża forma wobec oryginalnych plików ~1230-1250px (cel: ~340px)
@export var final_sprite_scale: float = 0.13 ## mała forma finałowa — proporcja final_radius/radius (20/44) razy sprite_scale
@export var cast_pose_duration: float = 0.4 ## s, jak długo trzyma się poza rzucenia pieczęci/cienia po jej użyciu
@export var rebirth_pose_duration: float = 0.6 ## s, poza odrodzenia małej formy po start_final_phase()

@onready var sprite: Sprite2D = $Sprite
@onready var lunge_warning: Sprite2D = $LungeWarning
@onready var sfx: AudioStreamPlayer2D = $Sfx

var _cast_pose_texture: Texture2D = null
var _cast_pose_timer: float = 0.0
var _taunt_pose_active: bool = false
var _rebirth_pose_timer: float = 0.0

var health: float
var max_health: float ## mianownik do paska HP w UI — phase_max_health w fazach 0-5, final_health w finale
var phase_index: int = 0 ## 0..5, indeks w Palette.PHASE_COLORS / PHASE_NAMES
var is_final_phase: bool = false
var is_dead: bool = false

var _invulnerable: bool = false
var _time_since_hit: float = 0.0
var _flash_frames: int = 0

var _attack_timer: float = 0.0
var _last_attack_name: String = ""
var current_color: Color ## publiczne, bo void_zone.gd czyta kolor aktualnej formy (sekcja 2 pkt 3)

var player: Player = null
var arena_rect: Rect2 ## granice areny, ustawiane z zewnątrz przez arena.gd po zespawnowaniu

var _position_history: PackedVector2Array = PackedVector2Array()
var _history_write_index: int = 0

var _lunge_state: String = "" ## "", "telegraph" albo "active"
var _lunge_timer: float = 0.0
var _lunge_direction: Vector2 = Vector2.ZERO
var _lunge_target: Vector2 = Vector2.ZERO
var _lunge_did_double: bool = false ## pilnuje, żeby dorzucić najwyżej jeden dodatkowy wypad

var _knockback_velocity: Vector2 = Vector2.ZERO ## ustawiane z zewnątrz przez blok gracza (PPM)

func _ready() -> void:
	max_health = phase_max_health
	health = max_health
	current_color = Palette.PHASE_COLORS[0]
	add_to_group("hittable")
	player = get_tree().get_first_node_in_group("player") as Player
	_attack_timer = attack_interval
	_init_position_history()
	sprite.scale = Vector2(sprite_scale, sprite_scale)
	lunge_warning.texture = TEX_LUNGE_WARNING
	# claw_dash_warning.png ma grot skierowany "w górę" na płótnie — offset centruje
	# go tak, żeby jego DÓŁ (nasada) siedział na bossie, a grot wskazywał kierunek wypadu.
	lunge_warning.centered = true
	lunge_warning.offset = Vector2(0.0, -lunge_warning.texture.get_height() * 0.5)
	var lunge_reach := lunge_speed * lunge_duration
	var lunge_warning_scale := lunge_reach / LUNGE_WARNING_CONTENT_HEIGHT
	lunge_warning.scale = Vector2(lunge_warning_scale, lunge_warning_scale)
	_update_sprite_state()

func _init_position_history() -> void:
	var frame_count: int = max(1, int(shadow_delay * Engine.physics_ticks_per_second))
	_position_history.resize(frame_count)
	var start_pos: Vector2 = player.global_position if player else Vector2.ZERO
	for i in range(frame_count):
		_position_history[i] = start_pos

func _physics_process(delta: float) -> void:
	if player == null:
		return
	if is_dead:
		_update_sprite_state() # inaczej poza kolapsu/prawdziwej śmierci nigdy by się nie pokazała
		queue_redraw()
		return

	_record_player_position()
	_time_since_hit += delta
	_check_body_contact()

	if _knockback_velocity.length() > 1.0:
		# Odepchnięcie od bloku gracza chwilowo zastępuje dryfowanie/wypad —
		# inaczej boss natychmiast "odklejałby się" z powrotem w tej samej klatce.
		global_position = _clamp_to_arena(global_position + _knockback_velocity * delta)
		_knockback_velocity = _knockback_velocity.move_toward(Vector2.ZERO, knockback_friction * delta)
	elif _lunge_state != "":
		_process_lunge(delta)
	elif not _invulnerable:
		_drift_towards_player(delta)
		_handle_hunger_regen(delta)
		_attack_timer -= delta
		if _attack_timer <= 0.0:
			_attack_timer = final_attack_interval if is_final_phase else attack_interval
			_pick_and_launch_attack()

	if _flash_frames > 0:
		_flash_frames -= 1
	if _cast_pose_timer > 0.0:
		_cast_pose_timer -= delta
	if _rebirth_pose_timer > 0.0:
		_rebirth_pose_timer -= delta

	lunge_warning.visible = _lunge_state == "telegraph"
	if _lunge_state == "telegraph":
		lunge_warning.rotation = (_lunge_target - global_position).angle() + PI * 0.5

	_update_sprite_state()
	queue_redraw()

## Kontakt z ciałem bossa zawsze rani (na życzenie autora) i odpycha gracza —
## throttlowane samo przez nietykalność gracza po trafieniu, tak jak pieczęcie/cień.
func _check_body_contact() -> void:
	if player == null or player.is_invulnerable():
		return
	var to_player: Vector2 = player.global_position - global_position
	if to_player.length() > radius + player.radius:
		return
	var damage := lunge_damage if _lunge_state == "active" else body_contact_damage
	player.take_damage(damage)
	var dir := to_player.normalized() if to_player.length() > 0.01 else Vector2.RIGHT
	player.apply_knockback(dir * knockback_strength)
	_play_sfx(SND_BODY_CONTACT)

## Wywoływane z zewnątrz (blok gracza pod PPM) — odpycha bossa na chwilę.
func apply_knockback(impulse: Vector2) -> void:
	_knockback_velocity = impulse

func _process_lunge(delta: float) -> void:
	_lunge_timer -= delta
	if _lunge_state == "telegraph":
		if _lunge_timer <= 0.0:
			_lunge_state = "active"
			_lunge_timer = lunge_duration
			var to_target: Vector2 = _lunge_target - global_position
			_lunge_direction = to_target.normalized() if to_target.length() > 0.01 else Vector2.RIGHT
			_play_sfx(SND_LUNGE_CHARGE)
	else: # "active"
		global_position = _clamp_to_arena(global_position + _lunge_direction * lunge_speed * delta)
		if _lunge_timer <= 0.0:
			# Losowo od razu drugi wypad (na życzenie autora) — najwyżej raz,
			# żeby to nie potrafiło się zapętlić w nieskończoność.
			if not _lunge_did_double and randf() < lunge_double_chance and player != null:
				_lunge_did_double = true
				_lunge_state = "telegraph"
				_lunge_timer = lunge_telegraph
				_lunge_target = player.global_position
				_play_sfx(SND_LUNGE_TELEGRAPH)
			else:
				_lunge_state = ""

func _clamp_to_arena(pos: Vector2) -> Vector2:
	var r := arena_rect
	return Vector2(
		clamp(pos.x, r.position.x + radius, r.position.x + r.size.x - radius),
		clamp(pos.y, r.position.y + radius, r.position.y + r.size.y - radius)
	)

func _record_player_position() -> void:
	_position_history[_history_write_index] = player.global_position
	_history_write_index = (_history_write_index + 1) % _position_history.size()

## Zwraca chronologiczną (od najstarszej do najnowszej) próbkę ostatnich
## `delay_seconds` sekund ruchu gracza, do odtworzenia przez cień (shadow.gd).
func _get_history_snapshot(delay_seconds: float) -> PackedVector2Array:
	var size := _position_history.size()
	var frames: int = clamp(int(delay_seconds * Engine.physics_ticks_per_second), 1, size)
	var start_idx: int = ((_history_write_index - frames) % size + size) % size
	var snapshot := PackedVector2Array()
	snapshot.resize(frames)
	for i in range(frames):
		snapshot[i] = _position_history[(start_idx + i) % size]
	return snapshot

func _drift_towards_player(delta: float) -> void:
	var to_player: Vector2 = player.global_position - global_position
	if to_player.length() > 1.0:
		global_position += to_player.normalized() * boss_drift_speed * delta

func _handle_hunger_regen(delta: float) -> void:
	# Głód (faza 5+) — modyfikatory się kumulują, więc to działa też w Zaćmieniu i finale.
	if phase_index < 4:
		return
	if _time_since_hit >= hunger_regen_delay and health < max_health:
		health = min(max_health, health + hunger_regen_rate * delta)

func _pick_and_launch_attack() -> void:
	var options := ["seal", "void", "shadow", "lunge"]
	# Losuj, dopóki nie trafisz na inny atak niż ostatnio (max 4 ataki, więc szybko się skończy).
	var choice: String = options[randi() % options.size()]
	if options.size() > 1:
		while choice == _last_attack_name:
			choice = options[randi() % options.size()]
	_last_attack_name = choice
	match choice:
		"seal":
			_launch_seal_attack()
		"void":
			_launch_void_attack()
		"shadow":
			_launch_shadow_attack()
		"lunge":
			_launch_lunge_attack()

## Atak fizyczny "Wypad" — gwałtowny ruch w stronę pozycji gracza z chwili zapowiedzi
## (nie namierza na bieżąco, żeby dało się go uniknąć wyjściem z linii ataku).
func _launch_lunge_attack() -> void:
	_lunge_did_double = false
	_lunge_state = "telegraph"
	_lunge_timer = lunge_telegraph
	_lunge_target = player.global_position
	_play_sfx(SND_LUNGE_TELEGRAPH)

func _set_cast_pose(tex: Texture2D) -> void:
	_cast_pose_texture = tex
	_cast_pose_timer = cast_pose_duration
	_play_sfx(SND_ATTACK_INHALE)

func _launch_seal_attack() -> void:
	_set_cast_pose(TEX_CAST_PULSE)
	# Instancjonujemy jedną pieczęć wcześniej tylko po to, żeby odczytać jej promień
	# (własność seal.gd) i użyć go jako marginesu od ścian — inaczej duże promienie
	# mogłyby wizualnie wychodzić poza granicę areny.
	var probe = SealScene.instantiate()
	var margin: float = probe.seal_radius
	probe.free()

	var points: Array = []
	var attempts := 0
	while points.size() < seal_count and attempts < 500:
		attempts += 1
		var p := _random_arena_point(margin)
		var ok := true
		for existing in points:
			if p.distance_to(existing) < seal_min_distance:
				ok = false
				break
		if ok:
			points.append(p)
	for i in range(points.size()):
		var seal = SealScene.instantiate()
		# Właściwości MUSZĄ być ustawione przed add_child(): _ready() odpala się
		# natychmiast po wejściu do drzewa, więc ustawienia "po" przyszłyby za późno.
		seal.player = player
		seal.stagger_delay = i * seal_interval # wybuchają po kolei, w kolejności pojawienia się
		seal.global_position = points[i]
		get_parent().add_child(seal)

func _launch_void_attack() -> void:
	_set_cast_pose(TEX_CAST_PULSE)
	var zone = VoidZoneScene.instantiate()
	zone.player = player
	zone.boss = self
	zone.global_position = _random_arena_point(zone.void_radius)
	get_parent().add_child(zone)

func _launch_shadow_attack() -> void:
	_set_cast_pose(TEX_PULL)
	_spawn_shadow(shadow_delay)
	# "Od fazy 4 mogą istnieć dwa cienie naraz" (sekcja 5) — w tabeli sekcji 7 to Ciężar
	# (phase_index == 3, licząc od 0). Drugi cień to echo bliższe teraźniejszości,
	# żeby oba ślady różniły się od siebie, a nie nakładały idealnie na siebie.
	if phase_index >= 3:
		_spawn_shadow(shadow_delay * 0.5)

func _spawn_shadow(delay_seconds: float) -> void:
	var shadow = ShadowScene.instantiate()
	shadow.player = player
	shadow.trace = _get_history_snapshot(delay_seconds)
	if shadow.trace.size() > 0:
		shadow.global_position = shadow.trace[0]
	get_parent().add_child(shadow)

func _random_arena_point(margin: float) -> Vector2:
	var r: Rect2 = arena_rect
	return Vector2(
		randf_range(r.position.x + margin, r.position.x + r.size.x - margin),
		randf_range(r.position.y + margin, r.position.y + r.size.y - margin)
	)

func take_damage(amount: float) -> void:
	if is_dead or _invulnerable:
		return
	health -= amount
	_time_since_hit = 0.0
	if health > 0.0:
		_play_sfx(SND_HURT)
		return

	health = 0.0
	var last_phase_index := Palette.PHASE_COLORS.size() - 1 # 5 = Zaćmienie
	if is_final_phase or phase_index >= last_phase_index:
		# Zaćmienie (albo już mała forma z finału) doszło do zera — to prawdziwy koniec
		# tej formy, nie kolejna przemiana. Sekcja 8 przejmuje dalej przez sygnał `died`.
		is_dead = true
		_play_sfx(SND_TRANSFORM_ROAR if is_final_phase else SND_BIGFORM_COLLAPSE)
		died.emit(is_final_phase)
	else:
		# Każda z 6 faz ma pełne, osobne życie do zdjęcia (na życzenie autora) —
		# dopiero gdy TO życie spadnie do zera, zmienia się kolor i jest kolejna faza.
		_enter_phase(phase_index + 1)

func _enter_phase(new_index: int) -> void:
	phase_index = new_index
	health = phase_max_health
	max_health = phase_max_health
	current_color = Palette.PHASE_COLORS[phase_index]
	phase_changed.emit(phase_index, current_color, Palette.PHASE_NAMES[phase_index])
	_start_transform_invulnerability()

func _start_transform_invulnerability() -> void:
	_invulnerable = true
	Juice.screen_shake()
	_play_sfx(SND_TRANSFORM_ROAR)
	await get_tree().create_timer(phase_transform_invuln).timeout
	_invulnerable = false

## Wywoływane przez arenę, żeby boss nie zaatakował, zanim nie zniknie pytanie finałowe.
func delay_next_attack(seconds: float) -> void:
	_attack_timer = max(_attack_timer, seconds)

func flash_white() -> void:
	_flash_frames = 2

## Wywoływane przez arenę po ekranie "ciało się rozpada" — boss wraca jako mała forma.
func start_final_phase() -> void:
	is_dead = false
	is_final_phase = true
	radius = final_radius
	health = final_health
	max_health = final_health
	current_color = Palette.PHASE_COLORS[5] # Zaćmienie — ta sama forma, ciąg dalszy
	_attack_timer = final_attack_interval
	sprite.scale = Vector2(final_sprite_scale, final_sprite_scale)
	_rebirth_pose_timer = rebirth_pose_duration
	_play_sfx(SND_SMALLFORM_RESURRECT)

## Wywoływane przez arenę na czas pytania finałowego (ui.show_taunt) — mała forma
## przybiera pozę "taunt" zamiast normalnego idle, dopóki drwina wisi na ekranie.
func show_taunt_pose(duration: float) -> void:
	_taunt_pose_active = true
	get_tree().create_timer(duration).timeout.connect(func(): _taunt_pose_active = false)

func _play_sfx(stream: AudioStream) -> void:
	sfx.stream = stream
	sfx.play()

## Zastępuje dawny draw_circle(color)+draw_line — wybiera teksturę wg priorytetu
## stanu, tak jak _update_sprite_state() w incarnation.gd. "Prawdziwa śmierć" i
## "kolaps dużej formy" mają najwyższy priorytet i muszą działać także gdy
## is_dead=true, stąd wywołanie także z _physics_process w ścieżce is_dead.
func _update_sprite_state() -> void:
	var tex: Texture2D
	if is_dead:
		tex = TEX_SMALL_FORM_TRUE_DEATH if is_final_phase else TEX_LARGE_FORM_COLLAPSE
	elif _rebirth_pose_timer > 0.0:
		tex = TEX_SMALL_FORM_REBIRTH
	elif _taunt_pose_active:
		tex = TEX_SMALL_FORM_TAUNT
	elif _invulnerable:
		tex = TEX_PHASE_TRANSFORM
	elif _flash_frames > 0:
		tex = TEX_HIT
	elif _cast_pose_timer > 0.0:
		tex = _cast_pose_texture
	elif _lunge_state == "telegraph":
		tex = TEX_TELEGRAPH
	elif _lunge_state == "active":
		tex = TEX_LUNGE
	else:
		tex = PHASE_BASE_TEXTURES[phase_index]
	if tex != null:
		sprite.texture = tex

func _draw() -> void:
	# Kontakt z ciałem zawsze rani (dodane na życzenie autora) — stały żółty kontur
	# to zapowiedź obowiązująca bez przerwy, żeby nie złamać zasady "żadne trafienie
	# bez zapowiedzi" (sekcja 4), skoro to zagrożenie nie ma osobnej fazy "przed".
	if not is_dead:
		var ring_width := 5.0 if _lunge_state == "telegraph" else 3.0
		draw_arc(Vector2.ZERO, radius + 4.0, 0.0, TAU, 32, Color(Palette.DANGER, 0.9), ring_width)
