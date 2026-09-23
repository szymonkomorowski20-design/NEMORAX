extends RefCounted
## Paczka 8 (AUDYT E4): Pakt fragmentu — pilotaż na Mordracie (rozdział 1 ↔
## faza Force). Fragment zawsze przyznany, wybór zapisywany, obie drogi
## zmieniają walkę teraz i finał (zapowiedziany przed wyborem).

func _cleanup(node: Node, root: Node) -> void:
	root.remove_child(node)
	node.queue_free()

func _reset() -> void:
	GameFlow.pacts = {}
	GameFlow.pending_pact = -1

func test_pact_choice_is_saved_and_loaded(_root: Node) -> void:
	GameFlow.reset_run(11)
	GameFlow.pending_pact = PactCatalog.PILOT_CHAPTER
	GameFlow.set_pact(PactCatalog.PILOT_CHAPTER, PactCatalog.ZWIAZ)
	NemoraxTest.assert_eq(GameFlow.pending_pact, -1, "wybór zdejmuje oczekujący pakt")
	GameFlow.pacts = {}
	NemoraxTest.assert_true(GameFlow._load_progress(), "wczytanie")
	NemoraxTest.assert_eq(PactCatalog.choice(), PactCatalog.ZWIAZ, "pakt przetrwał zapis")
	GameFlow.reset_run()
	NemoraxTest.assert_eq(PactCatalog.choice(), "", "nowa próba zaczyna bez paktu")

func test_cleanse_adds_stamina_and_keeps_finale_audio(root: Node) -> void:
	_reset()
	var p: Player = load("res://entities/player.tscn").instantiate()
	root.add_child(p)
	var base := p.max_stamina
	GameFlow.pacts = {str(PactCatalog.PILOT_CHAPTER): PactCatalog.OCZYSC}
	p._recompute_effective_stats()
	NemoraxTest.assert_almost_eq(p.max_stamina - base, PactCatalog.OCZYSC_STAMINA_BONUS, 0.01, "Oczyść: +20 maks. staminy")
	_cleanup(p, root)
	_reset()

func test_bind_adds_announced_force_pattern(root: Node) -> void:
	_reset()
	var boss: Boss = load("res://entities/boss.tscn").instantiate()
	root.add_child(boss)
	var names := []
	for g in boss._build_pattern_groups(1):
		names.append(g["name"])
	NemoraxTest.assert_true(not "F4_seal_ring" in names, "bez paktu faza Force bez nowego wzorca")
	GameFlow.pacts = {str(PactCatalog.PILOT_CHAPTER): PactCatalog.ZWIAZ}
	names.clear()
	for g in boss._build_pattern_groups(1):
		names.append(g["name"])
	NemoraxTest.assert_true("F4_seal_ring" in names, "Zwiąż: faza Force dostaje zapowiedziany wzorzec")
	_cleanup(boss, root)
	_reset()

func test_seal_ring_leaves_a_gap_and_a_center_seal(root: Node) -> void:
	_reset()
	var holder := Node2D.new()
	root.add_child(holder)
	var boss: Boss = load("res://entities/boss.tscn").instantiate()
	holder.add_child(boss)
	var p: Player = load("res://entities/player.tscn").instantiate()
	holder.add_child(p)
	p.global_position = Vector2(600, 360)
	boss.player = p
	boss._attack_force_seal_ring()
	var seals: Array = []
	for c in holder.get_children():
		if c.get("ring_variant") == true:
			seals.append(c)
	NemoraxTest.assert_eq(seals.size(), Boss.SEAL_RING_COUNT, "pierścień bez jednej + środek = %d pieczęci" % Boss.SEAL_RING_COUNT)
	var center_seals := 0
	for s in seals:
		NemoraxTest.assert_true(s.seal_telegraph >= 1.0, "dłuższy, osobny telegraf")
		if (s as Node2D).global_position.distance_to(p.global_position) < 1.0:
			center_seals += 1
	NemoraxTest.assert_eq(center_seals, 1, "pieczęć pod nogami — trzeba się ruszyć")
	_cleanup(holder, root)

func test_bind_parry_silences_nearby_enemy(root: Node) -> void:
	_reset()
	GameFlow.pacts = {str(PactCatalog.PILOT_CHAPTER): PactCatalog.ZWIAZ}
	var p: Player = load("res://entities/player.tscn").instantiate()
	root.add_child(p)
	p.global_position = Vector2(500, 500)
	p._shield_up = true
	p._shield_dir = Vector2.RIGHT
	p._shield_time = 0.05
	var near: Incarnation = load("res://entities/random_enemies/chaser.tscn").instantiate()
	root.add_child(near)
	near.global_position = p.global_position + Vector2(90, 0)
	var far: Incarnation = load("res://entities/random_enemies/chaser.tscn").instantiate()
	root.add_child(far)
	far.global_position = p.global_position + Vector2(600, 0)
	p.take_damage(10.0, near.global_position, true, near)
	NemoraxTest.assert_true(near._actions_blocked(), "parowanie po pakcie ucisza wroga obok")
	NemoraxTest.assert_true(not far._actions_blocked(), "daleki wróg bez ciszy")
	near._lunge_toward_player(400.0, 0.3)
	NemoraxTest.assert_true(not near._lunge_active, "uciszony wróg nie atakuje")
	_cleanup(near, root)
	_cleanup(far, root)
	_cleanup(p, root)
	_reset()

func test_soul_of_pilot_incarnation_leaves_pending_pact(root: Node) -> void:
	_reset()
	var old_map := GameFlow.room_map
	var old_pos := GameFlow.current_room_pos
	GameFlow.room_map = {Vector2i.ZERO: {"type": GameFlow.RoomType.SOUL, "chapter": PactCatalog.PILOT_CHAPTER, "enemy_index": 0, "cleared": true, "has_chest": false, "chest_opened": false}}
	GameFlow.current_room_pos = Vector2i.ZERO
	var room = load("res://rooms/room.tscn").instantiate()
	root.add_child(room)
	room._on_soul_collected(GameFlow.INCARNATION_NAMES[PactCatalog.PILOT_CHAPTER])
	NemoraxTest.assert_eq(GameFlow.pending_pact, PactCatalog.PILOT_CHAPTER, "pakt czeka na wybór (HUD), nic nie wyskakuje")
	NemoraxTest.assert_true(not room.get_tree().paused, "gra nie zatrzymana")
	room.ui._draw_reward_buttons()
	NemoraxTest.assert_true(room.ui._reward_button_rects.has("pact"), "przycisk paktu w HUD")
	_cleanup(room, root)
	GameFlow.room_map = old_map
	GameFlow.current_room_pos = old_pos
	_reset()
