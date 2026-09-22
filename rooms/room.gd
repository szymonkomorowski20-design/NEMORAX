extends Node2D
## Jedna, generyczna scena pomieszczenia — rozszerzenie poza dokument bazowy
## (patrz LORE_I_ASSETY.md). Ta sama scena jest przeładowywana dla każdego
## pokoju na siatce z game_flow.gd (styl "The Binding of Isaac", na życzenie
## autora) — GameFlow.current_room_data() mówi, jaki to typ pokoju i co w nim
## zespawnować; GameFlow.is_direction_open() mówi, które ściany mają teraz
## przejście.
##
## Przebieg: gracz pojawia się przy ścianie, którą wszedł (albo w środku, jeśli
## to pokój startowy) -> jeśli jest przeciwnik, drzwi są zamknięte (nie
## zespawnowane) dopóki się go nie pokona -> po pokonaniu (wcielenie: wypada
## dusza, gracz podnosi ją klawiszem F; losowy przeciwnik: bez duszy) -> drzwi
## pojawiają się na WSZYSTKICH otwartych teraz ścianach -> przejście do
## sąsiedniego pokoju (albo ołtarza, jeśli drzwi tam prowadzą), z zachowaniem
## statystyk gracza.

const ARENA_RECT := Rect2(90, 60, 1100, 600) # ta sama wyśrodkowana arena co w arena.tscn
const WALL_THICKNESS := 20.0

const DoorScene := preload("res://rooms/door.tscn")
const SoulScene := preload("res://rooms/soul.tscn")
const ChestScene := preload("res://rooms/chest.tscn")
const RoomAtmosphereScene := preload("res://rooms/room_atmosphere.gd")

const VOID_BACKGROUND := preload("res://assets/sprites/pokoje/tekstury/void_background.png")
# W kolejności GameFlow.INCARNATION_SCENES (Vhar'Nokh...Orryx) — indeksowane
# przez "chapter" (pokoje SOUL) albo "enemy_index" modulo rozmiar (pokoje
# RANDOM/START, tymczasowo — patrz PLAN_LOSOWYCH_POKOI.md).
const ROOM_FLOOR_TEXTURES: Array[Texture2D] = [
	preload("res://assets/sprites/pokoje/tekstury/vhar_nokh_floor.png"),
	preload("res://assets/sprites/pokoje/tekstury/mordrath_floor.png"),
	preload("res://assets/sprites/pokoje/tekstury/zha_ruun_floor.png"),
	preload("res://assets/sprites/pokoje/tekstury/nekravor_floor.png"),
	preload("res://assets/sprites/pokoje/tekstury/thal_gor_floor.png"),
	preload("res://assets/sprites/pokoje/tekstury/orryx_floor.png"),
]
const ROOM_WALL_TEXTURES: Array[Texture2D] = [
	preload("res://assets/sprites/pokoje/tekstury/vhar_nokh_wall.png"),
	preload("res://assets/sprites/pokoje/tekstury/mordrath_wall.png"),
	preload("res://assets/sprites/pokoje/tekstury/zha_ruun_wall.png"),
	preload("res://assets/sprites/pokoje/tekstury/nekravor_wall.png"),
	preload("res://assets/sprites/pokoje/tekstury/thal_gor_wall.png"),
	preload("res://assets/sprites/pokoje/tekstury/orryx_wall.png"),
]

