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

const BACKGROUND_COLOR := Color(0.04, 0.03, 0.06, 0.85)
const FILL_COLOR := Color("#D63B3B") # osobny od Palette.DANGER (ten zarezerwowany dla obrażeń ZADAWANYCH, nie otrzymywanych)
const BAR_HEIGHT := 6.0
const WIDTH_PER_RADIUS := 1.3 ## szerokość paska = radius encji * ten mnożnik — większy wróg, szerszy pasek

var _target: Incarnation = null
var bar_width: float = 60.0

func configure(target: Incarnation) -> void:
	_target = target
	bar_width = target.radius * WIDTH_PER_RADIUS
	position = Vector2(0.0, -(target.radius + 22.0))
	z_index = 6 # nad postacią/VFX (AttackVfx=5), pod HUD-em (osobny CanvasLayer i tak niedotykalny stąd)

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	if _target == null or _target.max_health <= 0.0:
		return
	var ratio: float = clamp(_target.health / _target.max_health, 0.0, 1.0)
	var half := bar_width * 0.5
	draw_rect(Rect2(Vector2(-half, 0.0), Vector2(bar_width, BAR_HEIGHT)), BACKGROUND_COLOR, true)
	draw_rect(Rect2(Vector2(-half, 0.0), Vector2(bar_width * ratio, BAR_HEIGHT)), FILL_COLOR, true)
