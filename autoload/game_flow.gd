extends Node
## Stan całego przebiegu gry — SIATKA pokoi 2D w stylu "The Binding of Isaac"
## (na życzenie autora, zastępuje dawną liniową sekwencję 30 pokoi). Autoload,
## więc przeżywa reload/zmianę sceny. Zapisywane na dysk, żeby zamknięcie gry
## w trakcie przebiegu nie cofało do początku.
##
## Mapa generowana proceduralnie przy starcie/resecie: START (1 pokój) +
## RANDOM (24, rosnąca trudność z rooms_cleared_count) + SOUL (6, po jednym
## na wcielenie, dają fragment duszy) + ALTAR (1, zablokowany dopóki nie
## zebrano wszystkich 6 fragmentów). Każdy SOUL/ALTAR dołączony jako ślepy
## zaułek — DOKŁADNIE jedno połączenie z resztą mapy — tak jak drzwi bossa w
## Isaacu, żeby czuły się jak celowy cel wyprawy, nie przystanek na trasie.
##
## Drzwi pokoju z żywym przeciwnikiem (RANDOM/SOUL, niepokonany) są zamknięte —
## nie da się wyjść, dopóki się go nie pokona (ustalone z autorem, jak w
## Isaacu). Dzięki temu da się ukończyć grę bez czyszczenia WSZYSTKICH 30
## pokoi — wystarczy dotrzeć do 6 z duszą i do ołtarza jakąkolwiek ścieżką po
## siatce, reszta jest opcjonalna.

enum RoomType { START, RANDOM, SOUL, ALTAR }

const NORTH := Vector2i(0, -1)
const SOUTH := Vector2i(0, 1)
const WEST := Vector2i(-1, 0)
const EAST := Vector2i(1, 0)
const DIRECTIONS: Array[Vector2i] = [NORTH, SOUTH, WEST, EAST]

var SAVE_PATH := "user://gauntlet_progress.json" ## var (nie const) tylko po to, żeby test mógł podmienić ścieżkę na tymczasową
## Dzielony z arena.gd (deaths/wins) — CELOWO osobna ścieżka/mechanizm od
## SAVE_PATH powyżej: to ostatnie to stan BIEŻĄCEGO przebiegu, kasowany przez
## reset_run() po przegranej, a "widział prolog" ma przetrwać całe zapisy
## (PLAN_CUTSCENEK.md 2.1 — "nigdy więcej się nie powtarza w tym zapisie").
var PERSISTENT_SAVE_PATH := "user://progress.json" ## var jak wyżej, żeby test mógł podmienić

const ROOM_SCENE := "res://rooms/room.tscn"
const ALTAR_SCENE := "res://rooms/altar.tscn"
const ARENA_SCENE := "res://arena.tscn"

const RANDOM_ROOM_COUNT := 24
const CHAPTER_COUNT := 6 ## = INCARNATION_SCENES.size() = liczba pokoi SOUL

## Skrzynie z ulepszeniami (CLAUDE_CODE_GAME_CONTENT_BIBLE.md sekcja 9) —
## dokument umieszcza je w oknach numerów pokoi, co nie ma odpowiednika na
## losowej siatce (adaptacja ustalona z autorem); tutaj 5 z 24 pokoi RANDOM,
## wybranych raz przy generacji mapy, dostaje skrzynię PO oczyszczeniu.
## Nigdy w SOUL/ALTAR/START, zgodnie z duchem dokumentu (nie w pokoju bossa).
const CHEST_COUNT := 5

## Kolejność wcieleń = kolejność "rozdziałów" (chapter 0..5). Nazwy plików/klas
## zostały po fazach Nemoraxa (Zalążek/Cisza/Zwłoka/Ciężar/Głód/Zaćmienie) ze
## starszej wersji dokumentu — nazwy WŁASNE poniżej (INCARNATION_NAMES) to to,
## co widzi gracz.
const INCARNATION_SCENES: Array[String] = [
	"res://entities/incarnations/zalazek.tscn",
	"res://entities/incarnations/cisza_incarnation.tscn",
	"res://entities/incarnations/zwloka_incarnation.tscn",
	"res://entities/incarnations/ciezar_incarnation.tscn",
	"res://entities/incarnations/glod_incarnation.tscn",
	"res://entities/incarnations/zacmienie_incarnation.tscn",
]