# 8 dedykowanych motywów pokoi RANDOM (PROMPTY_WROGOW_LOSOWYCH_I_SKRZYNI.md
# sekcja C, w kolejności C1-C8) — zastępuje dawne tymczasowe reużycie
# tekstur wcieleń dla pokoi RANDOM.
const RANDOM_ROOM_FLOOR_TEXTURES: Array[Texture2D] = [
	preload("res://assets/sprites/pokoje/tekstury/random_rooms/flooded_catacombs_floor_v2.png"),
	preload("res://assets/sprites/pokoje/tekstury/random_rooms/sunken_library_floor_v2.png"),
	preload("res://assets/sprites/pokoje/tekstury/random_rooms/frozen_crypt_floor_v2.png"),
	preload("res://assets/sprites/pokoje/tekstury/random_rooms/blood_ritual_hall_floor_v2.png"),
	preload("res://assets/sprites/pokoje/tekstury/random_rooms/overgrown_ruins_floor_v2.png"),
	preload("res://assets/sprites/pokoje/tekstury/random_rooms/ash_battlefield_floor_v2.png"),
	preload("res://assets/sprites/pokoje/tekstury/random_rooms/crystal_cavern_floor_v2.png"),
	preload("res://assets/sprites/pokoje/tekstury/random_rooms/rusted_machine_hall_floor_v2.png"),
]
const RANDOM_ROOM_WALL_TEXTURES: Array[Texture2D] = [
	preload("res://assets/sprites/pokoje/tekstury/random_rooms/flooded_catacombs_wall_v2.png"),
	preload("res://assets/sprites/pokoje/tekstury/random_rooms/sunken_library_wall_v2.png"),
	preload("res://assets/sprites/pokoje/tekstury/random_rooms/frozen_crypt_wall_v2.png"),
	preload("res://assets/sprites/pokoje/tekstury/random_rooms/blood_ritual_hall_wall_v2.png"),
	preload("res://assets/sprites/pokoje/tekstury/random_rooms/overgrown_ruins_wall_v2.png"),
	preload("res://assets/sprites/pokoje/tekstury/random_rooms/ash_battlefield_wall_v2.png"),
	preload("res://assets/sprites/pokoje/tekstury/random_rooms/crystal_cavern_wall_v2.png"),
	preload("res://assets/sprites/pokoje/tekstury/random_rooms/rusted_machine_hall_wall_v2.png"),
]

# Na życzenie autora: losowy utwór z tej puli przy KAŻDYM wejściu do pokoju
# (nie stały przydział pokój->utwór) — scena się przeładowuje przy każdym
# przejściu, więc losowanie w _ready() samo daje inny utwór za każdym razem.
const ROOM_MUSIC_TRACKS: Array[AudioStream] = [
	preload("res://assets/audio/music/MUS_room_synth_1.wav"),
	preload("res://assets/audio/music/MUS_room_synth_2.wav"),
	preload("res://assets/audio/music/MUS_room_synth_3.wav"),
	preload("res://assets/audio/music/MUS_room_synth_4.wav"),
	preload("res://assets/audio/music/MUS_room_chase_1.wav"),
	preload("res://assets/audio/music/MUS_room_chase_2.wav"),
	preload("res://assets/audio/music/MUS_room_melody_1.wav"),
	preload("res://assets/audio/music/MUS_room_melody_2.wav"),
	preload("res://assets/audio/music/MUS_room_melody_3.wav"),
	preload("res://assets/audio/music/MUS_room_melody_4.wav"),
]

@export var player_start_offset: Vector2 = Vector2(0.0, 0.0) ## względem środka areny, TYLKO w pokoju startowym (entry_direction == ZERO)
@export var incarnation_spawn_offset: Vector2 = Vector2(0.0, -60.0) ## względem środka areny

@onready var player: Player = $Player
@onready var ui: GameUI = $UILayer/UI
@onready var pause_menu: PauseMenu = $PauseLayer/PauseMenu
@onready var stats_screen: StatsScreen = $StatsLayer/StatsScreen
@onready var music: AudioStreamPlayer = $Music
@onready var cutscene: CutscenePlayer = $CutsceneLayer/CutscenePlayer

var incarnation: Incarnation
var _game_over_kind: String = "" # "" albo "death"
var _room_data: Dictionary

## Ściany/tło poza areną celowo przyciemnione WZGLĘDEM podłogi (ta sama
## tekstura co podłoga inaczej czyta się jak rama obrazka, nie jak granica
## świata — KIERUNEK_WIZUALNY_REFERENCJE.md). Tło poza areną ciemniejsze
## jeszcze bardziej niż ściana — ma sugerować otchłań, nie kolejną powierzchnię.
const WALL_MODULATE := Color(0.45, 0.45, 0.52, 1.0)
const VOID_MODULATE := Color(0.22, 0.22, 0.28, 1.0)

