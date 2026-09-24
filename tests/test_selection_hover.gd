extends RefCounted
## Najechanie kursorem wybiera tę samą kartę, którą można kliknąć.

func _motion(pos: Vector2) -> InputEventMouseMotion:
	var event := InputEventMouseMotion.new()
	event.position = pos
	return event

func _cleanup(node: Node, root: Node) -> void:
	root.remove_child(node)
	node.queue_free()

func test_skill_cards_follow_mouse(root: Node) -> void:
	var player: Player = load("res://entities/player.tscn").instantiate()
	root.add_child(player)
	player.skill_offers.assign(["blade_wide_sweep", "guard_iron_skin", "wand_mana_weave"])
	var panel := SkillDraft.new()
	root.add_child(panel)
	panel.player = player
	panel.visible = true
	panel._gui_input(_motion(panel._card_rect(2).get_center()))
	NemoraxTest.assert_eq(panel.selected, 2, "trzecia runa powinna podświetlić się po najechaniu")
	_cleanup(panel, root)
	_cleanup(player, root)

func test_relic_cards_follow_mouse(root: Node) -> void:
	var player: Player = load("res://entities/player.tscn").instantiate()
	root.add_child(player)
	player.pending_relic_offers.assign(["momentum", "iron_heart"])
	var panel := RelicDraft.new()
	root.add_child(panel)
	panel.player = player
	panel.visible = true
	panel._gui_input(_motion(panel._card_rect(1).get_center()))
	NemoraxTest.assert_eq(panel.selected, 1, "druga relikwia powinna podświetlić się po najechaniu")
	_cleanup(panel, root)
	_cleanup(player, root)

func test_pact_and_intent_cards_follow_mouse(root: Node) -> void:
	var pact := PactSelect.new()
	root.add_child(pact)
	pact.visible = true
	pact._gui_input(_motion(pact._card_rect(1).get_center()))
	NemoraxTest.assert_eq(pact.selected, 1, "drugi pakt powinien podświetlić się po najechaniu")
	_cleanup(pact, root)
	var intent := IntentSelect.new()
	root.add_child(intent)
	intent.visible = true
	intent._gui_input(_motion(intent._card_rect(2).get_center()))
	NemoraxTest.assert_eq(intent.selected, 2, "trzecia intencja powinna podświetlić się po najechaniu")
	_cleanup(intent, root)

func test_stat_rows_follow_mouse(root: Node) -> void:
	var player: Player = load("res://entities/player.tscn").instantiate()
	root.add_child(player)
	var panel := StatsScreen.new()
	root.add_child(panel)
	panel.player = player
	panel.visible = true
	panel._unhandled_input(_motion(Vector2(panel.LEFT_PANEL.position.x + 40.0, panel.LEFT_PANEL.position.y + 32.0 + 2.0 * 34.0 - 12.0)))
	NemoraxTest.assert_eq(panel._selected_index, 2, "trzecia statystyka powinna podświetlić się po najechaniu")
	_cleanup(panel, root)
	_cleanup(player, root)

func test_echo_selection_survives_panel_detach(root: Node) -> void:
	var panel := MenuListPanel.new()
	root.add_child(panel)
	panel.open("Komnata Echa", ["Nekravor"], true)
	var chosen := [-1]
	panel.chosen.connect(func(index: int):
		chosen[0] = index
		root.remove_child(panel)
	)
	var accept := InputEventAction.new()
	accept.action = "ui_accept"
	accept.pressed = true
	panel._unhandled_input(accept)
	NemoraxTest.assert_eq(chosen[0], 0, "wybór bossa powinien wyemitować indeks przed odłączeniem panelu")
	panel.queue_free()
