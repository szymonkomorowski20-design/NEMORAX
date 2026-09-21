extends Node2D
## Pokój ołtarza (rozszerzenie poza dokument bazowy, patrz LORE_I_ASSETY.md) —
## maszyna stanów LOCKED→READY→ACTIVATING→BOSS_ACTIVE→COMPLETE
## (CLAUDE_CODE_GAME_CONTENT_BIBLE.md sekcja 12). BOSS_ACTIVE/COMPLETE należą
## faktycznie do arena.gd (osobna scena po przejściu przez GameFlow.complete_altar())
## — ten skrypt odpowiada tylko za LOCKED/READY/ACTIVATING, czyli wszystko, co
## dzieje się PRZED przywołaniem Nemoraksa.
##
## LOCKED nie powinno się zdarzyć w normalnej rozgrywce: GameFlow.is_direction_open()
## blokuje drzwi DO tego pokoju, dopóki fragments_collected.size() < CHAPTER_COUNT
## (patrz autoload/game_flow.gd) — więc gracz fizycznie nie może tu wejść bez
## kompletu. Jeśli mimo to się zdarzy (np. przyszła ścieżka debug), traktujemy
## to jako uszkodzenie stanu (dokument: "content corruption") i logujemy zamiast
## pozwolić przejść dalej po cichu.

enum AltarState { LOCKED, READY, ACTIVATING, BOSS_ACTIVE, COMPLETE }

const ARENA_RECT := Rect2(90, 60, 1100, 600)
const WALL_THICKNESS := 20.0
const ALTAR_RADIUS := 60.0
const SOCKET_COLORS := [
	Color("#F0447A"), Color("#9B4DFF"), Color("#C44FD6"),
	Color("#6C63FF"), Color("#E8524A"), Color("#8C9AC2"),
]

const VOID_BACKGROUND := preload("res://assets/sprites/pokoje/tekstury/void_background.png")
const FLOOR_TEXTURE := preload("res://assets/sprites/pokoje/tekstury/altar_floor.png")
const WALL_TEXTURE := preload("res://assets/sprites/pokoje/tekstury/altar_wall.png")
const SOCKET_TEXTURE := preload("res://assets/sprites/pokoje/obiekty/altar_socket.png")
const SOCKET_SPRITE_SCALE := 0.054
const SOCKET_FILLED_BRIGHTNESS := 1.6 ## mnożnik modulate przy aktywacji — "ten sam obrazek z dodanym blaskiem" (brak dedykowanej grafiki "zapełnione")

@export var summon_trigger_radius: float = 50.0 ## px, jak blisko środka musi podejść gracz
@export var slot_activation_interval: float = 0.45 ## s, odstęp między aktywacją kolejnych gniazd (dokument, sekcja 12)
@export var summon_delay: float = 2.0 ## s, opóźnienie między ostatnim gniazdem a przejściem do walki

@onready var player: Player = $Player
@onready var ui: GameUI = $UILayer/UI

var state: AltarState = AltarState.LOCKED
var _sockets: Array[Sprite2D] = []

func _ready() -> void:
	Walls.build_void_background(self, get_viewport_rect().size, VOID_BACKGROUND)
	Walls.build_floor(self, ARENA_RECT, FLOOR_TEXTURE)
	Walls.build(self, ARENA_RECT, WALL_THICKNESS, WALL_TEXTURE)
	_spawn_sockets()
	player.global_position = ARENA_RECT.get_center() + Vector2(0, 200)
	ui.player = player

	if GameFlow.fragments_collected.size() >= GameFlow.CHAPTER_COUNT:
		state = AltarState.READY
		ui.show_taunt(
			"Wszystkie fragmenty duszy zebrane.\nPodejdź do ołtarza, aby przywołać Nemoraksa.",
			4.0
		)
		_play_ready_lore_lines()
	else:
		# Nie powinno się zdarzyć — patrz komentarz na górze pliku.
		state = AltarState.LOCKED
		push_warning("Altar: wejście z niekompletnym zestawem fragmentów (%d/%d) — GameFlow.is_direction_open() powinno to blokować" % [GameFlow.fragments_collected.size(), GameFlow.CHAPTER_COUNT])
		ui.show_taunt("Brakuje fragmentów duszy (%d/%d)." % [GameFlow.fragments_collected.size(), GameFlow.CHAPTER_COUNT], 4.0)

