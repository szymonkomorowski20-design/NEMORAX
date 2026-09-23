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
const RelicDraftScript := preload("res://ui/relic_draft.gd")
const RoomAtmosphereScene := preload("res://rooms/room_atmosphere.gd")
const ROOM_THEME_SLUGS := ["vhar_nokh", "mordrath", "zha_ruun", "nekravor", "thal_gor", "orryx"]
const RANDOM_THEME_SLUGS := [
	"flooded_catacombs", "sunken_library", "frozen_crypt", "blood_ritual_hall",
	"overgrown_ruins", "ash_battlefield", "crystal_cavern", "rusted_machine_hall",
]

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
const SND_ROOM_CLEAR := preload("res://assets/audio/sfx/p0/AMB_ROOM_CLEAR.wav")

@export var player_start_offset: Vector2 = Vector2(0.0, 0.0) ## względem środka areny, TYLKO w pokoju startowym (entry_direction == ZERO)
@export var incarnation_spawn_offset: Vector2 = Vector2(0.0, -60.0) ## względem środka areny

@onready var player: Player = $Player
@onready var ui: GameUI = $UILayer/UI
@onready var pause_menu: PauseMenu = $PauseLayer/PauseMenu
@onready var stats_screen: StatsScreen = $StatsLayer/StatsScreen
var _skill_draft: SkillDraft
var _relic_draft: RelicDraft
@onready var music: AudioStreamPlayer = $Music
@onready var cutscene: CutscenePlayer = $CutsceneLayer/CutscenePlayer

var incarnation: Incarnation
var _active_enemies: Array[Incarnation] = []
var _game_over_kind: String = "" # "" albo "death"
var _room_data: Dictionary
var _integrated_visual: IntegratedRoomVisual
## Obszar gry: kolizja, spawny, granice wrogów, drzwi. ARENA_RECT zostaje dla
## samej grafiki — w pokoju zintegrowanym mur zajmuje brzeg ARENA_RECT.
var _play_rect: Rect2 = ARENA_RECT

## Ściany/tło poza areną celowo przyciemnione WZGLĘDEM podłogi (ta sama
## tekstura co podłoga inaczej czyta się jak rama obrazka, nie jak granica
## świata — KIERUNEK_WIZUALNY_REFERENCJE.md). Tło poza areną ciemniejsze
## jeszcze bardziej niż ściana — ma sugerować otchłań, nie kolejną powierzchnię.
const WALL_MODULATE := Color(0.45, 0.45, 0.52, 1.0)
const SOUL_BASE_HEALTH := 550.0 ## wcielenie z duszą przed skalowaniem postępem (Paczka 4)
const VOID_MODULATE := Color(0.22, 0.22, 0.28, 1.0)

