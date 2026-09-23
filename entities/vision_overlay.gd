extends ColorRect
class_name VisionOverlay
## Faza Sovereignty/Zaćmienie Nemoraxa — zawężone pole widzenia. Priorytet 2
## (TERAZ_DLA_CLAUDE_ARENA_UI_I_FEELING.md) / sekcja 6 (PLAN_UI_UX_NAGRODY_
## DLA_CLAUDE.md): zgłoszony bug — sprite gracza znikał, pod WASD poruszało
## się tylko widoczne koło.
##
## Poprzednie podejście: CanvasLayer + ShaderMaterial liczący odległość od
## FRAGCOORD (współrzędne EKRANU) porównywanego z player.global_position
## (współrzędne ŚWIATA). Mimo że przy tej konkretnej Camera2D (position
## dokładnie na środku viewportu) offset matematycznie wychodził zerowy —
## potwierdzone zrzutem ekranu: "dziura" pojawiała się we WŁAŚCIWYM miejscu —
## gracz i tak nie prześwitywał przez nią. Zamiast dalej tropić tę konkretną
## kombinację CanvasLayer+ShaderMaterial, architektura jest teraz zgodna z
## tym, czego oba dokumenty wprost żądają: "VisionOverlay POD warstwą
## renderowania gracza", nie "dziura W warstwie NAD graczem".
##
## Ten węzeł żyje w TEJ SAMEJ przestrzeni co gracz (zwykły potomek Areny, NIE
## CanvasLayer) z z_index między podłogą (-10) a postaciami (0) — kontrakt w
## autoload/palette.gd. Gracz i wrogowie (z_index=0) zawsze rysują się NAD tą
## warstwą z definicji, więc są zawsze w pełni widoczni bez potrzeby
## "wycinania dziury" w czymkolwiek — przy okazji spełnia to też "zagrożenie
## nie może być całkowicie niewidzialne" (VFX/telegrafy mają z_index 1-3,
## też nad tą warstwą).

@export var radius: float = 160.0
@export var soft_edge: float = 70.0 ## px, szerokość miękkiego przejścia — dokument: "miękka, mglista krawędź"
@export var max_darkness: float = 0.92 ## nie 1.0 — dokument: zostawić 5-10% widoczności poza kręgiem
@export var darkness_color: Color = Color(0.102, 0.063, 0.149, 1.0)

var _target: Node2D

const SHADER_CODE := """
shader_type canvas_item;

uniform vec2 center;
uniform float radius = 160.0;
uniform float soft_edge = 70.0;
uniform float max_darkness = 0.92;
uniform vec4 darkness_color : source_color = vec4(0.102, 0.063, 0.149, 1.0);

varying vec2 local_pos;

void vertex() {
	local_pos = VERTEX;
}

void fragment() {
	float d = distance(local_pos, center);
	float a = smoothstep(radius, radius + soft_edge, d) * max_darkness;
	COLOR = vec4(darkness_color.rgb, a);
}
"""

func _ready() -> void:
	z_index = -1 # nad podłogą/ścianą (-10/-5, walls.gd), pod postaciami (0) — autoload/palette.gd
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false
	var shader := Shader.new()
	shader.code = SHADER_CODE
	var mat := ShaderMaterial.new()
	mat.shader = shader
	mat.set_shader_parameter("radius", radius)
	mat.set_shader_parameter("soft_edge", soft_edge)
	mat.set_shader_parameter("max_darkness", max_darkness)
	mat.set_shader_parameter("darkness_color", darkness_color)
	material = mat

## `arena_rect` z marginesem, żeby ciemność złapała też pustkę w tle, nie
## tylko samą arenę — inaczej byłoby widać jasną krawędź przy ścianach.
func activate(follow_target: Node2D, arena_rect: Rect2) -> void:
	_target = follow_target
	var margin := 400.0
	position = arena_rect.position - Vector2(margin, margin)
	size = arena_rect.size + Vector2(margin, margin) * 2.0
	visible = true

func deactivate() -> void:
	visible = false
	_target = null

func _process(_delta: float) -> void:
	if not visible or _target == null or material == null:
		return
	var local_center: Vector2 = _target.global_position - global_position
	material.set_shader_parameter("center", local_center)

## Paczka 10 / zgłoszenie autora (23.09): widoczność punktu świata w mroku
## (1 w kręgu, 0 w pełnej ciemności) — boss znika poza kręgiem, a gracz (cel
## kręgu) i telegrafy zagrożeń zostają widoczne.
func visibility_at(world_pos: Vector2, body_radius: float = 0.0) -> float:
	if not visible or _target == null:
		return 1.0
	var d := maxf(0.0, world_pos.distance_to(_target.global_position) - body_radius)
	return 1.0 - smoothstep(radius, radius + soft_edge, d)
