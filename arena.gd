extends Node2D
## Scena główna — ściany, spawn gracza i bossa, oraz "referee": reaguje na sygnały
## bossa (zmiana fazy, śmierć) i dopina do gracza modyfikatory z sekcji 7, bo to
## jedyne miejsce, które zna oboje naraz. Licznik prób/zgonów/zwycięstw (sekcja 8)
## też mieszka tutaj, razem z ekranami śmierci/zwycięstwa.

const ARENA_RECT := Rect2(90, 60, 1100, 600) # wyśrodkowana 1100x600 w oknie 1280x720
const WALL_THICKNESS := 20.0
var SAVE_PATH := "user://progress.json" ## var (nie const) tylko po to, żeby test mógł podmienić ścieżkę na tymczasową

const BossScene := preload("res://entities/boss.tscn")

# Brak dedykowanej tekstury dla areny Nemoraxa w katalogu (PROMPTY_FINALNE_WSZYSTKO.md
# ma D1-D15 na sześć pokoi + ołtarz + tło, ale nie na samą arenę finałową) —
# tymczasowo reużywam wygląd ołtarza (spójny tematycznie, "sala rytualna"),
# do podmiany jeśli/gdy powstanie dedykowana grafika.
const VOID_BACKGROUND := preload("res://assets/sprites/pokoje/tekstury/void_background.png")
const FLOOR_TEXTURE := preload("res://assets/sprites/pokoje/tekstury/altar_floor.png")
const WALL_TEXTURE := preload("res://assets/sprites/pokoje/tekstury/altar_wall.png")
const RoomAtmosphereScene := preload("res://rooms/room_atmosphere.gd")
## Ta sama zasada co rooms/room.gd i rooms/altar.gd (KIERUNEK_WIZUALNY_REFERENCJE.md).
const WALL_MODULATE := Color(0.45, 0.45, 0.52, 1.0)
const VOID_MODULATE := Color(0.22, 0.22, 0.28, 1.0)

@export var body_fade_duration: float = 2.0 ## s, ekran gaśnie po "śmierci" dużej formy (sekcja 8)
@export var finale_taunt_duration: float = 4.0 ## s, jak długo wisi pytanie finałowe

@onready var player: Player = $Player
@onready var ui: GameUI = $UILayer/UI
@onready var vision_overlay: VisionOverlay = $VisionOverlay
@onready var pause_menu: PauseMenu = $PauseLayer/PauseMenu
@onready var stats_screen: StatsScreen = $StatsLayer/StatsScreen
@onready var cutscene: CutscenePlayer = $CutsceneLayer/CutscenePlayer

var boss: Boss

var deaths: int = 0
var wins: int = 0

var _battle_time: float = 0.0
var _battle_over: bool = false
var _game_over_kind: String = "" # "", "death" albo "victory"

func _ready() -> void:
	# Wyciszenie z fazy Cisza jest globalnym stanem silnika, więc świeży start
	# (restart po śmierci) musi je jawnie zdjąć — inaczej zostałoby z poprzedniej próby.
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), false)

	_load_progress()
	_build_walls()

	player.global_position = ARENA_RECT.get_center() + Vector2(0, 150)
	player.died.connect(_on_player_died)
	# Priorytet 1, punkt 5: "wzmocnić gracza podczas bossa — minimalnie wyższy
	# kontrast sylwetki względem podłogi... bez rozjaśniania całej areny".
	# Kontaktowy cień gracza już istnieje (entities/player.gd, opacity 0.44,
	# już "wyraźniejszy" z wcześniejszej fazy) — tu tylko delikatny (+12%)
	# rozjaśniacz WYŁĄCZNIE sprite'a gracza (nie środowiska), bo nowy, ciemny
	# obsydianowy shader podłogi (entities/arena_stone_shader.gd) obniżył
	# ogólną jasność areny i gracz w ciemnym stroju zlewał się z nią bardziej
	# niż przy starym, jasnoszarym placeholderze.
	player.sprite.modulate = Color(1.12, 1.12, 1.12)

	boss = BossScene.instantiate() as Boss
	boss.arena_rect = ARENA_RECT
	add_child(boss)
	boss.global_position = ARENA_RECT.get_center() - Vector2(0, 150)
	boss.phase_changed.connect(_on_boss_phase_changed)
	boss.died.connect(_on_boss_died)

	ui.player = player
	ui.boss = boss
	player.resource_denied.connect(ui.flash_resource_denied) # krok 8, patrz room.gd (identyczne podpięcie)

