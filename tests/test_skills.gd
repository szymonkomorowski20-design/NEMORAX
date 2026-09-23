extends RefCounted

func _fresh_player(root: Node) -> Player:
	var player: Player = load("res://entities/player.tscn").instantiate()
	root.add_child(player)
	return player

func _cleanup(player: Player, root: Node) -> void:
	root.remove_child(player)
	player.queue_free()

func test_level_creates_persistent_three_card_offer(root: Node) -> void:
	var player := _fresh_player(root)
	player.gain_xp(3.0)
	NemoraxTest.assert_eq(player.pending_skill_choices, 1, "awans powinien dać wybór runy")
	var first := player.ensure_skill_offer().duplicate()
	NemoraxTest.assert_eq(first.size(), 3, "oferta ma trzy karty")
	NemoraxTest.assert_eq(player.ensure_skill_offer(), first, "ponowne otwarcie nie losuje oferty")
	GameFlow.capture_player_state(player)
	_cleanup(player, root)
	var restored := _fresh_player(root)
	GameFlow.apply_player_state(restored)
	NemoraxTest.assert_eq(restored.ensure_skill_offer(), first, "oferta musi przetrwać zmianę pokoju")
	NemoraxTest.assert_true(restored.choose_skill(first[0]), "można wybrać kartę z oferty")
	NemoraxTest.assert_eq(restored.pending_skill_choices, 0, "wybór konsumuje jeden awans")
	NemoraxTest.assert_eq(restored.skill_rank(first[0]), 1, "umiejętność dostała rangę")
	_cleanup(restored, root)
	GameFlow.saved_player_state = {}

func test_iron_skin_adds_only_new_health_delta(root: Node) -> void:
	var player := _fresh_player(root)
	player.health = 43.0
	player.pending_skill_choices = 1
	player.skill_offers = ["guard_iron_skin"]
	NemoraxTest.assert_true(player.choose_skill("guard_iron_skin"), "można wybrać kamienną skórę")
	NemoraxTest.assert_almost_eq(player.max_health, 115.0, 0.01, "ranga 1 to +15 HP")
	NemoraxTest.assert_almost_eq(player.health, 58.0, 0.01, "obecne HP rośnie o deltę, bez pełnego leczenia")
	player.pending_skill_choices = 1
	player.skill_offers = ["guard_iron_skin"]
	player.choose_skill("guard_iron_skin")
	NemoraxTest.assert_almost_eq(player.max_health, 130.0, 0.01, "ranga 2 to +30 HP łącznie")
	NemoraxTest.assert_almost_eq(player.health, 73.0, 0.01, "kolejna ranga nie leczy do pełna")
	_cleanup(player, root)

func test_split_volley_caps_damage_to_one_large_target(root: Node) -> void:
	var player := _fresh_player(root)
	player.skill_ranks["wand_split_bolt"] = 2
	var enemy := Node2D.new()
	root.add_child(enemy)
	NemoraxTest.assert_almost_eq(player.cap_volley_damage(enemy, 7, 10.0, 10.0), 10.0, 0.01, "pocisk główny zadaje pełne obrażenia")
	NemoraxTest.assert_almost_eq(player.cap_volley_damage(enemy, 7, 6.5, 10.0), 6.5, 0.01, "pierwszy boczny w limicie")
	NemoraxTest.assert_almost_eq(player.cap_volley_damage(enemy, 7, 6.5, 10.0), 1.5, 0.01, "salwa ma limit 1,8x")
	root.remove_child(enemy)
	enemy.queue_free()
	_cleanup(player, root)

func test_third_cut_requires_maxed_twin_cut(_root: Node) -> void:
	var catalog = load("res://entities/skill_catalog.gd")
	NemoraxTest.assert_true("blade_third_cut" not in catalog.available({}), "Trzeci rytm nie może wypaść przed Podwójnym ciosem")
	NemoraxTest.assert_true("blade_third_cut" not in catalog.available({"blade_twin_cut": 1}), "ranga 1 Podwójnego ciosu to za mało")
	NemoraxTest.assert_true("blade_third_cut" in catalog.available({"blade_twin_cut": 2}), "po randze 2 Trzeci rytm staje się dostępny")

func test_wand_cost_and_attack_speed_skills(root: Node) -> void:
	var player := _fresh_player(root)
	player.skill_ranks["wand_mana_weave"] = 3
	player.skill_ranks["wand_rapid_cast"] = 3
	player.current_weapon = "wand"
	player._swing_weapon = "wand"
	NemoraxTest.assert_almost_eq(player._wand_mana_cost(), 19.0, 0.01, "trzy rangi oszczędzają 6 many")
	NemoraxTest.assert_almost_eq(player._attack_speed_multiplier(), 1.24, 0.01, "trzy rangi zwiększają tempo różdżki o 24%")
	player.mana = 18.0
	NemoraxTest.assert_true(not player._can_afford_attack(), "nie można strzelać poniżej kosztu po zniżce")
	player.mana = 19.0
	NemoraxTest.assert_true(player._can_afford_attack(), "można strzelać po osiągnięciu obniżonego kosztu")
	_cleanup(player, root)

func test_quickstep_and_breath_scope(root: Node) -> void:
	var player := _fresh_player(root)
	player.skill_ranks["guard_quickstep"] = 3
	NemoraxTest.assert_almost_eq(player._effective_dash_cooldown(), 0.456, 0.001, "trzy rangi skracają odnowę dasha o 24%")
	player._second_breath_scope = "room:1:1"
	player._second_breath_used = true
	player.enter_breath_scope("room:1:1")
	NemoraxTest.assert_true(player._second_breath_used, "ponowne wejście do tego samego pokoju nie resetuje uratowania")
	player.enter_breath_scope("room:2:1")
	NemoraxTest.assert_true(not player._second_breath_used, "nowy pokój odnawia Drugi oddech")
	_cleanup(player, root)

func test_second_breath_saves_one_lethal_hit_per_room(root: Node) -> void:
	var old_reduce := Palette.reduce_flashing
	Palette.reduce_flashing = true
	var player := _fresh_player(root)
	player.skill_ranks["guard_second_breath"] = 1
	player.enter_breath_scope("room:trial")
	player.take_damage(player.health + 10.0)
	NemoraxTest.assert_almost_eq(player.health, 1.0, 0.01, "Drugi oddech zostawia 1 HP po pierwszym ciosie śmiertelnym")
	NemoraxTest.assert_true(player.state != Player.State.DEAD, "gracz przeżywa pierwsze śmiertelne trafienie")
	player._invuln_timer = 0.0
	player.take_damage(2.0)
	NemoraxTest.assert_eq(player.state, Player.State.DEAD, "kolejny śmiertelny cios w tym samym pokoju zabija")
	_cleanup(player, root)
	Palette.reduce_flashing = old_reduce
