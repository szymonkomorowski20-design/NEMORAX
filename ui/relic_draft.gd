extends Control
class_name RelicDraft
## Wybór jednej z trzech relikwii. Decyzja autora (23.09): skrzynia NIE otwiera
## tego ekranu sama — oddaje ofertę graczowi (Player.pending_relic_offers),
## a gracz otwiera wybór klawiszem "open_relic" (Q) albo przyciskiem w HUD,
## kiedy chce. Esc odkłada wybór. Stare relikwie pozostają unikalne.

signal relic_chosen(id: String)

const FONT_TITLE := preload("res://assets/fonts/Cinzel-SemiBold.woff")
const FONT_BODY := preload("res://assets/fonts/EBGaramond-Regular.woff")
const SkillCatalog := preload("res://entities/skill_catalog.gd")
const CARD_SIZE := Vector2(340.0, 380.0)
const CARD_GAP := 24.0

var player: Player
var selected: int = 0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	visible = false

func open_for(p: Player) -> void:
	if not is_inside_tree() or not is_instance_valid(p) or p.pending_relic_offers.is_empty():
		return
	player = p
	selected = 0
	visible = true
	get_tree().paused = true
	queue_redraw()

func close_for_later() -> void:
	visible = false
	get_tree().paused = false
	Juice.play_ui_sfx_variant(Juice.SND_UI_BACK)

func _choose(index: int) -> void:
	if not visible or not is_instance_valid(player) or index < 0 or index >= player.pending_relic_offers.size():
		return
	var id: String = player.pending_relic_offers[index]
	if not player.choose_relic(id):
		return
	visible = false
	get_tree().paused = false
	Juice.play_ui_sfx(Juice.SND_UI_LEVEL_UP)
	relic_chosen.emit(id)

func _unhandled_input(event: InputEvent) -> void:
	if not visible or not is_instance_valid(player):
		return
	var count := player.pending_relic_offers.size()
	if event.is_action_pressed("ui_left"):
		selected = maxi(0, selected - 1)
		queue_redraw()
	elif event.is_action_pressed("ui_right"):
		selected = mini(count - 1, selected + 1)
		queue_redraw()
	elif event.is_action_pressed("ui_accept"):
		_choose(selected)
	elif event.is_action_pressed("ui_cancel"):
		close_for_later()
	elif event is InputEventKey and event.pressed and not event.echo:
		if event.physical_keycode >= KEY_1 and event.physical_keycode <= KEY_4:
			_choose(event.physical_keycode - KEY_1)
	get_viewport().set_input_as_handled()

func _gui_input(event: InputEvent) -> void:
	if not visible or not is_instance_valid(player):
		return
	if event is InputEventMouseMotion:
		for i in range(player.pending_relic_offers.size()):
			if _card_rect(i).has_point(event.position):
				if selected != i:
					selected = i
					queue_redraw()
				return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		for i in range(player.pending_relic_offers.size()):
			if _card_rect(i).has_point(event.position):
				accept_event()
				_choose(i)
				return

## Szerokość karty: 340 px, węższa przy 4 ofertach (Pętla Otchłani I).
func _card_w() -> float:
	var count := player.pending_relic_offers.size() if is_instance_valid(player) else 3
	return minf(CARD_SIZE.x, (get_viewport_rect().size.x - 60.0 - CARD_GAP * (count - 1)) / maxf(1.0, count))

func _card_rect(i: int) -> Rect2:
	var size := get_viewport_rect().size
	var count := player.pending_relic_offers.size() if is_instance_valid(player) else 3
	var w := _card_w()
	var total := w * count + CARD_GAP * (count - 1)
	return Rect2(Vector2((size.x - total) * 0.5 + i * (w + CARD_GAP), size.y * 0.5 - CARD_SIZE.y * 0.5 + 10.0), Vector2(w, CARD_SIZE.y))

func _draw() -> void:
	if not visible or not is_instance_valid(player):
		return
	var size := get_viewport_rect().size
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.035, 0.025, 0.06, 0.95), true)
	var title := "RELIKWIA — WYBIERZ JEDNĄ"
	var title_w := FONT_TITLE.get_string_size(title, HORIZONTAL_ALIGNMENT_LEFT, -1, 32).x
	draw_string(FONT_TITLE, Vector2((size.x - title_w) * 0.5, _card_rect(0).position.y - 34.0), title, HORIZONTAL_ALIGNMENT_LEFT, -1, 32, Color("#e8c547"))
	var text_w := _card_w() - 36.0
	for i in range(player.pending_relic_offers.size()):
		var id: String = player.pending_relic_offers[i]
		var card := _card_rect(i)
		draw_rect(card, Color(0.10, 0.08, 0.14, 0.98), true)
		draw_rect(card, Color("#e8c547") if i == selected else Color("#695d76"), false, 3.0 if i == selected else 1.0)
		var icon: Texture2D = GameUI.RELIC_ICONS.get(id)
		if icon != null:
			draw_texture_rect(icon, Rect2(card.position + Vector2((card.size.x - 96.0) * 0.5, 22), Vector2(96, 96)), false)
		draw_string(FONT_TITLE, card.position + Vector2(18, 156), str(GameUI.RELIC_NAMES.get(id, id)), HORIZONTAL_ALIGNMENT_LEFT, text_w, 23, Color("#e9e1f0"))
		draw_string(FONT_BODY, card.position + Vector2(18, 184), ", ".join(SkillCatalog.RELIC_TAGS.get(id, [])), HORIZONTAL_ALIGNMENT_LEFT, text_w, 17, Color("#93879c"))
		draw_multiline_string(FONT_BODY, card.position + Vector2(18, 222), str(GameUI.RELIC_DESCRIPTIONS.get(id, "")), HORIZONTAL_ALIGNMENT_LEFT, text_w, 21, -1, Color("#f1eaf6"))
		draw_string(FONT_BODY, card.position + Vector2(18, CARD_SIZE.y - 18.0), "%d — wybierz" % [i + 1], HORIZONTAL_ALIGNMENT_LEFT, text_w, 18, Color("#93879c"))
	var hint := "Strzałki / Enter · klawisze 1–%d · kliknięcie   ·   Esc — później" % player.pending_relic_offers.size()
	var hint_w := FONT_BODY.get_string_size(hint, HORIZONTAL_ALIGNMENT_LEFT, -1, 20).x
	draw_string(FONT_BODY, Vector2((size.x - hint_w) * 0.5, _card_rect(0).end.y + 44.0), hint, HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color("#93879c"))
