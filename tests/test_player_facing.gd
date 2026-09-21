extends RefCounted
## _update_visuals() (player.gd) po przejściu na Facing.resolve() dla WSZYSTKICH
## póz (Fazy 3-5, PLAN_ANIMACJE_KIERUNKOWE.md) — dziś każda poza ma tylko
## "front", więc to musi wyglądać DOKŁADNIE tak samo jak przed refaktorem:
## właściwa tekstura, NIGDY nie odbita, niezależnie od kierunku myszy/ruchu.

func _fresh_player(root: Node) -> Player:
	var player: Player = load("res://entities/player.tscn").instantiate()
	root.add_child(player)
	return player

func _cleanup(player: Player, root: Node) -> void:
	root.remove_child(player)
	player.queue_free()

func test_death_pose_shows_front_texture_never_flipped(root: Node) -> void:
	var player := _fresh_player(root)
	player.state = Player.State.DEAD
	player._last_move_direction = Vector2(1.0, 0.0) # w prawo -> bucket "side" -> ryzyko flipa
	player._update_visuals()
	NemoraxTest.assert_eq(player.sprite.texture, Player.TEX_DEATH, "śmierć powinna pokazać player_death.png")
	NemoraxTest.assert_eq(player.sprite.flip_h, false, "brak grafiki kierunkowej -> nigdy nie odbite")
	_cleanup(player, root)

func test_hit_flash_shows_front_texture_never_flipped(root: Node) -> void:
	var player := _fresh_player(root)
	player._flash_frames = 2
	player._last_move_direction = Vector2(1.0, 0.0)
	player._update_visuals()
	NemoraxTest.assert_eq(player.sprite.texture, Player.TEX_HIT, "błysk trafienia powinien pokazać player_hit.png")
	NemoraxTest.assert_eq(player.sprite.flip_h, false, "brak grafiki kierunkowej -> nigdy nie odbite")
	_cleanup(player, root)

func test_block_pose_faces_attack_direction_source(root: Node) -> void:
	var player := _fresh_player(root)
	player._block_visual_timer = 0.1
	player._attack_direction = Vector2(1.0, 0.0)
	player._update_visuals()
	NemoraxTest.assert_eq(player.sprite.texture, Player.TEX_BLOCK, "blok powinien pokazać player_block.png")
	NemoraxTest.assert_eq(player.sprite.flip_h, false, "brak grafiki kierunkowej -> nigdy nie odbite")
	_cleanup(player, root)

func test_heal_pose_shows_front_texture(root: Node) -> void:
	var player := _fresh_player(root)
	player._heal_visual_timer = 0.1
	player._update_visuals()
	NemoraxTest.assert_eq(player.sprite.texture, Player.TEX_HEAL, "leczenie powinno pokazać player_heal.png")
	_cleanup(player, root)

func test_dash_pose_faces_dash_direction_source(root: Node) -> void:
	var player := _fresh_player(root)
	player.state = Player.State.DASHING
	player._dash_direction = Vector2(-1.0, 0.0)
	player._update_visuals()
	NemoraxTest.assert_eq(player.sprite.texture, Player.TEX_DASH, "dash powinien pokazać player_dash.png")
	NemoraxTest.assert_eq(player.sprite.flip_h, false, "brak grafiki kierunkowej -> nigdy nie odbite")
	_cleanup(player, root)

func test_sword_windup_and_active_face_attack_direction_source(root: Node) -> void:
	var player := _fresh_player(root)
	player._swing_weapon = "sword"
	player._attack_phase = "windup"
	player._update_visuals()
	NemoraxTest.assert_eq(player.sprite.texture, Player.TEX_SWORD_WINDUP, "zamach mieczem powinien pokazać player_sword_windup.png")

	player._attack_phase = "active"
	player._update_visuals()
	NemoraxTest.assert_eq(player.sprite.texture, Player.TEX_SWORD_ACTIVE, "cięcie mieczem powinno pokazać player_sword_active.png")
	_cleanup(player, root)

func test_wand_windup_and_fire_use_wand_textures(root: Node) -> void:
	var player := _fresh_player(root)
	player._swing_weapon = "wand"
	player._attack_phase = "windup"
	player._update_visuals()
	NemoraxTest.assert_eq(player.sprite.texture, Player.TEX_WAND_WINDUP, "naciąganie różdżki powinno pokazać player_wand_windup.png")

	player._attack_phase = "recovery"
	player._update_visuals()
	NemoraxTest.assert_eq(player.sprite.texture, Player.TEX_WAND_FIRE, "recovery różdżki powinno nadal pokazywać player_wand_fire.png")
	_cleanup(player, root)

func test_idle_pose_faces_last_move_direction_source(root: Node) -> void:
	var player := _fresh_player(root)
	player.velocity = Vector2.ZERO
	player._last_move_direction = Vector2(1.0, 0.0)
	player._update_visuals()
	NemoraxTest.assert_eq(player.sprite.texture, Player.TEX_BASE, "stanie w miejscu powinno pokazać player_base.png")
	NemoraxTest.assert_eq(player.sprite.flip_h, false, "brak grafiki kierunkowej -> nigdy nie odbite")
	_cleanup(player, root)
