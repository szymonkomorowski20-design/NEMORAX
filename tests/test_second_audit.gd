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

## A4: arena ma obraz sali jak pokoje, a wewnętrzna krawędź muru leży dokładnie
## na dotychczasowej granicy ruchu — kolizje i geometria walki bez zmian.
func test_arena_visual_wraps_unchanged_play_rect(_root: Node) -> void:
	var arena = load("res://arena.gd").new()
	var outer: Rect2 = arena._finale_visual_rect()
	NemoraxTest.assert_eq(IntegratedRoomVisual.play_rect(outer), arena.ARENA_RECT, "wnętrze muru = ARENA_RECT (kolizje bez zmian)")
	NemoraxTest.assert_true(ResourceLoader.exists(IntegratedRoomVisual.ART_ROOT + arena.FINALE_THEME + "/room_preview.png"), "grafika sali finału istnieje")
	arena.free()

## B1: „chroniony pierwszy cykl” — każda faza najpierw pokazuje każdy swój
## wzorzec raz, dopiero potem losuje z powtórzeniami.
func test_boss_first_cycle_shows_every_pattern(root: Node) -> void:
	var boss: Boss = load("res://entities/boss.tscn").instantiate()
	root.add_child(boss)
	for phase in 6:
		boss._pattern_groups = boss._build_pattern_groups(phase)
		boss._refill_unseen_patterns()
		boss._last_pattern_name = ""
		var seen := {}
		for i in boss._pattern_groups.size():
			var n := boss._choose_protected_pattern()
			seen[n] = true
			boss._last_pattern_name = n
		NemoraxTest.assert_eq(seen.size(), boss._pattern_groups.size(), "faza %d: pierwszy cykl bez powtórzeń" % phase)
	root.remove_child(boss)
	boss.queue_free()

## B3: 1000 ofert na styl (tylko miecz, tylko różdżka), kolejne poziomy
## i intencje — żadna oferta nie może mieć trzech kart martwych dla stylu
## (runy drugiej broni, Przeplot bez zmiany broni). Ziarno odtwarza ofertę.
func test_thousand_offers_never_all_dead(_root: Node) -> void:
	var SkillCatalog = load("res://entities/skill_catalog.gd")
	var intents := ["ostrze", "rozdzka", "kontra", ""]
	for style in ["sword", "wand"]:
		var offers := 0
		var dead := 0
		var run := 0
		while offers < 1000:
			var rng := RandomNumberGenerator.new()
			rng.seed = 9000 + run
			var ranks := {}
			var intent: String = intents[run % intents.size()]
			for level in range(1, 11):
				var offer: Array[String] = SkillCatalog.roll_offer(ranks, level, rng, style, intent, level <= SkillCatalog.INTENT_GUIDED_OFFERS)
				if offer.is_empty():
					continue
				offers += 1
				var pick := ""
				for id in offer:
					if SkillCatalog.useful_for(id, style):
						pick = id
						break
				if pick == "":
					dead += 1
					pick = offer[0]
				ranks[pick] = int(ranks.get(pick, 0)) + 1
			run += 1
		NemoraxTest.assert_eq(dead, 0, "styl %s: %d ofert, całkowicie martwych: %d" % [style, offers, dead])
	var a := RandomNumberGenerator.new()
	a.seed = 77
	var b := RandomNumberGenerator.new()
	b.seed = 77
	NemoraxTest.assert_eq(SkillCatalog.roll_offer({}, 4, a, "sword"), SkillCatalog.roll_offer({}, 4, b, "sword"), "to samo ziarno = ta sama oferta")

func test_weave_is_not_useful_for_single_weapon(_root: Node) -> void:
	var SkillCatalog = load("res://entities/skill_catalog.gd")
	NemoraxTest.assert_true(not SkillCatalog.useful_for("guard_weapon_weave", "sword"), "Przeplot nie jest przydatny dla samego miecza")
	NemoraxTest.assert_true(SkillCatalog.useful_for("guard_weapon_weave", "hybrid"), "ale jest dla hybrydy")
	NemoraxTest.assert_true(SkillCatalog.useful_for("guard_iron_skin", "wand"), "karty ogólne działają dla każdej broni")
	NemoraxTest.assert_true(not SkillCatalog.useful_for("wand_rapid_cast", "sword"), "runa różdżki martwa dla miecza")

## C4: ekran końca nie przyjmuje wyboru w klatce pojawienia się, a trzymany
## S (ruch w dół) nie restartuje próby — dopiero świeże wciśnięcie.
func test_end_screen_gate_ignores_held_s_and_early_input(_root: Node) -> void:
	Input.use_accumulated_input = false
	var press := InputEventKey.new()
	press.physical_keycode = KEY_S
	press.pressed = true
	Input.parse_input_event(press)
	var gate := EndScreenGate.new()
	gate.arm()
	NemoraxTest.assert_true(not gate.is_ready(), "tuż po pokazaniu ekran jeszcze nie przyjmuje wyboru")
	gate._ready_at_msec = 0
	NemoraxTest.assert_true(not gate.same_seed_pressed(), "S trzymany od chwili pokazania nie restartuje")
	var release := InputEventKey.new()
	release.physical_keycode = KEY_S
	release.pressed = false
	Input.parse_input_event(release)
	NemoraxTest.assert_true(not gate.same_seed_pressed(), "puszczony S nic nie robi")
	Input.parse_input_event(press)
	NemoraxTest.assert_true(gate.same_seed_pressed(), "świeże wciśnięcie S po odczekaniu = ta sama próba")
	Input.parse_input_event(release)
	Input.use_accumulated_input = true
