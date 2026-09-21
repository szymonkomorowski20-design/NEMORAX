class_name Facing
extends RefCounted
## Wspólny "bucket" kierunku na wariant grafiki kierunkowej + opcjonalny cykl
## chodu, używany wszędzie tam, gdzie dana poza ma warianty kierunkowe wg
## PLAN_ANIMACJE_KIERUNKOWE.md (na razie tylko pozy "chód"/"idle-dryf").
##
## Faza 1b: 5 kątów (front/front_diagonal/side/back_diagonal/back) zamiast
## dawnych 3 (front/back/side) — więcej kątów = płynniejsze skręcanie. Grafika
## bazowa (bez sufiksu) to zawsze "front" — model patrzy w stronę kamery/w dół.
## "side"/"front_diagonal"/"back_diagonal" pokrywają PRAWĄ stronę wprost,
## LEWĄ przez flip_h (jeden plik, dwa kierunki).

## Postać z wariantami: Dictionary {"front": Texture2D, ...} (bez cyklu chodu)
## albo {"front": [Texture2D, Texture2D, ...], ...} (Z cyklem chodu — `frame`
## wybiera indeks, zawijany modulo). Postać bez wariantów: zwykła Texture2D.
## Brakujący kąt w słowniku (np. stara poza bez front_diagonal/back_diagonal)
## degraduje łagodnie przez BUCKET_FALLBACKS zamiast się wysypać.
const BUCKET_FALLBACKS := {
	"front": ["front"],
	"front_diagonal": ["front_diagonal", "side", "front"],
	"side": ["side", "front"],
	"back_diagonal": ["back_diagonal", "side", "back", "front"],
	"back": ["back", "front"],
}
## Kąty odbijane lewo/prawo przez flip_h — wszystko poza czystym przód/tył.
const FLIPPED_BUCKETS := ["side", "front_diagonal", "back_diagonal"]

static func resolve(tex_or_variants, direction: Vector2, frame: int = 0) -> Dictionary:
	if tex_or_variants is Dictionary:
		var key := _bucket(direction)
		var resolved_key := _resolve_key(tex_or_variants, key)
		var entry = tex_or_variants[resolved_key] if tex_or_variants.has(resolved_key) else tex_or_variants.get("front")
		var tex: Texture2D = entry[frame % entry.size()] if entry is Array else entry
		# flip_h zależy od klucza, który FAKTYCZNIE dostarczył grafikę (po
		# fallbacku), nie od pierwotnie wyliczonego bucketu — inaczej poza
		# mająca dziś TYLKO "front" (większość, przed dowiezieniem grafiki
		# Fazy 3-5) migałaby losowo odbita/nieodbita zależnie od kierunku
		# myszy/ruchu, mimo że cały czas pokazuje ten sam, jedyny obrazek.
		return {"texture": tex, "flip_h": resolved_key in FLIPPED_BUCKETS and direction.x > 0.0}
	return {"texture": tex_or_variants, "flip_h": false}

## Pierwszy klucz z BUCKET_FALLBACKS[key], jaki faktycznie istnieje w
## `variants` — dzięki temu poza bez wariantów front_diagonal/back_diagonal
## (czyli dziś WSZYSTKO poza chodem, a nawet chód przed dowiezieniem nowej
## grafiki) dostaje najbliższe grubsze przybliżenie zamiast wyjątku.
static func _resolve_key(variants: Dictionary, key: String) -> String:
	for candidate in BUCKET_FALLBACKS.get(key, ["front"]):
		if variants.has(candidate):
			return candidate
	return "front"

## Dzieli pełne koło na 8 wycinków po 45° (granice co 22.5° od czystego
## przodu), zwinięte do 5 nazw przez odbicie lewo/prawo w resolve(). Y w
## Godot rośnie w dół, więc Vector2.DOWN to "front" (w stronę kamery).
static func _bucket(direction: Vector2) -> String:
	if direction.length() < 0.001:
		return "front"
	var angle_from_front := rad_to_deg(absf(direction.angle_to(Vector2.DOWN))) # 0..180
	if angle_from_front < 22.5:
		return "front"
	elif angle_from_front < 67.5:
		return "front_diagonal"
	elif angle_from_front < 112.5:
		return "side"
	elif angle_from_front < 157.5:
		return "back_diagonal"
	else:
		return "back"
