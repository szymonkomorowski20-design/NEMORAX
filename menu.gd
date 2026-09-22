extends Control
## Ekran startowy — rozszerzenie poza dokument bazowy. NIE resetuje GameFlow —
## postęp gauntletu jest zapisywany na dysk (patrz game_flow.gd), więc menu
## musi wznowić dokładnie tam, gdzie gracz skończył, zamiast czyścić postęp
## przy każdym uruchomieniu.
##
## PLAN_MENU_GLOWNE_DLA_CLAUDE.md, kroki 1-4: przepisane z ręcznie rysowanego
## Node2D (_draw() na cały tekst + prostokąty liczone na sztywno pod viewport)
## na Control z prawdziwymi węzłami Label i zakotwiczeniem procentowym —
## responsywne bez przeliczania pikseli pod jeden ekran, i pozwala na tweeny
## per-pozycja zamiast zmiany stanu w _process().

enum State { INTRO, IDLE, OPTIONS_OPEN, TRANSITIONING, EXITING }

const TEX_BACKGROUND := preload("res://assets/sprites/menu/menu_background.png")
const TEX_LOGO := preload("res://assets/sprites/menu/nemorax_logo.png")
const LOGO_SIZE := Vector2(480.0, 320.0) ## zachowuje proporcje źródłowego pliku 1536x1024
const FONT_ITEM := preload("res://assets/fonts/Cinzel-SemiBold.woff")
const FONT_HINT := preload("res://assets/fonts/EBGaramond-Regular.woff")

const MENU_ITEMS: Array[String] = ["Graj", "Opcje", "Wyjście"]
## Jasnoszary, NIE czysta biel (dokument, sekcja 4) — i wyraźnie inny niż
## poprzedni Palette.HIT_FLASH (#FFFFFF, identyczny z Color.WHITE — to był
## prawdziwy bug: podświetlenie było niewidoczne, bo miało ten sam kolor co tło).
const IDLE_COLOR := Color("#B0A8BC")
const SELECTED_COLOR := Color("#E8C547") ## przygaszone złoto
const ITEM_FONT_SIZE := 26
const ITEM_LINE_HEIGHT := 42.0
const SELECT_SHIFT_X := 8.0 ## px, dokument: 6-10
const ORNAMENT_GAP := 22.0 ## odstęp znaczka ◈ od tekstu
const HOVER_TWEEN_TIME := 0.15 ## dokument: 0.12-0.18s
const CLICK_PUNCH_TIME := 0.09 ## dokument: 0.08-0.12s
const TRANSITION_FADE_TIME := 0.4 ## dokument: 0.35-0.6s
const ITEMS_FADE_TIME := 0.2 ## dokument: "wejście elementu 0,25-0,4s" — trochę krócej, bo to zniknięcie/powrót, nie pierwsze wejście

@onready var background: TextureRect = $Background
@onready var logo: TextureRect = $Logo
@onready var items_container: Control = $MenuItemsContainer
@onready var hint_label: Label = $HintLabel
@onready var fade_rect: ColorRect = $FadeRect
@onready var keybind_screen: KeybindScreen = $KeybindScreen
@onready var options_screen: OptionsScreen = $OptionsScreen

var _state: State = State.INTRO
var _selected_index: int = 0
var _item_labels: Array[Label] = []
var _item_base_x: Array[float] = []
var _item_tweens: Array[Tween] = []
## Krok 12 (menu, EXITING): "pojedyncze potwierdzenie wyjścia; żadnego
## przypadkowego zamknięcia gry przez Esc". Dawniej Escape/"Wyjście" w IDLE
## zamykały grę NATYCHMIAST, bez pytania — jedno omyłkowe Escape (np. próba
## cofnięcia się z czegoś innego) kończyło sesję bez ostrzeżenia.
var _exit_confirm_pending: bool = false
const HINT_TEXT_DEFAULT := "↑↓ wybór   Enter zatwierdź"
const HINT_TEXT_CONFIRM_EXIT := "Na pewno wyjść?   Enter — tak    Escape — nie"

