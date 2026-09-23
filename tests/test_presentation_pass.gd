extends RefCounted
## Paczka 10 (AUDYT A9/A14/A15/A16): spójność prezentacji — polskie nazwy faz
## bez dublowania, napisy czcionką gry, runiczny krąg bossa, dźwięk
## przełamania gardy, muzyka ustępująca telegrafom.

func _cleanup(node: Node, root: Node) -> void:
	root.remove_child(node)
	node.queue_free()

func test_phase_banner_hides_phase_on_boss_bar(root: Node) -> void:
	var layer: CanvasLayer = load("res://ui/ui.tscn").instantiate()
	root.add_child(layer)
	var ui: GameUI = layer.get_node("UI")
	ui.show_form_name(Palette.PHASE_NAMES[1])
	NemoraxTest.assert_eq(ui._center_message, "Siła", "baner fazy po polsku")
	NemoraxTest.assert_true(ui._center_message_font_size >= ui.form_name_font_size, "baner rysowany czcionką banera (Cinzel)")
	ui.show_taunt("Pamiętam, że mam ręce.", 3.0)
	NemoraxTest.assert_true(ui._center_message_font_size < ui.form_name_font_size, "kwestia rysowana czcionką tekstu (Garamond)")
	_cleanup(layer, root)

func test_guard_break_plays_its_own_sound(root: Node) -> void:
	var player: Player = load("res://entities/player.tscn").instantiate()
	root.add_child(player)
	player.global_position = Vector2(500.0, 500.0)
	player._shield_up = true
	player._shield_dir = Vector2.RIGHT
	player._shield_time = 1.0
	player.stamina = 1.0
	var before := root.get_child_count()
	player.take_damage(20.0, player.global_position + Vector2(80.0, 0.0))
	var found := false
	for i in range(before, root.get_child_count()):
		var n := root.get_child(i)
		if n is AudioStreamPlayer2D and is_equal_approx(n.pitch_scale, Player.GUARD_BREAK_PITCH):
			found = true
			_cleanup(n, root)
			break
	NemoraxTest.assert_true(found, "przełamanie gardy ma osobny, niski dźwięk (nie ucina go dźwięk bólu)")
	_cleanup(player, root)

func test_music_ducks_and_recovers(root: Node) -> void:
	var music := AudioStreamPlayer.new()
	root.add_child(music)
	music.add_to_group(Juice.MUSIC_GROUP)
	Juice.music_duck_db = Juice.MUSIC_DUCK_DB
	NemoraxTest.assert_almost_eq(music.volume_db, Juice.MUSIC_DUCK_DB, 0.01, "telegraf ścisza muzykę")
	Juice.music_duck_db = 0.0
	NemoraxTest.assert_almost_eq(music.volume_db, 0.0, 0.01, "muzyka wraca do pełnej głośności")
	var bus := AudioServer.get_bus_index("Music")
	var bus_db := AudioServer.get_bus_volume_db(bus)
	Juice.duck_music(0.1)
	NemoraxTest.assert_almost_eq(AudioServer.get_bus_volume_db(bus), bus_db, 0.001, "ściszanie nie rusza głośności busa (ustawienie gracza)")
	Juice._duck_tween.kill()
	Juice.music_duck_db = 0.0
	_cleanup(music, root)

func test_boss_ring_is_runic_and_turns(root: Node) -> void:
	var boss: Boss = load("res://entities/boss.tscn").instantiate()
	root.add_child(boss)
	var p: Player = load("res://entities/player.tscn").instantiate()
	root.add_child(p)
	boss.player = p
	p.global_position = boss.global_position + Vector2(600.0, 0.0)
	var a0 := boss._rune_ring_angle
	boss._physics_process(0.5)
	NemoraxTest.assert_true(boss._rune_ring_angle > a0, "krąg runiczny powoli się obraca")
	NemoraxTest.assert_true(Boss.RUNE_RING_SEGMENTS >= 8, "krąg dzielony na łuki z przerwami, nie pełny okrąg")
	_cleanup(p, root)
	_cleanup(boss, root)

func test_same_sound_does_not_stack_into_noise(root: Node) -> void:
	var stream: AudioStream = load("res://assets/audio/sfx/p0/ENEMY_HIT_1.wav")
	var before := root.get_child_count()
	for i in 6:
		Juice.play_sfx_at(stream, Vector2.ZERO)
	var made: Array = []
	for i in range(before, root.get_child_count()):
		if root.get_child(i) is AudioStreamPlayer2D:
			made.append(root.get_child(i))
	NemoraxTest.assert_eq(made.size(), Juice.MAX_SAME_SFX, "najwyżej 3 kopie tego samego dźwięku naraz")
	NemoraxTest.assert_true(made[2].volume_db < made[0].volume_db, "kolejne kopie są cichsze")
	for n in made:
		_cleanup(n, root)
	NemoraxTest.assert_true(not Juice._active_sfx.has(stream), "licznik zwalnia się po usunięciu dźwięku")