func _process(delta: float) -> void:
	if not _battle_over:
		_battle_time += delta
	if _game_over_kind != "":
		_handle_game_over_input()

## Escape poza ekranami game-over pauzuje/wznawia — ekran zwycięstwa już
## używa Escape (ui_cancel) do wyjścia z gry (_handle_game_over_input), więc
## pauza musi być wyłączona w tym stanie, inaczej dwa różne działania
## walczyłyby o ten sam klawisz.
func _unhandled_input(event: InputEvent) -> void:
	if _game_over_kind != "":
		return
	if event.is_action_pressed("ui_cancel"):
		pause_menu.toggle()
	elif event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_TAB:
		stats_screen.open(player)

func _build_walls() -> void:
	Walls.build_void_background(self, get_viewport_rect().size, VOID_BACKGROUND, VOID_MODULATE)
	# Priorytet 1 (TERAZ_DLA_CLAUDE_ARENA_UI_I_FEELING.md): FLOOR_TEXTURE to
	# dziś altar_floor.png — jasny kamień z siecią wielokolorowych, jarzących
	# się pęknięć, dokładnie to, co dokument każe zastąpić. Bez nowej grafiki:
	# entities/arena_stone_shader.gd przemalowuje to na ciemny obsydian z JEDNYM
	# przygaszonym fioletowym akcentem i winietą wyciszającą pęknięcia bliżej
	# środka areny — tylko tutaj, zwykłe pokoje/ołtarz zostają bez zmian.
	Walls.build_floor(self, ARENA_RECT, FLOOR_TEXTURE, ArenaStoneShader.build_floor_material(ARENA_RECT))
	Walls.build(self, ARENA_RECT, WALL_THICKNESS, WALL_TEXTURE, WALL_MODULATE)
	var atmosphere := RoomAtmosphereScene.new() as RoomAtmosphere
	atmosphere.configure(ARENA_RECT)
	add_child(atmosphere)

## Kwestie fazy (FABULA_I_DIALOGI.md sekcja 3.4) — kluczowane po phase_index,
## nie po nazwie fazy (ta ostatnia to już samo "rule_name" z Palette).
const PHASE_TRANSITION_LINES := {
	1: "Pamiętam, że mam ręce.",
	2: "Widziałem to już. To spojrzenie. Ten strach.",
	3: "To miejsce. Zawsze było moje. Odzyskuję je.",
	4: "BOLAŁO. ZA KAŻDYM. RAZEM.",
	5: "Jestem. Naprawdę jestem. Po raz pierwszy od—",
}

func _on_boss_phase_changed(phase_index: int, _color: Color, rule_name: String) -> void:
	player.gain_xp() # spójne z pokojami — traktujemy każdą pokonaną fazę jak "pokonanego przeciwnika"
	if rule_name != "":
		ui.show_form_name(rule_name)
	if PHASE_TRANSITION_LINES.has(phase_index):
		_show_phase_line_after_name(PHASE_TRANSITION_LINES[phase_index])
	match phase_index:
		1: # Force (dawniej Cisza) — dźwięk wyciszony do końca walki. Nazwa/grafika
			# fazy się zmieniły (CLAUDE_CODE_GAME_CONTENT_BIBLE.md sekcja 13), ta
			# reguła "łamania zasad" (poza dokumentem) zostaje na tym samym indeksie.
			AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), true)
		2: # Instinct (dawniej Zwłoka) — dash_cooldown x2
			player.dash_cooldown *= 2.0
		3: # Dominion (dawniej Ciężar) — stałe przyciąganie w stronę bossa
			player.pull_source = boss
			player.pull_strength = boss.gravity_pull_strength
		5: # Sovereignty (dawniej Zaćmienie) — ciemność poza kręgiem wokół gracza
			vision_overlay.activate(player, ARENA_RECT)