func _ready() -> void:
	var vp_size := get_viewport_rect().size

	background.texture = TEX_BACKGROUND
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_SCALE
	background.position = Vector2.ZERO
	background.size = vp_size
	background.z_index = -1

	logo.texture = TEX_LOGO
	logo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	logo.stretch_mode = TextureRect.STRETCH_SCALE
	logo.size = LOGO_SIZE
	logo.position = Vector2((vp_size.x - LOGO_SIZE.x) * 0.5, vp_size.y * 0.28)
	logo.z_index = -1
	logo.pivot_offset = LOGO_SIZE * 0.5

	hint_label.add_theme_font_override("font", FONT_HINT)
	hint_label.add_theme_font_size_override("font_size", 15)
	hint_label.add_theme_color_override("font_color", Color(IDLE_COLOR, 0.55))
	hint_label.text = HINT_TEXT_DEFAULT
	hint_label.position = Vector2(0.0, vp_size.y * 0.92)
	hint_label.size = Vector2(vp_size.x, 24.0)
	hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	_build_menu_items(vp_size)
	_play_intro()

func _build_menu_items(vp_size: Vector2) -> void:
	var start_y := vp_size.y * 0.61
	for i in range(MENU_ITEMS.size()):
		var label := Label.new()
		label.text = MENU_ITEMS[i]
		label.add_theme_font_override("font", FONT_ITEM)
		label.add_theme_font_size_override("font_size", ITEM_FONT_SIZE)
		label.add_theme_constant_override("outline_size", 0)
		label.modulate = IDLE_COLOR
		items_container.add_child(label)
		var label_width: float = label.get_minimum_size().x
		var base_x := (vp_size.x - label_width) * 0.5
		label.position = Vector2(base_x, start_y + i * ITEM_LINE_HEIGHT)
		_item_labels.append(label)
		_item_base_x.append(base_x)
		_item_tweens.append(null)
	_update_selection_visuals(true)

## Faza INTRO (dokument, "Ruch i brak cięć"): tło widoczne od razu, logo robi
## krótki fade+scale 96%->100%, dopiero potem wchodzą pozycje menu — zamiast
## wszystkiego na raz w jednej klatce.
func _play_intro() -> void:
	logo.modulate.a = 0.0
	logo.scale = Vector2(0.96, 0.96)
	for label in _item_labels:
		label.modulate.a = 0.0

	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(logo, "modulate:a", 1.0, 0.7).set_ease(Tween.EASE_OUT)
	tw.tween_property(logo, "scale", Vector2.ONE, 0.7).set_ease(Tween.EASE_OUT)
	tw.chain().set_parallel(true)
	for i in range(_item_labels.size()):
		var label := _item_labels[i]
		tw.tween_property(label, "modulate:a", 1.0, 0.3).set_ease(Tween.EASE_OUT).set_delay(i * 0.06)
	tw.chain().tween_callback(func():
		_state = State.IDLE
		_start_ambient_motion()
	)

## Krok 12 (tło, dokument): "parallax: 6-16px w ciągu 10-18s, z płynnym
## powrotem... bardzo delikatny oddech jasności logo co 6-10s, maks. ±5%".
## Dawniej tło/logo stały nieruchomo po INTRO — jedyny ruch w całym menu był w
## reakcji na wejście gracza (hover/klik), nic samoistnego w tle. Nieskończone
## pętle (LOOPS_INFINITE) na osobnych tweenach od hover/klik/przejścia, więc
## nie kolidują z _item_tweens ani z fade_rect.
func _start_ambient_motion() -> void:
	var bg_start_x := background.position.x
	var bg_drift := create_tween()
	bg_drift.set_loops()
	bg_drift.tween_property(background, "position:x", bg_start_x - 6.0, 7.0).set_ease(Tween.EASE_IN_OUT)
	bg_drift.tween_property(background, "position:x", bg_start_x + 6.0, 14.0).set_ease(Tween.EASE_IN_OUT)
	bg_drift.tween_property(background, "position:x", bg_start_x, 7.0).set_ease(Tween.EASE_IN_OUT)

	var logo_breathe := create_tween()
	logo_breathe.set_loops()
	logo_breathe.tween_property(logo, "modulate", Color(1.05, 1.05, 1.05, 1.0), 4.0).set_ease(Tween.EASE_IN_OUT)
	logo_breathe.tween_property(logo, "modulate", Color(1.0, 1.0, 1.0, 1.0), 4.0).set_ease(Tween.EASE_IN_OUT)

