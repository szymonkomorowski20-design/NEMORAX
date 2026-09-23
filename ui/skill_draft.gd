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
	elif event is InputEventKey and event.pressed and not event.echo:
		if event.physical_keycode >= KEY_1 and event.physical_keycode <= KEY_3:
			_choose(event.physical_keycode - KEY_1)
	get_viewport().set_input_as_handled()

func _gui_input(event: InputEvent) -> void:
	if not visible:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		for i in range(player.skill_offers.size()):
			if _card_rect(i).has_point(event.position):
				_choose(i)
				accept_event()
				return

func _card_rect(i: int) -> Rect2:
	var size := get_viewport_rect().size
	return Rect2(Vector2(size.x * 0.5 - 446.0 + i * 304.0, size.y * 0.5 - 120.0), Vector2(280.0, 320.0))

func _draw() -> void:
	if not visible or not is_instance_valid(player):
		return
	var size := get_viewport_rect().size
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.035, 0.025, 0.06, 0.95), true)
	draw_string(FONT_TITLE, Vector2(size.x * 0.5 - 235.0, size.y * 0.22), "WYBIERZ RUNĘ — POZIOM %d" % player.level, HORIZONTAL_ALIGNMENT_LEFT, -1, 32, Color("#e8c547"))
	for i in range(player.skill_offers.size()):
		var id: String = player.skill_offers[i]
		var data: Dictionary = Catalog.SKILLS[id]
		var card := _card_rect(i)
		var active := i == selected
		draw_rect(card, Color(0.10, 0.08, 0.14, 0.98), true)
		draw_rect(card, Color("#e8c547") if active else Color("#695d76"), false, 3.0 if active else 1.0)
		var icon: Texture2D = Catalog.icon(id)
		if icon != null:
			draw_texture_rect(icon, Rect2(card.position + Vector2(92, 30), Vector2(96, 96)), false)
		draw_string(FONT_TITLE, card.position + Vector2(18, 165), str(data["name"]), HORIZONTAL_ALIGNMENT_LEFT, 244, 19, Color("#e9e1f0"))
		draw_string(FONT_BODY, card.position + Vector2(18, 205), "Ranga %d / %d" % [player.skill_rank(id) + 1, data["ranks"]], HORIZONTAL_ALIGNMENT_LEFT, 244, 18, Color("#e8c547"))
		draw_multiline_string(FONT_BODY, card.position + Vector2(18, 238), str(data["description"]), HORIZONTAL_ALIGNMENT_LEFT, 244, 18, -1, Color("#c8bfd0"))
		draw_string(FONT_BODY, card.position + Vector2(18, 294), "%d — wybierz" % [i + 1], HORIZONTAL_ALIGNMENT_LEFT, 244, 18, Color("#93879c"))
	draw_string(FONT_BODY, Vector2(size.x * 0.5 - 205, size.y * 0.86), "Strzałki / Enter · klawisze 1–3 · kliknięcie", HORIZONTAL_ALIGNMENT_LEFT, -1, 19, Color("#93879c"))
