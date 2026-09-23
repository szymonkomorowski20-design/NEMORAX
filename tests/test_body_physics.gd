extends RefCounted
## Decyzje autora 23.09: ciała nie przenikają się (odpychanie na krawędź
## dotyku), dotyk nadal rani; ciała pokonanych wrogów znikają; w mroku boss
## poza kręgiem niewidoczny, a gracz rysowany nad wrogami.

func _cleanup(nodes: Array, root: Node) -> void:
	for n in nodes:
		if is_instance_valid(n) and n.get_parent() == root:
			root.remove_child(n)
			n.queue_free()

func test_player_is_pushed_out_of_heavy_enemy(root: Node) -> void:
	var p: Player = load("res://entities/player.tscn").instantiate()
	root.add_child(p)
	var boss: Boss = load("res://entities/boss.tscn").instantiate()
	root.add_child(boss)
	boss.global_position = Vector2(600, 400)
	p.global_position = boss.global_position + Vector2(30, 0)
	var boss_before := boss.global_position
	p._resolve_body_overlaps()
	var d := p.global_position.distance_to(boss.global_position)
	NemoraxTest.assert_almost_eq(d, p.radius + boss.radius, 0.5, "gracz wypchnięty dokładnie na krawędź dotyku")
	NemoraxTest.assert_eq(boss.global_position, boss_before, "ciężki boss nie ustępuje")
	_cleanup([p, boss], root)

func test_light_enemy_and_player_split_the_push(root: Node) -> void:
	var p: Player = load("res://entities/player.tscn").instantiate()
	root.add_child(p)
	var e: Incarnation = load("res://entities/random_enemies/chaser.tscn").instantiate()
	root.add_child(e)
	e.arena_rect = Rect2(0, 0, 1280, 720)
	e.global_position = Vector2(600, 400)
	p.global_position = Vector2(620, 400)
	p._resolve_body_overlaps()
	NemoraxTest.assert_true(p.global_position.distance_to(e.global_position) >= p.radius + e.radius - 0.5, "po rozsunięciu brak nakładania")
	NemoraxTest.assert_true(e.global_position.x < 600.0, "lekki wróg też ustąpił")
	_cleanup([p, e], root)

func test_dash_passes_through_bodies(root: Node) -> void:
	var p: Player = load("res://entities/player.tscn").instantiate()
	root.add_child(p)
	var boss: Boss = load("res://entities/boss.tscn").instantiate()
	root.add_child(boss)
	boss.global_position = Vector2(600, 400)
	p.global_position = boss.global_position + Vector2(30, 0)
	p.state = Player.State.DASHING
	var before := p.global_position
	p._resolve_body_overlaps()
	NemoraxTest.assert_eq(p.global_position, before, "w dashu gracz przenika (ucieczka spod bossa)")
	_cleanup([p, boss], root)

func test_enemies_do_not_stack(root: Node) -> void:
	var a: Incarnation = load("res://entities/random_enemies/chaser.tscn").instantiate()
	var b: Incarnation = load("res://entities/random_enemies/chaser.tscn").instantiate()
	for e in [a, b]:
		root.add_child(e)
		e.arena_rect = Rect2(0, 0, 1280, 720)
	a.global_position = Vector2(500, 300)
	b.global_position = Vector2(510, 300)
	for i in 12: # po połowie na każdego — zbiega w kilka klatek
		a._separate_from_other_bodies()
		b._separate_from_other_bodies()
	NemoraxTest.assert_true(a.global_position.distance_to(b.global_position) >= a.radius + b.radius - 1.0, "wrogowie się rozsunęli (d=%.1f)" % a.global_position.distance_to(b.global_position))
	_cleanup([a, b], root)

func test_touch_at_body_edge_still_hurts(root: Node) -> void:
	var p: Player = load("res://entities/player.tscn").instantiate()
	root.add_child(p)
	var e: Incarnation = load("res://entities/random_enemies/chaser.tscn").instantiate()
	root.add_child(e)
	e.player = p
	p.global_position = Vector2(400, 400)
	e.global_position = p.global_position + Vector2(p.radius + e.radius + 1.0, 0)
	var hp := p.health
	e._check_contact()
	NemoraxTest.assert_true(p.health < hp, "dotyk na krawędzi ciał nadal rani")
	_cleanup([p, e], root)

func test_corpse_fades_and_stops_being_a_target(root: Node) -> void:
	var e: Incarnation = load("res://entities/random_enemies/chaser.tscn").instantiate()
	root.add_child(e)
	e.take_damage(99999.0)
	NemoraxTest.assert_true(e.is_dead, "wróg martwy")
	NemoraxTest.assert_true(not e.is_in_group("hittable"), "ciało nie jest już celem ani przeszkodą")
	NemoraxTest.assert_true(e.visible, "najpierw widać pozę śmierci")
	_cleanup([e], root)

func test_player_is_drawn_above_enemies(root: Node) -> void:
	var p: Player = load("res://entities/player.tscn").instantiate()
	root.add_child(p)
	NemoraxTest.assert_true(p.z_index > 0, "gracz nad wrogami (z_index 0)")
	_cleanup([p], root)
