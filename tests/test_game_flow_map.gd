extends RefCounted
## Mapa pokoi 2D w stylu "The Binding of Isaac" (game_flow.gd) — generacja
## proceduralna, blokada drzwi na czas walki, ołtarz zablokowany do kompletu
## fragmentów, ruch między pokojami.

func _reset() -> void:
	GameFlow.reset_run()

func test_generated_map_has_exactly_the_right_room_counts(_root: Node) -> void:
	_reset()
	var starts := 0
	var randoms := 0
	var souls := 0
	var altars := 0
	for pos in GameFlow.room_map.keys():
		match GameFlow.room_map[pos]["type"]:
			GameFlow.RoomType.START: starts += 1
			GameFlow.RoomType.RANDOM: randoms += 1
			GameFlow.RoomType.SOUL: souls += 1
			GameFlow.RoomType.ALTAR: altars += 1
	NemoraxTest.assert_eq(starts, 1, "dokładnie jeden pokój startowy")
	NemoraxTest.assert_eq(randoms, GameFlow.RANDOM_ROOM_COUNT, "24 losowe pokoje")
	NemoraxTest.assert_eq(souls, GameFlow.CHAPTER_COUNT, "6 pokoi z duszą, po jednym na wcielenie")
	NemoraxTest.assert_eq(altars, 1, "dokładnie jeden ołtarz")
	_reset()

## Generacja jest losowa — sprawdzone raz mogło się udać przypadkiem (dokładnie
## to się stało z dwoma osobnymi bugami złapanymi tym testem: kandydat mógł
## przypadkiem stykać się z INNYM już postawionym pokojem, i już postawiony
## pokój specjalny mógł zostać "rodzicem" kolejnego). 30 regeneracji z rzędu,
## żeby złapać rzadkie przypadki zamiast polegać na jednym ziarnie losowości.
func test_soul_and_altar_rooms_are_dead_ends(_root: Node) -> void:
	for i in range(30):
		_reset()
		for pos in GameFlow.room_map.keys():
			var data: Dictionary = GameFlow.room_map[pos]
			if data["type"] not in [GameFlow.RoomType.SOUL, GameFlow.RoomType.ALTAR]:
				continue
			var connections := 0
			for d in GameFlow.DIRECTIONS:
				if GameFlow.room_map.has(pos + d):
					connections += 1
			NemoraxTest.assert_eq(connections, 1, "pokój z duszą/ołtarz musi mieć dokładnie jedno połączenie (ślepy zaułek), próba %d" % i)
	_reset()

func test_soul_rooms_cover_each_chapter_exactly_once(_root: Node) -> void:
	_reset()
	var chapters_seen := {}
	for pos in GameFlow.room_map.keys():
		var data: Dictionary = GameFlow.room_map[pos]
		if data["type"] == GameFlow.RoomType.SOUL:
			chapters_seen[data["chapter"]] = true
	NemoraxTest.assert_eq(chapters_seen.size(), GameFlow.CHAPTER_COUNT, "każdy rozdział (wcielenie) powinien mieć dokładnie jeden pokój z duszą")
	_reset()

func test_uncleared_room_blocks_all_directions(_root: Node) -> void:
	_reset()
	# Startowy pokój jest "cleared" domyślnie — znajdź sąsiada (na pewno
	# istnieje, START zawsze ma >=1 połączenie) i przenieś się tam ręcznie,
	# udając że to nieoczyszczony losowy pokój.
	var direction: Vector2i = GameFlow.DIRECTIONS[0]
	for d in GameFlow.DIRECTIONS:
		if GameFlow.room_map.has(Vector2i.ZERO + d):
			direction = d
			break
	GameFlow.current_room_pos = direction
	var data: Dictionary = GameFlow.room_map[direction]
	data["cleared"] = false
	if data["type"] == GameFlow.RoomType.START:
		data["type"] = GameFlow.RoomType.RANDOM # symulacja — START zawsze "cleared", tu chcemy przetestować blokadę

	for d in GameFlow.DIRECTIONS:
		NemoraxTest.assert_true(not GameFlow.is_direction_open(d), "wszystkie kierunki powinny być zablokowane, gdy bieżący pokój ma żywego przeciwnika")

	data["cleared"] = true
	var any_open := false
	for d in GameFlow.DIRECTIONS:
		if GameFlow.is_direction_open(d):
			any_open = true
	NemoraxTest.assert_true(any_open, "po wyczyszczeniu przynajmniej jeden kierunek (powrót do startu) powinien się otworzyć")
	_reset()

