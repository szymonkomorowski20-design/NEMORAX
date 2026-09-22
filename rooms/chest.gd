extends Node2D
class_name Chest
## Skrzynia z ulepszeniem (CLAUDE_CODE_GAME_CONTENT_BIBLE.md sekcja 9) — pojawia
## się w 5 z 24 pokoi RANDOM (wybranych raz przy generacji mapy, patrz
## GameFlow._assign_chest_rooms()), dopiero PO oczyszczeniu pokoju. Otwiera się
## tym samym klawiszem F co podnoszenie duszy (rooms/soul.gd) — ta sama
## konwencja interakcji, nie nowy bind.

signal opened(upgrade_id: String)

const TEX_CLOSED := preload("res://assets/sprites/pokoje/obiekty/chest/chest_closed.png")
const TEX_OPEN := preload("res://assets/sprites/pokoje/obiekty/chest/chest_open.png")
const SND_OPEN := [
	preload("res://assets/audio/sfx/p0/WORLD_CHEST_OPEN_1.wav"),
	preload("res://assets/audio/sfx/p0/WORLD_CHEST_OPEN_2.wav"),
] # dedykowany dźwięk z paczki P0 (wrzesień 2026), zastępuje dawny reużyty W03_soul_pickup
const BASE_SPRITE_SCALE := 0.075 # analogicznie do Soul.BASE_SPRITE_SCALE, dopasowane do źródła 1024px
const OPEN_LINGER_SECONDS := 0.6 # jak długo widać chest_open.png przed zniknięciem skrzyni

@export var pickup_range: float = 45.0
@export var hint_font_size: int = 16
@export var pulse_speed: float = 2.0
@export var pulse_strength: float = 0.08

@onready var sprite: Sprite2D = $Sprite

var player: Player = null
var _opened: bool = false

func _ready() -> void:
	sprite.texture = TEX_CLOSED
	# Skala ustawiana też tutaj, nie tylko w _physics_process() poniżej — inaczej
	# skrzynia renderuje się w natywnej rozdzielczości tekstury (1024px) przez
	# każdą klatkę, zanim/jeśli `player` zostanie ustawiony (ten setter gates
	# całe _physics_process, patrz niżej).
	sprite.scale = Vector2(BASE_SPRITE_SCALE, BASE_SPRITE_SCALE)
	var contact_shadow := ContactShadow.new()
	contact_shadow.position = Vector2(0.0, 20.0)
	contact_shadow.configure(48.0, 12.0, 0.44) # wyraźniejszy (KIERUNEK_WIZUALNY_REFERENCJE.md)
	add_child(contact_shadow)

	# Mały, fizyczny blask przypisany do samej skrzyni (nie wielka plama światła
	# w pokoju) — pasuje do złotych pęknięć na chest_closed.png/chest_open.png.
	var glow := PointLight2D.new()
	glow.texture = _make_glow_texture()
	glow.color = Color("#E8933D")
	glow.energy = 0.9
	glow.texture_scale = 0.85
	glow.position = Vector2(0.0, -4.0)
	add_child(glow)

func _make_glow_texture() -> GradientTexture2D:
	var gradient := Gradient.new()
	gradient.set_color(0, Color(1, 1, 1, 1))
	gradient.set_color(1, Color(1, 1, 1, 0))
	var tex := GradientTexture2D.new()
	tex.gradient = gradient
	tex.width = 128
	tex.height = 128
	tex.fill = GradientTexture2D.FILL_RADIAL
	tex.fill_from = Vector2(0.5, 0.5)
	tex.fill_to = Vector2(1.0, 0.5)
	return tex

func _physics_process(_delta: float) -> void:
	if _opened or player == null:
		return
	var pulse := 1.0 + pulse_strength * sin(Time.get_ticks_msec() / 1000.0 * pulse_speed)
	sprite.scale = Vector2(BASE_SPRITE_SCALE, BASE_SPRITE_SCALE) * pulse
	queue_redraw()
	if global_position.distance_to(player.global_position) > pickup_range:
		return
	if Input.is_action_just_pressed("pickup"):
		_open()

## Losuje jedno z ulepszeń, których gracz JESZCZE nie ma (wszystkie 10 jest
## nie-stackowalnych, dokument sekcja 8/9) — pusta pula (wszystkie 10 już
## zdobyte) nic nie robi zamiast się wysypać, choć przy 5 skrzyniach/przebieg
## nigdy nie powinno się to zdarzyć.
func _open() -> void:
	var eligible: Array[String] = []
	for id in Player.UPGRADE_IDS:
		if not player.has_upgrade(id):
			eligible.append(id)
	if eligible.is_empty():
		return
	var chosen: String = eligible[randi() % eligible.size()]
	player.acquire_upgrade(chosen)
	_opened = true
	sprite.texture = TEX_OPEN
	sprite.scale = Vector2(BASE_SPRITE_SCALE, BASE_SPRITE_SCALE)
	queue_redraw()
	Juice.play_sfx_at(SND_OPEN[randi() % SND_OPEN.size()], global_position)
	opened.emit(chosen)
	# Opóźnione zniknięcie (nie w teście headless bez tickującej pętli klatek,
	# patrz established quirk) — żeby gracz zdążył zobaczyć chest_open.png
	# zamiast skrzyni znikającej w tej samej klatce, w której się otworzyła.
	get_tree().create_timer(OPEN_LINGER_SECONDS).timeout.connect(queue_free)

func _draw() -> void:
	if _opened:
		return
	if player and global_position.distance_to(player.global_position) <= pickup_range:
		var font := ThemeDB.fallback_font
		var text := "[F]"
		var text_size := font.get_string_size(text, HORIZONTAL_ALIGNMENT_CENTER, -1, hint_font_size)
		draw_string(font, Vector2(-text_size.x * 0.5, -55.0), text,
			HORIZONTAL_ALIGNMENT_LEFT, -1, hint_font_size, Palette.HIT_FLASH)
