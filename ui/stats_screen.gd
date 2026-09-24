extends Control
class_name StatsScreen
## Ekran statystyk postaci i wydawania punktów levela (Tab) — na życzenie
## autora. Strzałki lub najechanie myszą wybierają statystykę, Enter wydaje punkt,
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
	_effects_scroll = 0
	visible = true
	get_tree().paused = true
	Juice.play_ui_sfx(SND_OPEN)

func _close() -> void:
	visible = false
	get_tree().paused = false

func _unhandled_input(event: InputEvent) -> void:
	if not visible or player == null:
		return
	if event is InputEventMouseMotion:
		var row := _stat_row_at(event.position)
		if row >= 0 and row != _selected_index:
			_selected_index = row
			queue_redraw()
	elif event.is_action_pressed("ui_down"):
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
	elif event is InputEventKey and event.pressed and event.physical_keycode == KEY_PAGEDOWN:
		scroll_effects(maxi(1, _effects_visible))
	elif event is InputEventKey and event.pressed and event.physical_keycode == KEY_PAGEUP:
		scroll_effects(-maxi(1, _effects_visible))
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
		scroll_effects(1)
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_UP:
		scroll_effects(-1)

## Drugi audyt nagrania (24.09, A1): dawniej jedna kolumna z efektami na dole
## ściskała wiersze, aż tekst wchodził na stopkę, a opisy były UCINANE na
## szerokości kolumny (draw_string z szerokością obcina, nie zawija). Teraz:
## nieprzezroczyste okno (nic z gry pod spodem nie prześwituje), statystyki
## w lewym panelu, efekty w prawym — każdy opis zawinięty w całości, lista
## przewijana (PgUp/PgDn, kółko myszy) zamiast ściskania, stopka w stałym pasie.
const LEFT_PANEL := Rect2(40.0, 150.0, 470.0, 500.0)
const RIGHT_PANEL := Rect2(540.0, 150.0, 700.0, 500.0)
const FOOTER_Y := 690.0
const EFFECT_ICON := 30.0
const EFFECT_GAP := 10.0
var _effects_scroll: int = 0
var _effects_visible: int = 0
var _effects_total: int = 0

func _stat_row_at(pos: Vector2) -> int:
	var first_y := LEFT_PANEL.position.y + 32.0
	for i in Player.STAT_KEYS.size():
		if Rect2(LEFT_PANEL.position.x + 8.0, first_y + i * 34.0 - 24.0, LEFT_PANEL.size.x - 16.0, 32.0).has_point(pos):
			return i
	return -1

func _effect_entries() -> Array:
	# Jedno źródło: te same katalogi, które zasilają karty i HUD.
	var entries: Array = []
	var ids := player.skill_ranks.keys()
	ids.sort()
	for id in ids:
		if SkillCatalog.SKILLS.has(id) and player.skill_rank(id) > 0:
			entries.append({"icon": SkillCatalog.icon(id), "title": "%s %d/%d" % [SkillCatalog.SKILLS[id]["name"], player.skill_rank(id), SkillCatalog.SKILLS[id]["ranks"]],
				"text": SkillCatalog.rank_text(id, player.skill_rank(id))})
	for ch in GameFlow.pacts:
		var opt: Dictionary = PactCatalog.OPTIONS.get(GameFlow.pacts[ch], {})
		if not opt.is_empty():
			entries.append({"icon": null, "title": "Pakt: %s" % opt["name"], "text": "Teraz: %s\nW finale: %s" % [opt["now"], opt["finale"]]})
	for relic in player.owned_upgrades:
		entries.append({"icon": GameUI.RELIC_ICONS.get(relic), "title": str(GameUI.RELIC_NAMES.get(relic, relic)),
			"text": str(GameUI.RELIC_DESCRIPTIONS.get(relic, ""))})
	return entries

func _entry_height(e: Dictionary, text_w: float) -> float:
	var h := FONT_BODY.get_multiline_string_size(str(e["text"]), HORIZONTAL_ALIGNMENT_LEFT, text_w, 15).y
	return maxf(EFFECT_ICON + 4.0, 22.0 + h) + EFFECT_GAP

func scroll_effects(delta: int) -> void:
	_effects_scroll = clampi(_effects_scroll + delta, 0, maxi(0, _effects_total - 1))
	queue_redraw()

func _centered(font: Font, text: String, y: float, size: int, color: Color) -> void:
	var w := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x
	draw_string(font, Vector2((get_viewport_rect().size.x - w) * 0.5, y), text, HORIZONTAL_ALIGNMENT_LEFT, -1, size, color)

