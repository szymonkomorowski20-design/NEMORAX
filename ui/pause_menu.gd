extends Control
class_name PauseMenu
## Menu pauzy w trakcie gry (room.tscn/arena.tscn) — Escape pauzuje/wznawia.
## process_mode ALWAYS na całym poddrzewie (ustawiane tu i dziedziczone przez
## KeybindScreen/OptionsScreen), żeby działało mimo get_tree().paused = true —
## bez tego cała gałąź zamarłaby razem z resztą gry.
##
## Krok 9 (polish ekranów): "trzy opcje: kontynuuj, opcje, wyjdź do menu — ten
## sam materiał, font i animacja co menu główne". Dawniej to był statyczny
## tytuł + jedna linijka podpowiedzi z czterema literowymi skrótami (K/O/M),
## rysowane ThemeDB.fallback_font-em. Teraz nawigowalna lista trzech pozycji w
## Cinzel/EBGaramond ze złotym zaznaczeniem (SELECTED_COLOR, ten sam odcień co
## menu.gd/options_screen.gd) i krótkim fade-inem przy otwarciu (dokument:
## "wejścia/wyjścia UI przez krótkie Tweeny"). "K" (klawisze) nie ma już
## własnego skrótu — mieszka w Opcje → Sterowanie, jak w menu głównym.

const FONT_TITLE := preload("res://assets/fonts/Cinzel-SemiBold.woff")
const FONT_BODY := preload("res://assets/fonts/EBGaramond-Regular.woff")
const IDLE_COLOR := Color("#B0A8BC")
const SELECTED_COLOR := Color("#E8C547")
const HINT_COLOR := Color("#8A7FA0")
const MENU_ITEMS: Array[String] = ["Kontynuuj", "Opcje", "Wyjdź do menu"]
const ITEM_FONT_SIZE := 26
const ITEM_LINE_HEIGHT := 44.0
const FADE_IN_TIME := 0.18 ## dokument: "krótkie Tweeny", ten sam rząd wielkości co HOVER_TWEEN_TIME w menu.gd

@onready var keybind_screen: KeybindScreen = $KeybindScreen
@onready var options_screen: OptionsScreen = $OptionsScreen

var _selected_index: int = 0
var _item_rects: Array[Rect2] = []
var _fade_tween: Tween

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false

func _process(_delta: float) -> void:
	if visible:
		queue_redraw()

## Wywoływane z zewnątrz (room.gd/arena.gd) po naciśnięciu Escape. Gdy akurat
## otwarty jest ekran rebindingu/opcji, pierwsze Escape cofa do samej pauzy
## zamiast od razu wznawiać rozgrywkę — obsługiwane przez te ekrany same,
## tutaj tylko pilnujemy, żeby w tym stanie nie przełączyć też pauzy naraz.
func toggle() -> void:
	if keybind_screen.visible or options_screen.visible:
		return
	visible = not visible
	get_tree().paused = visible
	if visible:
		_selected_index = 0
		modulate.a = 0.0
		if _fade_tween != null and _fade_tween.is_valid():
			_fade_tween.kill()
		_fade_tween = create_tween()
		_fade_tween.tween_property(self, "modulate:a", 1.0, FADE_IN_TIME).set_ease(Tween.EASE_OUT)
	queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	if not visible or keybind_screen.visible or options_screen.visible:
		return
	if event is InputEventMouseMotion:
		_update_hover(event.position)
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_handle_click(event.position)
	elif event.is_action_pressed("ui_down"):
		_selected_index = (_selected_index + 1) % MENU_ITEMS.size()
		Juice.play_ui_sfx_variant(Juice.SND_UI_NAVIGATE)
	elif event.is_action_pressed("ui_up"):
		_selected_index = (_selected_index - 1 + MENU_ITEMS.size()) % MENU_ITEMS.size()
		Juice.play_ui_sfx_variant(Juice.SND_UI_NAVIGATE)
	elif event.is_action_pressed("ui_accept"):
		Juice.play_ui_sfx_variant(Juice.SND_UI_CONFIRM)
		_activate_selected()
	elif event.is_action_pressed("ui_cancel"):
		Juice.play_ui_sfx_variant(Juice.SND_UI_BACK)
		toggle() # Escape na pauzie = wznów, tak jak wybranie "Kontynuuj"

