extends Node
## Stan całego przebiegu gry (rozszerzenie poza pierwotny dokument): które
## pomieszczenie z sześciu wcieleń jest teraz, ile fragmentów duszy zebrano,
## i przejścia między scenami. Autoload, więc przeżywa reload/zmianę sceny.
## Zapisywane na dysk (na życzenie autora), żeby zamknięcie gry w trakcie
## gauntletu nie cofało do pokoju 1.

var SAVE_PATH := "user://gauntlet_progress.json" ## var (nie const) tylko po to, żeby test mógł podmienić ścieżkę na tymczasową

const ROOM_SCENE := "res://rooms/room.tscn"
const ALTAR_SCENE := "res://rooms/altar.tscn"
const ARENA_SCENE := "res://arena.tscn"

## Kolejność wcieleń = kolejność pomieszczeń 1-6. Nazwy plików/klas zostały po
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

var current_room_index: int = 0 ## 0..5 — indeks aktualnego wcielenia/pomieszczenia
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
	player.current_weapon = saved_player_state.get("current_weapon", player.current_weapon)

func current_incarnation_scene_path() -> String:
	return INCARNATION_SCENES[current_room_index]

func current_incarnation_name() -> String:
	return INCARNATION_NAMES[current_room_index]

## Scena, do której trzeba wrócić przy starcie gry, jeśli jest zapisany
## przebieg w toku — np. jeśli gracz zamknął grę już po ołtarzu, wraca się
## prosto do walki z Nemoraksem, nie do pokoju 1 (patrz menu.gd).
func resume_scene_path() -> String:
	return ROOM_SCENE if current_room_index < INCARNATION_SCENES.size() else ARENA_SCENE

## Wywoływane przez room.gd, gdy gracz pokona wcielenie w aktualnym pomieszczeniu.
func complete_current_room() -> void:
	fragments_collected.append(INCARNATION_NAMES[current_room_index])
	current_room_index += 1
	_save_progress()
	if current_room_index >= INCARNATION_SCENES.size():
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
	current_room_index = clampi(int(data.get("current_room_index", 0)), 0, INCARNATION_SCENES.size())
	var loaded_fragments: Array = data.get("fragments_collected", [])
	fragments_collected.assign(loaded_fragments)
	saved_player_state = data.get("saved_player_state", {})

func _save_progress() -> void:
	var data := {
		"current_room_index": current_room_index,
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