const INCARNATION_NAMES: Array[String] = [
	"Vhar’Nokh, Wygnany z Otchłani",
	"Mordrath Bez-Wymiaru",
	"Zha’Ruun, Pożeracz Granic",
	"Nekravor, Ten Którego Odrzucono",
	"Thal’Gor, Pęknięty Pomiędzy Światami",
	"Orryx Cień-Nicości",
]

## 11 archetypów wrogów losowych (CLAUDE_CODE_GAME_CONTENT_BIBLE.md sekcja 6) —
## mechanika/statystyki już wdrożone (entities/random_enemies/*.gd), grafika
## TYMCZASOWO reużywa istniejące sprite'y wcieleń (patrz komentarze w każdym
## pliku) do czasu, aż dedykowana grafika wróci z GPT
## (PROMPTY_WROGOW_LOSOWYCH_I_SKRZYNI.md sekcja A) — podmiana wtedy dotyczy
## WYŁĄCZNIE stałych TEX_* w tych 11 plikach, nie tej listy ani reszty systemu.
const RANDOM_ENEMY_SCENES: Array[String] = [
	"res://entities/random_enemies/chaser.tscn",
	"res://entities/random_enemies/striker.tscn",
	"res://entities/random_enemies/shooter.tscn",
	"res://entities/random_enemies/charger.tscn",
	"res://entities/random_enemies/orbiter.tscn",
	"res://entities/random_enemies/dasher.tscn",
	"res://entities/random_enemies/ambusher.tscn",
	"res://entities/random_enemies/zoner.tscn",
	"res://entities/random_enemies/summoner.tscn",
	"res://entities/random_enemies/tank.tscn",
	"res://entities/random_enemies/support.tscn",
]

## Szansa, że nowo postawiony pokój RANDOM dostanie Elite Modifier na swoim
## przeciwniku (dokument sekcja 6.2/18) — rośnie z postępem w przebiegu
## (rooms_cleared_count), tak jak zwykłe skalowanie trudności, żeby elity
## pojawiały się częściej w późniejszej fazie rundy, nie od pierwszego pokoju.
const ELITE_BASE_CHANCE := 0.05
const ELITE_CHANCE_PER_ROOM_CLEARED := 0.01
const ELITE_MAX_CHANCE := 0.35

## Ile % siły dokłada się za KAŻDY wyczyszczony pokój (nie tylko losowy) —
## patrz room.gd, Incarnation.apply_difficulty_scale().
const RANDOM_ENEMY_DIFFICULTY_STEP := 0.08

var room_map: Dictionary = {} ## Vector2i -> {"type","chapter","enemy_index","cleared"}
var current_room_pos: Vector2i = Vector2i.ZERO
var entry_direction: Vector2i = Vector2i.ZERO ## kierunek ruchu, którym gracz trafił do current_room_pos; ZERO w pokoju startowym
var visited_rooms: Dictionary = {} ## Vector2i -> true, do mgły wojny na minimapie (ui.gd)
var rooms_cleared_count: int = 0 ## napędza rosnącą trudność losowych przeciwników
var fragments_collected: Array[String] = [] ## nazwy zebranych fragmentów, w kolejności
var reached_arena: bool = false ## true po przejściu ołtarza — patrz resume_scene_path()

## Migawka statystyk gracza z chwili przejścia do kolejnego pokoju (na życzenie
## autora: "postać odradza się w kolejnym z takimi samymi statystykami") — puste
## w pierwszym pokoju, więc gracz startuje tam z domyślnych wartości @export.
var saved_player_state: Dictionary = {}

## Zaciemnienie na przejściach między scenami (Game Feel — Room Feel) — dawny
## reload_current_scene()/change_scene_to_file() był twardym cięciem z klatki
## na klatkę, co przy tak częstych, kierowanych przez gracza przejściach po
## siatce (patrz PLAN_LOSOWYCH_POKOI.md) rzuca się w oczy bardziej niż przy
## starej, liniowej sekwencji pokoi. CanvasLayer wisi na TYM autoloadzie (nie
## w scenie), więc przeżywa reload/zmianę sceny — bez tego zniknąłby w
## momencie przejścia, zamiast zostać widoczny przez obie połówki zacięcia.
const FADE_DURATION := 0.12 ## s, każda z dwóch połówek przejścia
var _fade_rect: ColorRect

