extends RefCounted
class_name MapMarker
## Paczka 7 (AUDYT E3/A13): jeden język symboli typu pokoju — minimapa, duża
## mapa (M) i znacznik nad drzwiami. Kształt + kolor (nie sam kolor), żeby
## rozróżnić ryzyko i nagrodę na rozgałęzieniu jeszcze przed wejściem.

const LABELS := {
	"soul": "Dusza (wcielenie)", "altar": "Ołtarz", "chest": "Skrzynia z relikwią",
	"trap": "Pokój pułapek", "elite": "Elita", "rest": "Odpoczynek",
}
const COLORS := {
	"soul": Color("#D9CFF2"), "altar": Color("#E8C547"), "chest": Color("#E8C547"),
	"trap": Color("#F09A3E"), "elite": Color("#E0584F"), "rest": Color("#7FD6A0"),
}

## Co gracz ma wiedzieć o pokoju z zewnątrz ("" = zwykły pokój lub już bez znaczenia).
static func kind_for(data: Dictionary) -> String:
	if data.is_empty():
		return ""
	match int(data.get("type", -1)):
		GameFlow.RoomType.SOUL:
			return "" if data.get("cleared", false) else "soul"
		GameFlow.RoomType.ALTAR:
			return "altar"
		GameFlow.RoomType.RANDOM:
			if data.get("rest", false):
				return "" if data.get("rest_used", false) else "rest"
			if data.get("has_chest", false) and not data.get("chest_opened", false):
				return "chest"
			if data.get("cleared", false):
				return ""
			if data.get("trap", false):
				return "trap"
			if data.get("elite", false):
				return "elite"
	return ""

static func draw_marker(ci: CanvasItem, center: Vector2, size: float, kind: String) -> void:
	if kind == "":
		return
	var c: Color = COLORS[kind]
	var h := size * 0.5
	match kind:
		"soul":
			ci.draw_arc(center, h * 0.8, 0.0, TAU, 20, c, maxf(1.5, size * 0.14), true)
		"altar":
			ci.draw_colored_polygon(PackedVector2Array([center + Vector2(0, -h), center + Vector2(h, 0), center + Vector2(0, h), center + Vector2(-h, 0)]), c)
		"chest":
			ci.draw_rect(Rect2(center - Vector2(h, h * 0.7), Vector2(size, size * 0.7)), c, true)
			ci.draw_line(center + Vector2(-h, -h * 0.1), center + Vector2(h, -h * 0.1), Color(0.2, 0.14, 0.05), maxf(1.0, size * 0.1))
		"trap":
			ci.draw_colored_polygon(PackedVector2Array([center + Vector2(0, -h), center + Vector2(h, h), center + Vector2(-h, h)]), c)
			ci.draw_line(center + Vector2(0, -h * 0.35), center + Vector2(0, h * 0.35), Color(0.15, 0.08, 0.02), maxf(1.0, size * 0.12))
		"elite":
			ci.draw_polyline(PackedVector2Array([center + Vector2(-h, h * 0.5), center + Vector2(-h * 0.5, -h * 0.6), center + Vector2(0, h * 0.1), center + Vector2(h * 0.5, -h * 0.6), center + Vector2(h, h * 0.5)]), c, maxf(1.5, size * 0.16), true)
		"rest":
			ci.draw_rect(Rect2(center - Vector2(h * 0.25, h), Vector2(h * 0.5, size)), c, true)
			ci.draw_rect(Rect2(center - Vector2(h, h * 0.25), Vector2(size, h * 0.5)), c, true)
