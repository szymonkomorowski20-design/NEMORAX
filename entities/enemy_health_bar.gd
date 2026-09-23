extends Node2D
class_name EnemyHealthBar
## Pasek życia nad głową — dla wszystkich Incarnation (6 wcieleń + 11 wrogów
## losowych). Nemorax (Boss, NIE dziedziczy po Incarnation) zatrzymuje osobny
## pasek na górze ekranu w ui/ui.gd — ten komponent nigdy się do niego nie
## podpina, na życzenie autora ("życie na górze tylko podczas bossów").
##
## Rysowany kodem (dwa prostokąty) — nie ma dedykowanej grafiki na tak mały,
## uniwersalny pasek, a stylizowane tekstury paska gracza/bossa są za ciężkie
## (ogromne płótno 1536x1024) na coś, co ma być czytelne przy 30-130px sylwetce.
##
## Zasady widoczności (TERAZ_DLA_CLAUDE_ARENA_UI_I_FEELING.md, "Zdrowie
## przeciwników"): elita/miniboss — pasek od startu walki, na stałe. Zwykły
## wróg losowy — pasek pojawia się dopiero po pierwszym trafieniu i znika po
## FADE_AFTER_NO_DAMAGE sekundach bez obrażeń (dokument: okno 1,5-2,5s; nie
## losowane per-instancja, bo to strojenie odczucia, nie mechanika zależna od
## seeda). "Nie zaśmiecać areny liczbami nad wszystkimi wrogami stale" — stąd
## brak tekstu HP tutaj, tylko sam pasek (liczby są na DamageNumber, przelotne).

const BACKGROUND_COLOR := Color(0.04, 0.03, 0.06, 0.85)
const FILL_COLOR := Color("#D63B3B") # osobny od Palette.DANGER (ten zarezerwowany dla obrażeń ZADAWANYCH, nie otrzymywanych)
const SHADOW_COLOR := Color(0.88, 0.85, 0.80, 0.9) ## "cień" poprzedniego HP — dokument: "aby ciosy miały wagę"
const BAR_HEIGHT := 6.0
const STANCE_COLOR := Color(0.93, 0.86, 0.62, 0.95) ## postawa — jasny, ciepły, inny niż HP
const STANCE_IMMUNE_COLOR := Color(0.93, 0.86, 0.62, 0.3)
const WIDTH_PER_RADIUS := 1.3 ## szerokość paska = radius encji * ten mnożnik — większy wróg, szerszy pasek
const FADE_AFTER_NO_DAMAGE := 2.0 ## s, środek okna 1,5-2,5s z dokumentu
const FADE_OUT_DURATION := 0.3 ## s, płynne zniknięcie zamiast nagłego pop-u
const SHADOW_CATCH_UP_SPEED := 1.2 ## ułamek paska/s, jak szybko cień doganiam prawdziwe HP

var _target: Incarnation = null
var bar_width: float = 60.0
var _shown: bool = false
var _time_since_damage: float = 0.0
var _last_health: float = -1.0
var _shadow_ratio: float = 1.0
var _fade_tween: Tween

## `is_elite`/`is_miniboss` NIE są jeszcze wiarygodne w chwili tego wywołania:
## apply_elite_modifier() leci PO add_child() (patrz jej komentarz), a każde z
## sześciu wcieleń ustawia is_miniboss we WŁASNYM _ready(), już PO
## super._ready() (który tworzy i konfiguruje ten pasek) — stąd _process()
## sprawdza je na bieżąco zamiast raz tutaj w cache'u.
func configure(target: Incarnation) -> void:
	_target = target
	bar_width = target.radius * WIDTH_PER_RADIUS
	position = Vector2(0.0, -(target.radius + 22.0))
	z_index = 6 # nad postacią/VFX (AttackVfx=5), pod HUD-em (osobny CanvasLayer i tak niedotykalny stąd)
	_last_health = target.health
	_shadow_ratio = _current_ratio()
	visible = false
	modulate.a = 0.0

func _current_ratio() -> float:
	if _target == null or _target.max_health <= 0.0:
		return 0.0
	return clamp(_target.health / _target.max_health, 0.0, 1.0)

func _process(delta: float) -> void:
	if _target == null or not is_instance_valid(_target):
		queue_free()
		return
	var always_visible: bool = _target.is_elite or _target.is_miniboss
	if always_visible and not _shown:
		_show_immediately()
	if _target.health < _last_health - 0.001:
		_on_damaged()
	_last_health = _target.health
	_shadow_ratio = move_toward(_shadow_ratio, _current_ratio(), SHADOW_CATCH_UP_SPEED * delta)
	if _shown and not always_visible:
		_time_since_damage += delta
		if _time_since_damage > FADE_AFTER_NO_DAMAGE:
			_fade_out()
	queue_redraw()

func _show_immediately() -> void:
	_shown = true
	visible = true
	if _fade_tween != null and _fade_tween.is_valid():
		_fade_tween.kill()
	modulate.a = 1.0

func _on_damaged() -> void:
	_time_since_damage = 0.0
	if not _shown:
		_show_immediately()

func _fade_out() -> void:
	_shown = false
	_fade_tween = create_tween()
	_fade_tween.tween_property(self, "modulate:a", 0.0, FADE_OUT_DURATION)
	_fade_tween.tween_callback(func(): visible = false)

func _draw() -> void:
	if _target == null or _target.max_health <= 0.0:
		return
	var ratio := _current_ratio()
	var half := bar_width * 0.5
	draw_rect(Rect2(Vector2(-half, 0.0), Vector2(bar_width, BAR_HEIGHT)), BACKGROUND_COLOR, true)
	if _shadow_ratio > ratio:
		draw_rect(Rect2(Vector2(-half, 0.0), Vector2(bar_width * _shadow_ratio, BAR_HEIGHT)), SHADOW_COLOR, true)
	draw_rect(Rect2(Vector2(-half, 0.0), Vector2(bar_width * ratio, BAR_HEIGHT)), FILL_COLOR, true)
	# Postawa (prototyp E1): cienka linia pod HP, nie drugi dominujący pasek.
	# Przerywana w czasie odporności, żeby było widać, że teraz nie rośnie.
	if _target.stance_enabled:
		var y := BAR_HEIGHT + 2.0
		if _target.is_stance_immune():
			for i in 8:
				var x0 := -half + bar_width * float(i) / 8.0
				draw_rect(Rect2(Vector2(x0, y), Vector2(bar_width / 8.0 - 3.0, 2.0)), STANCE_IMMUNE_COLOR, true)
		else:
			draw_rect(Rect2(Vector2(-half, y), Vector2(bar_width * _target.stance_ratio(), 2.0)), STANCE_COLOR, true)
