extends Node2D
## Ekran startowy — rozszerzenie poza dokument bazowy. NIE resetuje GameFlow —
## postęp gauntletu jest zapisywany na dysk (patrz game_flow.gd), więc menu
## musi wznowić dokładnie tam, gdzie gracz skończył, zamiast czyścić postęp
## przy każdym uruchomieniu.

const TEX_BACKGROUND := preload("res://assets/sprites/menu/menu_background.png")
const TEX_LOGO := preload("res://assets/sprites/menu/nemorax_logo.png")
const LOGO_SIZE := Vector2(480.0, 320.0) ## zachowuje proporcje źródłowego pliku 1536x1024

## Menu z prawdziwą, wybieralną listą (nie tylko "naciśnij Spację") — Escape
## na tym, najwyższym poziomie wychodzi z gry (na życzenie autora), w
## przeciwieństwie do Escape w OptionsScreen/KeybindScreen, które tylko
## wracają o poziom wyżej.
const MENU_ITEMS: Array[String] = ["Graj", "Opcje", "Wyjście"]
## Osobny, wyraźnie inny niż biały tekst opcji — Palette.HIT_FLASH to też
## czysta biel (#FFFFFF), więc "podświetlenie" nim było identyczne z resztą i
## faktycznie niewidoczne (prawdziwy bug, nie tylko brak kontrastu).
const SELECTED_COLOR := Color("#E8C547")
const SELECTED_BG := Color("#E8C547", 0.16)

@onready var background: TextureRect = $Background
@onready var logo: TextureRect = $Logo
@onready var keybind_screen: KeybindScreen = $KeybindScreen
@onready var options_screen: OptionsScreen = $OptionsScreen

var _selected_index: int = 0
## Prostokąty wierszy wyliczane w _draw(), używane przez najechanie/klik
## myszką w _unhandled_input() — menu jest Node2D rysowanym przez _draw(),
## nie drzewem klikanych Control/Button, więc trafienie myszką trzeba
## sprawdzać ręcznie, tak samo jak np. rooms/chest.gd sprawdza zasięg gracza.
var _item_rects: Array[Rect2] = []

func _ready() -> void:
	var vp_size := get_viewport_rect().size
	# expand_mode domyślnie każe kontrolce rosnąć do natywnego rozmiaru
	# tekstury (1536x1024) niezależnie od .size — IGNORE_SIZE to wyłącza,
	# inaczej logo/tło wystają poza ekran zamiast trzymać się zadanych wymiarów.
	background.texture = TEX_BACKGROUND
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_SCALE
	background.position = Vector2.ZERO
	background.size = vp_size
	# z_index ujemny na oba — inaczej rysują się PO własnym _draw() korzenia
	# (dzieci renderują się nad rodzicem przy tym samym z_index, kolejność w
	# drzewie rozstrzyga remis), a pełnoekranowe tło całkowicie zasłaniało listę
	# menu poniżej — dokładnie ten sam bug co "Naciśnij Spację" wcześniej,
	# tylko niewidoczny do teraz, bo nikt tego ekranu nie testował wizualnie.
	background.z_index = -1

	logo.texture = TEX_LOGO
	logo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	logo.stretch_mode = TextureRect.STRETCH_SCALE
	logo.size = LOGO_SIZE
	logo.position = Vector2((vp_size.x - LOGO_SIZE.x) * 0.5, vp_size.y * 0.28)
	logo.z_index = -1

func _process(_delta: float) -> void:
	if keybind_screen.visible or options_screen.visible:
		return
	queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	if keybind_screen.visible or options_screen.visible:
		return
	if event is InputEventMouseMotion:
		_update_hover(event.position)
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_handle_click(event.position)
	elif event.is_action_pressed("ui_down"):
		_selected_index = (_selected_index + 1) % MENU_ITEMS.size()
	elif event.is_action_pressed("ui_up"):
		_selected_index = (_selected_index - 1 + MENU_ITEMS.size()) % MENU_ITEMS.size()
	elif event.is_action_pressed("ui_accept"):
		_activate_selected()
	elif event.is_action_pressed("ui_cancel"):
		get_tree().quit()
	elif event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_K:
		keybind_screen.open()

func _update_hover(mouse_pos: Vector2) -> void:
	for i in range(_item_rects.size()):
		if _item_rects[i].has_point(mouse_pos):
			_selected_index = i
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
			get_tree().change_scene_to_file(GameFlow.resume_scene_path())
		1:
			options_screen.open()
		2:
			get_tree().quit()

func _draw() -> void:
	if keybind_screen.visible or options_screen.visible:
		return
	var size := get_viewport_rect().size
	var font := ThemeDB.fallback_font

	var start_y := size.y * 0.64
	var line_height := 34.0
	_item_rects.resize(MENU_ITEMS.size())
	for i in range(MENU_ITEMS.size()):
		var label: String = MENU_ITEMS[i]
		var is_selected := i == _selected_index
		var label_size := font.get_string_size(label, HORIZONTAL_ALIGNMENT_CENTER, -1, 24)
		var baseline := Vector2((size.x - label_size.x) * 0.5, start_y + i * line_height)
		# Pełna szerokość ekranu, nie tylko szerokość napisu — łatwiejszy,
		# pewniejszy cel dla myszki (mniej ważne gdzie w wierszu ktoś kliknie).
		var row_rect := Rect2(0.0, baseline.y - label_size.y - 4.0, size.x, label_size.y + 12.0)
		_item_rects[i] = row_rect
		if is_selected:
			draw_rect(row_rect, SELECTED_BG, true)
		var color := SELECTED_COLOR if is_selected else Color.WHITE
		draw_string(font, baseline, label, HORIZONTAL_ALIGNMENT_LEFT, -1, 24, color)

	var hint := "Strzałki: wybór — Enter/Spacja: zatwierdź — Escape: wyjście — K: klawisze"
	var hint_size := font.get_string_size(hint, HORIZONTAL_ALIGNMENT_CENTER, -1, 16)
	draw_string(font, Vector2((size.x - hint_size.x) * 0.5, size.y * 0.92), hint,
		HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color.WHITE)
