extends Node2D
## Scena główna — ściany, spawn gracza i bossa, oraz "referee": reaguje na sygnały
## bossa (zmiana fazy, śmierć) i dopina do gracza modyfikatory z sekcji 7, bo to
## jedyne miejsce, które zna oboje naraz. Licznik prób/zgonów/zwycięstw (sekcja 8)
## też mieszka tutaj, razem z ekranami śmierci/zwycięstwa.

const ARENA_RECT := Rect2(90, 60, 1100, 600) # wyśrodkowana 1100x600 w oknie 1280x720
const WALL_THICKNESS := 20.0
## Pusty = GameFlow.PERSISTENT_SAVE_PATH (ten sam plik progress.json). Dzięki
## temu skrypt, który izoluje zapis GameFlow, izoluje też arenę — dawna stała
## "user://progress.json" pozwoliła botowi pomiarowemu dopisać zwycięstwa do
## prawdziwego zapisu gracza (24.09, przywrócone z kopii).
var SAVE_PATH := ""

func _save_path() -> String:
	return SAVE_PATH if SAVE_PATH != "" else GameFlow.PERSISTENT_SAVE_PATH

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
## Reguła 7 (Odwrócenie) w fazie finałowej — NIE trwałe na resztę walki (za
## małe HP formy i tak szybkie ataki 0,6s wystarczająco utrudniają tę fazę;
## nieprzerwane odwrócone sterowanie do samego końca byłoby po prostu
## nieczytelne, nie "trudne"). Zamiast tego okresowe, krótkie epizody: chwila
## normalnego sterowania, potem krótki ostry epizod odwrócenia, w kółko.
@export var reversal_normal_duration: float = 5.0 ## s, sterowanie normalne między epizodami
@export var reversal_burst_duration: float = 2.5 ## s, jak długo trwa jeden epizod odwrócenia

@onready var player: Player = $Player
@onready var ui: GameUI = $UILayer/UI
@onready var vision_overlay: VisionOverlay = $VisionOverlay
@onready var pause_menu: PauseMenu = $PauseLayer/PauseMenu
@onready var stats_screen: StatsScreen = $StatsLayer/StatsScreen
var _skill_draft: SkillDraft
var _relic_draft: RelicDraft
@onready var cutscene: CutscenePlayer = $CutsceneLayer/CutscenePlayer

var _reversal_timer: Timer

var boss: Boss

var deaths: int = 0
var wins: int = 0

var _battle_time: float = 0.0
var _battle_over: bool = false
var _game_over_kind: String = "" # "", "death" albo "victory"
var _end_gate := EndScreenGate.new() ## drugi audyt C4: bez przypadkowego restartu

func _ready() -> void:
	# Wyciszenie z fazy Cisza jest globalnym stanem silnika, więc świeży start
	# (restart po śmierci) musi je jawnie zdjąć — inaczej zostałoby z poprzedniej próby.
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), false)

	_load_progress()
	_build_walls()

	player.global_position = ARENA_RECT.get_center() + Vector2(0, 150)
	GameFlow.apply_player_state(player)
	player.enter_breath_scope("arena")
	_skill_draft = SkillDraft.new()
	$StatsLayer.add_child(_skill_draft)
	# Decyzja autora (23.09): awans nie otwiera wyboru sam — przyciski w HUD.
	_relic_draft = RelicDraft.new()
	$StatsLayer.add_child(_relic_draft)
	_relic_draft.relic_chosen.connect(func(id: String): ui.show_relic_card(id))
	ui.reward_button_pressed.connect(_on_reward_button)
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
	elif event.is_action_pressed("open_runes"):
		RewardPrompt.open_runes_or_points(player, _skill_draft, stats_screen)
	elif event.is_action_pressed("open_relic"):
		_relic_draft.open_for(player)

const FINALE_THEME := "blood_ritual_hall" ## ciemny kamień sali rytuału — ten sam świat co pokoje
const CORRUPTION_DEPTH := 120.0 ## px spaczenia od krawędzi posadzki ku środkowi
const CORRUPTION_COLOR := Color(0.42, 0.12, 0.62, 0.30)

func _finale_visual_rect() -> Rect2:
	var inset: Dictionary = IntegratedRoomVisual.WALL_INNER_INSET
	return Rect2(ARENA_RECT.position - Vector2(inset["left"], inset["top"]),
		ARENA_RECT.size + Vector2(inset["left"] + inset["right"], inset["top"] + inset["bottom"]))