func _ready() -> void:
	_room_data = GameFlow.current_room_data()
	Walls.build_void_background(self, get_viewport_rect().size, VOID_BACKGROUND, VOID_MODULATE)

	var floor_tex: Texture2D
	var wall_tex: Texture2D
	var theme_slug: String
	if _room_data.get("type") == GameFlow.RoomType.SOUL:
		var chapter: int = _room_data.get("chapter", 0)
		floor_tex = ROOM_FLOOR_TEXTURES[chapter]
		wall_tex = ROOM_WALL_TEXTURES[chapter]
		theme_slug = ROOM_THEME_SLUGS[chapter]
	elif _room_data.get("type") == GameFlow.RoomType.RANDOM:
		var theme_index: int = int(_room_data.get("theme", int(_room_data.get("enemy_index", 0)) % RANDOM_ROOM_FLOOR_TEXTURES.size()))
		floor_tex = RANDOM_ROOM_FLOOR_TEXTURES[theme_index]
		wall_tex = RANDOM_ROOM_WALL_TEXTURES[theme_index]
		theme_slug = RANDOM_THEME_SLUGS[theme_index]
	else: # START — bez dedykowanego wyglądu, reużywam pierwszy motyw jako placeholder
		floor_tex = ROOM_FLOOR_TEXTURES[0]
		wall_tex = ROOM_WALL_TEXTURES[0]
		theme_slug = ROOM_THEME_SLUGS[0]
	var integrated_visual := IntegratedRoomVisual.new()
	if integrated_visual.configure(ARENA_RECT, theme_slug):
		_integrated_visual = integrated_visual
		add_child(_integrated_visual)
		_play_rect = IntegratedRoomVisual.play_rect(ARENA_RECT)
		Walls.build(self, _play_rect, WALL_THICKNESS) # tylko kolizje; wygląd w IntegratedRoomVisual
	else:
		integrated_visual.free()
		Walls.build_floor(self, ARENA_RECT, floor_tex)
		Walls.build(self, ARENA_RECT, WALL_THICKNESS, wall_tex, WALL_MODULATE)
	_add_room_atmosphere()
	if _room_data.get("type") == GameFlow.RoomType.RANDOM:
		_build_terrain(wall_tex)

	var track: AudioStreamWAV = ROOM_MUSIC_TRACKS[randi() % ROOM_MUSIC_TRACKS.size()]
	# Ustawiane w kodzie, nie tylko w .import — headless `--import` (używane w
	# tej sesji do generowania .import przy nowych plikach) niezawodnie nie
	# zapisuje edit/loop_mode do faktycznego cache'owanego zasobu, sprawdzone
	# bezpośrednim testem (loop_mode wychodził 0 mimo poprawnego .import).
	track.loop_mode = AudioStreamWAV.LOOP_FORWARD
	music.stream = track
	music.play()

	var center := _play_rect.get_center()
	player.global_position = _player_spawn_position(center)
	player.died.connect(_on_player_died)
	GameFlow.apply_player_state(player) # ta sama migawka co przy wejściu do tego pokoju
	player.enter_breath_scope("room:%d:%d" % [GameFlow.current_room_pos.x, GameFlow.current_room_pos.y])
	_skill_draft = SkillDraft.new()
	$StatsLayer.add_child(_skill_draft)
	_relic_draft = RelicDraftScript.new()
	$StatsLayer.add_child(_relic_draft)
	# Decyzja autora (23.09): awans i skrzynia NIE otwierają wyboru same —
	# HUD pokazuje przyciski (R: runa/punkty, Q: relikwia) do skutku.
	_relic_draft.relic_chosen.connect(_on_relic_chosen)
	ui.reward_button_pressed.connect(_on_reward_button)

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
			if _room_data.get("rest", false):
				_enter_rest_room()
			elif already_cleared:
				_spawn_doors_for_open_directions()
				_maybe_spawn_chest()
			else:
				_spawn_random_encounter()
		GameFlow.RoomType.SOUL:
			if already_cleared:
				_spawn_doors_for_open_directions()
			else:
				_spawn_enemy(GameFlow.current_incarnation_scene_path(), false)
				GameFlow.note_incarnation_met(int(_room_data.get("chapter", 0))) # Komnata Echa (Paczka 9)
		_: # START — pusty, bezpieczny pokój, drzwi od razu otwarte
			_spawn_doors_for_open_directions()
			if not GameFlow.has_seen_prolog():
				_play_prolog()
			if GameFlow.run_intent == "" and get_tree().current_scene == self:
				_offer_intent()

## Pokój odpoczynku (Paczka 7): bez walki, drzwi od razu otwarte, jednorazowo
## +30% życia. Bez XP i bez podbijania trudności — to wybór trasy "oddech".
func _enter_rest_room() -> void:
	_room_data["cleared"] = true
	_spawn_doors_for_open_directions()
	var spring := RestSpring.new()
	spring.used = _room_data.get("rest_used", false)
	spring.position = _play_rect.get_center()
	add_child(spring)
	if _room_data.get("rest_used", false):
		return
	_room_data["rest_used"] = true
	var healed := minf(player.max_health - player.health, player.max_health * GameFlow.REST_HEAL_FRACTION)
	player.health += healed
	Juice.play_sfx_at(player.SND_HEAL_USE, player.global_position)
	get_tree().create_timer(1.3).timeout.connect(func(): if is_instance_valid(ui): ui.show_taunt("Odpoczynek: +%d życia" % roundi(healed), 2.2))
	GameFlow.capture_player_state(player)
	GameFlow._save_progress()

