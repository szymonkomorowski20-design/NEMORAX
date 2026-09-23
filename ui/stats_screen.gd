extends Control
class_name StatsScreen
## Ekran statystyk postaci i wydawania punktów levela (Tab) — na życzenie
## autora. Klawiaturowy, spójny z resztą UI gry (keybind_screen.gd,
## pause_menu.gd) — strzałki wybierają statystykę, Enter wydaje punkt,
## Tab/Escape zamyka. Pauzuje grę samodzielnie na czas otwarcia — dzięki temu
## room.gd/arena.gd nie musi pilnować wzajemnego wykluczania z pause_menu: skoro
## drzewo jest spauzowane, ich WŁASNY _unhandled_input (domyślny process_mode)
## i tak przestaje działać, więc oba ekrany nie mogą być otwarte naraz.

const FONT_TITLE := preload("res://assets/fonts/Cinzel-SemiBold.woff")
const FONT_BODY := preload("res://assets/fonts/EBGaramond-Regular.woff")
const FONT_BODY_MEDIUM := preload("res://assets/fonts/EBGaramond-Medium.woff")
const SELECTED_COLOR := Color("#E8C547")
const SELECTED_BG := Color("#E8C547", 0.16)
const TEXT_COLOR := Color("#E9E1F0") # parchment-lavender, cieplejsze niż czyste WHITE
const HINT_COLOR := Color("#8A7FA0") # przygaszony — podpowiedź ma być mniej widoczna niż treść
const SkillCatalog := preload("res://entities/skill_catalog.gd")

var player: Player = null
var _selected_index: int = 0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false

func _process(_delta: float) -> void:
	if visible:
		queue_redraw()

const SND_OPEN := preload("res://assets/audio/sfx/p0/UI_STATS_OPEN.wav")

func open(p: Player) -> void:
	player = p
	_selected_index = 0
	visible = true
	get_tree().paused = true
	Juice.play_ui_sfx(SND_OPEN)

func _close() -> void:
	visible = false
	get_tree().paused = false

func _unhandled_input(event: InputEvent) -> void:
	if not visible or player == null:
		return
	if event.is_action_pressed("ui_down"):
		_selected_index = (_selected_index + 1) % Player.STAT_KEYS.size()
		Juice.play_ui_sfx_variant(Juice.SND_UI_NAVIGATE)
	elif event.is_action_pressed("ui_up"):
		_selected_index = (_selected_index - 1 + Player.STAT_KEYS.size()) % Player.STAT_KEYS.size()
		Juice.play_ui_sfx_variant(Juice.SND_UI_NAVIGATE)
	elif event.is_action_pressed("ui_accept"):
		if player.spend_stat_point(Player.STAT_KEYS[_selected_index]):
			Juice.play_ui_sfx(Juice.SND_UI_LEVEL_UP)
			if get_tree().current_scene != null:
				GameFlow.capture_player_state(player)
				GameFlow._save_progress()
		else:
			Juice.play_ui_sfx(Juice.SND_UI_ERROR)
	elif event.is_action_pressed("ui_cancel"):
		Juice.play_ui_sfx_variant(Juice.SND_UI_BACK)
		_close()
	elif event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_TAB:
		Juice.play_ui_sfx_variant(Juice.SND_UI_BACK)
		_close()

const SKILLS_GRID_COLUMNS := 4
const SKILLS_GRID_COL_WIDTH := 300.0
const SKILLS_GRID_ROW_HEIGHT := 26.0
const SKILLS_ICON_SIZE := 22.0