func _process(_delta: float) -> void:
	if _state == State.OPTIONS_OPEN and not options_screen.visible:
		_state = State.IDLE # gracz wyszedł z opcji przez Esc — options_screen.gd sam to obsługuje
		var fade := create_tween()
		fade.tween_property(items_container, "modulate:a", 1.0, ITEMS_FADE_TIME).set_ease(Tween.EASE_OUT)
		queue_redraw() # diament/podkreślenie wracają razem z pozycjami menu

func _unhandled_input(event: InputEvent) -> void:
	if keybind_screen.visible:
		return
	if _state == State.OPTIONS_OPEN:
		if not options_screen.visible:
			_state = State.IDLE
		return
	if _state != State.IDLE:
		return # INTRO/TRANSITIONING/EXITING ignorują wejście (dokument: brak podwójnych aktywacji)

	if event is InputEventMouseMotion:
		_update_hover(event.position)
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_handle_click(event.position)
	elif event.is_action_pressed("ui_down"):
		_select_index((_selected_index + 1) % MENU_ITEMS.size())
	elif event.is_action_pressed("ui_up"):
		_select_index((_selected_index - 1 + MENU_ITEMS.size()) % MENU_ITEMS.size())
	elif event.is_action_pressed("ui_accept"):
		# Enter podczas "na pewno?" potwierdza wyjście NIEZALEŻNIE od tego, co
		# akurat jest zaznaczone (Escape, który zadał to pytanie, nie zmienia
		# _selected_index) — inaczej Enter aktywowałby zaznaczoną pozycję
		# zamiast odpowiadać na pytanie.
		if _exit_confirm_pending:
			_confirm_exit()
		else:
			_activate_selected()
	elif event.is_action_pressed("ui_cancel"):
		if _exit_confirm_pending:
			_cancel_exit_confirmation()
		else:
			_confirm_exit()
	elif event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_K:
		keybind_screen.open()

func _update_hover(mouse_pos: Vector2) -> void:
	for i in range(_item_labels.size()):
		if _item_labels[i].get_rect().has_point(mouse_pos):
			_select_index(i)
			return

func _handle_click(mouse_pos: Vector2) -> void:
	for i in range(_item_labels.size()):
		if _item_labels[i].get_rect().has_point(mouse_pos):
			_select_index(i)
			_activate_selected()
			return

func _select_index(index: int) -> void:
	if _exit_confirm_pending:
		_cancel_exit_confirmation() # zmiana wyboru w trakcie "na pewno?" po cichu anuluje pytanie
	if index == _selected_index:
		return
	_selected_index = index
	_update_selection_visuals(false)

## Stan zaznaczony (dokument, sekcja 4): kość/złoto zamiast bieli, przesunięcie
## 6-10px w prawo, znaczek ◈ po obu stronach — NIGDY pełnoekranowy pasek.
## Tween zamiast bezpośredniej zmiany w _process(); poprzedni tween tej samej
## pozycji jest zabijany, żeby szybkie zmiany wyboru się nie nakładały.
func _update_selection_visuals(instant: bool) -> void:
	for i in range(_item_labels.size()):
		var label := _item_labels[i]
		var is_selected := i == _selected_index
		var target_x: float = _item_base_x[i] + (SELECT_SHIFT_X if is_selected else 0.0)
		var target_color := SELECTED_COLOR if is_selected else IDLE_COLOR

		if _item_tweens[i] != null and _item_tweens[i].is_valid():
			_item_tweens[i].kill()

		if instant:
			label.position.x = target_x
			label.modulate = target_color
		else:
			var tw := create_tween()
			tw.set_parallel(true)
			tw.tween_property(label, "position:x", target_x, HOVER_TWEEN_TIME).set_ease(Tween.EASE_OUT)
			tw.tween_property(label, "modulate", target_color, HOVER_TWEEN_TIME).set_ease(Tween.EASE_OUT)
			_item_tweens[i] = tw
	queue_redraw() # ornament w _draw() śledzi pozycję zaznaczonej etykiety

