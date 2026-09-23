extends Control
class_name PactSelect
## Paczka 8 (AUDYT E4): karta Paktu fragmentu — dwie drogi, każda z efektem
## TERAZ i zapowiedzianą konsekwencją W FINALE. Otwierana z HUD (P); przy
## ołtarzu wybór jest obowiązkowy (can_postpone = false).

signal pact_chosen(choice: String)

const FONT_TITLE := preload("res://assets/fonts/Cinzel-SemiBold.woff")
const FONT_BODY := preload("res://assets/fonts/EBGaramond-Regular.woff")
const ORDER := [PactCatalog.OCZYSC, PactCatalog.ZWIAZ]
const CARD_SIZE := Vector2(460.0, 360.0)
const CARD_GAP := 30.0

var chapter: int = PactCatalog.PILOT_CHAPTER
var can_postpone: bool = true
var selected: int = 0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	visible = false

func open(for_chapter: int, postpone_allowed: bool = true) -> void:
	chapter = for_chapter
	can_postpone = postpone_allowed
	selected = 0
	visible = true
	get_tree().paused = true
	queue_redraw()

func _pick(choice: String) -> void:
	GameFlow.set_pact(chapter, choice)
	visible = false
	get_tree().paused = false
	Juice.play_ui_sfx(Juice.SND_UI_LEVEL_UP)
	pact_chosen.emit(choice)

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("ui_left"):
		selected = 0
		queue_redraw()
	elif event.is_action_pressed("ui_right"):
		selected = 1
		queue_redraw()
	elif event.is_action_pressed("ui_accept"):
		_pick(ORDER[selected])
	elif event.is_action_pressed("ui_cancel") and can_postpone:
		visible = false
		get_tree().paused = false
		Juice.play_ui_sfx_variant(Juice.SND_UI_BACK)
	elif event is InputEventKey and event.pressed and not event.echo and event.physical_keycode in [KEY_1, KEY_2]:
		_pick(ORDER[event.physical_keycode - KEY_1])
	get_viewport().set_input_as_handled()

func _gui_input(event: InputEvent) -> void:
	if visible and event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		for i in 2:
			if _card_rect(i).has_point(event.position):
				_pick(ORDER[i])
				accept_event()
				return

func _card_rect(i: int) -> Rect2:
	var size := get_viewport_rect().size
	var total := CARD_SIZE.x * 2.0 + CARD_GAP
	return Rect2(Vector2((size.x - total) * 0.5 + i * (CARD_SIZE.x + CARD_GAP), size.y * 0.5 - CARD_SIZE.y * 0.5 + 30.0), CARD_SIZE)

func _draw() -> void:
	if not visible:
		return
	var size := get_viewport_rect().size
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.035, 0.025, 0.06, 0.95), true)
	var title := "PAKT FRAGMENTU — %s" % GameFlow.INCARNATION_NAMES[chapter].split(",")[0].to_upper()
	var tw := FONT_TITLE.get_string_size(title, HORIZONTAL_ALIGNMENT_LEFT, -1, 30).x
	draw_string(FONT_TITLE, Vector2((size.x - tw) * 0.5, _card_rect(0).position.y - 58.0), title, HORIZONTAL_ALIGNMENT_LEFT, -1, 30, Color("#e8c547"))
	var sub := "Fragment jest twój w obu przypadkach. Wybierasz, jak użyjesz jego mocy — i co zrobi z tym Nemorax."
	var sw := FONT_BODY.get_string_size(sub, HORIZONTAL_ALIGNMENT_LEFT, -1, 19).x
	draw_string(FONT_BODY, Vector2((size.x - sw) * 0.5, _card_rect(0).position.y - 24.0), sub, HORIZONTAL_ALIGNMENT_LEFT, -1, 19, Color("#b8afc2"))
	for i in 2:
		var data: Dictionary = PactCatalog.OPTIONS[ORDER[i]]
		var card := _card_rect(i)
		var accent := Color("#9fd3c7") if i == 0 else Color("#d98a8a")
		draw_rect(card, Color(0.10, 0.08, 0.14, 0.98), true)
		draw_rect(card, Color("#e8c547") if i == selected else Color("#695d76"), false, 3.0 if i == selected else 1.0)
		draw_string(FONT_TITLE, card.position + Vector2(22, 46), str(data["name"]), HORIZONTAL_ALIGNMENT_LEFT, CARD_SIZE.x - 44.0, 26, accent)
		draw_string(FONT_BODY, card.position + Vector2(22, 92), "Teraz, w tej próbie:", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("#93879c"))
		draw_multiline_string(FONT_BODY, card.position + Vector2(22, 120), str(data["now"]), HORIZONTAL_ALIGNMENT_LEFT, CARD_SIZE.x - 44.0, 21, -1, Color("#f1eaf6"))
		draw_string(FONT_BODY, card.position + Vector2(22, 208), "W finale (faza Force):", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("#93879c"))
		draw_multiline_string(FONT_BODY, card.position + Vector2(22, 236), str(data["finale"]), HORIZONTAL_ALIGNMENT_LEFT, CARD_SIZE.x - 44.0, 21, -1, accent)
		draw_string(FONT_BODY, card.position + Vector2(22, CARD_SIZE.y - 18.0), "%d — wybierz" % [i + 1], HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("#93879c"))
	var hint := "Strzałki / Enter · 1–2 · kliknięcie" + ("   ·   Esc — później" if can_postpone else "   ·   wybór wymagany przed rytuałem")
	var hw := FONT_BODY.get_string_size(hint, HORIZONTAL_ALIGNMENT_LEFT, -1, 20).x
	draw_string(FONT_BODY, Vector2((size.x - hw) * 0.5, _card_rect(0).end.y + 44.0), hint, HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color("#93879c"))
