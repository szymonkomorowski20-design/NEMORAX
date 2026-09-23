extends Node2D
class_name DamageNumber
## Second Impact — obowiązkowy audyt mechaniki (TERAZ_DLA_CLAUDE_ARENA_UI_I_
## FEELING.md / PLAN_UI_UX_NAGRODY_DLA_CLAUDE.md): dokument wymaga "osobnej
## liczby obrażeń" jako dowodu, że drugie trafienie faktycznie się zdarzyło —
## w całej grze nie istniał dotąd ŻADEN system liczb obrażeń (sprawdzone
## grepem), więc "drugi cios" był nieodróżnialny od zwykłego trafienia.
##
## Prosty, jednorazowy węzeł świata (NIE CanvasLayer — ma żyć przy celu,
## przewijać się z kamerą jak VFX ataku): unosi się, blaknie, sam się sprząta.
## Rysowany kodem (ThemeDB.fallback_font) jak reszta HUD-u (ui.gd) — bez
## dedykowanej sceny/tekstury na coś tak małego.

const RISE_DISTANCE := 30.0
const DURATION := 0.6
const FONT_SIZE := 16
const BONUS_FONT_SIZE := 20 ## drugie trafienie Second Impact — nieco większe, żeby było czytelnie inne

var _text: String
var _color: Color
var _font_size: int

## `is_bonus` — Second Impact / inne opóźnione dodatkowe trafienia: większa
## czcionka, żeby "osobna liczba obrażeń" faktycznie rzucała się w oczy jako
## COŚ WIĘCEJ niż zwykłe trafienie, nie tylko przez sam fakt drugiego pojawienia.
static func spawn(parent: Node, world_pos: Vector2, damage: float, color: Color, is_bonus: bool = false) -> void:
	spawn_text(parent, world_pos, str(int(round(damage))), color, is_bonus)

## Ten sam unoszący się napis, ale z dowolnym tekstem (np. wynik bloku).
static func spawn_text(parent: Node, world_pos: Vector2, text: String, color: Color, is_bonus: bool = false) -> void:
	var number: DamageNumber = DamageNumber.new()
	parent.add_child(number)
	number.global_position = world_pos + Vector2(randf_range(-6.0, 6.0), 0.0)
	number.z_index = 6 # nad postaciami/VFX ataku (5), pod HUD-em (osobny CanvasLayer)
	number._text = text
	number._color = color
	number._font_size = BONUS_FONT_SIZE if is_bonus else FONT_SIZE
	var tween := number.create_tween()
	tween.set_parallel(true)
	tween.tween_property(number, "position:y", number.position.y - RISE_DISTANCE, DURATION).set_ease(Tween.EASE_OUT)
	tween.tween_property(number, "modulate:a", 0.0, DURATION).set_delay(DURATION * 0.4)
	tween.chain().tween_callback(number.queue_free)

func _draw() -> void:
	var font := ThemeDB.fallback_font
	var text_size := font.get_string_size(_text, HORIZONTAL_ALIGNMENT_CENTER, -1, _font_size)
	draw_string(font, Vector2(-text_size.x * 0.5, 0.0), _text, HORIZONTAL_ALIGNMENT_LEFT, -1, _font_size, _color)
