extends Node
## Stan całego przebiegu gry (rozszerzenie poza pierwotny dokument): który
## pokój z 30 jest teraz, ile fragmentów duszy zebrano, i przejścia między
## scenami. Autoload, więc przeżywa reload/zmianę sceny. Zapisywane na dysk
## (na życzenie autora), żeby zamknięcie gry w trakcie gauntletu nie cofało
## do pokoju 1.
##
## Struktura 30 pokoi (na życzenie autora, rozszerzenie o "przeciwników
## losowych" ponad pierwotne 6 wcieleń): 6 ROZDZIAŁÓW, każdy to 4 pokoje z
## losowym przeciwnikiem (z puli RANDOM_ENEMY_SCENES, rosnąca trudność) + 1
## pokój z wcieleniem dającym fragment duszy — dokładnie jak dotychczasowe 6
## wcieleń, bez zmian w ich kolejności/nazwach/fragmentach. current_room_index
## rośnie 0..29 zamiast 0..5; is_random_enemy_room()/current_chapter_index()
## mówią, co jest w danym slocie.

var SAVE_PATH := "user://gauntlet_progress.json" ## var (nie const) tylko po to, żeby test mógł podmienić ścieżkę na tymczasową

const ROOM_SCENE := "res://rooms/room.tscn"
const ALTAR_SCENE := "res://rooms/altar.tscn"
const ARENA_SCENE := "res://arena.tscn"

const ROOMS_PER_CHAPTER := 5 ## 4 losowe pokoje + 1 pokój z wcieleniem
const CHAPTER_COUNT := 6 ## = INCARNATION_SCENES.size(), razem 30 pokoi

## Kolejność wcieleń = kolejność rozdziałów 1-6. Nazwy plików/klas zostały po
## fazach Nemoraxa (Zalążek/Cisza/Zwłoka/Ciężar/Głód/Zaćmienie) ze starszej wersji
## dokumentu — nazwy WŁASNE poniżej (INCARNATION_NAMES) to to, co widzi gracz.
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

## TYMCZASOWE: docelowo 7 dedykowanych przeciwników (4 wręcz + 3 dystansowych,
## patrz PLAN_LOSOWYCH_POKOI.md) — jeszcze nie wygenerowane. Reużywam sceny
## wcieleń jako zastępcze losowe przeciwniki, żeby 30-pokojowy przebieg był
## grywalny już teraz; podmienić na docelową listę 7 ścieżek, gdy assety będą
## gotowe (patrz PLAN_LOSOWYCH_POKOI.md — jedyne miejsce, które trzeba zmienić).
const RANDOM_ENEMY_SCENES: Array[String] = INCARNATION_SCENES

## Ile % siły dokłada się za KAŻDY ukończony pokój (nie tylko losowy) — patrz
## room.gd._spawn_random_enemy(), Incarnation.apply_difficulty_scale().
const RANDOM_ENEMY_DIFFICULTY_STEP := 0.08

var current_room_index: int = 0 ## 0..(total_room_count()-1) — indeks aktualnego pokoju
var last_random_enemy_index: int = -1 ## pilnuje, żeby losowy przeciwnik nie powtórzył się dwa pokoje z rzędu
var fragments_collected: Array[String] = [] ## nazwy zebranych fragmentów, w kolejności

## Migawka statystyk gracza z chwili przejścia do kolejnego pokoju (na życzenie
## autora: "postać odradza się w kolejnym z takimi samymi statystykami") — puste
## w pierwszym pokoju, więc gracz startuje tam z domyślnych wartości @export.
var saved_player_state: Dictionary = {}

func _ready() -> void:
	_load_progress()

func capture_player_state(player: Player) -> void:
	saved_player_state = {
		"health": player.health,
		"stamina": player.stamina,
		"mana": player.mana,
		"heal_charge_hits": player.get_heal_charge_hits(),
		"heal_stacks": player.get_heal_stacks(),
		"current_weapon": player.current_weapon,
	}

## Wywoływane w room.gd zaraz po zespawnowaniu gracza — działa zarówno przy
## wejściu do nowego pokoju, jak i przy retry po śmierci w tym samym pokoju,
## więc "checkpoint" zawsze jest stanem sprzed wejścia do BIEŻĄCEGO pokoju.
func apply_player_state(player: Player) -> void:
	if saved_player_state.is_empty():
		return
	player.health = saved_player_state.get("health", player.health)
	player.stamina = saved_player_state.get("stamina", player.stamina)
	player.mana = saved_player_state.get("mana", player.mana)
	player.set_heal_charge_hits(int(saved_player_state.get("heal_charge_hits", 0))) # JSON zwraca float
	player.set_heal_stacks(int(saved_player_state.get("heal_stacks", 0)))
	player.current_weapon = saved_player_state.get("current_weapon", player.current_weapon)