## Mały znaczek ◈ po obu stronach zaznaczonej pozycji i cienkie podkreślenie
## pod samym tekstem (nie całą szerokością ekranu) — jedyne ręczne rysowanie,
## które zostaje: dokładny kształt diamentu nie zależy od tego, czy aktualna
## czcionka ma taki glif w swoim zestawie znaków.
func _draw() -> void:
	if _item_labels.is_empty() or _state != State.IDLE:
		return # OPTIONS_OPEN: pozycje menu są przygaszone/niewidoczne, diament/podkreślenie nie mają czego otaczać
	var label := _item_labels[_selected_index]
	var label_rect := label.get_rect()
	var mid_y := label_rect.position.y + label_rect.size.y * 0.5
	_draw_diamond(Vector2(label_rect.position.x - ORNAMENT_GAP, mid_y), SELECTED_COLOR)
	_draw_diamond(Vector2(label_rect.end.x + ORNAMENT_GAP, mid_y), SELECTED_COLOR)
	var underline_y := label_rect.end.y + 2.0
	draw_line(Vector2(label_rect.position.x, underline_y), Vector2(label_rect.end.x, underline_y), Color(SELECTED_COLOR, 0.65), 1.5)

func _draw_diamond(center: Vector2, color: Color) -> void:
	var r := 4.5
	var points := PackedVector2Array([
		center + Vector2(0.0, -r), center + Vector2(r, 0.0),
		center + Vector2(0.0, r), center + Vector2(-r, 0.0),
	])
	draw_colored_polygon(points, color)

func _activate_selected() -> void:
	match _selected_index:
		0:
			_transition_to_game()
		1:
			_open_options()
		2:
			_confirm_exit()

## Krok 12 (OPTIONS_OPEN, dokument): "główne pozycje miękko znikają, panel
## opcji wchodzi z dołu lub z prawej" — dawniej to był twardy cut (options_screen
## po prostu stawał się visible=true w tej samej klatce, bez żadnego przejścia).
func _open_options() -> void:
	_state = State.OPTIONS_OPEN
	var fade := create_tween()
	fade.tween_property(items_container, "modulate:a", 0.0, ITEMS_FADE_TIME).set_ease(Tween.EASE_IN)
	queue_redraw() # chowa diament/podkreślenie natychmiast, nie czeka na koniec tweena pozycji
	options_screen.open()

## Stan kliknięcia (dokument, sekcja 4): lekkie zmniejszenie, potem przejście;
## wejście blokowane na czas przejścia, żeby podwójny klik/Enter nie wystrzelił
## zmiany sceny dwa razy.
func _transition_to_game() -> void:
	_state = State.TRANSITIONING
	var label := _item_labels[_selected_index]
	var punch := create_tween()
	punch.tween_property(label, "scale", Vector2(0.92, 0.92), CLICK_PUNCH_TIME).set_ease(Tween.EASE_IN)
	punch.tween_property(label, "scale", Vector2.ONE, CLICK_PUNCH_TIME).set_ease(Tween.EASE_OUT)
	await punch.finished

	fade_rect.visible = true
	fade_rect.modulate.a = 0.0
	var fade := create_tween()
	fade.tween_property(fade_rect, "modulate:a", 1.0, TRANSITION_FADE_TIME).set_ease(Tween.EASE_IN)
	await fade.finished

	get_tree().change_scene_to_file(GameFlow.resume_scene_path())

## Krok 12: pierwsze wywołanie tylko PYTA (zmienia podpowiedź na dole, nic
## więcej) — dopiero DRUGIE wywołanie (Enter na "Wyjście"/Escape jeszcze raz,
## z _exit_confirm_pending już ustawionym) faktycznie zamyka grę.
func _confirm_exit() -> void:
	if _exit_confirm_pending:
		_state = State.EXITING
		get_tree().quit()
		return
	_exit_confirm_pending = true
	hint_label.text = HINT_TEXT_CONFIRM_EXIT

func _cancel_exit_confirmation() -> void:
	_exit_confirm_pending = false
	hint_label.text = HINT_TEXT_DEFAULT