## show_form_name i show_taunt piszą do tego samego pola w ui.gd
## (_center_message) — pokazanie kwestii RAZEM z banerem nazwy fazy zjadłoby
## baner w 0 klatek, więc czekamy, aż baner sam zejdzie.
func _show_phase_line_after_name(line: String) -> void:
	await get_tree().create_timer(ui.form_name_display_time).timeout
	ui.show_taunt(line, 3.0)

func _on_boss_died(is_final: bool) -> void:
	if is_final:
		_finish_victory()
	else:
		_play_big_form_death()

## Duża forma spadła do 0 HP — to jeszcze nie koniec (sekcja 8), i to NAJWAŻNIEJSZA
## scena całej gry (PLAN_CUTSCENEK.md 2.3, gdzie żyje cały twist): ciało "znika",
## chwila ciszy, wraca mała forma z pytaniem finałowym, zanim zdąży zaatakować.
func _play_big_form_death() -> void:
	# Duża forma jest is_dead=true w tym oknie — boss.gd sam pokazuje pozę
	# "kolaps" (nemorax_large-form-collapse.png) przez _update_sprite_state(),
	# więc nie trzeba już chować sprite'a na ślepo.
	await get_tree().create_timer(body_fade_duration).timeout

	var beats: Array[DialogueBeat] = []
	# Tło mieni się kolejno przez wszystkie 6 kolorów faz — "to wszystko, czym
	# właśnie było, w jednej chwili", bez potrzeby dodatkowego tekstu.
	for phase_color in Palette.PHASE_COLORS:
		var flash := DialogueBeat.new()
		flash.background_tint = phase_color
		flash.fallback_seconds = 0.3
		beats.append(flash)

	var beat1 := DialogueBeat.new()
	beat1.speaker_name = "Nemorax"
	beat1.portrait = Boss.TEX_LARGE_FORM_COLLAPSE
	beat1.text = "Pamiętam. Pamiętam WAS. Ilu was było?"
	beat1.fallback_seconds = 2.5
	beats.append(beat1)

	var beat2 := DialogueBeat.new()
	beat2.text = "Nie pierwszy raz to robisz. Coś w tobie o tym wie."
	beat2.fallback_seconds = 2.5
	beat2.silence_before = 0.8 # celowy oddech, nie na tekst
	beats.append(beat2)

	await cutscene.play(beats)

	# Mała forma się wyłania — mechanika bez zmian (start_final_phase itd.),
	# tylko teraz w środku sceny zamiast przed nią.
	boss.start_final_phase()
	boss.global_position = ARENA_RECT.get_center()

	var beat3 := DialogueBeat.new()
	beat3.speaker_name = "Nemorax"
	beat3.portrait = Boss.TEX_SMALL_FORM_REBIRTH
	beat3.text = _finale_taunt_text()
	beat3.fallback_seconds = finale_taunt_duration
	await cutscene.play([beat3])

	# Cięcie na taunt-pytanie finałowe — jak dziś, ale teraz naturalna
	# kontynuacja sceny, nie osobny byt.
	boss.delay_next_attack(finale_taunt_duration)
	boss.show_taunt_pose(finale_taunt_duration)
	player.input_reversed = true # reguła siódma: Odwrócenie
	ui.hide_all = true # interfejs znika w całości w fazie finałowej

## Drwina przed finałową formą, coraz bardziej wprost o pętli w miarę
## kolejnych porażek Strażnika w tym zapisie (FABULA_I_DIALOGI.md sekcja 3.5).
func _finale_taunt_text() -> String:
	if deaths < 3:
		return "Czy pamiętasz, ile razy już mnie pokonałeś?"
	elif deaths < 10:
		return "Czy pamiętasz, ile razy już mnie pokonałeś? Bo ja pamiętam każdy."
	else:
		return "Czy pamiętasz, ile razy już mnie pokonałeś? Nie musisz. Ja policzę za nas oboje. To jedno, co zawsze mi zostaje."

func _finish_victory() -> void:
	_battle_over = true
	var is_first_win := wins == 0
	wins += 1
	_save_progress()
	_play_victory_epilogue(is_first_win)

