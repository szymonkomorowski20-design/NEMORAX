extends RefCounted
## Losowy utwór muzyczny przy wejściu do pokoju (room.gd) — sprawdza, że
## _ready() faktycznie przypisuje i odtwarza jeden z ROOM_MUSIC_TRACKS, oraz
## że pula jest wystarczająco duża/zróżnicowana, żeby kolejne wejścia realnie
## dawały różne utwory (nie tylko technicznie "losowe" z puli rozmiaru 1).

func _fresh_room(root: Node) -> Node:
	var room = load("res://rooms/room.tscn").instantiate()
	root.add_child(room)
	return room

func _cleanup(room: Node, root: Node) -> void:
	root.remove_child(room)
	room.queue_free()

func test_room_assigns_and_plays_a_pool_track(root: Node) -> void:
	var room := _fresh_room(root)
	NemoraxTest.assert_true(room.music.stream != null, "room.gd powinien przypisać jakiś utwór w _ready()")
	NemoraxTest.assert_true(room.music.stream in room.ROOM_MUSIC_TRACKS, "przypisany utwór musi pochodzić z puli ROOM_MUSIC_TRACKS")
	NemoraxTest.assert_true(room.music.playing, "muzyka powinna zacząć grać zaraz po wejściu do pokoju")
	NemoraxTest.assert_eq(room.music.stream.loop_mode, AudioStreamWAV.LOOP_FORWARD, "utwory pokoju muszą się zapętlać (loop_mode=1 w imporcie)")
	_cleanup(room, root)

func test_music_pool_has_enough_tracks_to_feel_random(_root: Node) -> void:
	# Bez add_child() — const ROOM_MUSIC_TRACKS nie wymaga _ready(), więc
	# starczy goła instancja skryptu, żeby sprawdzić samą pulę.
	var room: Node = load("res://rooms/room.gd").new()
	var tracks: Array = room.ROOM_MUSIC_TRACKS
	NemoraxTest.assert_true(tracks.size() >= 8, "pula utworów pokoju powinna mieć sensowną różnorodność (>=8), jest %d" % tracks.size())
	var unique := {}
	for t in tracks:
		unique[t.resource_path] = true
	NemoraxTest.assert_eq(unique.size(), tracks.size(), "wszystkie utwory w puli powinny być różnymi plikami")