func _update_hover(mouse_pos: Vector2) -> void:
	for i in range(_item_rects.size()):
		if _item_rects[i].has_point(mouse_pos):
			if i != _selected_index:
				_selected_index = i
				Juice.play_ui_sfx_variant(Juice.SND_UI_NAVIGATE)
			return

func _handle_click(mouse_pos: Vector2) -> void:
	for i in range(_item_rects.size()):
		if _item_rects[i].has_point(mouse_pos):
			_selected_index = i
			_activate_selected()
			return

func _activate_selected() -> void:
	match _selected_index:
		0:
			toggle() # Kontynuuj
		1:
			options_screen.open()
		2:
			_exit_to_main_menu()

## Porzuca bieżący przebieg (jak przegrana z Nemoraxem — GameFlow.reset_run())
## i wraca do ekranu tytułowego, zamiast po prostu zamykać grę. Bez tego nie
## było ŻADNEGO sposobu, żeby wyjść z aktywnej rozgrywki poza zabiciem procesu.
func _exit_to_main_menu() -> void:
	GameFlow.reset_run()
	# Scena menu nie ma process_mode ALWAYS — zostawienie drzewa spauzowanego
	# zamroziłoby ją od razu po wczytaniu (żaden _process/_unhandled_input).
	get_tree().paused = false
	get_tree().change_scene_to_file("res://menu.tscn")

func _draw() -> void:
	if not visible:
		return
	var viewport_size := get_viewport_rect().size
	draw_rect(Rect2(Vector2.ZERO, viewport_size), Color(Palette.BACKGROUND, 0.75), true)

	var title := "Pauza"
	var title_size := FONT_TITLE.get_string_size(title, HORIZONTAL_ALIGNMENT_CENTER, -1, 32)
	draw_string(FONT_TITLE, Vector2((viewport_size.x - title_size.x) * 0.5, viewport_size.y * 0.36), title,
		HORIZONTAL_ALIGNMENT_LEFT, -1, 32, SELECTED_COLOR)

	_item_rects.resize(MENU_ITEMS.size())
	var start_y := viewport_size.y * 0.48
	for i in range(MENU_ITEMS.size()):
		var is_selected := i == _selected_index
		var color := SELECTED_COLOR if is_selected else IDLE_COLOR
		var text := ("◈ %s ◈" % MENU_ITEMS[i]) if is_selected else MENU_ITEMS[i]
		var line_size := FONT_TITLE.get_string_size(text, HORIZONTAL_ALIGNMENT_CENTER, -1, ITEM_FONT_SIZE)
		var baseline := Vector2((viewport_size.x - line_size.x) * 0.5, start_y + i * ITEM_LINE_HEIGHT)
		_item_rects[i] = Rect2(baseline.x - 20.0, baseline.y - line_size.y - 4.0, line_size.x + 40.0, line_size.y + 12.0)
		draw_string(FONT_TITLE, baseline, text, HORIZONTAL_ALIGNMENT_LEFT, -1, ITEM_FONT_SIZE, color)

	var hint := "Strzałki: wybór — Enter: zatwierdź — Escape: wznów"
	var hint_size := FONT_BODY.get_string_size(hint, HORIZONTAL_ALIGNMENT_CENTER, -1, 18)
	draw_string(FONT_BODY, Vector2((viewport_size.x - hint_size.x) * 0.5, viewport_size.y * 0.92), hint,
		HORIZONTAL_ALIGNMENT_LEFT, -1, 18, HINT_COLOR)