## Dwa dodatkowe okrzyki po istniejącym (FABULA_I_DIALOGI.md sekcja 3.3),
## odpalane w tle — sprawdzają `state` przed każdym, żeby nie nadpisać
## "Nemorax powstaje..." tekstem lore, gdyby gracz zdążył wejść w aktywację
## zanim ta sekwencja się skończy.
func _play_ready_lore_lines() -> void:
	await get_tree().create_timer(4.0).timeout
	if state != AltarState.READY:
		return
	ui.show_taunt("Sześć głosów, sześć krzywd. Za chwilę znów będą jednym.", 3.5)
	await get_tree().create_timer(3.5).timeout
	if state != AltarState.READY:
		return
	ui.show_taunt("Nie pierwszy raz to robisz. Coś w tobie o tym wie, nawet jeśli ty nie wiesz.", 4.0)

## Sześć gniazd w kręgu wokół pedestału — sam obrazek jest neutralny, więc
## każde gniazdo dostaje kolor swojego wcielenia przez modulate (patrz
## PROMPTY_FINALNE_WSZYSTKO.md C2/C3 — jedna grafika, tintowana w silniku).
func _spawn_sockets() -> void:
	_sockets.clear()
	var center := ARENA_RECT.get_center()
	for i in range(SOCKET_COLORS.size()):
		var angle := TAU * float(i) / float(SOCKET_COLORS.size())
		var socket := Sprite2D.new()
		socket.texture = SOCKET_TEXTURE
		socket.scale = Vector2(SOCKET_SPRITE_SCALE, SOCKET_SPRITE_SCALE)
		socket.modulate = SOCKET_COLORS[i]
		socket.position = center + Vector2(cos(angle), sin(angle)) * (ALTAR_RADIUS + 40.0)
		add_child(socket)
		_sockets.append(socket)

func _physics_process(_delta: float) -> void:
	if state != AltarState.READY:
		return
	if player.global_position.distance_to(ARENA_RECT.get_center()) <= summon_trigger_radius:
		_begin_activation()

## READY -> ACTIVATING (dokument, sekcja 12): aktywuje gniazda po kolei w
## kanonicznej kolejności Motion/Force/Instinct/Dominion/Ruin/Sovereignty
## (ta sama kolejność co SOCKET_COLORS/GameFlow.INCARNATION_NAMES, chapter
## 0..5), w odstępach slot_activation_interval, POTEM dopiero przejście do
## bossa. Gracz traci sterowanie na czas sekwencji (get_tree().paused) — jak
## PauseMenu, ten węzeł MUSI dostać PROCESS_MODE_ALWAYS, żeby przeżyć własną pauzę.
func _begin_activation() -> void:
	state = AltarState.ACTIVATING
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().paused = true
	_run_activation_sequence()

func _run_activation_sequence() -> void:
	for socket in _sockets:
		socket.modulate = socket.modulate * SOCKET_FILLED_BRIGHTNESS
		await get_tree().create_timer(slot_activation_interval).timeout
	ui.show_taunt("Nemorax powstaje...", summon_delay)
	await get_tree().create_timer(summon_delay).timeout
	get_tree().paused = false
	# BOSS_ACTIVE/COMPLETE żyją w arena.gd (osobna scena) — ta zmiana stanu
	# jest tu tylko na wypadek, gdyby coś jeszcze odpytało `state` w tej samej
	# klatce przed zmianą sceny (change_scene_to_file nie jest natychmiastowe).
	state = AltarState.BOSS_ACTIVE
	GameFlow.complete_altar()

## Sam centralny pedestał nie ma dedykowanej grafiki w katalogu (tylko gniazda
## dookoła) — zostaje rysowany kodem.
func _draw() -> void:
	draw_circle(ARENA_RECT.get_center(), ALTAR_RADIUS, Palette.ARENA_WALL)