func _ready() -> void:
	_setup_fade_overlay()
	if not _load_progress():
		_generate_map()

func _setup_fade_overlay() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 100 # ponad UI każdej sceny (pokój/ołtarz/arena)
	_fade_rect = ColorRect.new()
	_fade_rect.color = Color(0.0, 0.0, 0.0, 0.0)
	_fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fade_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	layer.add_child(_fade_rect)
	add_child(layer)

## Wspólne przejście: zaciemnia ekran, wykonuje `apply` (reload albo zmiana
## sceny), czeka jedną klatkę żeby nowa scena zdążyła się zbudować, po czym
## rozjaśnia z powrotem. Fire-and-forget — wołający (room.gd/altar.gd) nie
## musi czekać na dokończenie animacji, żeby przejście logicznie "zaszło".
func _transition(apply: Callable) -> void:
	var fade_in := create_tween()
	fade_in.tween_property(_fade_rect, "color:a", 1.0, FADE_DURATION)
	await fade_in.finished
	apply.call()
	await get_tree().process_frame
	var fade_out := create_tween()
	fade_out.tween_property(_fade_rect, "color:a", 0.0, FADE_DURATION)

## Rozrost losowego błądzenia od pokoju startowego (24 RANDOM), potem 6 SOUL +
## 1 ALTAR dołączone jako ślepe zaułki do już postawionych pokoi — dokładnie
## jedno połączenie każdy, żeby czuły się jak cel, a nie przystanek.
func _generate_map() -> void:
	room_map.clear()
	visited_rooms.clear()
	current_room_pos = Vector2i.ZERO
	entry_direction = Vector2i.ZERO
	room_map[Vector2i.ZERO] = {"type": RoomType.START, "chapter": -1, "enemy_index": -1, "cleared": true, "has_chest": false, "chest_opened": false}
	visited_rooms[Vector2i.ZERO] = true

	var frontier: Array[Vector2i] = _neighbors_of(Vector2i.ZERO)
	var placed := 0
	var last_enemy := -1
	while placed < RANDOM_ROOM_COUNT and not frontier.is_empty():
		var idx := randi() % frontier.size()
		var pos: Vector2i = frontier[idx]
		frontier.remove_at(idx)
		if room_map.has(pos):
			continue
		var enemy_index := randi() % RANDOM_ENEMY_SCENES.size()
		if RANDOM_ENEMY_SCENES.size() > 1:
			while enemy_index == last_enemy:
				enemy_index = randi() % RANDOM_ENEMY_SCENES.size()
		last_enemy = enemy_index
		room_map[pos] = {"type": RoomType.RANDOM, "chapter": -1, "enemy_index": enemy_index, "cleared": false, "has_chest": false, "chest_opened": false}
		placed += 1
		for n in _neighbors_of(pos):
			if not room_map.has(n):
				frontier.append(n)

	for chapter in range(CHAPTER_COUNT):
		var attach = _pick_leaf_attachment_point()
		if attach == null:
			break
		room_map[attach] = {"type": RoomType.SOUL, "chapter": chapter, "enemy_index": -1, "cleared": false, "has_chest": false, "chest_opened": false}

	var altar_pos = _pick_leaf_attachment_point()
	if altar_pos != null:
		room_map[altar_pos] = {"type": RoomType.ALTAR, "chapter": -1, "enemy_index": -1, "cleared": false, "has_chest": false, "chest_opened": false}

	_assign_chest_rooms()

