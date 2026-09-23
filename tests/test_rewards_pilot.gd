extends RefCounted
## Paczka 6 (AUDYT A11/A12/A16, E3) + decyzja autora 23.09: czytelne karty,
## oferty z ziarna z gwarancją użytecznej karty, przerzut, intencje startowe
## i ODŁOŻONE nagrody (awans/skrzynia nie otwierają wyboru same).

const Catalog := preload("res://entities/skill_catalog.gd")

func _player(root: Node) -> Player:
	var p: Player = load("res://entities/player.tscn").instantiate()
	root.add_child(p)
	return p

func _cleanup(node: Node, root: Node) -> void:
	root.remove_child(node)
	node.queue_free()

func test_rank_text_picks_the_value_of_that_rank(_root: Node) -> void:
	NemoraxTest.assert_eq(Catalog.rank_text("blade_wide_sweep", 1), "Kąt miecza: 125°.", "ranga 1")
	NemoraxTest.assert_eq(Catalog.rank_text("blade_wide_sweep", 3), "Kąt miecza: 175°.", "ranga 3")
	NemoraxTest.assert_eq(Catalog.rank_text("blade_sunder", 2), "Co 3. cios w cel: +100% obrażeń.", "grupy z kropką i procentem")
	NemoraxTest.assert_eq(Catalog.rank_text("void_dash_ring", 2), "Po dashu krąg 95 px, 50% obrażeń.", "kilka grup w jednym opisie")
	for id in Catalog.SKILLS:
		for r in range(1, int(Catalog.SKILLS[id]["ranks"]) + 1):
			NemoraxTest.assert_true(not "/" in Catalog.rank_text(id, r), "%s ranga %d nie może zawierać ciągu a/b" % [id, r])

## Liczby z kart = liczby mechaniki (odbiór Paczki 6: "brak rozjazdu").
func test_card_numbers_match_mechanics(root: Node) -> void:
	var p := _player(root)
	var base_hp := p.max_health
	p.skill_ranks["guard_iron_skin"] = 2
	p._recompute_effective_stats()
	NemoraxTest.assert_almost_eq(p.max_health - base_hp, 30.0, 0.01, "Kamienna skóra 2 = +30 życia, jak na karcie")
	p.skill_ranks["wand_mana_weave"] = 3
	NemoraxTest.assert_almost_eq(p._wand_mana_cost(), maxf(15.0, p.wand_mana_cost - 6.0), 0.01, "Splot many 3 = −6 many, min. 15")
	p.skill_ranks["guard_quickstep"] = 1
	NemoraxTest.assert_almost_eq(p._effective_dash_cooldown(), maxf(0.35, p.dash_cooldown * 0.92), 0.001, "Krótki oddech 1 = −8% odnowy")
	NemoraxTest.assert_eq(p.attack_angle_degrees + 25.0 * 1, 125.0, "Szeroki zamach 1 = 125°")
	_cleanup(p, root)

func test_offers_are_reproducible_from_seed(root: Node) -> void:
	GameFlow.reset_run(777)
	var a := _player(root)
	a.pending_skill_choices = 1
	a.level = 1
	var first := a.ensure_skill_offer().duplicate()
	_cleanup(a, root)
	GameFlow.reset_run(777)
	var b := _player(root)
	b.pending_skill_choices = 1
	b.level = 1
	NemoraxTest.assert_eq(b.ensure_skill_offer(), first, "ten sam seed i te same decyzje = te same karty")
	_cleanup(b, root)
	GameFlow.reset_run()

func test_offer_always_has_a_card_for_current_weapon(_root: Node) -> void:
	for s in 200:
		var rng := RandomNumberGenerator.new()
		rng.seed = s
		for weapon in ["sword", "wand"]:
			var offer := Catalog.roll_offer({}, 5, rng, weapon)
			var useful := false
			for id in offer:
				if Catalog.weapon_of(id) in [weapon, "any"]:
					useful = true
			NemoraxTest.assert_true(useful, "seed %d, broń %s: brak użytecznej karty w %s" % [s, weapon, offer])

func test_intent_guides_first_offers_only(_root: Node) -> void:
	for intent in Catalog.INTENTS:
		var pool: Array = Catalog.INTENTS[intent]["pool"]
		for s in 50:
			var rng := RandomNumberGenerator.new()
			rng.seed = s
			var offer := Catalog.roll_offer({}, 1, rng, "", intent, true)
			var hit := false
			for id in offer:
				if id in pool:
					hit = true
			NemoraxTest.assert_true(hit, "intencja %s musi dać kartę ze swojej puli (seed %d)" % [intent, s])
		# Każda intencja rozwija się w co najmniej dwa różne kierunki buildu.
		var weapons := {}
		for id in pool:
			weapons[Catalog.weapon_of(id)] = true
		var tags := {}
		for id in pool:
			for t in Catalog.SKILL_TAGS.get(id, []):
				tags[t] = true
		NemoraxTest.assert_true(tags.size() >= 4, "intencja %s ma zróżnicowane tagi (%d)" % [intent, tags.size()])

func test_single_reroll_changes_offer_and_is_spent(root: Node) -> void:
	var p := _player(root)
	p.pending_skill_choices = 1
	p.level = 4
	var before := p.ensure_skill_offer().duplicate()
	NemoraxTest.assert_true(p.reroll_skill_offer(), "pierwszy przerzut działa")
	var overlap := 0
	for id in p.skill_offers:
		if id in before:
			overlap += 1
	NemoraxTest.assert_true(overlap < 3, "przerzut daje inną trójkę")
	NemoraxTest.assert_true(not p.reroll_skill_offer(), "drugi przerzut w tej próbie odmówiony")
	_cleanup(p, root)