func _ready() -> void:
	_room_data = GameFlow.current_room_data()
	Walls.build_void_background(self, get_viewport_rect().size, VOID_BACKGROUND, VOID_MODULATE)

	var floor_tex: Texture2D
	var wall_tex: Texture2D
	if _room_data.get("type") == GameFlow.RoomType.SOUL:
		var chapter: int = _room_data.get("chapter", 0)
		floor_tex = ROOM_FLOOR_TEXTURES[chapter]
		wall_tex = ROOM_WALL_TEXTURES[chapter]
	elif _room_data.get("type") == GameFlow.RoomType.RANDOM:
		var theme_index: int = int(_room_data.get("enemy_index", 0)) % RANDOM_ROOM_FLOOR_TEXTURES.size()
		floor_tex = RANDOM_ROOM_FLOOR_TEXTURES[theme_index]
		wall_tex = RANDOM_ROOM_WALL_TEXTURES[theme_index]
	else: # START — bez dedykowanego wyglądu, reużywam pierwszy motyw jako placeholder
		floor_tex = ROOM_FLOOR_TEXTURES[0]
		wall_tex = ROOM_WALL_TEXTURES[0]
	Walls.build_floor(self, ARENA_RECT, floor_tex)
	Walls.build(self, ARENA_RECT, WALL_THICKNESS, wall_tex, WALL_MODULATE)
	_add_room_atmosphere()

	var track: AudioStreamWAV = ROOM_MUSIC_TRACKS[randi() % ROOM_MUSIC_TRACKS.size()]
	# Ustawiane w kodzie, nie tylko w .import — headless `--import` (używane w
	# tej sesji do generowania .import przy nowych plikach) niezawodnie nie
	# zapisuje edit/loop_mode do faktycznego cache'owanego zasobu, sprawdzone
	# bezpośrednim testem (loop_mode wychodził 0 mimo poprawnego .import).
	track.loop_mode = AudioStreamWAV.LOOP_FORWARD
	music.stream = track
	music.play()

	var center := ARENA_RECT.get_center()
	player.global_position = _player_spawn_position(center)
	player.died.connect(_on_player_died)
	GameFlow.apply_player_state(player) # ta sama migawka co przy wejściu do tego pokoju

	ui.player = player
	ui.show_minimap = true
	player.resource_denied.connect(ui.flash_resource_denied)

	# Krok 8 (TERAZ_DLA_CLAUDE_ARENA_UI_I_FEELING.md): "krótki tytuł miejsca /
	# wejście przez drzwi" — górny środek, ta sama, przelotna ścieżka co
	# baner fazy bossa w arena.gd (osobna scena, więc nigdy się nie zderzą) —
	# tylko mniejszą czcionką (show_taunt, nie show_form_name) i krócej (1,2s
	# z dokumentu zamiast 2s domyślnych dla "ciężkiego" tytułu fazy).
	var room_title := _room_display_name()
	if room_title != "":
		ui.show_taunt(room_title, 1.2)

	# Pokój już wyczyszczony (gracz wrócił po fakcie przez inne drzwi na siatce
	# — możliwe, bo to graf, nie jednokierunkowy korytarz) NIE respawnuje
	# przeciwnika. Bez tej kontroli re-zabicie tego samego wcielenia wołałoby
	# GameFlow.clear_current_room() drugi raz: podwójny fragment duszy na
	# liście i podwójne dobicie rooms_cleared_count za ten sam pokój.
	var already_cleared: bool = _room_data.get("cleared", false)
	match _room_data.get("type"):
		GameFlow.RoomType.RANDOM:
			if already_cleared:
				_spawn_doors_for_open_directions()
				_maybe_spawn_chest()
			else:
				_spawn_enemy(GameFlow.current_random_enemy_scene_path(), true)
		GameFlow.RoomType.SOUL:
			if already_cleared:
				_spawn_doors_for_open_directions()
			else:
				_spawn_enemy(GameFlow.current_incarnation_scene_path(), false)
		_: # START — pusty, bezpieczny pokój, drzwi od razu otwarte
			_spawn_doors_for_open_directions()
			if not GameFlow.has_seen_prolog():
				_play_prolog()

