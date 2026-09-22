extends Node
## Odczucia z walki (sekcja 4 dokumentu) — hitstop i trzęsienie ekranu.
## Błysk trafienia NIE mieszka tutaj: to czysto wizualny stan pojedynczego
## obiektu (2 klatki na biało), więc każdy `_draw()` robi to sam u siebie —
## robienie z tego wspólnego systemu byłoby przedwczesną abstrakcją.

@export var boss_hit_hitstop: float = 0.05 ## s, zatrzymanie gry gdy gracz trafia bossa
@export var player_hit_hitstop: float = 0.08 ## s, zatrzymanie gry gdy gracz dostaje obrażenia (górna granica zakresu 0.03-0.08s, PLAN_PROFESSIONAL_GAME_FEEL_DLA_CLAUDE.md sekcja 2C — było 0.10s, poza zakresem)
@export var shake_amplitude: float = 4.0 ## px, maksymalne przesunięcie ekranu przy trzęsieniu
@export var shake_duration: float = 0.12 ## s, jak długo trwa trzęsienie ekranu

var _hitstop_active := false
var _shake_time_left := 0.0

## Opcje — Grafika: "screen shake" (włącz/wyłącz). `var`, ustawiane z
## ui/options_screen.gd i zapisywane w user://settings.json.
var shake_enabled: bool = true

## Podgląd na żywo (sekcja Debug Mode) — F3, dotąd nic takiego nie istniało.
## Czysto tekstowy odczyt, nie edytor "na żywo": tabelka liczb do tuningu
## (stamina/mana/cooldowny/timery bufora/hitstop/shake) zamiast zgadywania z
## samego patrzenia na ekran. Mieszka na Juice, bo to już właściciel
## hitstopu/trzęsienia, i CanvasLayer tutaj (jak fade w game_flow.gd) przeżywa
## reload/zmianę sceny, więc F3 działa identycznie w pokoju/ołtarzu/arenie.
var debug_visible: bool = false
var _debug_label: Label

func _ready() -> void:
	_setup_debug_overlay()

func _setup_debug_overlay() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 101 # nad zaciemnieniem przejść (100, patrz game_flow.gd)
	_debug_label = Label.new()
	_debug_label.add_theme_color_override("font_color", Color.WHITE)
	_debug_label.add_theme_color_override("font_outline_color", Color.BLACK)
	_debug_label.add_theme_constant_override("outline_size", 3)
	_debug_label.position = Vector2(8.0, 8.0)
	_debug_label.visible = false
	layer.add_child(_debug_label)
	add_child(layer)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_debug"):
		debug_visible = not debug_visible
		_debug_label.visible = debug_visible

func _update_debug_label() -> void:
	var lines: Array[String] = [
		"FPS: %d   time_scale: %.2f   hitstop: %s   shake_left: %.3f" % [
			Engine.get_frames_per_second(), Engine.time_scale, _hitstop_active, _shake_time_left,
		],
	]
	var player := get_tree().get_first_node_in_group("player")
	if player != null:
		lines.append("player.state: %s   attack_phase: %s   weapon: %s" % [
			Player.State.keys()[player.state],
			player._attack_phase if player._attack_phase != "" else "-",
			player.current_weapon,
		])
		lines.append("hp: %.0f/%.0f   stamina: %.0f/%.0f   mana: %.0f/%.0f" % [
			player.health, player.max_health, player.stamina, player.max_stamina, player.mana, player.max_mana,
		])
		lines.append("dash_cooldown: %.2f   buffered_dash: %.2f   buffered_attack: %.2f   heal_stacks: %d" % [
			player._dash_cooldown_timer, player._buffered_dash_timer, player._buffered_attack_timer, player.get_heal_stacks(),
		])
	_debug_label.text = "\n".join(lines)