## Skrzynie (dokument sekcja 9, zaadaptowane na siatkę — patrz stała
## CHEST_COUNT): wybiera CHEST_COUNT z JUŻ postawionych pokoi RANDOM, raz, na
## starcie przebiegu — nigdy nie losuje ponownie przy wejściu/wyjściu z pokoju.
func _assign_chest_rooms() -> void:
	var random_positions: Array[Vector2i] = []
	for pos in room_map.keys():
		if room_map[pos]["type"] == RoomType.RANDOM:
			random_positions.append(pos)
	random_positions.shuffle()
	var count: int = mini(CHEST_COUNT, random_positions.size())
	for i in range(count):
		room_map[random_positions[i]]["has_chest"] = true

func _neighbors_of(pos: Vector2i) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	for d in DIRECTIONS:
		result.append(pos + d)
	return result

## Losowy JUŻ POSTAWIONY pokój z co najmniej jednym pustym sąsiadem, i losowy
## z tych pustych sąsiadów — ale TYLKO jeśli ten sąsiad sam ma dokładnie
## JEDNEGO zajętego sąsiada (czyli właśnie "pos"). Bez tego drugiego warunku
## kandydat mógłby przypadkiem stykać się też z innym, już postawionym
## pokojem (np. losowym z wcześniejszej fazy) i po postawieniu tam pokoju z
## duszą/ołtarza wyszedłby z 2+ połączeniami zamiast ślepego zaułka —
## dokładnie to złapał test_soul_and_altar_rooms_are_dead_ends.
func _pick_leaf_attachment_point():
	var positions := room_map.keys()
	positions.shuffle()
	for pos in positions:
		# Pokój z duszą/ołtarz NIGDY nie może być "rodzicem" kolejnego
		# specjalnego pokoju — inaczej sam zyskałby drugie połączenie i
		# przestał być ślepym zaułkiem. Tylko START/RANDOM mogą się rozgałęziać.
		if room_map[pos]["type"] in [RoomType.SOUL, RoomType.ALTAR]:
			continue
		var candidates: Array[Vector2i] = []
		for n in _neighbors_of(pos):
			if room_map.has(n):
				continue
			var occupied_neighbors := 0
			for nn in _neighbors_of(n):
				if room_map.has(nn):
					occupied_neighbors += 1
			if occupied_neighbors == 1:
				candidates.append(n)
		if not candidates.is_empty():
			return candidates[randi() % candidates.size()]
	return null

func current_room_data() -> Dictionary:
	return room_map.get(current_room_pos, {})

func has_neighbor(direction: Vector2i) -> bool:
	return room_map.has(current_room_pos + direction)

func neighbor_data(direction: Vector2i) -> Dictionary:
	return room_map.get(current_room_pos + direction, {})

## Czy dana ściana OBECNEGO pokoju ma teraz przejście, którym da się wyjść —
## fałsz gdy: sąsiada nie ma; obecny pokój ma jeszcze żywego przeciwnika
## (blokada na czas walki, jak w Isaacu — dotyczy WSZYSTKICH ścian naraz);
## sąsiadem jest ołtarz, a fragmentów wciąż brakuje (drzwi bossa, zablokowane
## do klucza — tu: do kompletu fragmentów).
func is_direction_open(direction: Vector2i) -> bool:
	if not has_neighbor(direction):
		return false
	var current := current_room_data()
	if current.get("type") in [RoomType.RANDOM, RoomType.SOUL] and not current.get("cleared", false):
		return false
	var neighbor := neighbor_data(direction)
	if neighbor.get("type") == RoomType.ALTAR and fragments_collected.size() < CHAPTER_COUNT:
		return false
	return true

const WALL_FOR_DIRECTION := {
	Vector2i(0, -1): "top",
	Vector2i(0, 1): "bottom",
	Vector2i(-1, 0): "left",
	Vector2i(1, 0): "right",
}
const OPPOSITE_WALL_FOR_DIRECTION := {
	Vector2i(0, -1): "bottom", # przyszedł z północy -> pojawia się przy południowej (dolnej) ścianie
	Vector2i(0, 1): "top",
	Vector2i(-1, 0): "right",
	Vector2i(1, 0): "left",
}

## Ściana, przez którą wychodzi się w danym kierunku (Walls.wall_point()).
func wall_for_direction(direction: Vector2i) -> String:
	return WALL_FOR_DIRECTION.get(direction, "bottom")

