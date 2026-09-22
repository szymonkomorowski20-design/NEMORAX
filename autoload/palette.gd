extends Node
## Jedyne miejsce z kolorami gry (sekcja 2 dokumentu) i konfiguracją wejścia.
## Autoload, więc `_ready()` odpala się raz na start gry, nawet gdy `arena.tscn`
## jest później przeładowywana (restart po śmierci).

const BACKGROUND := Color("#1A1026")
const ARENA_FLOOR := Color("#2A1B3D")
const ARENA_WALL := Color("#3E2A57")
const PLAYER_BODY := Color("#5BE0C8")
const DANGER := Color("#FFC857") # wyłącznie to, co zadaje obrażenia
const VOID_INTERIOR := Color("#0B0810")
const HIT_FLASH := Color("#FFFFFF")

## Opcje — Dostępność: "redukcja migotania". Jedyny naprawdę powtarzalny,
## częsty efekt "flash" w grze to biała poza "hit" pokazywana na 2 klatki przy
## KAŻDYM trafieniu (flash_white() w player.gd/incarnation.gd/boss.gd,
## patrz komentarz w autoload/juice.gd: "błysk trafienia... 2 klatki na
## biało") — w długiej walce to dużo migotania. `var`, nie `const`: ustawiane
## z ui/options_screen.gd i zapisywane w user://settings.json.
var reduce_flashing: bool = false

## Faza 2A (PLAN_PROFESSIONAL_GAME_FEEL_DLA_CLAUDE.md) — jedna, spisana
## konwencja z_index dla całej gry. Wartości poniżej już były w kodzie
## (walls.gd, room_atmosphere.gd, door.gd, contact_shadow.gd, attack_vfx.gd,
## enemy_health_bar.gd) — to jest tylko pierwsze miejsce, gdzie są spisane
## RAZEM, żeby nowy kod miał z czym się porównać zamiast zgadywać. Każdy
## wyjątek od tej kolejności w kodzie MUSI mieć komentarz wyjaśniający dlaczego.
##   -20  pustka poza pokojem            (walls.gd: build_void_background)
##   -10  podłoga                        (walls.gd: build_floor)
##    -8  atmosfera/cień otoczenia       (room_atmosphere.gd)
##    -5  ściana                         (walls.gd: build)
##    -3  drzwi / portal osadzony w murze (door.gd)
##    -1  dekoracje podłogowe, cień kontaktowy (contact_shadow.gd)
##     0  postacie, skrzynie, pickupy    (domyślny z_index węzłów encji)
##     5  pociski/VFX ataku nad postaciami (attack_vfx.gd)
##     6  paski zdrowia nad głową        (enemy_health_bar.gd)
##    10+ HUD i cutscenki                (osobne CanvasLayer, poza z_index)

## Faza 5 (PLAN_PROFESSIONAL_GAME_FEEL_DLA_CLAUDE.md sekcja "Dźwięk"):
## "różne materiały mają różne odpowiedzi: metal, kość, magia, kamień" —
## wcześniej WSZYSTKIE 17 archetypów (11 losowych + 6 wcieleń) dzieliło jeden
## wspólny dźwięk trafienia/śmierci. Pliki w assets/audio/sfx/materials/ są
## na razie CISZĄ — autor gry uzupełni prawdziwe brzmienia sam, w swoim
## czasie; nie czekaj na to, samo przypisanie kategorii per-archetyp już
## przygotowuje kod. Nemorax ma własny, unikalny zestaw dźwięków (boss.gd) i
## celowo NIE korzysta z tej tabeli — nie jest "jednym z wielu materiałów".
enum HitMaterial { METAL, BONE, MAGIC, STONE }

const MATERIAL_HURT_SOUNDS := {
	HitMaterial.METAL: preload("res://assets/audio/sfx/materials/metal_hurt.wav"),
	HitMaterial.BONE: preload("res://assets/audio/sfx/materials/bone_hurt.wav"),
	HitMaterial.MAGIC: preload("res://assets/audio/sfx/materials/magic_hurt.wav"),
	HitMaterial.STONE: preload("res://assets/audio/sfx/materials/stone_hurt.wav"),
}
const MATERIAL_DEATH_SOUNDS := {
	HitMaterial.METAL: preload("res://assets/audio/sfx/materials/metal_death.wav"),
	HitMaterial.BONE: preload("res://assets/audio/sfx/materials/bone_death.wav"),
	HitMaterial.MAGIC: preload("res://assets/audio/sfx/materials/magic_death.wav"),
	HitMaterial.STONE: preload("res://assets/audio/sfx/materials/stone_death.wav"),
}

# Kolory sześciu faz Nemoraksa — CLAUDE_CODE_GAME_CONTENT_BIBLE.md sekcja 13
# (Motion/Force/Instinct/Dominion/Ruin/Sovereignty, na życzenie autora zamiast
# Cisza/Zwłoka/Ciężar/Głód/Zaćmienie). TYMCZASOWE dobranie kolorów — grafika i
# tak idzie osobno przez GPT (PLAN_ANIMACJE_KIERUNKOWE.md), te wartości można
# swobodnie zmienić bez wpływu na kod (arena.gd przełącza po indeksie, nie po
# kolorze/nazwie — patrz tests/test_boss_phases.gd).
const PHASE_COLORS := [
	Color("#4FC3E8"), # Motion — chłodny błękit, kinetyczny
	Color("#E8622E"), # Force — pomarańcz uderzenia
	Color("#9B4DFF"), # Instinct — fiolet, nieprzewidywalność
	Color("#4FA65E"), # Dominion — zieleń kontroli terenu
	Color("#D63B3B"), # Ruin — czerwień agresji
	Color("#E8C547"), # Sovereignty — złoto, kulminacja
]

const PHASE_NAMES := [
	"Motion",
	"Force",
	"Instinct",
	"Dominion",
	"Ruin",
	"Sovereignty",
]

func _ready() -> void:
	_setup_input_map()

## Definiujemy akcje wejścia w kodzie zamiast ręcznie edytować `project.godot`:
## ręczne wpisywanie zasobów InputEventKey w formacie tekstowym projektu jest
## bardzo podatne na literówki, które psują cały plik. Autor gry może mimo to
## podejrzeć/przypisać klawisze w Project Settings > Input Map w edytorze.
func _setup_input_map() -> void:
	_bind_key("move_left", KEY_A)
	_bind_key("move_right", KEY_D)
	_bind_key("move_up", KEY_W)
	_bind_key("move_down", KEY_S)
	_bind_key("dash", KEY_SPACE)
	_bind_mouse_button("attack", MOUSE_BUTTON_LEFT)
	_bind_mouse_button("block", MOUSE_BUTTON_RIGHT)
	_bind_key("weapon_sword", KEY_1)
	_bind_key("weapon_wand", KEY_2)
	_bind_key("heal", KEY_E)
	_bind_key("pickup", KEY_F)
	_bind_key("toggle_debug", KEY_F3) # narzędzie dewelopera (Juice._update_debug_label) — celowo poza REBINDABLE_ACTIONS, gracz go nie rebinduje

func _bind_key(action: String, keycode: Key) -> void:
	if InputMap.has_action(action):
		return
	InputMap.add_action(action)
	var event := InputEventKey.new()
	event.physical_keycode = keycode
	InputMap.action_add_event(action, event)

func _bind_mouse_button(action: String, button: MouseButton) -> void:
	if InputMap.has_action(action):
		return
	InputMap.add_action(action)
	var event := InputEventMouseButton.new()
	event.button_index = button
	InputMap.action_add_event(action, event)