## Intencja startowa (Paczka 6) — raz na próbę, po prologu.
func _offer_intent() -> void:
	await get_tree().process_frame
	while is_instance_valid(cutscene) and cutscene.visible:
		await get_tree().process_frame
	var select := IntentSelect.new()
	$StatsLayer.add_child(select)
	select.open()

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
			if _room_data.get("rest", false):
				return "Komnata odpoczynku"
			return "Komnata — zasadzka" if _random_group_count() > 1 else "Komnata"
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
	var wall_pos := Walls.wall_point(_play_rect, wall_side)
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
	# Ta sama warstwa co przy rytuale ołtarza (A3): bez tego HUD zamrażał się
	# pod półprzezroczystym tłem prologu.
	ui.hide_for_cutscene()
	await cutscene.play(beats)
	ui.hide_all = false

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
	elif event.is_action_pressed("open_runes"):
		RewardPrompt.open_runes_or_points(player, _skill_draft, stats_screen)
	elif event.is_action_pressed("open_relic"):
		_relic_draft.open_for(player)
	elif event.is_action_pressed("toggle_map"):
		ui.big_map = not ui.big_map
	elif event.is_action_pressed("open_pact"):
		_open_pact()

func _on_relic_chosen(id: String) -> void:
	ui.show_relic_card(id)
	GameFlow.capture_player_state(player)
	GameFlow._save_progress()

func _random_group_count() -> int:
	if _room_data.get("type") != GameFlow.RoomType.RANDOM:
		return 1
	if int(_room_data.get("enemy_index", 0)) >= 8 or GameFlow.rooms_cleared_count < 3:
		return 1
	if GameFlow.rooms_cleared_count % 4 != 3:
		return 1
	return 2 if GameFlow.rooms_cleared_count < 12 else 3

## Teren (Paczka 5): przeszkody układu, akcent motywu, pokój pułapek.
var terrain: RoomTerrain

func _build_terrain(wall_tex: Texture2D) -> void:
	terrain = RoomTerrain.new()
	terrain.setup(_play_rect, str(_room_data.get("layout", "open")), int(_room_data.get("theme", 0)), bool(_room_data.get("trap", false)))
	terrain.wall_texture = wall_tex
	add_child(terrain)
	if bool(_room_data.get("cleared", false)):
		terrain.stop_trap()
	if terrain.slow_lane.has_area():
		player.slow_zones = [terrain.slow_lane]
	if terrain.accent != "" and not bool(_room_data.get("cleared", false)):
		# Po banerze tytułu pokoju (1,2 s, ten sam kanał) — zapowiedź zasady miejsca.
		var label: String = EncounterPlan.ACCENT_LABEL[terrain.accent]
		get_tree().create_timer(1.3).timeout.connect(func(): if is_instance_valid(ui): ui.show_taunt(label, 2.2))

## Plan walki pokoju RANDOM (Paczka 5): przepis grupowy albo pojedynczy wróg,
## z regułą "bez trzech podobnych walk pod rząd". Deterministyczny z ziarna
## próby i pozycji pokoju. Zwraca [[indeks_wroga, ranga], ...] i podpis.
func _plan_random_encounter() -> Dictionary:
	var rng := GameFlow.room_rng(GameFlow.current_room_pos, 1)
	var enemy_index := int(_room_data.get("enemy_index", 0))
	var progress := GameFlow.rooms_cleared_count
	var recipe_id := ""
	if _random_group_count() > 1 and not bool(_room_data.get("trap", false)):
		var allowed := EncounterPlan.recipes_allowed(progress)
		if not allowed.is_empty():
			recipe_id = allowed[rng.randi() % allowed.size()]
	var sig := EncounterPlan.signature(recipe_id, enemy_index)
	if EncounterPlan.would_repeat_three(GameFlow.recent_encounters, sig):
		if recipe_id != "":
			var others := EncounterPlan.recipes_allowed(progress).filter(func(id): return id != recipe_id)
			recipe_id = others[rng.randi() % others.size()] if not others.is_empty() else ""
		if recipe_id == "" and not bool(_room_data.get("trap", false)):
			enemy_index = EncounterPlan.alternative_enemy(enemy_index, rng.randi())
		sig = EncounterPlan.signature(recipe_id, enemy_index)
	var members: Array = []
	if recipe_id != "":
		members = EncounterPlan.RECIPES[recipe_id]["members"]
	else:
		members = [[enemy_index, "front"]]
	return {"members": members, "signature": sig, "recipe": recipe_id}

