extends Node2D
class_name DamageZone
## Strefa okresowych obrażeń — Zoner (CLAUDE_CODE_GAME_CONTENT_BIBLE.md sekcja
## 6). Ani entities/seal.gd (jednorazowy wybuch), ani entities/void_zone.gd
## (blokuje dash, nie rani) nie pasują do "tick obrażeń co jakiś czas przez
## czas trwania" — stąd nowa, mała scena zamiast naciągania jednej z tamtych
## pod coś, do czego nie została zaprojektowana.

const TEX_ZONE := preload("res://assets/sprites/enemy_vfx/zoner_skill.png") # dedykowana grafika strefy Zonera (KIERUNEK_WIZUALNY_REFERENCJE.md)
const SND_ZONE_TICK := preload("res://assets/audio/sfx/swiat/W12_zone_tick.mp3")
const SND_ZONE_FADE := preload("res://assets/audio/sfx/swiat/W13_zone_fade.mp3")
const ZONE_CONTENT_SIZE := 900.0 ## szacunkowy zasięg widocznej treści w kanwie 1024px
## Faza 2D (PLAN_PROFESSIONAL_GAME_FEEL_DLA_CLAUDE.md): "telegraf musi być
## odrobinę większy niż realna strefa obrażeń, nigdy mniejszy" — podczas
## zapowiedzi grafika jest odrobinę większa niż zone_radius, żeby gracz miał
## mały margines bezpieczeństwa; po aktywacji wraca do dokładnego rozmiaru.
const TELEGRAPH_SAFETY_MARGIN := 1.12

@export var zone_radius: float = 64.0
@export var telegraph_duration: float = 0.9
@export var duration: float = 3.5
@export var tick_damage: float = 5.0
@export var tick_interval: float = 0.75 ## AUDYT C: ciągła strefa najwyżej jedno trafienie co 0,75–1 s

@onready var sprite: Sprite2D = $Sprite

var _telegraph_timer: float
var _active_timer: float = 0.0
var _tick_timer: float = 0.0
var _is_active: bool = false
var _zone_scale: float = 1.0
## Drugi audyt (A3): trzy czytelne stany zamiast jednej naklejonej plamy —
## zapowiedź (przerywany brzeg + wypełnianie od środka), aktywna (pełny brzeg
## DOKŁADNIE na promieniu obrażeń, puls przy każdym tyknięciu), wygasanie
## (FADE_TIME bez obrażeń). Kolizja bez zmian.
const FADE_TIME := 0.45
var _fade_timer: float = -1.0
var _tick_flash: float = 0.0

func _ready() -> void:
	_telegraph_timer = telegraph_duration
	sprite.texture = TEX_ZONE
	sprite.show_behind_parent = true # brzeg stanu (_draw) nad teksturą
	_zone_scale = (zone_radius * 2.0) / ZONE_CONTENT_SIZE
	sprite.scale = Vector2(_zone_scale, _zone_scale) * TELEGRAPH_SAFETY_MARGIN
	sprite.modulate = Color(Palette.DANGER.r, Palette.DANGER.g, Palette.DANGER.b, 0.3)

func _physics_process(delta: float) -> void:
	queue_redraw()
	if _fade_timer >= 0.0:
		_fade_timer -= delta
		sprite.modulate.a = 0.55 * clampf(_fade_timer / FADE_TIME, 0.0, 1.0)
		if _fade_timer <= 0.0:
			queue_free()
		return
	_tick_flash = maxf(0.0, _tick_flash - delta)
	if not _is_active:
		_telegraph_timer -= delta
		sprite.modulate.a = 0.3 + 0.4 * (1.0 - clamp(_telegraph_timer / telegraph_duration, 0.0, 1.0))
		if _telegraph_timer <= 0.0:
			_is_active = true
			_active_timer = duration
			_tick_timer = 0.0
			sprite.modulate.a = 0.55
			sprite.scale = Vector2(_zone_scale, _zone_scale) # koniec marginesu bezpieczeństwa telegrafu — teraz dokładny zasięg
		return

	_active_timer -= delta
	_tick_timer -= delta
	if _tick_timer <= 0.0:
		_tick_timer = tick_interval
		_tick_flash = 0.18
		_try_damage_player()
	if _active_timer <= 0.0:
		_fade_timer = FADE_TIME # wygasanie: widać, że już nie rani
		Juice.play_sfx_at(SND_ZONE_FADE, global_position)

func _try_damage_player() -> void:
	var player := get_tree().get_first_node_in_group("player") as Player
	if player == null:
		return
	if global_position.distance_to(player.global_position) > zone_radius:
		return
	if player.is_invulnerable():
		return
	player.take_damage(tick_damage, global_position, false, self) # strefa na podłożu — tarcza nie pomaga
	Juice.play_sfx_at(SND_ZONE_TICK, global_position)

func _draw() -> void:
	var danger := Palette.DANGER
	if _fade_timer >= 0.0:
		var k := clampf(_fade_timer / FADE_TIME, 0.0, 1.0)
		draw_arc(Vector2.ZERO, zone_radius, 0.0, TAU, 40, Color(0.6, 0.55, 0.5, 0.35 * k), 2.0, true)
		return
	if not _is_active:
		var p := 1.0 - clampf(_telegraph_timer / telegraph_duration, 0.0, 1.0)
		var r := zone_radius * TELEGRAPH_SAFETY_MARGIN
		draw_circle(Vector2.ZERO, r * p, Color(danger, 0.10 + 0.12 * p))
		for i in 16:
			var a0 := TAU * float(i) / 16.0
			draw_arc(Vector2.ZERO, r, a0, a0 + TAU / 32.0, 4, Color(danger, 0.45 + 0.5 * p), 3.0, true)
		return
	var pulse := _tick_flash / 0.18
	draw_arc(Vector2.ZERO, zone_radius + 5.0, 0.0, TAU, 48, Color(danger, 0.10), 8.0, true) # miękkie przejście do kamienia
	draw_arc(Vector2.ZERO, zone_radius, 0.0, TAU, 48, Color(danger, 0.75 + 0.25 * pulse), 2.5 + 2.0 * pulse, true)