## Ściana, przy której gracz powinien się pojawić w NOWYM pokoju po wejściu w
## danym kierunku — przeciwna do kierunku ruchu (wszedł od północy -> ląduje
## przy południowej ścianie nowego pokoju, twarzą z powrotem do wyjścia).
func opposite_wall_for_direction(direction: Vector2i) -> String:
	return OPPOSITE_WALL_FOR_DIRECTION.get(direction, "bottom")

func current_incarnation_scene_path() -> String:
	return INCARNATION_SCENES[current_room_data().get("chapter", 0)]

func current_incarnation_name() -> String:
	return INCARNATION_NAMES[current_room_data().get("chapter", 0)]

func current_random_enemy_scene_path() -> String:
	return RANDOM_ENEMY_SCENES[current_room_data().get("enemy_index", 0)]

## Szansa na Elite Modifier dla przeciwnika w BIEŻĄCYM pokoju — patrz stałe
## ELITE_* powyżej. Wydzielone dla testowalności (czysta arytmetyka, bez
## losowania) — room.gd sam rzuca kością i porównuje z tym wynikiem.
func elite_chance_for_current_progress() -> float:
	return min(ELITE_MAX_CHANCE, ELITE_BASE_CHANCE + rooms_cleared_count * ELITE_CHANCE_PER_ROOM_CLEARED)

func capture_player_state(player: Player) -> void:
	saved_player_state = {
		"health": player.health,
		"stamina": player.stamina,
		"mana": player.mana,
		"heal_charge_hits": player.get_heal_charge_hits(),
		"heal_stacks": player.get_heal_stacks(),
		"current_weapon": player.current_weapon,
		"level": player.level,
		"xp": player.xp,
		"unspent_stat_points": player.unspent_stat_points,
		"stat_points": player.stat_points.duplicate(),
		"owned_upgrades": player.owned_upgrades.duplicate(),
		"skill_ranks": player.skill_ranks.duplicate(),
		"pending_skill_choices": player.pending_skill_choices,
		"skill_offers": player.skill_offers.duplicate(),
		"second_breath_used": player._second_breath_used,
		"second_breath_scope": player._second_breath_scope,
	}

## Wywoływane w room.gd zaraz po zespawnowaniu gracza — działa zarówno przy
## wejściu do nowego pokoju, jak i przy retry po śmierci w tym samym pokoju,
## więc "checkpoint" zawsze jest stanem sprzed wejścia do BIEŻĄCEGO pokoju.
func apply_player_state(player: Player) -> void:
	if saved_player_state.is_empty():
		return
	# Poziom/punkty MUSZĄ wrócić PRZED health/stamina/mana — _recompute_effective_stats()
	# przelicza max_health itd. z punktów, a zaraz potem ustawiamy KONKRETNĄ
	# zapisaną wartość health (nie max_health), więc kolejność ma znaczenie.
	player.level = int(saved_player_state.get("level", 0))
	player.xp = saved_player_state.get("xp", 0.0)
	player.unspent_stat_points = int(saved_player_state.get("unspent_stat_points", 0))
	var loaded_points: Dictionary = saved_player_state.get("stat_points", {})
	for key in player.stat_points.keys():
		player.stat_points[key] = int(loaded_points.get(key, 0))
	var loaded_upgrades: Array = saved_player_state.get("owned_upgrades", [])
	player.owned_upgrades.assign(loaded_upgrades) # PRZED _recompute_effective_stats(): Iron Heart/Razor Wind czytają has_upgrade()
	player.skill_ranks = saved_player_state.get("skill_ranks", {}).duplicate()
	player.pending_skill_choices = int(saved_player_state.get("pending_skill_choices", 0))
	player.skill_offers.clear()
	player.skill_offers.assign(saved_player_state.get("skill_offers", []))
	player._second_breath_used = bool(saved_player_state.get("second_breath_used", false))
	player._second_breath_scope = str(saved_player_state.get("second_breath_scope", ""))
	player._recompute_effective_stats()

	player.health = saved_player_state.get("health", player.health)
	player.stamina = saved_player_state.get("stamina", player.stamina)
	player.mana = saved_player_state.get("mana", player.mana)
	player.set_heal_charge_hits(int(saved_player_state.get("heal_charge_hits", 0))) # JSON zwraca float
	player.set_heal_stacks(int(saved_player_state.get("heal_stacks", 0)))
	player.current_weapon = saved_player_state.get("current_weapon", player.current_weapon)