func _spawn_random_encounter() -> void:
	var plan := _plan_random_encounter()
	GameFlow.record_encounter(plan["signature"])
	var ranks: Array = []
	for m in plan["members"]:
		ranks.append(m[1])
	var points := EncounterPlan.spawn_points(_play_rect, GameFlow.entry_direction, ranks)
	var group := (plan["members"] as Array).size() > 1
	var rng := GameFlow.room_rng(GameFlow.current_room_pos, 2)
	for i in (plan["members"] as Array).size():
		var index: int = int(plan["members"][i][0])
		_spawn_enemy_at(GameFlow.RANDOM_ENEMY_SCENES[index], points[i], group, rng)

## Spawn w konkretnym punkcie planu spotkania (Paczka 5) — elita losowana z
## generatora pokoju, więc ten sam seed daje tę samą walkę.
func _spawn_enemy_at(scene_path: String, point: Vector2, group_member: bool, rng: RandomNumberGenerator) -> void:
	var offset := point - _play_rect.get_center()
	if offset == Vector2.ZERO:
		offset = Vector2(0.0, -0.01)
	# Paczka 7: elita zaplanowana przy generowaniu mapy (widoczna na mapie i
	# nad drzwiami); starsze zapisy bez pola — dawny rzut z generatora pokoju.
	var roll := rng.randf()
	if _room_data.has("elite"):
		roll = 0.0 if _room_data.get("elite", false) and not group_member else 2.0
	_spawn_enemy(scene_path, true, offset, group_member, roll)

func _spawn_enemy(scene_path: String, is_random: bool, offset: Vector2 = Vector2.ZERO, group_member: bool = false, elite_roll: float = -1.0) -> void:
	var scene: PackedScene = load(scene_path)
	var spawned: Incarnation = scene.instantiate() as Incarnation
	spawned.arena_rect = _play_rect
	spawned.global_position = _play_rect.get_center() + (offset if offset != Vector2.ZERO else incarnation_spawn_offset)
	if terrain != null:
		spawned.obstacles = terrain.obstacles
		if terrain.slow_lane.has_area():
			spawned.slow_zones = [terrain.slow_lane]
		spawned.global_position = EncounterPlan.push_out_of(terrain.obstacles, spawned.global_position, EncounterPlan.SPAWN_OBSTACLE_CLEARANCE)
	spawned.died.connect(_on_incarnation_died.bind(spawned))
	add_child(spawned)
	_active_enemies.append(spawned)
	if incarnation == null:
		incarnation = spawned
	if is_random:
		# Rosnąca trudność losowych przeciwników z liczbą wyczyszczonych pokoi
		# (ustalone z autorem) — wcielenia z duszami zachowują swoje ręcznie
		# dobrane, stałe statystyki, więc ta gałąź ich nie dotyczy.
		var n := GameFlow.rooms_cleared_count
		var group_factor := 0.55 if group_member else 1.0
		spawned.apply_difficulty_scale(minf(2.10, 1.0 + 0.045 * n) * group_factor, minf(1.45, 1.0 + 0.015 * n) * (0.70 if group_member else 1.0))
		var roll := elite_roll if elite_roll >= 0.0 else randf()
		if not group_member and roll < GameFlow.elite_chance_for_current_progress():
			spawned.apply_elite_modifier()
	else:
		# Paczka 4 (AUDYT, cel 25-50 s mocny / 45-75 s średni): przy stałych
		# 160 HP wcielenie padało w 2-4 s, zanim użyło choć jednej
		# umiejętności. Baza 550 HP i ta sama krzywa postępu co zwykli wrogowie
		# (do 2,1x), bo pokój z duszą może trafić się wcześnie albo późno.
		var soul_n := GameFlow.rooms_cleared_count
		spawned.max_health = SOUL_BASE_HEALTH
		spawned.apply_difficulty_scale(minf(2.10, 1.0 + 0.045 * soul_n), minf(1.45, 1.0 + 0.015 * soul_n))
	ui.boss = incarnation

