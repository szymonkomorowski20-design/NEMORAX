extends RefCounted

const RECT := Rect2(90.0, 60.0, 1100.0, 600.0)
const THEMES := [
	"flooded_catacombs", "sunken_library", "frozen_crypt", "blood_ritual_hall",
	"overgrown_ruins", "ash_battlefield", "crystal_cavern", "rusted_machine_hall",
	"vhar_nokh", "mordrath", "zha_ruun", "nekravor", "thal_gor", "orryx",
]

func test_every_theme_has_four_integrated_wall_sprites(_root: Node) -> void:
	for theme in THEMES:
		var visual := IntegratedRoomVisual.new()
		NemoraxTest.assert_true(visual.configure(RECT, theme), "brak grafiki motywu " + theme)
		for side in ["top", "bottom", "left", "right"]:
			var sprite := visual.get_node_or_null("WallDoor_" + side) as Sprite2D
			NemoraxTest.assert_true(sprite != null and sprite.texture != null, theme + ": brak ściany " + side)
		visual.free()

func test_portal_starts_sealed_and_opens_without_separate_sprite(_root: Node) -> void:
	var visual := IntegratedRoomVisual.new()
	NemoraxTest.assert_true(visual.configure(RECT, "crystal_cavern"), "pokój testowy musi się wczytać")
	var wall := visual.get_node("WallDoor_top") as Sprite2D
	var material := wall.material as ShaderMaterial
	NemoraxTest.assert_eq(material.get_shader_parameter("open_amount"), 0.0, "portal przed walką jest wygaszony")
	visual.set_portal_open("top")
	NemoraxTest.assert_eq(material.get_shader_parameter("open_amount"), 1.0, "portal aktywuje się z drzwiami")
	visual.free()

func test_real_room_uses_integrated_art(root: Node) -> void:
	var room = load("res://rooms/room.tscn").instantiate()
	root.add_child(room)
	NemoraxTest.assert_true(room.get("_integrated_visual") is IntegratedRoomVisual, "zwykły pokój musi korzystać z nowych ścian")
	root.remove_child(room)
	room.queue_free()

func test_door_trigger_has_no_duplicate_sprite_with_integrated_wall(root: Node) -> void:
	var door := load("res://rooms/door.tscn").instantiate() as Door
	door.use_integrated_visual = true
	root.add_child(door)
	NemoraxTest.assert_true(not door.sprite.visible, "drugi PNG portalu nie może nakładać się na mur")
	root.remove_child(door)
	door.queue_free()

func test_integrated_portal_trigger_covers_all_four_openings_without_auto_entry(_root: Node) -> void:
	var door := Door.new()
	door.use_integrated_visual = true
	var cases := [
		{"side": "top", "inside": Vector2(105, 30), "outside": Vector2(125, 30), "spawn": Vector2(0, 70)},
		{"side": "bottom", "inside": Vector2(-105, -30), "outside": Vector2(-125, -30), "spawn": Vector2(0, -70)},
		{"side": "left", "inside": Vector2(30, 100), "outside": Vector2(30, 115), "spawn": Vector2(70, 0)},
		{"side": "right", "inside": Vector2(-30, -100), "outside": Vector2(-30, -115), "spawn": Vector2(-70, 0)},
	]
	for entry in cases:
		door.wall_side = entry["side"]
		NemoraxTest.assert_true(door._player_reaches_portal(entry["inside"]), entry["side"] + ": bok otworu ma działać")
		NemoraxTest.assert_true(not door._player_reaches_portal(entry["outside"]), entry["side"] + ": poza otworem nie może działać")
		NemoraxTest.assert_true(not door._player_reaches_portal(entry["spawn"]), entry["side"] + ": wejście do pokoju nie może od razu zawrócić")
	door.free()
