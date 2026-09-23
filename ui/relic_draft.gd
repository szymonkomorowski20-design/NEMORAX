extends Control
class_name RelicDraft
## Skrzynia: wybór jednej z trzech relikwii. Stare relikwie pozostają unikalne.

const FONT_TITLE := preload("res://assets/fonts/Cinzel-SemiBold.woff")
const FONT_BODY := preload("res://assets/fonts/EBGaramond-Regular.woff")
var chest: Chest
var offers: Array[String] = []
var selected: int = 0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	visible = false

func open(source: Chest, choices: Array[String]) -> void:
	if not is_inside_tree() or not is_instance_valid(source) or choices.is_empty():
		return
	chest = source
	offers = choices.duplicate()
	selected = 0
	visible = true
	get_tree().paused = true
	if get_tree().current_scene != null:
		GameFlow.capture_player_state(chest.player)
		GameFlow.saved_player_state["pending_chest_offers"] = offers.duplicate()
		GameFlow.saved_player_state["pending_chest_room"] = [GameFlow.current_room_pos.x, GameFlow.current_room_pos.y]
		GameFlow._save_progress()
	queue_redraw()

func _choose(index: int) -> void:
	if not visible or not is_instance_valid(chest) or index < 0 or index >= offers.size():
		return
	if not chest.choose(offers[index]):
		return
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
		selected = mini(offers.size() - 1, selected + 1)
		queue_redraw()
	elif event.is_action_pressed("ui_accept"):
		_choose(selected)
	elif event is InputEventKey and event.pressed and not event.echo:
		if event.physical_keycode >= KEY_1 and event.physical_keycode <= KEY_3:
			_choose(event.physical_keycode - KEY_1)
	get_viewport().set_input_as_handled()

func _gui_input(event: InputEvent) -> void:
	if not visible:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		for i in range(offers.size()):
			if _card_rect(i).has_point(event.position):
				_choose(i)
				accept_event()
				return

func _card_rect(i: int) -> Rect2:
	var size := get_viewport_rect().size
	var left := size.x * 0.5 - (offers.size() * 304.0 - 24.0) * 0.5
	return Rect2(Vector2(left + i * 304.0, size.y * 0.5 - 120.0), Vector2(280.0, 320.0))

func _draw() -> void:
	if not visible:
		return
	var size := get_viewport_rect().size
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.035, 0.025, 0.06, 0.95), true)
	draw_string(FONT_TITLE, Vector2(size.x * 0.5 - 270.0, size.y * 0.22), "SKRZYNIA — WYBIERZ RELIKWIĘ", HORIZONTAL_ALIGNMENT_LEFT, -1, 31, Color("#e8c547"))
	for i in range(offers.size()):
		var id := offers[i]
		var card := _card_rect(i)
		draw_rect(card, Color(0.10, 0.08, 0.14, 0.98), true)
		draw_rect(card, Color("#e8c547") if i == selected else Color("#695d76"), false, 3.0 if i == selected else 1.0)
		var icon: Texture2D = load("res://assets/sprites/ui/relic_%s.png" % id)
		if icon != null:
			draw_texture_rect(icon, Rect2(card.position + Vector2(92, 30), Vector2(96, 96)), false)
		draw_string(FONT_TITLE, card.position + Vector2(18, 165), str(Player.UPGRADE_LABELS[id]), HORIZONTAL_ALIGNMENT_LEFT, 244, 20, Color("#e9e1f0"))
		draw_multiline_string(FONT_BODY, card.position + Vector2(18, 208), str(GameUI.RELIC_DESCRIPTIONS.get(id, "")), HORIZONTAL_ALIGNMENT_LEFT, 244, 19, -1, Color("#c8bfd0"))
		draw_string(FONT_BODY, card.position + Vector2(18, 294), "%d — wybierz" % [i + 1], HORIZONTAL_ALIGNMENT_LEFT, 244, 18, Color("#93879c"))
	draw_string(FONT_BODY, Vector2(size.x * 0.5 - 205, size.y * 0.86), "Strzałki / Enter · klawisze 1–3 · kliknięcie", HORIZONTAL_ALIGNMENT_LEFT, -1, 19, Color("#93879c"))