## Krok 8: tytuł banera wejścia do pokoju. SOUL pokazuje imię wcielenia
## (GameFlow.INCARNATION_NAMES, ta sama lista co INCARNATION_DEATH_LINES niżej
## — gracz i tak zobaczy przeciwnika natychmiast po wejściu, więc to nie jest
## spoiler) — Ołtarz nazwany wprost w LORE_I_ASSETY.md ("Pokój 7 — Ołtarz").
## START pomija baner (pierwszy pokój ma już własny prolog).
func _room_display_name() -> String:
	match _room_data.get("type"):
		GameFlow.RoomType.SOUL:
			return GameFlow.INCARNATION_NAMES[_room_data.get("chapter", 0)]
		GameFlow.RoomType.ALTAR:
			return "Ołtarz"
		GameFlow.RoomType.RANDOM:
			return "Komnata"
		_: # START
			return ""

## Pokój startowy (entry_direction == ZERO) nie ma "kierunku, z którego
## przyszliśmy", więc gracz staje po prostu na środku. W każdym innym pokoju
## pojawia się przy ścianie PRZECIWNEJ do kierunku ruchu — wszedł od północy,
## więc ląduje przy południowej (dolnej) ścianie, twarzą z powrotem do wyjścia.
func _player_spawn_position(center: Vector2) -> Vector2:
	if GameFlow.entry_direction == Vector2i.ZERO:
		return center + player_start_offset
	var wall_side := GameFlow.opposite_wall_for_direction(GameFlow.entry_direction)
	var wall_pos := Walls.wall_point(ARENA_RECT, wall_side)
	var inward := (center - wall_pos).normalized() * 70.0
	return wall_pos + inward

func _process(_delta: float) -> void:
	if _game_over_kind != "":
		_handle_game_over_input()

## Prolog (PLAN_CUTSCENEK.md sekcja 2.1) — raz na zapis, przy pierwszym
## wejściu do pokoju startowego. Ekran całkiem czarny, bez portretu (głos bez
## twarzy), 3 beaty. Wołane fire-and-forget (bez await w _ready()) — reszta
## setupu pokoju nie musi na to czekać, cutscenka i tak przykrywa cały ekran.
func _play_prolog() -> void:
	GameFlow.mark_prolog_seen()
	var beats: Array[DialogueBeat] = []
	for line in [
		"Nie pamiętasz, jak tu trafiłeś.",
		"To normalne. Nikt z nas nie pamięta.",
		"Zbierz sześć fragmentów. Idź do ołtarza. Zrób to, co robisz zawsze.",
	]:
		var beat := DialogueBeat.new()
		beat.text = line
		beat.fallback_seconds = 2.0
		beats.append(beat)
	await cutscene.play(beats)

func _add_room_atmosphere() -> void:
	var atmosphere := RoomAtmosphereScene.new() as RoomAtmosphere
	atmosphere.configure(ARENA_RECT)
	add_child(atmosphere)

## Escape poza ekranem game-over pauzuje/wznawia — w trakcie game-over Spacja
## (ui_accept) już obsługuje retry, nie ma tam czego pauzować.
## Ten handler nie musi sam pilnować wykluczania z pause_menu/stats_screen —
## oba pauzują drzewo, kiedy są otwarte, a wtedy TEN węzeł (domyślny
## process_mode) w ogóle przestaje dostawać input, więc się nie zdublują.
func _unhandled_input(event: InputEvent) -> void:
	if _game_over_kind != "":
		return
	if event.is_action_pressed("ui_cancel"):
		pause_menu.toggle()
	elif event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_TAB:
		stats_screen.open(player)

