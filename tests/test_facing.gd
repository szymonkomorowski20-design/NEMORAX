extends RefCounted
## Facing.resolve() (facing.gd) — bucket kierunku + polaryzacja flip_h. Test
## regresyjny na buga zgłoszonego przez gracza: ruch w prawo pokazywał
## teksturę "side" tak, jakby postać szła w lewo (sprite bazowy patrzy w lewo
## z natury, flip_h miał odwróconą polaryzację).

## resolve() typuje wewnętrznie `var tex: Texture2D` — placeholdery MUSZĄ być
## prawdziwymi Texture2D (nie np. String), inaczej ta linia wywala się cicho
## w runtime i psuje wynik bez rzucenia widocznego błędu testu.
const TEX_FRONT := preload("res://assets/sprites/gracz/player_walk.png")
const TEX_BACK := preload("res://assets/sprites/gracz/player_walk_back.png")
const TEX_SIDE := preload("res://assets/sprites/gracz/player_walk_side.png")
const VARIANTS := {"front": TEX_FRONT, "back": TEX_BACK, "side": TEX_SIDE}

func test_front_back_no_flip(_root: Node) -> void:
	var down := Facing.resolve(VARIANTS, Vector2(0.0, 200.0)) # w dół = front
	NemoraxTest.assert_eq(down["texture"], TEX_FRONT, "ruch w dół powinien dać front")
	NemoraxTest.assert_eq(down["flip_h"], false, "front nigdy nie jest odbijany")

	var up := Facing.resolve(VARIANTS, Vector2(0.0, -200.0)) # w górę = back
	NemoraxTest.assert_eq(up["texture"], TEX_BACK, "ruch w górę powinien dać back")
	NemoraxTest.assert_eq(up["flip_h"], false, "back nigdy nie jest odbijany")

func test_side_flip_polarity_matches_source_art(_root: Node) -> void:
	# Grafika _side.png patrzy w lewo z natury (sprawdzone wizualnie) — ruch w
	# LEWO pokazuje ją WPROST (bez odbicia), ruch w PRAWO wymaga flip_h=true,
	# żeby sylwetka faktycznie odwróciła się w stronę ruchu.
	var right := Facing.resolve(VARIANTS, Vector2(200.0, 0.0))
	NemoraxTest.assert_eq(right["texture"], TEX_SIDE, "ruch w prawo powinien dać side")
	NemoraxTest.assert_eq(right["flip_h"], true, "ruch w prawo MUSI odbić stronę (bug: było na odwrót)")

	var left := Facing.resolve(VARIANTS, Vector2(-200.0, 0.0))
	NemoraxTest.assert_eq(left["texture"], TEX_SIDE, "ruch w lewo powinien dać side")
	NemoraxTest.assert_eq(left["flip_h"], false, "ruch w lewo pokazuje side wprost, bez odbicia")

func test_plain_texture_without_variants_never_flips(_root: Node) -> void:
	var result := Facing.resolve(TEX_FRONT, Vector2(200.0, 0.0))
	NemoraxTest.assert_eq(result["texture"], TEX_FRONT, "poza bez wariantów zwraca teksturę bez zmian")
	NemoraxTest.assert_eq(result["flip_h"], false, "poza bez wariantów (Texture2D, nie Dictionary) nigdy nie jest odbijana")