func test_altar_direction_locked_until_all_fragments_collected(_root: Node) -> void:
	_reset()
	# Znajdź faktyczną pozycję ołtarza i sąsiada, z którego się do niego wchodzi.
	var altar_pos: Vector2i
	for pos in GameFlow.room_map.keys():
		if GameFlow.room_map[pos]["type"] == GameFlow.RoomType.ALTAR:
			altar_pos = pos
			break
	# Ołtarz to ślepy zaułek (patrz test_soul_and_altar_rooms_are_dead_ends) —
	# ma dokładnie jednego sąsiada, szukamy go wprost.
	var neighbor_pos: Vector2i
	var direction_to_altar: Vector2i
	for pos in GameFlow.room_map.keys():
		for d in GameFlow.DIRECTIONS:
			if pos + d == altar_pos:
				neighbor_pos = pos
				direction_to_altar = d

	GameFlow.current_room_pos = neighbor_pos
	GameFlow.room_map[neighbor_pos]["cleared"] = true
	GameFlow.room_map[neighbor_pos]["type"] = GameFlow.RoomType.RANDOM if GameFlow.room_map[neighbor_pos]["type"] == GameFlow.RoomType.START else GameFlow.room_map[neighbor_pos]["type"]

	GameFlow.fragments_collected = []
	NemoraxTest.assert_true(not GameFlow.is_direction_open(direction_to_altar), "drzwi do ołtarza powinny być zamknięte bez kompletu 6 fragmentów")

	GameFlow.fragments_collected = ["A", "B", "C", "D", "E", "F"]
	NemoraxTest.assert_true(GameFlow.is_direction_open(direction_to_altar), "drzwi do ołtarza powinny się otworzyć z kompletem 6 fragmentów")
	_reset()

func test_clear_current_room_awards_fragment_only_for_soul(_root: Node) -> void:
	_reset()
	var soul_pos: Vector2i
	for pos in GameFlow.room_map.keys():
		if GameFlow.room_map[pos]["type"] == GameFlow.RoomType.SOUL:
			soul_pos = pos
			break
	GameFlow.current_room_pos = soul_pos
	var before := GameFlow.fragments_collected.size()
	var before_cleared := GameFlow.rooms_cleared_count
	GameFlow.clear_current_room()
	NemoraxTest.assert_eq(GameFlow.fragments_collected.size(), before + 1, "wyczyszczenie pokoju z duszą powinno dać dokładnie jeden fragment")
	NemoraxTest.assert_eq(GameFlow.rooms_cleared_count, before_cleared + 1, "licznik wyczyszczonych pokoi powinien wzrosnąć")
	NemoraxTest.assert_true(GameFlow.room_map[soul_pos]["cleared"], "pokój powinien być oznaczony jako wyczyszczony")

	var random_pos: Vector2i
	for pos in GameFlow.room_map.keys():
		if GameFlow.room_map[pos]["type"] == GameFlow.RoomType.RANDOM:
			random_pos = pos
			break
	GameFlow.current_room_pos = random_pos
	var fragments_before_random := GameFlow.fragments_collected.size()
	GameFlow.clear_current_room()
	NemoraxTest.assert_eq(GameFlow.fragments_collected.size(), fragments_before_random, "wyczyszczenie losowego pokoju NIE powinno dać fragmentu")
	_reset()

func test_move_to_neighbor_updates_position_and_visited(_root: Node) -> void:
	_reset()
	var direction: Vector2i = GameFlow.DIRECTIONS[0]
	for d in GameFlow.DIRECTIONS:
		if GameFlow.room_map.has(Vector2i.ZERO + d):
			direction = d
			break
	# move_to_neighbor() na końcu woła reload_current_scene(), które w tym
	# kontekście testowym (brak realnej bieżącej sceny) rzuci nieszkodliwy
	# błąd w logu — sprawdzamy tylko stan GameFlow, nie efekt reloadu.
	GameFlow.move_to_neighbor(direction)
	NemoraxTest.assert_eq(GameFlow.current_room_pos, direction, "current_room_pos powinien się przesunąć o wybrany kierunek")
	NemoraxTest.assert_eq(GameFlow.entry_direction, direction, "entry_direction powinien zapamiętać kierunek ruchu")
	NemoraxTest.assert_true(GameFlow.visited_rooms.has(direction), "nowy pokój powinien trafić do visited_rooms")
	_reset()