func _draw() -> void:
	if not visible or player == null:
		return
	var vp := get_viewport_rect().size
	draw_rect(Rect2(Vector2.ZERO, vp), Palette.BACKGROUND, true) # nieprzezroczyste: modalne okno
	var title := ("Statystyki postaci — Poziom %d/%d · MAX" if player.level >= player.max_level else "Statystyki postaci — Poziom %d/%d") % [player.level, player.max_level]
	_centered(FONT_TITLE, title, 58.0, 30, SELECTED_COLOR)
	var bar_width := 420.0
	var bar_pos := Vector2((vp.x - bar_width) * 0.5, 76.0)
	draw_rect(Rect2(bar_pos, Vector2(bar_width, 12.0)), Color(1.0, 1.0, 1.0, 0.2), true)
	draw_rect(Rect2(bar_pos, Vector2(bar_width * player.xp_ratio(), 12.0)), Palette.PLAYER_BODY, true)
	var points_text := "Niewydane punkty: %d" % player.unspent_stat_points
	_centered(FONT_BODY_MEDIUM, points_text, 122.0, 20, SELECTED_COLOR if player.unspent_stat_points > 0 else TEXT_COLOR)

	# Lewy panel: punkty, podgląd, podsumowanie.
	var lp := LEFT_PANEL
	draw_rect(lp, Color(1, 1, 1, 0.03), true)
	var y := lp.position.y + 32.0
	var line_height := 34.0
	for i in range(Player.STAT_KEYS.size()):
		var key: String = Player.STAT_KEYS[i]
		var points: int = player.stat_points[key]
		var line := "%s — %d %s" % [Player.STAT_LABELS[key], points, ("punkt" if points == 1 else "punktów")]
		var is_selected := i == _selected_index
		if is_selected:
			draw_rect(Rect2(lp.position.x + 8.0, y - 24.0, lp.size.x - 16.0, 32.0), SELECTED_BG, true)
		draw_string(FONT_BODY_MEDIUM if is_selected else FONT_BODY, Vector2(lp.position.x + 20.0, y), line, HORIZONTAL_ALIGNMENT_LEFT, -1, 22, SELECTED_COLOR if is_selected else TEXT_COLOR)
		y += line_height
	y += 10.0
	var text_w := lp.size.x - 40.0
	var preview := "+1 punkt: " + player.stat_point_preview(Player.STAT_KEYS[_selected_index])
	draw_multiline_string(FONT_BODY_MEDIUM, Vector2(lp.position.x + 20.0, y), preview, HORIZONTAL_ALIGNMENT_LEFT, text_w, 19, -1, SELECTED_COLOR if player.unspent_stat_points > 0 else HINT_COLOR)
	y += FONT_BODY_MEDIUM.get_multiline_string_size(preview, HORIZONTAL_ALIGNMENT_LEFT, text_w, 19).y + 14.0
	var summary := "HP %.0f/%.0f  ·  Miecz %.1f  ·  Różdżka %.1f  ·  Ruch %.0f" % [player.health, player.max_health, player.attack_damage, player.wand_damage, minf(player.base_max_speed * 1.4, player.max_speed * player._upgrade_speed_multiplier())]
	draw_multiline_string(FONT_BODY_MEDIUM, Vector2(lp.position.x + 20.0, y), summary, HORIZONTAL_ALIGNMENT_LEFT, text_w, 18, -1, TEXT_COLOR)

	# Prawy panel: aktywne efekty, pełne opisy, przewijanie wpisami.
	var rp := RIGHT_PANEL
	draw_rect(rp, Color(1, 1, 1, 0.03), true)
	var entries := _effect_entries()
	_effects_total = entries.size()
	_effects_scroll = clampi(_effects_scroll, 0, maxi(0, _effects_total - 1))
	draw_string(FONT_TITLE, rp.position + Vector2(16.0, 28.0), "Aktywne efekty (%d)" % _effects_total, HORIZONTAL_ALIGNMENT_LEFT, -1, 20, SELECTED_COLOR)
	var list_top := rp.position.y + 44.0
	var list_bottom := rp.end.y - 24.0
	var ew := rp.size.x - 32.0 - EFFECT_ICON - 10.0
	var ey := list_top
	_effects_visible = 0
	if entries.is_empty():
		draw_string(FONT_BODY, Vector2(rp.position.x + 16.0, ey + 20.0), "Brak — runy, relikwie i Pakt pojawią się tutaj.", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, HINT_COLOR)
	for i in range(_effects_scroll, entries.size()):
		var e: Dictionary = entries[i]
		var h := _entry_height(e, ew)
		if ey + h > list_bottom and _effects_visible > 0:
			break
		var x0 := rp.position.x + 16.0
		if e["icon"] != null:
			draw_texture_rect(e["icon"], Rect2(Vector2(x0, ey + 2.0), Vector2(EFFECT_ICON, EFFECT_ICON)), false)
		draw_string(FONT_BODY_MEDIUM, Vector2(x0 + EFFECT_ICON + 10.0, ey + 16.0), e["title"], HORIZONTAL_ALIGNMENT_LEFT, ew, 17, SELECTED_COLOR)
		draw_multiline_string(FONT_BODY, Vector2(x0 + EFFECT_ICON + 10.0, ey + 34.0), str(e["text"]), HORIZONTAL_ALIGNMENT_LEFT, ew, 15, -1, TEXT_COLOR)
		ey += h
		_effects_visible += 1
	var more_up := _effects_scroll > 0
	var more_down := _effects_scroll + _effects_visible < _effects_total
	if more_up or more_down:
		var nav := "%s%s  wpisy %d–%d z %d  ·  PgUp/PgDn lub kółko myszy" % ["▲ " if more_up else "", "▼" if more_down else "", _effects_scroll + 1, _effects_scroll + _effects_visible, _effects_total]
		draw_string(FONT_BODY, Vector2(rp.position.x + 16.0, rp.end.y - 6.0), nav, HORIZONTAL_ALIGNMENT_LEFT, rp.size.x - 32.0, 15, HINT_COLOR)

	# Stopka w stałym pasie — nic nad nią nie wchodzi.
	_centered(FONT_BODY, "Strzałki/mysz: wybór — Enter: wydaj punkt — PgUp/PgDn: efekty — Tab/Escape: zamknij", FOOTER_Y, 18, HINT_COLOR)
