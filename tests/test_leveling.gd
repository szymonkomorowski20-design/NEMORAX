extends RefCounted
## System poziomów i punktów statystyk (player.gd) — 1 XP na zabójstwo, co
## xp_per_level (=3) XP daje +1 level aż do max_level (=10), każdy level to
## 1 punkt do wydania w jedną z 6 statystyk (STAT_KEYS).

func _fresh_player(root: Node) -> Player:
	var player: Player = load("res://entities/player.tscn").instantiate()
	root.add_child(player)
	return player

func _cleanup(player: Node, root: Node) -> void:
	root.remove_child(player)
	player.queue_free()

func test_three_kills_gives_one_level(root: Node) -> void:
	var player := _fresh_player(root)
	NemoraxTest.assert_eq(player.level, 0, "gracz zaczyna na poziomie 0")
	player.gain_xp()
	player.gain_xp()
	NemoraxTest.assert_eq(player.level, 0, "2 zabójstwa to jeszcze nie level")
	player.gain_xp() # 3.
	NemoraxTest.assert_eq(player.level, 1, "3. zabójstwo powinno dać level 1")
	NemoraxTest.assert_eq(player.unspent_stat_points, 1, "level powinien dać 1 punkt do wydania")
	_cleanup(player, root)

func test_level_caps_at_max_and_xp_stops_counting(root: Node) -> void:
	var player := _fresh_player(root)
	for i in range(100): # dużo więcej niż potrzeba na 10 poziomów (30 zabójstw)
		player.gain_xp()
	NemoraxTest.assert_eq(player.level, player.max_level, "level nie powinien przekroczyć max_level")
	NemoraxTest.assert_eq(player.unspent_stat_points, player.max_level, "punkty = dokładnie tyle ile poziomów, bez nadmiaru")
	_cleanup(player, root)

func test_spend_stat_point_updates_effective_stats(root: Node) -> void:
	var player := _fresh_player(root)
	player.gain_xp()
	player.gain_xp()
	player.gain_xp() # level 1, 1 punkt do wydania
	var base_health: float = player.base_max_health

	var spent := player.spend_stat_point("health")
	NemoraxTest.assert_true(spent, "wydanie punktu powinno się udać, gdy jest dostępny")
	NemoraxTest.assert_eq(player.unspent_stat_points, 0, "punkt powinien zostać zużyty")
	NemoraxTest.assert_almost_eq(player.max_health, base_health + player.health_per_point, 0.01, "max_health powinien wzrosnąć o health_per_point")

	var spent_again := player.spend_stat_point("health")
	NemoraxTest.assert_true(not spent_again, "bez punktów wydanie powinno zwrócić false i nic nie zmieniać")
	NemoraxTest.assert_almost_eq(player.max_health, base_health + player.health_per_point, 0.01, "nieudane wydanie nie powinno zmienić statystyki")
	_cleanup(player, root)

func test_damage_point_scales_both_weapons(root: Node) -> void:
	var player := _fresh_player(root)
	var base_sword: float = player.base_attack_damage
	var base_wand: float = player.base_wand_damage
	player.gain_xp(); player.gain_xp(); player.gain_xp()
	player.spend_stat_point("damage")
	NemoraxTest.assert_almost_eq(player.attack_damage, base_sword * (1.0 + player.damage_bonus_per_point), 0.01, "punkt w atak powinien podbić obrażenia miecza")
	NemoraxTest.assert_almost_eq(player.wand_damage, base_wand * (1.0 + player.damage_bonus_per_point), 0.01, "punkt w atak powinien podbić też obrażenia różdżki")
	_cleanup(player, root)

func test_game_flow_persists_level_and_points_across_rooms(root: Node) -> void:
	var player := _fresh_player(root)
	player.gain_xp(); player.gain_xp(); player.gain_xp()
	player.gain_xp(); player.gain_xp(); player.gain_xp() # level 2, 2 punkty
	player.spend_stat_point("speed")

	GameFlow.capture_player_state(player)
	_cleanup(player, root)

	var player2 := _fresh_player(root)
	GameFlow.apply_player_state(player2)
	NemoraxTest.assert_eq(player2.level, 2, "level powinien przetrwać przejście do nowej instancji Playera")
	NemoraxTest.assert_eq(player2.unspent_stat_points, 1, "1 punkt wydany, 1 powinien zostać niewydany")
	NemoraxTest.assert_eq(player2.stat_points["speed"], 1, "przydział punktu w speed powinien się odtworzyć")
	NemoraxTest.assert_almost_eq(player2.max_speed, player2.base_max_speed * (1.0 + player2.speed_bonus_per_point), 0.01, "max_speed powinien odzwierciedlać odtworzony punkt")
	_cleanup(player2, root)
	GameFlow.saved_player_state = {}