## Drzwi zamknięte na czas walki (jak w Isaacu, ustalone z autorem) — dopiero
## teraz, po pokonaniu przeciwnika, sprawdzamy KTÓRE ściany mają teraz
## przejście (GameFlow.is_direction_open) i stawiamy tam realne drzwi.
func _spawn_doors_for_open_directions() -> void:
	for direction in GameFlow.DIRECTIONS:
		if not GameFlow.is_direction_open(direction):
			continue
		var wall_side := GameFlow.wall_for_direction(direction)
		var pos := Walls.wall_point(_play_rect, wall_side)
		var neighbor := GameFlow.neighbor_data(direction)
		var callback := _on_altar_door_entered if neighbor.get("type") == GameFlow.RoomType.ALTAR else _on_move_door_entered.bind(direction)
		# Wyzwalacz stoi na linii ściany; portal jest częścią grafiki muru.
		_spawn_door(pos, callback, wall_side)
		# Paczka 7: co czeka za drzwiami (ryzyko/nagroda przed wejściem).
		var kind := MapMarker.kind_for(neighbor)
		if kind != "":
			var badge := DoorBadge.new()
			badge.kind = kind
			# Obok otworu, nie w nim — gracz wchodzący tymi drzwiami staje 70 px od ściany.
			var inward := (_play_rect.get_center() - pos).normalized()
			var aside := Vector2(175.0, 0.0) if absf(inward.y) > 0.5 else Vector2(0.0, -130.0)
			badge.position = pos + inward * 60.0 + aside
			add_child(badge)

func _spawn_door(pos: Vector2, on_entered: Callable, wall_side: String) -> void:
	var door: Door = DoorScene.instantiate()
	door.player = player
	door.wall_side = wall_side
	if _integrated_visual != null:
		_integrated_visual.set_portal_open(wall_side)
		door.use_integrated_visual = true
	door.global_position = pos
	door.entered.connect(on_entered)
	add_child(door)

func _on_incarnation_died(fragment_name: String, dead_enemy: Incarnation = null) -> void:
	if dead_enemy == null:
		dead_enemy = incarnation
	_active_enemies.erase(dead_enemy)
	if not _active_enemies.is_empty():
		if dead_enemy == incarnation:
			incarnation = _active_enemies[0]
			ui.boss = incarnation
		return
	if GameFlow.training:
		# Komnata Echa: bez XP, fragmentu, duszy i postępu.
		Juice.play_sfx_at(SND_ROOM_CLEAR, dead_enemy.global_position)
		_show_training_end("Trening ukończony")
		return
	player.gain_xp(2.0 if _room_data.get("type") == GameFlow.RoomType.SOUL or dead_enemy.is_elite else 1.0)
	GameFlow.clear_current_room()
	if terrain != null:
		terrain.stop_trap() # nagroda i przejście bez pułapki po walce
	Juice.play_sfx_at(SND_ROOM_CLEAR, dead_enemy.global_position)
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
	soul.color = dead_enemy.current_color
	soul.player = player
	soul.global_position = dead_enemy.global_position
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
	# Pakt fragmentu (Paczka 8, pilotaż): czeka pod przyciskiem w HUD (P).
	var chapter: int = _room_data.get("chapter", -1)
	if chapter == PactCatalog.PILOT_CHAPTER and PactCatalog.choice(chapter) == "":
		GameFlow.pending_pact = chapter
		GameFlow._save_progress()
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
	chest.global_position = _play_rect.get_center() + incarnation_spawn_offset
	chest.opened.connect(_on_chest_opened)
	chest.selection_requested.connect(_on_chest_selection_requested.bind(chest))
	add_child(chest)
	# Niedokończona oferta nie wisi już na skrzyni — skrzynia oddaje ją
	# graczowi (Player.pending_relic_offers) i zapis trzyma ją w stanie gracza.

## Skrzynia oddaje ofertę graczowi i zostaje otwarta — wybór relikwii
## gracz robi, kiedy chce (Q / przycisk w HUD), także w innym pokoju.
func _on_chest_selection_requested(offers: Array[String], chest: Chest) -> void:
	player.pending_relic_offers.assign(offers)
	chest.hand_over()
	GameFlow.mark_chest_opened()
	GameFlow.capture_player_state(player)
	GameFlow._save_progress()

## Krok 4/8: "karta relikwii w dolnej/środkowej części ekranu — ikona, nazwa,
## jedno zdanie efektu" — zastępuje dawny zwykły tekstowy toast.
func _on_chest_opened(upgrade_id: String) -> void:
	GameFlow.capture_player_state(player)
	GameFlow.mark_chest_opened()
	ui.show_relic_card(upgrade_id)

