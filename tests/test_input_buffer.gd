extends RefCounted
## Bufor wejścia dla dasha i ataku (player.gd, Game Feel — Responsywność):
## naciśnięcie tuż przed tym, jak akcja znów będzie możliwa (cooldown/koniec
## recovery) zostaje w pamięci na input_buffer_window sekund i odpala się
## automatycznie, bez potrzeby drugiego, idealnie wymierzonego naciśnięcia.
##
## UWAGA O KOLEJNOŚCI TESTÓW: test_runner.gd nigdy nie przechodzi przez realną
## klatkę silnika między wywołaniami testów (patrz jego komentarz) — a raz
## wywołane Input.action_press("dash") sprawia, że is_action_just_pressed("dash")
## zostaje "true" już do końca CAŁEGO przebiegu testów, niezależnie od
## późniejszego action_release (sprawdzone empirycznie). Test poniżej, który
## sprawdza WYGASANIE bufora BEZ nowego naciśnięcia, musi więc być zadeklarowany
## jako PIERWSZY w tym pliku — inaczej zawsze zobaczy is_action_just_pressed
## jako "true" (od wcześniejszego testu w tym samym pliku) i bufor odświeżałby
## się w nieskończoność, zamiast wygasać. Pozostałe testy nie mają tego problemu:
## ich asercje są prawdziwe niezależnie od tego, czy is_action_just_pressed
## akurat "true" czy "false" w danej chwili.

func _fresh_player(root: Node) -> Player:
	var player: Player = load("res://entities/player.tscn").instantiate()
	root.add_child(player)
	return player

func _cleanup(player: Player, root: Node) -> void:
	root.remove_child(player)
	player.queue_free()

## MUSI zostać pierwszym testem w pliku — patrz komentarz na górze pliku.
func test_dash_buffer_expires_without_firing_if_never_ready(root: Node) -> void:
	var player := _fresh_player(root)
	player.stamina = player.max_stamina
	player._dash_cooldown_timer = 10.0 # daleko od gotowości
	player._buffered_dash_timer = player.input_buffer_window # symulacja naciśnięcia chwilę wcześniej

	player._handle_dash_input(player.input_buffer_window + 0.01) # okno bufora mija, cooldown wciąż nie skończony

	NemoraxTest.assert_true(player._buffered_dash_timer <= 0.0, "bufor powinien wygasnąć bez odpalenia dasha")
	NemoraxTest.assert_true(player.state != Player.State.DASHING, "dash nie powinien odpalić bez gotowości")
	_cleanup(player, root)

func test_dash_fires_immediately_when_already_ready(root: Node) -> void:
	var player := _fresh_player(root)
	player.stamina = player.max_stamina

	Input.action_press("dash")
	player._handle_dash_input(0.0)
	Input.action_release("dash")

	NemoraxTest.assert_eq(player.state, Player.State.DASHING, "naciśnięcie gdy dash jest gotowy powinno odpalić go od razu, bez zmiany istniejącego zachowania")
	_cleanup(player, root)

## Nie używa Input.action_press — symuluje bezpośrednio zabuforowany stan po
## wcześniejszym naciśnięciu, żeby test nie zależał od tego, czy
## is_action_just_pressed("dash") jest akurat "true" czy "false" (patrz uwaga
## na górze pliku); w obu przypadkach dash i tak powinien odpalić, gdy gotowy.
func test_dash_buffered_press_fires_automatically_once_cooldown_ends(root: Node) -> void:
	var player := _fresh_player(root)
	player.stamina = player.max_stamina
	player._dash_cooldown_timer = 0.0 # cooldown już minął (symulacja _tick_timers z wcześniejszej klatki)
	player._buffered_dash_timer = player.input_buffer_window * 0.5 # zabuforowane naciśnięcie, wciąż w oknie

	player._handle_dash_input(0.01)

	NemoraxTest.assert_eq(player.state, Player.State.DASHING, "zabuforowane naciśnięcie powinno automatycznie odpalić dash, gdy cooldown się skończy")
	_cleanup(player, root)

func test_attack_fires_immediately_when_already_ready(root: Node) -> void:
	var player := _fresh_player(root)
	player.stamina = player.max_stamina

	Input.action_press("attack")
	player._handle_attack_input(0.0)
	Input.action_release("attack")

	NemoraxTest.assert_eq(player._attack_phase, "windup", "naciśnięcie gdy atak jest gotowy powinno odpalić go od razu, bez zmiany istniejącego zachowania")
	_cleanup(player, root)

## Nie używa Input.action_press — patrz uwaga na górze pliku i przy dash.
func test_attack_buffered_press_fires_automatically_once_recovery_ends(root: Node) -> void:
	var player := _fresh_player(root)
	player.stamina = player.max_stamina
	player.mana = player.max_mana
	player._attack_phase = "" # recovery już się skończył (symulacja _process_attack_phase z wcześniejszej klatki)
	player._buffered_attack_timer = player.input_buffer_window * 0.5 # zabuforowane naciśnięcie, wciąż w oknie

	player._handle_attack_input(0.01)

	NemoraxTest.assert_eq(player._attack_phase, "windup", "zabuforowane naciśnięcie powinno automatycznie zacząć nowy zamach")
	_cleanup(player, root)

func test_attack_denied_sound_plays_immediately_when_resources_insufficient(root: Node) -> void:
	var player := _fresh_player(root)
	player.stamina = 0.0
	player.mana = 0.0

	Input.action_press("attack")
	player._handle_attack_input(0.0)
	Input.action_release("attack")

	NemoraxTest.assert_eq(player._attack_phase, "", "bez staminy/many atak nie powinien odpalić")
	NemoraxTest.assert_true(player._buffered_attack_timer > 0.0, "naciśnięcie mimo odmowy wciąż zostaje zabuforowane na wypadek regeneracji zasobu w oknie bufora")
	_cleanup(player, root)