func test_reroll_and_pending_relics_survive_save(root: Node) -> void:
	var p := _player(root)
	p.skill_rerolls = 0
	p.pending_relic_offers.assign(["momentum", "iron_heart"])
	p.skill_offer_count = 5
	GameFlow.capture_player_state(p)
	var q := _player(root)
	GameFlow.apply_player_state(q)
	NemoraxTest.assert_eq(q.skill_rerolls, 0, "wykorzystany przerzut nie wraca po wczytaniu")
	NemoraxTest.assert_eq(q.pending_relic_offers, ["momentum", "iron_heart"] as Array[String], "odłożona relikwia czeka po wczytaniu")
	NemoraxTest.assert_eq(q.skill_offer_count, 5, "licznik ofert (ziarno) zapisany")
	GameFlow.saved_player_state = {}
	_cleanup(p, root)
	_cleanup(q, root)

## Decyzja autora: awans NIE otwiera wyboru sam, HUD pokazuje przycisk.
func test_level_up_does_not_open_draft_automatically(root: Node) -> void:
	var old_map := GameFlow.room_map
	var old_pos := GameFlow.current_room_pos
	GameFlow.room_map = {Vector2i.ZERO: {"type": GameFlow.RoomType.START, "chapter": -1, "enemy_index": -1, "cleared": true, "has_chest": false, "chest_opened": false}}
	GameFlow.current_room_pos = Vector2i.ZERO
	var room = load("res://rooms/room.tscn").instantiate()
	root.add_child(room)
	room.player.gain_xp(10.0)
	NemoraxTest.assert_true(room.player.pending_skill_choices > 0, "awans daje runę do wyboru")
	NemoraxTest.assert_true(not room._skill_draft.visible, "ale okno nie otwiera się samo")
	NemoraxTest.assert_true(not room.get_tree().paused, "gra nie zatrzymuje się sama")
	room.ui._draw_reward_buttons()
	NemoraxTest.assert_true(room.ui._reward_button_rects.has("level"), "HUD pokazuje przycisk awansu")
	RewardPrompt.open_runes_or_points(room.player, room._skill_draft, room.stats_screen)
	NemoraxTest.assert_true(room._skill_draft.visible, "przycisk / R otwiera wybór")
	room._skill_draft.close_for_later()
	NemoraxTest.assert_true(not room._skill_draft.visible and room.player.pending_skill_choices > 0, "Esc odkłada, runa dalej czeka")
	room.get_tree().paused = false
	root.remove_child(room)
	room.queue_free()
	GameFlow.room_map = old_map
	GameFlow.current_room_pos = old_pos

func test_chest_hands_offer_to_player_and_choice_waits(root: Node) -> void:
	var old_map := GameFlow.room_map
	var old_pos := GameFlow.current_room_pos
	GameFlow.room_map = {Vector2i.ZERO: {"type": GameFlow.RoomType.START, "chapter": -1, "enemy_index": -1, "cleared": true, "has_chest": true, "chest_opened": false}}
	GameFlow.current_room_pos = Vector2i.ZERO
	var room = load("res://rooms/room.tscn").instantiate()
	root.add_child(room)
	var chest: Chest = load("res://rooms/chest.tscn").instantiate()
	room.add_child(chest)
	chest.player = room.player
	chest.selection_requested.connect(room._on_chest_selection_requested.bind(chest))
	chest._open()
	NemoraxTest.assert_eq(room.player.pending_relic_offers.size(), 3, "oferta trafia do gracza")
	NemoraxTest.assert_true(not room._relic_draft.visible, "wybór nie otwiera się sam")
	NemoraxTest.assert_true(GameFlow.room_map[Vector2i.ZERO]["chest_opened"], "skrzynia zapisana jako otwarta")
	room.ui._draw_reward_buttons()
	NemoraxTest.assert_true(room.ui._reward_button_rects.has("relic"), "HUD pokazuje przycisk relikwii")
	room._relic_draft.open_for(room.player)
	var id: String = room.player.pending_relic_offers[0]
	room._relic_draft._choose(0)
	NemoraxTest.assert_true(room.player.has_upgrade(id), "wybrana relikwia przyznana")
	NemoraxTest.assert_true(room.player.pending_relic_offers.is_empty(), "przycisk znika po wyborze")
	room.get_tree().paused = false
	root.remove_child(room)
	room.queue_free()
	GameFlow.room_map = old_map
	GameFlow.current_room_pos = old_pos

func test_xp_bar_uses_real_threshold_and_max(root: Node) -> void:
	var p := _player(root)
	p.level = 5 # próg 3 XP
	p.xp = 1.5
	NemoraxTest.assert_almost_eq(p.xp_ratio(), 0.5, 0.001, "połowa progu 3 XP = 50%")
	p.level = p.max_level
	NemoraxTest.assert_almost_eq(p.xp_ratio(), 0.0, 0.001, "xp_ratio na maksimum = 0, HUD pokazuje pełny pasek i MAX")
	_cleanup(p, root)

func test_stat_preview_matches_real_spend(root: Node) -> void:
	var p := _player(root)
	p.unspent_stat_points = 1
	var preview := p.stat_point_preview("health")
	var before := p.max_health
	p.spend_stat_point("health")
	NemoraxTest.assert_eq(preview, "Maks. życie %.0f → %.0f" % [before, p.max_health], "podgląd = prawdziwy wynik wydania punktu")
	_cleanup(p, root)