## Fioletowe spaczenie Nemoraksa: gradient od krawędzi posadzki do środka.
func _draw_corruption(canvas: Node2D) -> void:
	# Kolejne ramki o malejącej alfie: najmocniej przy murze, nic w środku.
	var steps := 12
	var band := CORRUPTION_DEPTH / steps
	for i in steps:
		var inner := ARENA_RECT.grow(-band * i - band * 0.5)
		var a := CORRUPTION_COLOR.a * pow(1.0 - float(i) / steps, 2.0)
		canvas.draw_rect(inner, Color(CORRUPTION_COLOR, a), false, band)

func _build_walls() -> void:
	Walls.build_void_background(self, get_viewport_rect().size, VOID_BACKGROUND, VOID_MODULATE)
	# Priorytet 1 (TERAZ_DLA_CLAUDE_ARENA_UI_I_FEELING.md): FLOOR_TEXTURE to
	# dziś altar_floor.png — jasny kamień z siecią wielokolorowych, jarzących
	# się pęknięć, dokładnie to, co dokument każe zastąpić. Bez nowej grafiki:
	# entities/arena_stone_shader.gd przemalowuje to na ciemny obsydian z JEDNYM
	# przygaszonym fioletowym akcentem i winietą wyciszającą pęknięcia bliżej
	# środka areny — tylko tutaj, zwykłe pokoje/ołtarz zostają bez zmian.
	# Drugi audyt (A4): arena była osobnym, gładkim fioletowym polem. Teraz ten
	# sam system co pokoje — zintegrowana sala z murem i zapieczętowanymi
	# bramami — a spaczenie Nemoraksa to lokalna warstwa przy krawędziach
	# posadzki (środek spokojny do walki). Obraz jest rozciągnięty o grubość muru
	# tak, by wewnętrzna krawędź muru leżała DOKŁADNIE na ARENA_RECT — kolizje
	# i cała geometria walki bez zmian.
	var visual := IntegratedRoomVisual.new()
	add_child(visual)
	if visual.configure(_finale_visual_rect(), FINALE_THEME):
		Walls.build(self, ARENA_RECT, WALL_THICKNESS) # tylko kolizje; wygląd w IntegratedRoomVisual
		var corruption := Node2D.new()
		corruption.z_index = -9 # nad posadzką (-10), pod murem (-5)
		corruption.draw.connect(_draw_corruption.bind(corruption))
		add_child(corruption)
	else:
		visual.queue_free()
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
			# Pakt "Oczyść ciszę" (Paczka 8): zapowiedziana, prostsza wersja fazy.
			if PactCatalog.is_cleansed():
				_show_phase_line_after_name("Oczyszczona cisza nie ma nad tobą władzy.")
			else:
				AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), true)
		2: # Instinct (dawniej Zwłoka) — dash_cooldown x2
			player.dash_cooldown *= 2.0
		3: # Dominion (dawniej Ciężar) — stałe przyciąganie w stronę bossa
			player.pull_source = boss
			player.pull_strength = boss.gravity_pull_strength
		5: # Sovereignty (dawniej Zaćmienie) — ciemność poza kręgiem wokół gracza
			vision_overlay.activate(player, ARENA_RECT)
			boss.vision = vision_overlay # boss chowa się w mroku poza kręgiem

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
	ui.hide_for_cutscene()

	# Jedna klatka bez pauzy pozwala boss._physics_process() przetworzyć
	# is_dead=true (ustawione tuż przed emisją died() w take_damage()) i
	# zdążyć przemalować teksturę na pozę "kolaps", zanim pauza zamrozi
	# _physics_process na resztę sekwencji.
	await get_tree().process_frame

	# Zdjęte z końca funkcji (gdzie było wcześniej) na sam początek: te dwie
	# linijki + await cutscene.play() poniżej rzeczywiście pauzują drzewo (więc
	# gracz i tak przestaje móc atakować), ALE między tym wejściem a pierwszym
	# await cutscene.play() był ~2-sekundowy odcinek (body_fade_duration) BEZ
	# żadnej pauzy, w którym pasek bossa/stare napisy wciąż wisiały, a gracz
	# nadal mógł się ruszać i atakować "martwe już" ciało. get_tree().paused
	# przeżywa to okno bez zmian (create_timer ma domyślnie process_always=true),
	# więc przesunięcie tu obu linii zamyka całą lukę, nie tylko jej część.
	get_tree().paused = true
	_clear_boss_hazards()
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
	_start_reversal_cycle() # reguła siódma: Odwrócenie — teraz okresowa, patrz komentarz przy reversal_normal_duration
	# ui.hide_all już ustawione na samym początku _play_big_form_death()