## Scena, do której trzeba wrócić przy starcie gry, jeśli jest zapisany
## przebieg w toku — np. jeśli gracz zamknął grę już po ołtarzu, wraca się
## prosto do walki z Nemoraksem, nie do pokoju startowego (patrz menu.gd).
func resume_scene_path() -> String:
	return ARENA_SCENE if reached_arena else ROOM_SCENE

## Wywoływane przez room.gd po pokonaniu przeciwnika w bieżącym pokoju —
## odblokowuje jego drzwi, dolicza fragment duszy (TYLKO SOUL — losowi
## przeciwnicy nie dają fragmentów, ustalone z autorem) i podbija licznik
## trudności.
func clear_current_room() -> void:
	var data := current_room_data()
	if data.is_empty():
		return
	data["cleared"] = true
	rooms_cleared_count += 1
	if data.get("type") == RoomType.SOUL:
		fragments_collected.append(INCARNATION_NAMES[data.get("chapter", 0)])
	_save_progress()

## Wywoływane przez room.gd po otwarciu skrzyni w bieżącym pokoju — bez tego
## re-wejście do pokoju (retry po śmierci itd.) spawnowałoby ją ponownie.
func mark_chest_opened() -> void:
	var data := current_room_data()
	if data.is_empty():
		return
	data["chest_opened"] = true
	_save_progress()

## Wywoływane przez room.gd, gdy gracz przechodzi przez drzwi w danym
## kierunku (jeden z NORTH/SOUTH/WEST/EAST) — przenosi na sąsiedni pokój.
func move_to_neighbor(direction: Vector2i) -> void:
	current_room_pos += direction
	entry_direction = direction
	visited_rooms[current_room_pos] = true
	_save_progress()
	_transition(get_tree().reload_current_scene)

## Wywoływane przez room.gd, gdy gracz przechodzi przez drzwi prowadzące do
## ołtarza — osobna, stała scena (rooms/altar.tscn), nie generyczny room.tscn.
func enter_altar() -> void:
	_save_progress()
	_transition(get_tree().change_scene_to_file.bind(ALTAR_SCENE))

## Wywoływane przez altar.gd po złożeniu wszystkich fragmentów.
func complete_altar() -> void:
	reached_arena = true
	_save_progress()
	_transition(get_tree().change_scene_to_file.bind(ARENA_SCENE))

## Do restartu całego przebiegu od zera — po PRZEGRANEJ z Nemoraksem (patrz
## arena.gd) wraca się tu, do świeżo wygenerowanej mapy od pokoju startowego.
## Zwycięstwo NIE resetuje przebiegu — to prawdziwy koniec (ekran endgame).
## Odczyt/zapis TYLKO klucza "seen_prolog" w pliku dzielonym z arena.gd —
## read-modify-write całego JSON-a, żeby nie nadpisać deaths/wins zapisanych
## przez arena.gd (i odwrotnie: arena.gd robi to samo, więc kolejność wołań
## między nimi nie ma znaczenia).
func has_seen_prolog() -> bool:
	if not FileAccess.file_exists(PERSISTENT_SAVE_PATH):
		return false
	var file := FileAccess.open(PERSISTENT_SAVE_PATH, FileAccess.READ)
	if file == null:
		return false
	var data = JSON.parse_string(file.get_as_text())
	if typeof(data) != TYPE_DICTIONARY:
		return false
	return bool(data.get("seen_prolog", false))

func mark_prolog_seen() -> void:
	var data: Dictionary = {}
	if FileAccess.file_exists(PERSISTENT_SAVE_PATH):
		var existing := FileAccess.open(PERSISTENT_SAVE_PATH, FileAccess.READ)
		if existing != null:
			var parsed = JSON.parse_string(existing.get_as_text())
			if typeof(parsed) == TYPE_DICTIONARY:
				data = parsed
	data["seen_prolog"] = true
	var out := FileAccess.open(PERSISTENT_SAVE_PATH, FileAccess.WRITE)
	if out == null:
		push_warning("GameFlow: nie udało się zapisać seen_prolog (%s), błąd %d" % [PERSISTENT_SAVE_PATH, FileAccess.get_open_error()])
		return
	out.store_string(JSON.stringify(data))
	out.close()

