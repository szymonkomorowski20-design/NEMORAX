extends RefCounted
## Drugi audyt nagrania (24.09): okno statystyk bez ucinania i prześwitów (A1),
## stany zagrożeń finału — zapowiedź / aktywne / wygasłe (A3).

func _cleanup(node: Node, root: Node) -> void:
	root.get_tree().paused = false
	root.remove_child(node)
	node.queue_free()

func test_stats_effects_wrap_and_scroll(root: Node) -> void:
	var layer: CanvasLayer = load("res://ui/stats_screen.tscn").instantiate()
	root.add_child(layer)
	var stats = layer.get_node("StatsScreen")
	var player: Player = load("res://entities/player.tscn").instantiate()
	root.add_child(player)
	stats.player = player
	var long_text := "Teraz: +20 maks. staminy — więcej bloków i dashy.\nW finale: Faza Siła NIE wycisza dźwięku: usłyszysz zapowiedzi Nemoraksa."
	var h_long: float = stats._entry_height({"text": long_text}, 600.0)
	var h_short: float = stats._entry_height({"text": "Krótko."}, 600.0)
	NemoraxTest.assert_true(h_long > h_short + 10.0, "długi opis dostaje więcej wysokości (zawijanie, nie ucinanie)")
	stats._effects_total = 12
	stats.scroll_effects(50)
	NemoraxTest.assert_eq(stats._effects_scroll, 11, "przewijanie nie wychodzi za ostatni wpis")
	stats.scroll_effects(-50)
	NemoraxTest.assert_eq(stats._effects_scroll, 0, "ani przed pierwszy")
	stats.open(player)
	NemoraxTest.assert_eq(stats._effects_scroll, 0, "otwarcie zaczyna od początku listy")
	_cleanup(player, root)
	_cleanup(layer, root)

func test_world_messages_hide_under_modal(root: Node) -> void:
	var layer: CanvasLayer = load("res://ui/ui.tscn").instantiate()
	root.add_child(layer)
	var ui: GameUI = layer.get_node("UI")
	NemoraxTest.assert_true(ui.world_messages_visible(), "bez okna komunikaty widoczne")
	root.get_tree().paused = true
	NemoraxTest.assert_true(not ui.world_messages_visible(), "pod modalnym oknem (pauza) drwiny i nagrody schowane")
	_cleanup(layer, root)

func test_zone_fades_without_damage(root: Node) -> void:
	var player: Player = load("res://entities/player.tscn").instantiate()
	root.add_child(player)
	var zone: Node2D = load("res://entities/damage_zone.tscn").instantiate()
	root.add_child(zone)
	zone.global_position = player.global_position
	zone._is_active = true
	zone._active_timer = 0.01
	zone._tick_timer = 5.0
	zone._physics_process(0.05)
	NemoraxTest.assert_true(zone._fade_timer > 0.0 and not zone.is_queued_for_deletion(), "po aktywnej fazie strefa wygasa, nie znika w klatce")
	var hp := player.health
	zone._physics_process(0.1)
	NemoraxTest.assert_almost_eq(player.health, hp, 0.01, "wygasająca strefa nie rani")
	_cleanup(zone, root)
	_cleanup(player, root)

func test_seal_flashes_after_explosion_once(root: Node) -> void:
	var player: Player = load("res://entities/player.tscn").instantiate()
	root.add_child(player)
	var seal: Node2D = load("res://entities/seal.tscn").instantiate()
	root.add_child(seal)
	seal.player = player
	seal.global_position = player.global_position
	seal._timer = 0.01
	var hp := player.health
	seal._physics_process(0.05)
	NemoraxTest.assert_true(player.health < hp, "wybuch rani")
	NemoraxTest.assert_true(seal._flash > 0.0 and not seal.is_queued_for_deletion(), "po wybuchu krótki rozbłysk")
	player._invuln_timer = 0.0
	var hp2 := player.health
	seal._physics_process(0.05)
	NemoraxTest.assert_almost_eq(player.health, hp2, 0.01, "rozbłysk nie rani drugi raz")
	_cleanup(seal, root)
	_cleanup(player, root)
