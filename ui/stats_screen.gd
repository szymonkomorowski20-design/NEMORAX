extends Control
class_name StatsScreen
## Ekran statystyk postaci i wydawania punktów levela (Tab) — na życzenie
## autora. Klawiaturowy, spójny z resztą UI gry (keybind_screen.gd,
## pause_menu.gd) — strzałki wybierają statystykę, Enter wydaje punkt,
## Tab/Escape zamyka. Pauzuje grę samodzielnie na czas otwarcia — dzięki temu
## room.gd/arena.gd nie musi pilnować wzajemnego wykluczania z pause_menu: skoro
## drzewo jest spauzowane, ich WŁASNY _unhandled_input (domyślny process_mode)
## i tak przestaje działać, więc oba ekrany nie mogą być otwarte naraz.

var player: Player = null
var _selected_index: int = 0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false

func _process(_delta: float) -> void:
	if visible:
		queue_redraw()

func open(p: Player) -> void:
	player = p
	_selected_index = 0
	visible = true
	get_tree().paused = true

func _close() -> void:
	visible = false
	get_tree().paused = false

func _unhandled_input(event: InputEvent) -> void:
	if not visible or player == null:
		return
	if event.is_action_pressed("ui_down"):
		_selected_index = (_selected_index + 1) % Player.STAT_KEYS.size()
	elif event.is_action_pressed("ui_up"):
		_selected_index = (_selected_index - 1 + Player.STAT_KEYS.size()) % Player.STAT_KEYS.size()
	elif event.is_action_pressed("ui_accept"):
		player.spend_stat_point(Player.STAT_KEYS[_selected_index])
	elif event.is_action_pressed("ui_cancel"):
		_close()
	elif event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_TAB:
		_close()

func _draw() -> void:
	if not visible or player == null:
		return
	var viewport_size := get_viewport_rect().size
	draw_rect(Rect2(Vector2.ZERO, viewport_size), Color(Palette.BACKGROUND, 0.92), true)
	var font := ThemeDB.fallback_font

	var title := "Statystyki postaci — Level %d/%d" % [player.level, player.max_level]
	var title_size := font.get_string_size(title, HORIZONTAL_ALIGNMENT_CENTER, -1, 30)
	draw_string(font, Vector2((viewport_size.x - title_size.x) * 0.5, viewport_size.y * 0.1), title,
		HORIZONTAL_ALIGNMENT_LEFT, -1, 30, Palette.PLAYER_BODY)

	var bar_width := 420.0
	var bar_pos := Vector2((viewport_size.x - bar_width) * 0.5, viewport_size.y * 0.18)
	draw_rect(Rect2(bar_pos, Vector2(bar_width, 14.0)), Color(1.0, 1.0, 1.0, 0.2), true)
	draw_rect(Rect2(bar_pos, Vector2(bar_width * player.xp_ratio(), 14.0)), Palette.PLAYER_BODY, true)

	var points_text := "Niewydane punkty: %d" % player.unspent_stat_points
	var points_size := font.get_string_size(points_text, HORIZONTAL_ALIGNMENT_CENTER, -1, 20)
	draw_string(font, Vector2((viewport_size.x - points_size.x) * 0.5, viewport_size.y * 0.25), points_text,
		HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color.WHITE)

	var start_y := viewport_size.y * 0.34
	var line_height := 34.0
	for i in range(Player.STAT_KEYS.size()):
		var key: String = Player.STAT_KEYS[i]
		var label: String = Player.STAT_LABELS[key]
		var points: int = player.stat_points[key]
		var line := "%s — %d %s" % [label, points, ("punkt" if points == 1 else "punktów")]
		var color := Palette.HIT_FLASH if i == _selected_index else Color.WHITE
		var line_size := font.get_string_size(line, HORIZONTAL_ALIGNMENT_CENTER, -1, 22)
		draw_string(font, Vector2((viewport_size.x - line_size.x) * 0.5, start_y + i * line_height), line,
			HORIZONTAL_ALIGNMENT_LEFT, -1, 22, color)

	var hint := "Strzałki: wybór — Enter: wydaj punkt — Tab/Escape: zamknij"
	var hint_size := font.get_string_size(hint, HORIZONTAL_ALIGNMENT_CENTER, -1, 18)
	draw_string(font, Vector2((viewport_size.x - hint_size.x) * 0.5, viewport_size.y * 0.92), hint,
		HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color.WHITE)
