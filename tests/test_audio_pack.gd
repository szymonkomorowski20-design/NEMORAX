extends RefCounted
## Import paczki dźwiękowej: wszystkie pliki, które użytkownik dostarczył jako
## .wav z kodowaniem MP3, muszą być czytelne jako AudioStreamMP3.

const AUDIO_DIRS := [
	"res://assets/audio/music",
	"res://assets/audio/sfx/gracz",
	"res://assets/audio/sfx/wcielenia",
	"res://assets/audio/sfx/swiat",
	"res://assets/audio/sfx/nemorax",
]

func test_new_mp3_files_import_and_have_duration(_root: Node) -> void:
	var checked := 0
	for directory in AUDIO_DIRS:
		var dir := DirAccess.open(directory)
		NemoraxTest.assert_true(dir != null, "brak katalogu audio: " + directory)
		if dir == null:
			continue
		for file_name in dir.get_files():
			if not file_name.ends_with(".mp3"):
				continue
			var stream := load(directory + "/" + file_name) as AudioStreamMP3
			NemoraxTest.assert_true(stream != null, "nie udało się zaimportować " + file_name)
			if stream != null:
				NemoraxTest.assert_true(stream.get_length() > 0.0, "pusty dźwięk: " + file_name)
			checked += 1
	NemoraxTest.assert_true(checked >= 35, "powinno być co najmniej 35 plików z nowej paczki, jest %d" % checked)

func test_scene_music_uses_one_player_and_music_bus(_root: Node) -> void:
	var menu_track: AudioStream = load("res://assets/audio/music/MUS_theme_main.mp3")
	var boss_track: AudioStream = load("res://assets/audio/music/MUS_nemorax_phase_1.mp3")
	Juice.play_music(menu_track)
	NemoraxTest.assert_true(Juice._scene_music.playing, "muzyka menu wystartowała")
	NemoraxTest.assert_eq(Juice._scene_music.bus, &"Music", "muzyka idzie przez suwak Music")
	Juice.play_music(boss_track)
	NemoraxTest.assert_eq(Juice._scene_music.stream, boss_track, "przejście na muzykę bossa bez nakładania utworów")
	Juice.stop_music()
	NemoraxTest.assert_true(not Juice._scene_music.playing, "po zatrzymaniu nie zostaje stary utwór")
