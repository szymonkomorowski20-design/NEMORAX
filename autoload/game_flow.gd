extends Node
## Stan całego przebiegu gry (rozszerzenie poza pierwotny dokument): które
## pomieszczenie z sześciu wcieleń jest teraz, ile fragmentów duszy zebrano,
## i przejścia między scenami. Autoload, więc przeżywa reload/zmianę sceny.
## Na razie trzymane tylko w pamięci — resetuje się przy zamknięciu gry
## (najprostsze rozwiązanie na start; łatwo dograć zapis do pliku później).

const ROOM_SCENE := "res://rooms/room.tscn"
const ALTAR_SCENE := "res://rooms/altar.tscn"
const ARENA_SCENE := "res://arena.tscn"

## Kolejność wcieleń = kolejność pomieszczeń 1-6. Nazwa i kolor odpowiadają
## fazom Nemoraxa (sekcja 2 katalogu LORE_I_ASSETY.md).
const INCARNATION_SCENES: Array[String] = [
	"res://entities/incarnations/zalazek.tscn",
	"res://entities/incarnations/cisza_incarnation.tscn",
	"res://entities/incarnations/zwloka_incarnation.tscn",
	"res://entities/incarnations/ciezar_incarnation.tscn",
	"res://entities/incarnations/glod_incarnation.tscn",
	"res://entities/incarnations/zacmienie_incarnation.tscn",
]

const INCARNATION_NAMES: Array[String] = [
	"Zalążek", "Cisza", "Zwłoka", "Ciężar", "Głód", "Zaćmienie",
]

var current_room_index: int = 0 ## 0..5 — indeks aktualnego wcielenia/pomieszczenia
var fragments_collected: Array[String] = [] ## nazwy zebranych fragmentów, w kolejności

func current_incarnation_scene_path() -> String:
	return INCARNATION_SCENES[current_room_index]

func current_incarnation_name() -> String:
	return INCARNATION_NAMES[current_room_index]

## Wywoływane przez room.gd, gdy gracz pokona wcielenie w aktualnym pomieszczeniu.
func complete_current_room() -> void:
	fragments_collected.append(INCARNATION_NAMES[current_room_index])
	current_room_index += 1
	if current_room_index >= INCARNATION_SCENES.size():
		get_tree().change_scene_to_file(ALTAR_SCENE)
	else:
		get_tree().reload_current_scene() # ten sam room.tscn, kolejne wcielenie

## Wywoływane przez altar.gd po złożeniu wszystkich fragmentów.
func complete_altar() -> void:
	get_tree().change_scene_to_file(ARENA_SCENE)

## Do restartu całego przebiegu od zera (np. nowa gra z menu, gdyby powstało).
func reset_run() -> void:
	current_room_index = 0
	fragments_collected.clear()
