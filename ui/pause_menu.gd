extends Control
class_name PauseMenu
## Menu pauzy w trakcie gry (room.tscn/arena.tscn) — Escape pauzuje/wznawia,
## K w trakcie pauzy otwiera ten sam ekran rebindingu co w menu głównym
## (ui/keybind_screen.gd). process_mode ALWAYS na całym poddrzewie (ustawiane
## tu i dziedziczone przez KeybindScreen), żeby działało mimo
## get_tree().paused = true — bez tego cała gałąź zamarłaby razem z resztą gry.

@onready var keybind_screen: KeybindScreen = $KeybindScreen

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false

func _process(_delta: float) -> void:
	if visible:
		queue_redraw()

## Wywoływane z zewnątrz (room.gd/arena.gd) po naciśnięciu Escape. Gdy akurat
## otwarty jest ekran rebindingu, pierwsze Escape cofa do samej pauzy zamiast
## od razu wznawiać rozgrywkę — obsługiwane przez KeybindScreen samo, tutaj
## tylko pilnujemy, żeby w tym stanie nie przełączyć też pauzy naraz.
func toggle() -> void:
	if keybind_screen.visible:
		return
	visible = not visible
	get_tree().paused = visible
	queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	if not visible or keybind_screen.visible:
		return
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_cancel"):
		toggle() # Enter LUB Escape na pauzie = wznów
	elif event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_K:
		keybind_screen.open()

func _draw() -> void:
	if not visible:
		return
	var size := get_viewport_rect().size
	draw_rect(Rect2(Vector2.ZERO, size), Color(Palette.BACKGROUND, 0.75), true)
	var font := ThemeDB.fallback_font

	var title := "PAUZA"
	var title_size := font.get_string_size(title, HORIZONTAL_ALIGNMENT_CENTER, -1, 32)
	draw_string(font, Vector2((size.x - title_size.x) * 0.5, size.y * 0.4), title,
		HORIZONTAL_ALIGNMENT_LEFT, -1, 32, Palette.PLAYER_BODY)

	var hint := "Escape / Enter — wznów        K — zmień klawisze"
	var hint_size := font.get_string_size(hint, HORIZONTAL_ALIGNMENT_CENTER, -1, 20)
	draw_string(font, Vector2((size.x - hint_size.x) * 0.5, size.y * 0.5), hint,
		HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color.WHITE)
