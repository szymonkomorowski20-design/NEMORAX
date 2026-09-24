extends RefCounted
## Losowy utwór muzyczny przy wejściu do pokoju (room.gd).
## Audyt nagrania 24.09 (P2.16): dawny jeden test mieszał „dobry utwór
## i pętla” z „odtwarzanie ruszyło” i zależał od stanu globalnego — gdy prolog
## nie był oznaczony jako widziany, pokój startowy odpalał cutscenkę, ta
## pauzowała drzewo, a spauzowany odtwarzacz zgłaszał playing = false
## (odtworzone 100/100 w debug/music_flake). Teraz każdy test ustawia własne
## warunki, a muzyka pokoju gra także pod cutscenką.

const PROLOG_TEST_PATH := "user://test_music_prolog.json"

func _fresh_room(root: Node) -> Node:
	var room = load("res://rooms/room.tscn").instantiate()
	root.add_child(room)
	return room

func _cleanup(room: Node, root: Node) -> void:
	root.get_tree().paused = false
	root.remove_child(room)
	room.queue_free()

func _diag(room: Node, root: Node) -> String:
	return " [pauza=%s, prolog_widziany=%s, typ=%s, stream=%s]" % [root.get_tree().paused, GameFlow.has_seen_prolog(), room._room_data.get("type"), room.music.stream != null]

func test_room_assigns_a_looping_pool_track(root: Node) -> void:
	GameFlow.reset_run()
	GameFlow.mark_prolog_seen()
	var room := _fresh_room(root)
	NemoraxTest.assert_true(room.music.stream != null, "room.gd powinien przypisać jakiś utwór w _ready()")
	NemoraxTest.assert_true(room.music.stream in room.ROOM_MUSIC_TRACKS, "przypisany utwór musi pochodzić z puli ROOM_MUSIC_TRACKS")
	NemoraxTest.assert_true((room.music.stream as AudioStreamMP3).loop, "utwory pokoju muszą się zapętlać")
	NemoraxTest.assert_true(room.ui.show_minimap, "room.gd powinien włączyć minimapę w UI (arena.gd jej nie włącza)")
	_cleanup(room, root)

func test_room_music_actually_starts(root: Node) -> void:
	GameFlow.reset_run()
	GameFlow.mark_prolog_seen()
	root.get_tree().paused = false
	var room := _fresh_room(root)
	NemoraxTest.assert_true(room.music.playing, "muzyka powinna zacząć grać zaraz po wejściu do pokoju" + _diag(room, root))
	_cleanup(room, root)

## Pierwsze wejście: prolog pauzuje drzewo, ale muzyka ma grać pod dialogiem.
func test_room_music_plays_under_prolog(root: Node) -> void:
	var original := GameFlow.PERSISTENT_SAVE_PATH
	GameFlow.PERSISTENT_SAVE_PATH = PROLOG_TEST_PATH
	if FileAccess.file_exists(PROLOG_TEST_PATH):
		DirAccess.remove_absolute(PROLOG_TEST_PATH)
	GameFlow.reset_run()
	var room := _fresh_room(root)
	NemoraxTest.assert_true(root.get_tree().paused, "warunek testu: prolog spauzował drzewo")
	NemoraxTest.assert_true(room.music.playing, "muzyka gra pod cutscenką prologu" + _diag(room, root))
	_cleanup(room, root)
	if FileAccess.file_exists(PROLOG_TEST_PATH):
		DirAccess.remove_absolute(PROLOG_TEST_PATH)
	GameFlow.PERSISTENT_SAVE_PATH = original
	GameFlow.mark_prolog_seen()

func test_music_pool_has_enough_tracks_to_feel_random(_root: Node) -> void:
	# Bez add_child() — const ROOM_MUSIC_TRACKS nie wymaga _ready(), więc
	# starczy goła instancja skryptu, żeby sprawdzić samą pulę.
	var room: Node = load("res://rooms/room.gd").new()
	var tracks: Array = room.ROOM_MUSIC_TRACKS
	NemoraxTest.assert_true(tracks.size() >= 4, "pula nowych utworów eksploracji powinna mieć 4 pozycje, jest %d" % tracks.size())
	var unique := {}
	for t in tracks:
		unique[t.resource_path] = true
	NemoraxTest.assert_eq(unique.size(), tracks.size(), "wszystkie utwory w puli powinny być różnymi plikami")
	room.free()