func _spawn_enemy(scene_path: String, is_random: bool) -> void:
	var scene: PackedScene = load(scene_path)
	incarnation = scene.instantiate() as Incarnation
	incarnation.arena_rect = ARENA_RECT
	incarnation.global_position = ARENA_RECT.get_center() + incarnation_spawn_offset
	incarnation.died.connect(_on_incarnation_died)
	add_child(incarnation)
	if is_random:
		# Rosnąca trudność losowych przeciwników z liczbą wyczyszczonych pokoi
		# (ustalone z autorem) — wcielenia z duszami zachowują swoje ręcznie
		# dobrane, stałe statystyki, więc ta gałąź ich nie dotyczy.
		incarnation.apply_difficulty_scale(1.0 + GameFlow.rooms_cleared_count * GameFlow.RANDOM_ENEMY_DIFFICULTY_STEP)
		if randf() < GameFlow.elite_chance_for_current_progress():
			incarnation.apply_elite_modifier()
	ui.boss = incarnation

## Drzwi zamknięte na czas walki (jak w Isaacu, ustalone z autorem) — dopiero
## teraz, po pokonaniu przeciwnika, sprawdzamy KTÓRE ściany mają teraz
## przejście (GameFlow.is_direction_open) i stawiamy tam realne drzwi.
func _spawn_doors_for_open_directions() -> void:
	for direction in GameFlow.DIRECTIONS:
		if not GameFlow.is_direction_open(direction):
			continue
		var wall_side := GameFlow.wall_for_direction(direction)
		var pos := Walls.wall_point(ARENA_RECT, wall_side)
		var neighbor := GameFlow.neighbor_data(direction)
		var callback := _on_altar_door_entered if neighbor.get("type") == GameFlow.RoomType.ALTAR else _on_move_door_entered.bind(direction)
		# Drzwi są osadzane DOKŁADNIE na linii ściany — rift_doorway_rotatable_v3
		# jest symetryczny na wszystkie 4 strony, więc obrót pod wall_side
		# wygląda poprawnie z każdej strony (patrz rooms/door.gd).
		_spawn_door(pos, callback, wall_side)

func _spawn_door(pos: Vector2, on_entered: Callable, wall_side: String) -> void:
	var door: Door = DoorScene.instantiate()
	door.player = player
	door.wall_side = wall_side
	door.global_position = pos
	door.entered.connect(on_entered)
	add_child(door)

func _on_incarnation_died(fragment_name: String) -> void:
	player.gain_xp() # 1 XP za każdego pokonanego przeciwnika, losowego i wcielenie jednakowo
	GameFlow.clear_current_room()
	if _room_data.get("type") == GameFlow.RoomType.RANDOM:
		# Losowi przeciwnicy nie dają fragmentów/dusz do podniesienia (ustalone
		# z autorem) — od razu otwarte drzwi, bez kroku z podnoszeniem duszy.
		# Faza 4 (PLAN_PROFESSIONAL_GAME_FEEL_DLA_CLAUDE.md): "pół sekundy
		# spokoju" między śmiercią ostatniego wroga a nagrodą/drzwiami — bez
		# tego drzwi i skrzynia pojawiały się w tej samej klatce co zgon.
		await get_tree().create_timer(0.5).timeout
		_spawn_doors_for_open_directions()
		_maybe_spawn_chest()
		return
	var soul: Soul = SoulScene.instantiate()
	soul.color = incarnation.current_color
	soul.player = player
	soul.global_position = incarnation.global_position
	soul.collected.connect(_on_soul_collected.bind(fragment_name))
	add_child(soul)

## Ostatnie słowa każdego wcielenia (FABULA_I_DIALOGI.md sekcja 3.2) —
## zastępują generyczny toast, klucz to dokładny fragment_name z
## entities/incarnations/*.gd. Nieznany klucz (nie powinno się zdarzyć,
## wszystkie 6 jest tu ujęte) spada z powrotem na generyczny tekst.
const INCARNATION_DEATH_LINES := {
	"Vhar’Nokh, Wygnany z Otchłani": "Vhar’Nokh: „Wygnaliście mnie raz. Teraz robicie to znowu.”",
	"Mordrath Bez-Wymiaru": "Mordrath: „Nie... nie zdążyłem... nie zdąży—”",
	"Zha’Ruun, Pożeracz Granic": "Zha’Ruun: „Granica. Granica. Zawsze jakaś granica.”",
	"Nekravor, Ten Którego Odrzucono": "Nekravor: „Odrzucony. Jak zawsze. Jak zawsze. Jak—”",
	"Thal’Gor, Pęknięty Pomiędzy Światami": "Thal’Gor: „Byłem tak blisko. Byłem tak blisko całości.”",
	"Orryx Cień-Nicości": "Orryx: „...”",
}