## Zatrzymuje grę na `duration` sekund w czasie rzeczywistym. Kolejne wywołanie
## w trakcie trwającego hitstopu jest ignorowane (sekcja 4: „nie mogą się nakładać").
## Opcje — Dostępność: "redukcja migotania" pomija hitstop całkowicie — nagłe
## zerwanie płynności ruchu na każde trafienie jest tym samym rodzajem
## bodźca, którego ta opcja ma unikać, nawet jeśli to nie dosłowny "flash".
func hitstop(duration: float) -> void:
	if _hitstop_active or Palette.reduce_flashing:
		return
	_hitstop_active = true
	Engine.time_scale = 0.0
	# Zwykły create_timer nigdy by nie wypalił przy time_scale == 0 — czwarty
	# argument (ignore_time_scale) każe mu liczyć w czasie rzeczywistym.
	await get_tree().create_timer(duration, true, false, true).timeout
	Engine.time_scale = 1.0
	_hitstop_active = false

## Uruchamia (lub przedłuża) trzęsienie ekranu na `shake_duration` s.
func screen_shake() -> void:
	if not shake_enabled:
		return
	_shake_time_left = shake_duration

## Wspólne "trafienie wroga" — ujednolica take_damage+flash_white+hitstop,
## które inaczej trzeba by powtarzać w każdym miejscu, skąd gracz może zadać
## obrażenia (miecz w player.gd, pocisk w projectile.gd), a każde kolejne
## miejsce byłoby kolejną kopią do rozjechania się przy następnej zmianie.
## NIE obejmuje register_hit_on_enemy() (mana/stacki leczenia) ani dźwięku
## trafienia — to zależy od konkretnej broni, nie jest uniwersalną reakcją celu.
## Faza 2C (PLAN_PROFESSIONAL_GAME_FEEL_DLA_CLAUDE.md): BEZ screen_shake() tutaj
## — to najczęstsza ścieżka trafienia w grze (każde cięcie mieczem, każdy
## pocisk), a dokument wprost zastrzega trzęsienie kamery WYŁĄCZNIE dla
## ciężkich ataków (patrz np. boss.gd._start_transform_invulnerability(),
## gdzie zostaje wywołane bezpośrednio dla konkretnego, rzadkiego momentu).
func apply_hit(target: Node, damage: float, hitstop_duration: float = boss_hit_hitstop, is_bonus_hit: bool = false) -> void:
	if target.has_method("take_damage"):
		target.take_damage(damage)
	if target.has_method("flash_white"):
		target.flash_white()
	if target is Node2D:
		var parent: Node = target.get_parent() if target.get_parent() != null else get_tree().current_scene
		DamageNumber.spawn(parent, target.global_position, damage, Palette.DANGER, is_bonus_hit)
	hitstop(hitstop_duration)

## Odtwarza jednorazowy dźwięk w danym miejscu świata i sam się sprząta po
## zakończeniu — do obiektów, które znikają (queue_free()) w tej samej klatce,
## w której powinien zabrzmieć ich dźwięk (pocisk, pieczęć, dusza itd.), więc
## własny AudioStreamPlayer2D obiektu zniknąłby razem z dźwiękiem.
func play_sfx_at(stream: AudioStream, world_position: Vector2, bus: String = "SFX") -> void:
	var player := AudioStreamPlayer2D.new()
	player.stream = stream
	player.bus = bus
	player.global_position = world_position
	# current_scene może być null (np. testy bez realnej sceny, albo w trakcie
	# przejścia między scenami) — root jako zapasowy rodzic zamiast crasha.
	var parent: Node = get_tree().current_scene if get_tree().current_scene != null else get_tree().root
	parent.add_child(player)
	player.finished.connect(player.queue_free)
	player.play()

func _process(delta: float) -> void:
	if debug_visible:
		_update_debug_label()
	if _shake_time_left <= 0.0:
		return
	_shake_time_left -= delta
	var camera := get_viewport().get_camera_2d()
	if camera == null:
		return
	if _shake_time_left <= 0.0:
		camera.offset = Vector2.ZERO
	else:
		camera.offset = Vector2(
			randf_range(-shake_amplitude, shake_amplitude),
			randf_range(-shake_amplitude, shake_amplitude)
		)
