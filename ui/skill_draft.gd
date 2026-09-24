extends Control
class_name SkillDraft
## Wybór jednej z trzech run po awansie. To osobny ekran nad statystykami.

const Catalog := preload("res://entities/skill_catalog.gd")
const FONT_TITLE := preload("res://assets/fonts/Cinzel-SemiBold.woff")
const FONT_BODY := preload("res://assets/fonts/EBGaramond-Regular.woff")
var player: Player
var selected: int = 0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	visible = false

func open(p: Player) -> void:
	if not is_inside_tree() or not is_instance_valid(p) or p.pending_skill_choices <= 0:
		return
	player = p
	player.ensure_skill_offer()
	_persist_choice()
	selected = 0
	visible = true
	get_tree().paused = true
	queue_redraw()

func _choose(index: int) -> void:
	if not visible or not is_instance_valid(player) or index < 0 or index >= player.skill_offers.size():
		return
	if not player.choose_skill(player.skill_offers[index]):
		return
	_persist_choice()
	Juice.play_ui_sfx(Juice.SND_UI_LEVEL_UP)
	if player.pending_skill_choices > 0:
		player.ensure_skill_offer()
		_persist_choice()
		selected = 0
		queue_redraw()
	else:
		visible = false
		get_tree().paused = false

func _persist_choice() -> void:
	# W prawdziwej scenie zapisujemy także nierozstrzygniętą ofertę. Testy
	# jednostkowe bez current_scene nie modyfikują pliku postępu gracza.
	if get_tree().current_scene != null:
		GameFlow.capture_player_state(player)
		GameFlow._save_progress()

func _unhandled_input(event: InputEvent) -> void:
	if not visible or not is_instance_valid(player):
		return
	if event.is_action_pressed("ui_left"):
		selected = maxi(0, selected - 1)
		queue_redraw()
	elif event.is_action_pressed("ui_right"):
		selected = mini(player.skill_offers.size() - 1, selected + 1)
		queue_redraw()
	elif event.is_action_pressed("ui_accept"):
		_choose(selected)
	elif event.is_action_pressed("ui_cancel"):
		close_for_later()
	elif event is InputEventKey and event.pressed and not event.echo:
		if event.physical_keycode >= KEY_1 and event.physical_keycode <= KEY_3:
			_choose(event.physical_keycode - KEY_1)
		elif event.physical_keycode == KEY_4:
			_reroll()
	get_viewport().set_input_as_handled()

## Decyzja autora (23.09): gracz sam wybiera, KIEDY wybrać runę — Esc odkłada
## wybór, oferta zostaje zapisana, a HUD dalej pokazuje przycisk.
func close_for_later() -> void:
	visible = false
	get_tree().paused = false
	Juice.play_ui_sfx_variant(Juice.SND_UI_BACK)

## Jeden przerzut na próbę (Paczka 6). Zapisywany od razu — wczytanie gry
## nie może dać nowej trójki za darmo.
func _reroll() -> void:
	if not is_instance_valid(player) or not player.reroll_skill_offer():
		Juice.play_ui_sfx(Juice.SND_UI_ERROR)
		return
	Juice.play_ui_sfx_variant(Juice.SND_UI_NAVIGATE)
	_persist_choice()
	selected = 0
	queue_redraw()

func _gui_input(event: InputEvent) -> void:
	if not visible or not is_instance_valid(player):
		return
	if event is InputEventMouseMotion:
		for i in range(player.skill_offers.size()):
			if _card_rect(i).has_point(event.position):
				if selected != i:
					selected = i
					queue_redraw()
				return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		for i in range(player.skill_offers.size()):
			if _card_rect(i).has_point(event.position):
				accept_event()
				_choose(i)
				return

const CARD_SIZE := Vector2(360.0, 470.0)
const CARD_GAP := 24.0
const WEAPON_LABEL := {"sword": "Miecz", "wand": "Różdżka", "any": "Każda broń"}

func _card_rect(i: int) -> Rect2:
	var size := get_viewport_rect().size
	var total := CARD_SIZE.x * 3.0 + CARD_GAP * 2.0
	return Rect2(Vector2((size.x - total) * 0.5 + i * (CARD_SIZE.x + CARD_GAP), size.y * 0.5 - CARD_SIZE.y * 0.5 + 20.0), CARD_SIZE)