func total_room_count() -> int:
	return ROOMS_PER_CHAPTER * CHAPTER_COUNT

## Indeks rozdziału (0..CHAPTER_COUNT-1) obecnego pokoju — sensowny w OBU
## typach pokoju (losowy i wcielenie), bo rozdział obejmuje oba naraz.
func current_chapter_index() -> int:
	return current_room_index / ROOMS_PER_CHAPTER

## true = obecny slot to jeden z 4 losowych przeciwników danego rozdziału,
## false = to pokój z wcieleniem/duszą (ostatni slot rozdziału).
func is_random_enemy_room() -> bool:
	return current_room_index % ROOMS_PER_CHAPTER < ROOMS_PER_CHAPTER - 1

## Losuje ścieżkę sceny losowego przeciwnika (bez powtórzenia poprzedniego,
## ta sama zasada co ataki bossa/umiejętności wcieleń) — wołane TYLKO gdy
## is_random_enemy_room() == true.
func choose_random_enemy_scene_path() -> String:
	var index := randi() % RANDOM_ENEMY_SCENES.size()
	if RANDOM_ENEMY_SCENES.size() > 1:
		while index == last_random_enemy_index:
			index = randi() % RANDOM_ENEMY_SCENES.size()
	last_random_enemy_index = index
	return RANDOM_ENEMY_SCENES[index]

func current_incarnation_scene_path() -> String:
	return INCARNATION_SCENES[current_chapter_index()]

func current_incarnation_name() -> String:
	return INCARNATION_NAMES[current_chapter_index()]

## Scena, do której trzeba wrócić przy starcie gry, jeśli jest zapisany
## przebieg w toku — np. jeśli gracz zamknął grę już po ołtarzu, wraca się
## prosto do walki z Nemoraksem, nie do pokoju 1 (patrz menu.gd).
func resume_scene_path() -> String:
	return ROOM_SCENE if current_room_index < total_room_count() else ARENA_SCENE

## Wywoływane przez room.gd, gdy gracz pokona przeciwnika w aktualnym
## pomieszczeniu — fragment duszy TYLKO za wcielenie, losowi przeciwnicy nie
## dają fragmentów (ustalone z autorem, system fragmentów zostaje bez zmian).
func complete_current_room() -> void:
	if not is_random_enemy_room():
		fragments_collected.append(INCARNATION_NAMES[current_chapter_index()])
	current_room_index += 1
	_save_progress()
	if current_room_index >= total_room_count():
		get_tree().change_scene_to_file(ALTAR_SCENE)
	else:
		get_tree().reload_current_scene() # ten sam room.tscn, kolejne wcielenie

## Wywoływane przez altar.gd po złożeniu wszystkich fragmentów.
func complete_altar() -> void:
	get_tree().change_scene_to_file(ARENA_SCENE)

## Do restartu całego przebiegu od zera — po PRZEGRANEJ z Nemoraksem
## (patrz arena.gd) wraca się tu, do pokoju sprzed pierwszego bossa.
## Zwycięstwo NIE resetuje przebiegu — to prawdziwy koniec (ekran endgame).
func reset_run() -> void:
	current_room_index = 0
	last_random_enemy_index = -1
	fragments_collected.clear()
	saved_player_state.clear()
	_save_progress()

func _load_progress() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		# open() zwraca null zamiast rzucać wyjątek (Godot 4) — bez tej kontroli
		# get_as_text() poniżej wywaliłoby się na null-referencji. Zostają
		# domyślne wartości ustawione wyżej (current_room_index=0 itd.).
		push_warning("GameFlow: nie udało się otworzyć zapisu do odczytu (%s), błąd %d" % [SAVE_PATH, FileAccess.get_open_error()])
		return
	var data = JSON.parse_string(file.get_as_text())
	if typeof(data) != TYPE_DICTIONARY:
		return
	current_room_index = clampi(int(data.get("current_room_index", 0)), 0, total_room_count())
	last_random_enemy_index = int(data.get("last_random_enemy_index", -1))
	var loaded_fragments: Array = data.get("fragments_collected", [])
	fragments_collected.assign(loaded_fragments)
	saved_player_state = data.get("saved_player_state", {})

func _save_progress() -> void:
	var data := {
		"current_room_index": current_room_index,
		"last_random_enemy_index": last_random_enemy_index,
		"fragments_collected": fragments_collected,
		"saved_player_state": saved_player_state,
	}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		# Dysk pełny / user:// tylko do odczytu itp. — stan w pamięci już jest
		# zaktualizowany, po prostu nie zostanie tym razem zapisany na dysk.
		push_warning("GameFlow: nie udało się zapisać postępu (%s), błąd %d" % [SAVE_PATH, FileAccess.get_open_error()])
		return
	file.store_string(JSON.stringify(data))