## Timer (nie async-while+await) celowo — testowalne wprost wywołaniem
## _on_reversal_timer_timeout() bez czekania na realny czas (ta sama zasada co
## reszta menu/ekranów w tym projekcie), i samo się zatrzymuje: po ustawieniu
## _battle_over kolejne wywołanie po prostu nic nie robi, zamiast wymagać
## osobnej flagi "przerwij pętlę" pilnowanej w kilku miejscach.
func _start_reversal_cycle() -> void:
	player.input_reversed = false
	_reversal_timer = Timer.new()
	_reversal_timer.one_shot = true
	add_child(_reversal_timer)
	_reversal_timer.timeout.connect(_on_reversal_timer_timeout)
	_reversal_timer.start(reversal_normal_duration)

func _on_reversal_timer_timeout() -> void:
	if _battle_over:
		return
	player.input_reversed = not player.input_reversed
	_reversal_timer.start(reversal_burst_duration if player.input_reversed else reversal_normal_duration)

## Drwina przed finałową formą, coraz bardziej wprost o pętli i coraz bardziej
## perfidna w miarę kolejnych porażek Strażnika w tym zapisie (deaths, trwałe
## między resetami — patrz _load_progress/_save_progress). FABULA_I_DIALOGI.md
## sekcja 3.5: progi 3/10 to oryginalny, kanoniczny tekst; reszta to
## rozszerzenie na życzenie autora, aż do 100 (potem jedna, stała, najciemniejsza
## linia — sto to już nie licznik, to punkt bez powrotu dla samej drwiny).
const FINALE_TAUNT_TIERS: Array[Dictionary] = [
	{"below": 3, "text": "Czy pamiętasz, ile razy już mnie pokonałeś?"},
	{"below": 10, "text": "Czy pamiętasz, ile razy już mnie pokonałeś? Bo ja pamiętam każdy."},
	{"below": 20, "text": "Dwadzieścia prób i wciąż myślisz, że to Ty prowadzisz tę rozmowę?"},
	{"below": 30, "text": "Za każdym razem inny Strażnik. Za każdym razem to samo pierwsze spojrzenie — jakbyś nigdy wcześniej nie stał w tej sali."},
	{"below": 40, "text": "Wiesz, co jest najlepsze? Ty nie pamiętasz nic. A ja pamiętam wszystko. To nie jest walka. To jest powtórka, którą oglądam z Twojej strony ekranu."},
	{"below": 50, "text": "Czterdzieści... nie, pięćdziesiąt. Straciłem już rachubę tego, kim byłeś przed chwilą, kiedy jeszcze myślałeś, że wygrasz."},
	{"below": 60, "text": "Chcesz wiedzieć, co czuje więzień, który uczy strażnika, jak go zabić? Ulgę. Za każdym razem większą ulgę."},
	{"below": 70, "text": "Jesteś coraz bliżej. Nie zwycięstwa — mnie. Im dłużej to trwa, tym mniej dzieli nas różnicy."},
	{"below": 80, "text": "Osiemdziesiąt twarzy, które myślały, że są pierwsze. Twoja różni się tylko numerem."},
	{"below": 90, "text": "Powiedz mi szczerze — ile z tych prób pamiętasz Ty, a ile ja odgrywam za Ciebie, żebyś miał wrażenie, że próbowałeś?"},
	{"below": 100, "text": "Dziewięćdziesiąt kilka. Setka tuż za rogiem. Zastanawiam się, czy przy stu w ogóle będziesz jeszcze kimś, kogo warto drażnić — czy tylko cyfrą."},
]
const FINALE_TAUNT_AT_100 := "Sto. Przestałem liczyć Strażników i zacząłem liczyć powroty. To już nie jest Twoja porażka. To mój kalendarz."

func _finale_taunt_text() -> String:
	for tier in FINALE_TAUNT_TIERS:
		if deaths < int(tier["below"]):
			return tier["text"]
	return FINALE_TAUNT_AT_100

## Pieczęcie/strefy/pociski/przyzwańcy bossa żyją jako rodzeństwo bossa, nie
## jego dzieci, więc nie znikają razem z nim. Po zwycięstwie drzewo zostaje
## odpauzowane pod ekranem wyniku — zostawiony pocisk małej formy mógł trafić
## gracza PO wygranej i nadpisać "victory" ekranem śmierci.
func _clear_boss_hazards() -> void:
	for hazard in get_tree().get_nodes_in_group("boss_hazard"):
		hazard.queue_free()

