extends SceneTree
## Długość trasy próby (AUDYT Paczka 5 pkt 4). Dla N seedów liczy:
## - pełna: wszystkie pokoje (24 RANDOM + 6 SOUL + ołtarz),
## - minimalna: pokoje, przez które TRZEBA przejść, by zebrać 6 dusz i dojść do
##   ołtarza (suma najkrótszych ścieżek BFS od startu — przybliżenie z góry),
## - najdłuższy odcinek RANDOM bez pokoju z duszą/pułapką na najkrótszej drodze.
## Użycie: Godot --headless --script res://debug/measure_route.gd -- [liczba_seedów]

func _initialize() -> void:
	await process_frame
	var gf: Node = root.get_node("GameFlow")
	gf.SAVE_PATH = "user://measure_run.json"
	gf.PERSISTENT_SAVE_PATH = "user://measure_persistent.json"
	var args := OS.get_cmdline_user_args()
	var n := int(args[0]) if args.size() > 0 else 20
	var mins: Array[int] = []
	var depths: Array[int] = []
	var traps_on_path := 0
	for s in n:
		gf.reset_run(5000 + s)
		var dist := {Vector2i.ZERO: 0}
		var parent := {}
		var queue: Array[Vector2i] = [Vector2i.ZERO]
		while not queue.is_empty():
			var cur: Vector2i = queue.pop_front()
			for d in gf.DIRECTIONS:
				var nb: Vector2i = cur + d
				if gf.room_map.has(nb) and not dist.has(nb):
					dist[nb] = dist[cur] + 1
					parent[nb] = cur
					queue.append(nb)
		var needed := {}
		var deepest := 0
		for pos in gf.room_map:
			var t: int = gf.room_map[pos]["type"]
			if t == gf.RoomType.SOUL or t == gf.RoomType.ALTAR:
				deepest = maxi(deepest, int(dist.get(pos, 0)))
				var p: Vector2i = pos
				while parent.has(p):
					needed[p] = true
					p = parent[p]
		var trap_needed := false
		for p in needed:
			if gf.room_map[p].get("trap", false):
				trap_needed = true
		traps_on_path += 1 if trap_needed else 0
		mins.append(needed.size())
		depths.append(deepest)
	mins.sort()
	depths.sort()
	print("=== TRASA (%d seedów) ===" % n)
	print("pełna próba: %d pokoi" % gf.room_map.size())
	print("minimalna trasa do 6 dusz + ołtarza: min %d, mediana %d, max %d pokoi" % [mins[0], mins[n / 2], mins[-1]])
	print("najgłębszy cel od startu: min %d, mediana %d, max %d przejść" % [depths[0], depths[n / 2], depths[-1]])
	print("pokój pułapek na minimalnej trasie: %d / %d seedów" % [traps_on_path, n])
	quit()