func reset_run() -> void:
	Juice.reset_damage_metrics()
	rooms_cleared_count = 0
	fragments_collected.clear()
	saved_player_state.clear()
	reached_arena = false
	_generate_map()
	_save_progress()

## Zwraca true, jeśli udało się wczytać PRAWDZIWY zapis mapy — false (i wtedy
## wołający musi wygenerować nową mapę) dla braku pliku, błędu odczytu, albo
## starego zapisu sprzed tego systemu (brak klucza "rooms").
func _load_progress() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		return false
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		# open() zwraca null zamiast rzucać wyjątek (Godot 4) — bez tej kontroli
		# get_as_text() poniżej wywaliłoby się na null-referencji.
		push_warning("GameFlow: nie udało się otworzyć zapisu do odczytu (%s), błąd %d" % [SAVE_PATH, FileAccess.get_open_error()])
		return false
	var data = JSON.parse_string(file.get_as_text())
	if typeof(data) != TYPE_DICTIONARY or not data.has("rooms"):
		return false

	room_map.clear()
	for entry in data["rooms"]:
		var pos := Vector2i(int(entry.get("x", 0)), int(entry.get("y", 0)))
		room_map[pos] = {
			"type": int(entry.get("type", RoomType.RANDOM)),
			"chapter": int(entry.get("chapter", -1)),
			"enemy_index": int(entry.get("enemy_index", -1)),
			"cleared": bool(entry.get("cleared", false)),
			"has_chest": bool(entry.get("has_chest", false)),
			"chest_opened": bool(entry.get("chest_opened", false)),
		}
	var pos_data: Dictionary = data.get("current_room_pos", {})
	current_room_pos = Vector2i(int(pos_data.get("x", 0)), int(pos_data.get("y", 0)))
	var dir_data: Dictionary = data.get("entry_direction", {})
	entry_direction = Vector2i(int(dir_data.get("x", 0)), int(dir_data.get("y", 0)))
	visited_rooms.clear()
	for v in data.get("visited_rooms", []):
		visited_rooms[Vector2i(int(v.get("x", 0)), int(v.get("y", 0)))] = true
	rooms_cleared_count = int(data.get("rooms_cleared_count", 0))
	var loaded_fragments: Array = data.get("fragments_collected", [])
	fragments_collected.assign(loaded_fragments)
	reached_arena = bool(data.get("reached_arena", false))
	saved_player_state = data.get("saved_player_state", {})
	return true

func _save_progress() -> void:
	var rooms_array := []
	for pos in room_map.keys():
		var d: Dictionary = room_map[pos]
		rooms_array.append({
			"x": pos.x, "y": pos.y,
			"type": d["type"], "chapter": d["chapter"],
			"enemy_index": d["enemy_index"], "cleared": d["cleared"],
			"has_chest": d.get("has_chest", false), "chest_opened": d.get("chest_opened", false),
		})
	var visited_array := []
	for pos in visited_rooms.keys():
		visited_array.append({"x": pos.x, "y": pos.y})
	var data := {
		"rooms": rooms_array,
		"current_room_pos": {"x": current_room_pos.x, "y": current_room_pos.y},
		"entry_direction": {"x": entry_direction.x, "y": entry_direction.y},
		"visited_rooms": visited_array,
		"rooms_cleared_count": rooms_cleared_count,
		"fragments_collected": fragments_collected,
		"reached_arena": reached_arena,
		"saved_player_state": saved_player_state,
	}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		# Dysk pełny / user:// tylko do odczytu itp. — stan w pamięci już jest
		# zaktualizowany, po prostu nie zostanie tym razem zapisany na dysk.
		push_warning("GameFlow: nie udało się zapisać postępu (%s), błąd %d" % [SAVE_PATH, FileAccess.get_open_error()])
		return
	file.store_string(JSON.stringify(data))
