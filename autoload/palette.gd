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

# Kolory kolejnych faz bossa (sekcja 7) — każdy inny, w kolejności od 600 HP do 0 HP.
const PHASE_COLORS := [
	Color("#F0447A"), # bez formy (faza nauki)
	Color("#FF8A3D"), # Cisza
	Color("#C44FD6"), # Zwłoka
	Color("#6C63FF"), # Ciężar
	Color("#7ED957"), # Głód
	Color("#C9C2B4"), # Zaćmienie
]

const PHASE_NAMES := [
	"",
	"Cisza",
	"Zwłoka",
	"Ciężar",
	"Głód",
	"Zaćmienie",
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