func _on_soul_collected(fragment_name: String) -> void:
	var line: String = INCARNATION_DEATH_LINES.get(fragment_name, "Zdobyto fragment duszy: %s" % fragment_name)
	ui.show_taunt(line, 3.0)
	# Soul Bond (CLAUDE_CODE_GAME_CONTENT_BIBLE.md sekcja 8) — aktywuje się w
	# chwili PODNIESIENIA duszy (nie samego pokonania wcielenia), stąd tutaj a
	# nie w _on_incarnation_died(). Nic nie robi, jeśli gracz nie ma Soul Bond.
	player.activate_soul_bond(_room_data.get("chapter", -1))
	_spawn_doors_for_open_directions()

## Skrzynie (dokument sekcja 9, zaadaptowane na siatkę pokoi) — TYLKO w
## pokojach RANDOM oznaczonych przy generacji mapy (GameFlow._assign_chest_rooms),
## dopiero po oczyszczeniu, i tylko raz (chest_opened pilnuje retry po śmierci
## w tym samym pokoju nie dawał drugiej skrzyni za darmo).
func _maybe_spawn_chest() -> void:
	if not _room_data.get("has_chest", false) or _room_data.get("chest_opened", false):
		return
	var chest: Chest = ChestScene.instantiate()
	chest.player = player
	chest.global_position = ARENA_RECT.get_center() + incarnation_spawn_offset
	chest.opened.connect(_on_chest_opened)
	add_child(chest)

## Krok 8: "ulepszenie — dolny środek" (osobny kanał od show_taunt, który
## dzieli górny środek z fazą bossa/nazwą pokoju/kwestiami wcieleń) —
## show_upgrade_toast zamiast show_taunt. Wciąż zwykły tekst, nie pełna karta
## relikwii (ikona+nazwa+zdanie) — krok 4 tego samego dokumentu, wstrzymany do
## czasu ikon relikwii.
func _on_chest_opened(upgrade_id: String) -> void:
	GameFlow.mark_chest_opened()
	ui.show_upgrade_toast("Zdobyto ulepszenie: %s" % Player.UPGRADE_LABELS.get(upgrade_id, upgrade_id), 2.5)

func _on_move_door_entered(direction: Vector2i) -> void:
	GameFlow.capture_player_state(player)
	GameFlow.move_to_neighbor(direction)

func _on_altar_door_entered() -> void:
	GameFlow.capture_player_state(player)
	GameFlow.enter_altar()

func _on_player_died() -> void:
	ui.show_overlay("Zginąłeś\n\nSpacja, aby zacząć od nowa")
	_game_over_kind = "death"

## Zgon w zwykłym pokoju (dowolny losowy wróg albo wcielenie) MUSI resetować
## przebieg tak samo jak zgon w arena.gd (walka z Nemoraxem) — dawne
## reload_current_scene() tylko odświeżało TEN SAM pokój na TYCH SAMYCH
## danych z GameFlow (fragmenty, wyczyszczone pokoje, pozycja bez zmian), więc
## śmierć poza finałową walką w ogóle nie cofała przebiegu do początku, mimo
## że ekran mówił "spróbuj ponownie". Prawdziwy bug, nie tylko niespójność.
func _handle_game_over_input() -> void:
	if _game_over_kind == "death" and Input.is_action_just_pressed("ui_accept"):
		_restart_run_from_scratch()

## Wydzielone z _handle_game_over_input() tak, żeby dało się przetestować
## sam reset przebiegu wprost (bez symulowania Input.is_action_just_pressed,
## co w tym zestawie testów jest niewiarygodne bez realnej klatki silnika —
## patrz inne testy tego zestawu).
func _restart_run_from_scratch() -> void:
	GameFlow.reset_run()
	get_tree().change_scene_to_file(GameFlow.ROOM_SCENE)
