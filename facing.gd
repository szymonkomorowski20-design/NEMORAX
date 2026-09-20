class_name Facing
extends RefCounted
## Wspólny "bucket" kierunku na wariant grafiki kierunkowej (przód/tył/bok),
## używany wszędzie tam, gdzie dana poza ma warianty _back/_side wygenerowane
## wg PLAN_ANIMACJE_KIERUNKOWE.md (na razie tylko pozy "chód"/"idle-dryf").
##
## Grafika bazowa (bez sufiksu) to zawsze "front" — model patrzy w stronę
## kamery/w dół. "side" pokrywa PRAWO wprost, LEWO przez flip_h (jeden plik,
## dwa kierunki), więc każda poza z wariantami potrzebuje tylko 2 nowych
## obrazków (_back, _side), nie 3-4.

## Postać z wariantami: Dictionary {"front": Texture2D, "back": Texture2D, "side": Texture2D}.
## Postać bez wariantów: zwykła Texture2D — resolve() obsługuje oba przypadki,
## żeby wywołujący kod nie musiał sam sprawdzać typu.
static func resolve(tex_or_variants, direction: Vector2) -> Dictionary:
	if tex_or_variants is Dictionary:
		var key := _bucket(direction)
		var tex: Texture2D = tex_or_variants.get(key, tex_or_variants.get("front"))
		return {"texture": tex, "flip_h": key == "side" and direction.x < 0.0}
	return {"texture": tex_or_variants, "flip_h": false}

## Dzieli pełny kąt na 4 sektory po 90° (granice po przekątnych) — "front" i
## "back" to góra/dół (Y w Godot rośnie w dół, więc dodatnie Y = w stronę
## kamery = front), "side" to lewo/prawo (rozróżniane osobno przez flip_h w resolve()).
static func _bucket(direction: Vector2) -> String:
	if direction.length() < 0.001:
		return "front"
	if absf(direction.x) > absf(direction.y):
		return "side"
	return "front" if direction.y > 0.0 else "back"