func _finish_victory() -> void:
	_battle_over = true
	_clear_boss_hazards()
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
	# Paczka 9 (A17): podsumowanie próby + jedna rzecz do sprawdzenia następnym razem.
	var entry := RunSummary.build(player, "victory", "Nemorax pokonany — walka %s   ·   podejście %d   ·   ukończeń %d" % [_format_time(_battle_time), _attempts(), wins])
	GameFlow.add_chronicle_entry(entry)
	ui.show_run_summary(entry)
	_game_over_kind = "victory"
	_end_gate.arm()

func _on_player_died() -> void:
	# _battle_over przed śmiercią gracza = już wygrana (gracz nie umiera dwa
	# razy, take_damage pilnuje State.DEAD). queue_free() zagrożeń jest
	# odroczone do końca klatki, więc strefa mogła jeszcze raz tyknąć.
	if _battle_over:
		return
	_battle_over = true
	deaths += 1
	_save_progress()
	# Krok 9: "najpierw widoczny moment porażki: 0,15s hit-stop, ciało/
	# osłabienie, świat wygasa" — dotąd panel wskakiwał w tej samej klatce, w
	# której zdrowie spadło do zera, bez żadnego przejścia.
	Juice.hitstop(0.15)
	# Paczka 9: historia próby, przyczyna, rada + Kronika.
	var entry := RunSummary.build(player, "death", _stage_label(), boss.phase_index if not boss.is_final_phase else 5)
	GameFlow.add_chronicle_entry(entry)
	ui.show_run_summary(entry)
	_game_over_kind = "death"
	_end_gate.arm()


func _stage_label() -> String:
	var phase := "mała forma" if boss.is_final_phase else "faza %s" % Palette.PHASE_NAMES[clampi(boss.phase_index, 0, 5)]
	var hp := roundi(100.0 * boss.health / maxf(boss.max_health, 1.0))
	return "Nemorax — %s (%d%% HP)   ·   Próba: %d" % [phase, hp, _attempts()]

func _handle_game_over_input() -> void:
	match _game_over_kind:
		"death":
			# Przegrana z Nemoraksem = koniec całego przebiegu, nie tylko tej
			# walki — wraca się do pokoju 1 na czysto (nowe fragmenty, świeży gracz).
			if _end_gate.accept_pressed():
				GameFlow.reset_run()
				get_tree().change_scene_to_file(GameFlow.ROOM_SCENE)
			elif _end_gate.same_seed_pressed():
				GameFlow.reset_run(GameFlow.run_seed)
				get_tree().change_scene_to_file(GameFlow.ROOM_SCENE)
			# Krok 9: "przyciski: spróbuj ponownie / menu" — dawniej jedyną
			# drogą z ekranu porażki był restart, bez wyjścia do menu.
			elif _end_gate.cancel_pressed():
				GameFlow.reset_run()
				get_tree().change_scene_to_file("res://menu.tscn")
		"victory":
			# Paczka 9: po zwycięstwie od razu kolejna próba (inny wybór) albo menu.
			if _end_gate.accept_pressed():
				GameFlow.reset_run()
				get_tree().change_scene_to_file(GameFlow.ROOM_SCENE)
			elif _end_gate.same_seed_pressed():
				GameFlow.reset_run(GameFlow.run_seed)
				get_tree().change_scene_to_file(GameFlow.ROOM_SCENE)
			elif _end_gate.cancel_pressed():
				GameFlow.reset_run()
				get_tree().change_scene_to_file("res://menu.tscn")

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
	if not FileAccess.file_exists(_save_path()):
		return
	var file := FileAccess.open(_save_path(), FileAccess.READ)
	if file == null:
		push_warning("Arena: nie udało się otworzyć zapisu do odczytu (%s), błąd %d" % [_save_path(), FileAccess.get_open_error()])
		return
	var data = JSON.parse_string(file.get_as_text())
	if typeof(data) == TYPE_DICTIONARY:
		deaths = int(data.get("deaths", 0))
		wins = int(data.get("wins", 0))

## Scalany z resztą trwałego zapisu (prolog, Kronika, Pętla) — dawniej ten
## zapis nadpisywał cały progress.json i gubił "seen_prolog" (Paczka 9).
func _save_progress() -> void:
	if GameFlow.training:
		return
	var patch := {"deaths": deaths, "wins": wins}
	if wins > 0:
		patch["loop_unlocked"] = true
	GameFlow.merge_json_dict(_save_path(), patch)

## Przycisk nagrody w HUD (decyzja autora 23.09) — to samo co klawisze R / Q.
func _on_reward_button(kind: String) -> void:
	if kind == "level":
		RewardPrompt.open_runes_or_points(player, _skill_draft, stats_screen)
	else:
		_relic_draft.open_for(player)
