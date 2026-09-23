extends Control
class_name IntentSelect
## Paczka 6 (AUDYT E3, pilotaż): intencja startowa próby — Ostrze / Różdżka /
## Kontra. Lekko ukierunkowuje 3 pierwsze oferty run (jedna karta z puli
## intencji), bez trwałego bonusu i bez blokowania innych dróg. Esc = bez
## intencji. Pokazywane raz na próbę, w pokoju startowym, po prologu.

const Catalog := preload("res://entities/skill_catalog.gd")
const FONT_TITLE := preload("res://assets/fonts/Cinzel-SemiBold.woff")
const FONT_BODY := preload("res://assets/fonts/EBGaramond-Regular.woff")
const ORDER := ["ostrze", "rozdzka", "kontra"]
const ICON_SKILL := {"ostrze": "blade_twin_cut", "rozdzka": "wand_split_bolt", "kontra": "guard_counterbrand"}
const CARD_SIZE := Vector2(340.0, 300.0)
const CARD_GAP := 24.0

var selected: int = 0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	visible = false

func open() -> void:
	selected = 0
	visible = true
	get_tree().paused = true
	queue_redraw()

func _pick(intent: String) -> void:
	GameFlow.set_run_intent(intent)
	visible = false
	get_tree().paused = false
	Juice.play_ui_sfx(Juice.SND_UI_LEVEL_UP)

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("ui_left"):
		selected = maxi(0, selected - 1)
		queue_redraw()
	elif event.is_action_pressed("ui_right"):
		selected = mini(ORDER.size() - 1, selected + 1)
		queue_redraw()
	elif event.is_action_pressed("ui_accept"):
		_pick(ORDER[selected])
	elif event.is_action_pressed("ui_cancel"):
		_pick("brak")
	elif event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_L and GameFlow.loop_unlocked():
		GameFlow.loop_level = 0 if GameFlow.loop_level >= 1 else 1
		Juice.play_ui_sfx_variant(Juice.SND_UI_NAVIGATE)
		queue_redraw()
	elif event is InputEventKey and event.pressed and not event.echo and event.physical_keycode >= KEY_1 and event.physical_keycode <= KEY_3:
		_pick(ORDER[event.physical_keycode - KEY_1])
	get_viewport().set_input_as_handled()

func _gui_input(event: InputEvent) -> void:
	if visible and event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		for i in ORDER.size():
			if _card_rect(i).has_point(event.position):
				_pick(ORDER[i])
				accept_event()
				return

func _card_rect(i: int) -> Rect2:
	var size := get_viewport_rect().size
	var total := CARD_SIZE.x * 3.0 + CARD_GAP * 2.0
	return Rect2(Vector2((size.x - total) * 0.5 + i * (CARD_SIZE.x + CARD_GAP), size.y * 0.5 - CARD_SIZE.y * 0.5 + 20.0), CARD_SIZE)

func _draw() -> void:
	if not visible:
		return
	var size := get_viewport_rect().size
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.035, 0.025, 0.06, 0.95), true)
	var title := "CO PROWADZI TĘ PRÓBĘ?"
	var tw := FONT_TITLE.get_string_size(title, HORIZONTAL_ALIGNMENT_LEFT, -1, 32).x
	draw_string(FONT_TITLE, Vector2((size.x - tw) * 0.5, _card_rect(0).position.y - 50.0), title, HORIZONTAL_ALIGNMENT_LEFT, -1, 32, Color("#e8c547"))
	var sub := "Intencja tylko podsuwa pierwsze runy. Każdą drogę możesz później zmienić."
	var sw := FONT_BODY.get_string_size(sub, HORIZONTAL_ALIGNMENT_LEFT, -1, 19).x
	draw_string(FONT_BODY, Vector2((size.x - sw) * 0.5, _card_rect(0).position.y - 18.0), sub, HORIZONTAL_ALIGNMENT_LEFT, -1, 19, Color("#b8afc2"))
	for i in ORDER.size():
		var id: String = ORDER[i]
		var data: Dictionary = Catalog.INTENTS[id]
		var card := _card_rect(i)
		draw_rect(card, Color(0.10, 0.08, 0.14, 0.98), true)
		draw_rect(card, Color("#e8c547") if i == selected else Color("#695d76"), false, 3.0 if i == selected else 1.0)
		var icon: Texture2D = Catalog.icon(ICON_SKILL[id])
		if icon != null:
			draw_texture_rect(icon, Rect2(card.position + Vector2((CARD_SIZE.x - 80.0) * 0.5, 20), Vector2(80, 80)), false)
		draw_string(FONT_TITLE, card.position + Vector2(18, 140), str(data["name"]), HORIZONTAL_ALIGNMENT_LEFT, CARD_SIZE.x - 36.0, 26, Color("#e9e1f0"))
		draw_multiline_string(FONT_BODY, card.position + Vector2(18, 176), str(data["desc"]), HORIZONTAL_ALIGNMENT_LEFT, CARD_SIZE.x - 36.0, 20, -1, Color("#f1eaf6"))
		draw_string(FONT_BODY, card.position + Vector2(18, CARD_SIZE.y - 18.0), "%d — wybierz" % [i + 1], HORIZONTAL_ALIGNMENT_LEFT, CARD_SIZE.x - 36.0, 18, Color("#93879c"))
	# Paczka 9: Pętla Otchłani I — dostępna po pierwszym zwycięstwie.
	if GameFlow.loop_unlocked():
		var loop: Dictionary = GameFlow.LOOP_RULES[1]
		var on := GameFlow.loop_level >= 1
		var lt := "[L] %s: %s — %s" % [loop["name"], "WŁĄCZONA" if on else "wyłączona", loop["rule"]]
		var lw := FONT_BODY.get_string_size(lt, HORIZONTAL_ALIGNMENT_LEFT, -1, 18).x
		draw_string(FONT_BODY, Vector2(maxf(20.0, (size.x - lw) * 0.5), _card_rect(0).end.y + 80.0), lt, HORIZONTAL_ALIGNMENT_LEFT, size.x - 40.0, 18, Color("#d98a8a") if on else Color("#93879c"))
	var hint := "Strzałki / Enter · 1–3 · kliknięcie   ·   Esc — bez intencji"
	var hw := FONT_BODY.get_string_size(hint, HORIZONTAL_ALIGNMENT_LEFT, -1, 20).x
	draw_string(FONT_BODY, Vector2((size.x - hw) * 0.5, _card_rect(0).end.y + 44.0), hint, HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color("#93879c"))
