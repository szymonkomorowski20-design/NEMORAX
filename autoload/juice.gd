extends Node
## Odczucia z walki (sekcja 4 dokumentu) — hitstop i trzęsienie ekranu.
## Błysk trafienia NIE mieszka tutaj: to czysto wizualny stan pojedynczego
## obiektu (2 klatki na biało), więc każdy `_draw()` robi to sam u siebie —
## robienie z tego wspólnego systemu byłoby przedwczesną abstrakcją.

@export var boss_hit_hitstop: float = 0.05 ## s, zatrzymanie gry gdy gracz trafia bossa
@export var player_hit_hitstop: float = 0.10 ## s, zatrzymanie gry gdy gracz dostaje obrażenia
@export var shake_amplitude: float = 4.0 ## px, maksymalne przesunięcie ekranu przy trzęsieniu
@export var shake_duration: float = 0.12 ## s, jak długo trwa trzęsienie ekranu

var _hitstop_active := false
var _shake_time_left := 0.0

## Zatrzymuje grę na `duration` sekund w czasie rzeczywistym. Kolejne wywołanie
## w trakcie trwającego hitstopu jest ignorowane (sekcja 4: „nie mogą się nakładać").
func hitstop(duration: float) -> void:
	if _hitstop_active:
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
	_shake_time_left = shake_duration

func _process(delta: float) -> void:
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