## Był zbudowany z niezależnych procentów viewport_size.y dobranych osobno dla
## każdego elementu (0.1 / 0.18 / 0.25 / 0.34...) — stąd linia podsumowania
## (0.30) faktycznie nachodziła na pierwszy, podświetlony wiersz statystyk
## (zaczynający się na 0.34, ale jego TŁO sięga wyżej niż sama linia bazowa
## tekstu). Płynący kursor `y`, powiększany o rzeczywistą wysokość właśnie
## narysowanego elementu, wyklucza taki nachodzący się odstęp z konstrukcji,
## zamiast wymagać, żeby ktoś ręcznie utrzymywał zgodność kolejnych stałych.
func _draw() -> void:
	if not visible or player == null:
		return
	var viewport_size := get_viewport_rect().size
	draw_rect(Rect2(Vector2.ZERO, viewport_size), Color(Palette.BACKGROUND, 0.92), true)
	var y := viewport_size.y * 0.08

	var title := "Statystyki postaci — Level %d/%d" % [player.level, player.max_level]
	var title_size := FONT_TITLE.get_string_size(title, HORIZONTAL_ALIGNMENT_CENTER, -1, 30)
	draw_string(FONT_TITLE, Vector2((viewport_size.x - title_size.x) * 0.5, y), title,
		HORIZONTAL_ALIGNMENT_LEFT, -1, 30, SELECTED_COLOR)
	y += 42.0

	var bar_width := 420.0
	var bar_pos := Vector2((viewport_size.x - bar_width) * 0.5, y)
	draw_rect(Rect2(bar_pos, Vector2(bar_width, 14.0)), Color(1.0, 1.0, 1.0, 0.2), true)
	draw_rect(Rect2(bar_pos, Vector2(bar_width * player.xp_ratio(), 14.0)), Palette.PLAYER_BODY, true)
	y += 34.0

	var points_text := "Niewydane punkty: %d" % player.unspent_stat_points
	var points_size := FONT_BODY_MEDIUM.get_string_size(points_text, HORIZONTAL_ALIGNMENT_CENTER, -1, 20)
	draw_string(FONT_BODY_MEDIUM, Vector2((viewport_size.x - points_size.x) * 0.5, y), points_text,
		HORIZONTAL_ALIGNMENT_LEFT, -1, 20, TEXT_COLOR)
	y += 38.0

	var line_height := 34.0
	var row_width := 360.0
	for i in range(Player.STAT_KEYS.size()):
		var key: String = Player.STAT_KEYS[i]
		var label: String = Player.STAT_LABELS[key]
		var points: int = player.stat_points[key]
		var line := "%s — %d %s" % [label, points, ("punkt" if points == 1 else "punktów")]
		var is_selected := i == _selected_index
		var font := FONT_BODY_MEDIUM if is_selected else FONT_BODY
		var color := SELECTED_COLOR if is_selected else TEXT_COLOR
		var line_size := font.get_string_size(line, HORIZONTAL_ALIGNMENT_CENTER, -1, 22)
		var baseline := Vector2((viewport_size.x - line_size.x) * 0.5, y + i * line_height)
		if is_selected:
			var row_rect := Rect2((viewport_size.x - row_width) * 0.5, baseline.y - line_size.y - 4.0, row_width, line_size.y + 12.0)
			draw_rect(row_rect, SELECTED_BG, true)
		draw_string(font, baseline, line, HORIZONTAL_ALIGNMENT_LEFT, -1, 22, color)
	y += Player.STAT_KEYS.size() * line_height + 20.0

	# Podsumowanie efektywnych statystyk PO liście punktów, nie przed nią —
	# to wynik ich wydawania, więc czytelnie idzie za przyczyną, nie nad nią.
	var summary := "HP %.0f/%.0f  ·  Miecz %.1f  ·  Różdżka %.1f  ·  Ruch %.0f" % [player.health, player.max_health, player.attack_damage, player.wand_damage, minf(player.base_max_speed * 1.4, player.max_speed * player._upgrade_speed_multiplier())]
	var summary_size := FONT_BODY_MEDIUM.get_string_size(summary, HORIZONTAL_ALIGNMENT_CENTER, -1, 19)
	draw_string(FONT_BODY_MEDIUM, Vector2((viewport_size.x - summary_size.x) * 0.5, y), summary,
		HORIZONTAL_ALIGNMENT_LEFT, -1, 19, TEXT_COLOR)
	y += 40.0

	var ids := player.skill_ranks.keys()
	ids.sort()
	if not ids.is_empty():
		draw_string(FONT_TITLE, Vector2((viewport_size.x - SKILLS_GRID_COLUMNS * SKILLS_GRID_COL_WIDTH) * 0.5, y), "Umiejętności",
			HORIZONTAL_ALIGNMENT_LEFT, -1, 20, SELECTED_COLOR)
		y += 26.0
		# 4 kolumny x tyle wierszy, ile trzeba (rząd-po-rzędzie, nie kolumna-po-
		# kolumnie jak poprzednio) — poprzedni układ (5 wierszy, kolumny co
		# 390px) przy 28 możliwych umiejętnościach potrzebowałby 6 kolumn,
		# a viewport ma 1280px: piąta i szósta kolumna renderowałyby się poza
		# ekranem. 4x300px = 1200px mieści się z zapasem niezależnie od tego,
		# ile z 28 gracz już ma.
		var grid_left := (viewport_size.x - SKILLS_GRID_COLUMNS * SKILLS_GRID_COL_WIDTH) * 0.5
		for i in range(ids.size()):
			var id: String = ids[i]
			if not SkillCatalog.SKILLS.has(id):
				continue
			var col := i % SKILLS_GRID_COLUMNS
			var row := i / SKILLS_GRID_COLUMNS
			var pos := Vector2(grid_left + col * SKILLS_GRID_COL_WIDTH, y + row * SKILLS_GRID_ROW_HEIGHT)
			var icon: Texture2D = SkillCatalog.icon(id)
			if icon != null:
				draw_texture_rect(icon, Rect2(pos, Vector2(SKILLS_ICON_SIZE, SKILLS_ICON_SIZE)), false)
			draw_string(FONT_BODY_MEDIUM, pos + Vector2(SKILLS_ICON_SIZE + 6.0, 17), "%s %d/%d" % [SkillCatalog.SKILLS[id]["name"], player.skill_rank(id), SkillCatalog.SKILLS[id]["ranks"]],
				HORIZONTAL_ALIGNMENT_LEFT, SKILLS_GRID_COL_WIDTH - SKILLS_ICON_SIZE - 10.0, 16, TEXT_COLOR)

	var hint := "Strzałki: wybór — Enter: wydaj punkt — Tab/Escape: zamknij"
	var hint_size := FONT_BODY.get_string_size(hint, HORIZONTAL_ALIGNMENT_CENTER, -1, 18)
	draw_string(FONT_BODY, Vector2((viewport_size.x - hint_size.x) * 0.5, viewport_size.y * 0.92), hint,
		HORIZONTAL_ALIGNMENT_LEFT, -1, 18, HINT_COLOR)