func _on_move_door_entered(direction: Vector2i) -> void:
	GameFlow.capture_player_state(player)
	GameFlow.move_to_neighbor(direction)

func _on_altar_door_entered() -> void:
	GameFlow.capture_player_state(player)
	GameFlow.enter_altar()

func _on_player_died() -> void:
	# Krok 9: "najpierw widoczny moment porażki: 0,15s hit-stop" — ten sam
	# krótki freeze co w arena.gd, zanim panel w ogóle się pojawi.
	Juice.hitstop(0.15)
	if GameFlow.training:
		_show_training_end("Trening przerwany")
		return
	# Paczka 9: historia próby, przyczyna i rada + wpis do Kroniki.
	var entry := RunSummary.build(player, "death", _room_display_name())
	GameFlow.add_chronicle_entry(entry)
	ui.show_run_summary(entry)
	_game_over_kind = "death"

## Zgon w zwykłym pokoju (dowolny losowy wróg albo wcielenie) MUSI resetować
## przebieg tak samo jak zgon w arena.gd (walka z Nemoraxem) — dawne
## reload_current_scene() tylko odświeżało TEN SAM pokój na TYCH SAMYCH
## danych z GameFlow (fragmenty, wyczyszczone pokoje, pozycja bez zmian), więc
## śmierć poza finałową walką w ogóle nie cofała przebiegu do początku, mimo
## że ekran mówił "spróbuj ponownie". Prawdziwy bug, nie tylko niespójność.
func _handle_game_over_input() -> void:
	if _game_over_kind == "training":
		if Input.is_action_just_pressed("ui_accept"):
			GameFlow.begin_training(GameFlow.training_chapter)
			get_tree().change_scene_to_file(GameFlow.ROOM_SCENE)
		elif Input.is_action_just_pressed("ui_cancel"):
			GameFlow.end_training()
			get_tree().change_scene_to_file("res://menu.tscn")
		return
	if _game_over_kind != "death":
		return
	if Input.is_action_just_pressed("ui_accept"):
		_restart_run_from_scratch()
	elif Input.is_physical_key_pressed(KEY_S):
		_restart_same_seed()
	# Krok 9: "przyciski: spróbuj ponownie / menu" — dawniej jedyną drogą z
	# ekranu porażki był restart, bez wyjścia do menu.
	elif Input.is_action_just_pressed("ui_cancel"):
		_exit_to_menu_from_death()

## Wydzielone z _handle_game_over_input() tak, żeby dało się przetestować
## sam reset przebiegu wprost (bez symulowania Input.is_action_just_pressed,
## co w tym zestawie testów jest niewiarygodne bez realnej klatki silnika —
## patrz inne testy tego zestawu).
func _restart_run_from_scratch() -> void:
	GameFlow.reset_run()
	get_tree().change_scene_to_file(GameFlow.ROOM_SCENE)

## Paczka 9: ta sama mapa i oferty, żeby sprawdzić inną decyzję.
func _restart_same_seed() -> void:
	GameFlow.reset_run(GameFlow.run_seed)
	get_tree().change_scene_to_file(GameFlow.ROOM_SCENE)

func _show_training_end(title: String) -> void:
	ui.show_overlay("%s

Komnata Echa — bez nagród i bez wpływu na próbę.

Enter — jeszcze raz      Escape — wyjdź z Komnaty Echa" % title, "death")
	_game_over_kind = "training"

func _exit_to_menu_from_death() -> void:
	GameFlow.reset_run()
	get_tree().change_scene_to_file("res://menu.tscn")

## Przycisk nagrody w HUD (decyzja autora 23.09) — to samo co klawisze R / Q.
func _on_reward_button(kind: String) -> void:
	if kind == "level":
		RewardPrompt.open_runes_or_points(player, _skill_draft, stats_screen)
	elif kind == "pact":
		_open_pact()
	else:
		_relic_draft.open_for(player)

func _open_pact() -> void:
	if GameFlow.pending_pact < 0:
		Juice.play_ui_sfx(Juice.SND_UI_ERROR)
		return
	var pact := PactSelect.new()
	$StatsLayer.add_child(pact)
	pact.pact_chosen.connect(func(_c: String): player._recompute_effective_stats())
	pact.open(GameFlow.pending_pact)