## Epilog PRZED istniejącym ekranem statystyk (PLAN_CUTSCENEK.md 2.4) — pełny
## czarny ekran spinający klamrą całą rozgrywkę (jak prolog). Ukryty pierwszy
## beat TYLKO przy PIERWSZYM prawdziwym zwycięstwie w tym zapisie, znika bez
## śladu przy każdym kolejnym — celowo niewyjaśniony haczyk fabularny.
func _play_victory_epilogue(is_first_win: bool) -> void:
	var beats: Array[DialogueBeat] = []
	if is_first_win:
		var hidden := DialogueBeat.new()
		hidden.text = "...to twoja twarz."
		hidden.fallback_seconds = 1.0
		beats.append(hidden)

	var b1 := DialogueBeat.new()
	b1.text = "Rozpada się. Fragmenty już szukają, gdzie zasnąć."
	b1.fallback_seconds = 2.5
	beats.append(b1)

	var b2 := DialogueBeat.new()
	b2.text = "Ktoś je znowu zbierze. Ty, albo ktoś bardzo do ciebie podobny."
	b2.fallback_seconds = 2.5
	b2.silence_before = 0.5
	beats.append(b2)

	var b3 := DialogueBeat.new()
	b3.text = "To nie było ocalenie. To było odłożenie na później."
	b3.fallback_seconds = 2.5
	beats.append(b3)

	await cutscene.play(beats)

	# Wygrana to prawdziwy koniec przebiegu (endgame) — zostaje jako ekran
	# końcowy, bez pętli z powrotem do pokoju 1.
	ui.show_overlay(
		"Zwycięstwo\n\nPodejście: %d\nUkończeń: %d\nCzas walki: %s\n\nEscape, aby wyjść" %
		[_attempts(), wins, _format_time(_battle_time)],
		"victory"
	)
	_game_over_kind = "victory"

func _on_player_died() -> void:
	_battle_over = true
	deaths += 1
	_save_progress()
	# Krok 9: "najpierw widoczny moment porażki: 0,15s hit-stop, ciało/
	# osłabienie, świat wygasa" — dotąd panel wskakiwał w tej samej klatce, w
	# której zdrowie spadło do zera, bez żadnego przejścia.
	Juice.hitstop(0.15)
	ui.show_death_overlay("Próba: %d" % _attempts())
	_game_over_kind = "death"

func _handle_game_over_input() -> void:
	match _game_over_kind:
		"death":
			# Przegrana z Nemoraksem = koniec całego przebiegu, nie tylko tej
			# walki — wraca się do pokoju 1 na czysto (nowe fragmenty, świeży gracz).
			if Input.is_action_just_pressed("ui_accept"):
				GameFlow.reset_run()
				get_tree().change_scene_to_file(GameFlow.ROOM_SCENE)
			# Krok 9: "przyciski: spróbuj ponownie / menu" — dawniej jedyną
			# drogą z ekranu porażki był restart, bez wyjścia do menu.
			elif Input.is_action_just_pressed("ui_cancel"):
				GameFlow.reset_run()
				get_tree().change_scene_to_file("res://menu.tscn")
		"victory":
			if Input.is_action_just_pressed("ui_cancel"):
				get_tree().quit()

func _attempts() -> int:
	return deaths + 1

func _format_time(seconds: float) -> String:
	var total := int(seconds)
	@warning_ignore("integer_division") # celowe dzielenie całkowite — liczymy pełne minuty
	var minutes := total / 60
	return "%d:%02d" % [minutes, total % 60]

func _load_progress() -> void:
	deaths = 0
	wins = 0
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		push_warning("Arena: nie udało się otworzyć zapisu do odczytu (%s), błąd %d" % [SAVE_PATH, FileAccess.get_open_error()])
		return
	var data = JSON.parse_string(file.get_as_text())
	if typeof(data) == TYPE_DICTIONARY:
		deaths = int(data.get("deaths", 0))
		wins = int(data.get("wins", 0))

func _save_progress() -> void:
	var data := {"deaths": deaths, "wins": wins}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_warning("Arena: nie udało się zapisać postępu (%s), błąd %d" % [SAVE_PATH, FileAccess.get_open_error()])
		return
	file.store_string(JSON.stringify(data))