## Paczka 6 (A11): duża karta z KONKRETNĄ zmianą. "Teraz" i "Po wyborze" to
## ten sam opis policzony dla dwóch rang (Catalog.rank_text), więc nie ma
## ciągów 125/150/175 do rozszyfrowania.
func _draw() -> void:
	if not visible or not is_instance_valid(player):
		return
	var size := get_viewport_rect().size
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.035, 0.025, 0.06, 0.95), true)
	var title := "WYBIERZ RUNĘ — POZIOM %d" % player.level
	var title_w := FONT_TITLE.get_string_size(title, HORIZONTAL_ALIGNMENT_LEFT, -1, 34).x
	draw_string(FONT_TITLE, Vector2((size.x - title_w) * 0.5, _card_rect(0).position.y - 36.0), title, HORIZONTAL_ALIGNMENT_LEFT, -1, 34, Color("#e8c547"))
	var text_w := CARD_SIZE.x - 36.0
	for i in range(player.skill_offers.size()):
		var id: String = player.skill_offers[i]
		var data: Dictionary = Catalog.SKILLS[id]
		var card := _card_rect(i)
		var active := i == selected
		var rank_now := player.skill_rank(id)
		draw_rect(card, Color(0.10, 0.08, 0.14, 0.98), true)
		draw_rect(card, Color("#e8c547") if active else Color("#695d76"), false, 3.0 if active else 1.0)
		var icon: Texture2D = Catalog.icon(id)
		if icon != null:
			draw_texture_rect(icon, Rect2(card.position + Vector2((CARD_SIZE.x - 88.0) * 0.5, 18), Vector2(88, 88)), false)
		var y := card.position.y + 140.0
		draw_string(FONT_TITLE, Vector2(card.position.x + 18, y), str(data["name"]), HORIZONTAL_ALIGNMENT_LEFT, text_w, 23, Color("#e9e1f0"))
		y += 28.0
		var weapon: String = Catalog.weapon_of(id)
		var chip := "%s · %s" % [WEAPON_LABEL[weapon], ", ".join(Catalog.SKILL_TAGS.get(id, []))]
		draw_string(FONT_BODY, Vector2(card.position.x + 18, y), chip, HORIZONTAL_ALIGNMENT_LEFT, text_w, 17, Color("#93879c") if weapon in [player.current_weapon, "any"] else Color("#b0655a"))
		y += 30.0
		draw_string(FONT_BODY, Vector2(card.position.x + 18, y), "Ranga %d → %d  (maks. %d)" % [rank_now, rank_now + 1, data["ranks"]], HORIZONTAL_ALIGNMENT_LEFT, text_w, 20, Color("#e8c547"))
		y += 30.0
		draw_string(FONT_BODY, Vector2(card.position.x + 18, y), "Teraz:", HORIZONTAL_ALIGNMENT_LEFT, text_w, 18, Color("#93879c"))
		y += 6.0
		var now_text := "— jeszcze nie masz tej runy" if rank_now == 0 else Catalog.rank_text(id, rank_now)
		y = _wrapped(now_text, card.position.x + 18, y, text_w, 19, Color("#b8afc2"))
		y += 12.0
		draw_string(FONT_BODY, Vector2(card.position.x + 18, y + 16.0), "Po wyborze:", HORIZONTAL_ALIGNMENT_LEFT, text_w, 18, Color("#e8c547"))
		y += 22.0
		_wrapped(Catalog.rank_text(id, rank_now + 1), card.position.x + 18, y, text_w, 20, Color("#f1eaf6"))
		draw_string(FONT_BODY, card.position + Vector2(18, CARD_SIZE.y - 18.0), "%d — wybierz" % [i + 1], HORIZONTAL_ALIGNMENT_LEFT, text_w, 18, Color("#93879c"))
	var hint := "Strzałki / Enter · klawisze 1–3 · kliknięcie"
	hint += "   ·   4 — przerzuć (%d)" % player.skill_rerolls if player.skill_rerolls > 0 else "   ·   przerzut wykorzystany"
	hint += "   ·   Esc — później"
	var hint_w := FONT_BODY.get_string_size(hint, HORIZONTAL_ALIGNMENT_LEFT, -1, 20).x
	draw_string(FONT_BODY, Vector2((size.x - hint_w) * 0.5, _card_rect(0).end.y + 44.0), hint, HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color("#93879c"))

## Tekst zawijany, zwraca y pod ostatnią linią.
func _wrapped(text: String, x: float, y: float, width: float, font_size: int, color: Color) -> float:
	var lines := FONT_BODY.get_multiline_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, width, font_size)
	draw_multiline_string(FONT_BODY, Vector2(x, y + font_size), text, HORIZONTAL_ALIGNMENT_LEFT, width, font_size, -1, color)
	return y + lines.y
