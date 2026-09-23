extends RefCounted
## Paczka 4 (AUDYT): pule HP wcieleń i Nemoraksa po strojeniu według
## debug/measure_*.gd (wyniki w POMIARY_WALKI.md). Te testy pilnują, żeby
## zmiana gdzie indziej nie cofnęła po cichu długości walk do 2-4 s.

func _soul_room_with_progress(root: Node, rooms_cleared: int) -> Node:
	var previous := GameFlow.rooms_cleared_count
	GameFlow.rooms_cleared_count = rooms_cleared
	var room = load("res://rooms/room.tscn").instantiate()
	root.add_child(room)
	room._spawn_enemy(GameFlow.INCARNATION_SCENES[0], false)
	GameFlow.rooms_cleared_count = previous
	return room

func _cleanup(room: Node, root: Node) -> void:
	root.remove_child(room)
	room.queue_free()

func test_soul_incarnation_starts_from_tuned_base(root: Node) -> void:
	var room := _soul_room_with_progress(root, 0)
	NemoraxTest.assert_almost_eq(room.incarnation.max_health, room.SOUL_BASE_HEALTH, 0.01, "wcielenie na starcie trasy ma bazowe HP pokoju z duszą")
	NemoraxTest.assert_almost_eq(room.incarnation.health, room.incarnation.max_health, 0.01, "i zaczyna z pełnym HP")
	_cleanup(room, root)

func test_soul_incarnation_scales_with_progress_up_to_cap(root: Node) -> void:
	var room := _soul_room_with_progress(root, 10)
	NemoraxTest.assert_almost_eq(room.incarnation.max_health, room.SOUL_BASE_HEALTH * 1.45, 0.01, "10 pokoi = +45% HP, ta sama krzywa co zwykli wrogowie")
	_cleanup(room, root)
	room = _soul_room_with_progress(root, 60)
	NemoraxTest.assert_almost_eq(room.incarnation.max_health, room.SOUL_BASE_HEALTH * 2.10, 0.01, "skalowanie ma sufit 2,1x")
	_cleanup(room, root)

func test_nemorax_total_pool_is_tuned(root: Node) -> void:
	var boss: Boss = load("res://entities/boss.tscn").instantiate()
	var total := boss.final_health
	for m in Boss.PHASE_HP_MULTIPLIERS:
		total += roundf(boss.phase_max_health * m)
	NemoraxTest.assert_true(total >= 2800.0 and total <= 3500.0, "łączna pula Nemoraksa po Paczce 4 ~3100 HP (jest %.0f)" % total)
	boss.free()
