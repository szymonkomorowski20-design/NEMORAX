extends Node2D
class_name Chest
## Skrzynia z ulepszeniem (CLAUDE_CODE_GAME_CONTENT_BIBLE.md sekcja 9) — pojawia
## się w 5 z 24 pokoi RANDOM (wybranych raz przy generacji mapy, patrz
## GameFlow._assign_chest_rooms()), dopiero PO oczyszczeniu pokoju. Otwiera się
## tym samym klawiszem F co podnoszenie duszy (rooms/soul.gd) — ta sama
## konwencja interakcji, nie nowy bind. Brak dedykowanej grafiki skrzyni w
## katalogu assetów — rysowana kodem, jak pedestał ołtarza w rooms/altar.gd;
## TYMCZASOWE, do podmiany gdy powstanie właściwy sprite.

signal opened(upgrade_id: String)

const SND_OPEN := preload("res://assets/audio/sfx/swiat/W03_soul_pickup.wav") # TYMCZASOWE: reużyty dźwięk duszy, brak dedykowanego W02/W04 dla skrzyni
const CHEST_COLOR := Color("#C9962C") # złoto-brąz, celowo INNY niż Palette.DANGER (zarezerwowany wyłącznie dla obrażeń)
const CHEST_TRIM_COLOR := Color("#7A5A1E")

@export var pickup_range: float = 45.0
@export var chest_size: Vector2 = Vector2(48.0, 36.0)
@export var hint_font_size: int = 16
@export var pulse_speed: float = 2.0
@export var pulse_strength: float = 0.08

var player: Player = null
var _opened: bool = false

func _physics_process(_delta: float) -> void:
	if _opened or player == null:
		return
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
	Juice.play_sfx_at(SND_OPEN, global_position)
	opened.emit(chosen)
	queue_free()

func _draw() -> void:
	if _opened:
		return
	var pulse := 1.0 + pulse_strength * sin(Time.get_ticks_msec() / 1000.0 * pulse_speed)
	var half := chest_size * 0.5 * pulse
	draw_rect(Rect2(-half, half * 2.0), CHEST_COLOR, true)
	draw_rect(Rect2(-half, half * 2.0), CHEST_TRIM_COLOR, false, 3.0)
	if player and global_position.distance_to(player.global_position) <= pickup_range:
		var font := ThemeDB.fallback_font
		var text := "[F]"
		var text_size := font.get_string_size(text, HORIZONTAL_ALIGNMENT_CENTER, -1, hint_font_size)
		draw_string(font, Vector2(-text_size.x * 0.5, -half.y - 12.0), text,
			HORIZONTAL_ALIGNMENT_LEFT, -1, hint_font_size, Palette.HIT_FLASH)
