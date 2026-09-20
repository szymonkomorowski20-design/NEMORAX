extends RefCounted
## Walls.wall_point() — drzwi muszą tkwić dokładnie na granicy areny (tam gdzie
## Walls.build() stawia sam segment ściany), nie na dowolnym przesunięciu od
## środka floated na otwartej podłodze (bug zgłoszony przez autora).

const RECT := Rect2(90.0, 60.0, 1100.0, 600.0) # ta sama ARENA_RECT co w room.gd/arena.gd

func test_wall_points_sit_exactly_on_the_rect_boundary(_root: Node) -> void:
	var top := Walls.wall_point(RECT, "top")
	NemoraxTest.assert_almost_eq(top.y, RECT.position.y, 0.01, "top powinien być na górnej krawędzi rect")
	NemoraxTest.assert_almost_eq(top.x, RECT.get_center().x, 0.01, "top powinien być wyśrodkowany poziomo")

	var bottom := Walls.wall_point(RECT, "bottom")
	NemoraxTest.assert_almost_eq(bottom.y, RECT.position.y + RECT.size.y, 0.01, "bottom powinien być na dolnej krawędzi rect")

	var left := Walls.wall_point(RECT, "left")
	NemoraxTest.assert_almost_eq(left.x, RECT.position.x, 0.01, "left powinien być na lewej krawędzi rect")

	var right := Walls.wall_point(RECT, "right")
	NemoraxTest.assert_almost_eq(right.x, RECT.position.x + RECT.size.x, 0.01, "right powinien być na prawej krawędzi rect")

