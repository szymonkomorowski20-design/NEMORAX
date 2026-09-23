extends RefCounted
## _update_visuals() (player.gd) — każda poza bojowa ma od Fazy 3-5 pełne 5
## kątów (PLAN_ANIMACJE_KIERUNKOWE.md), więc te testy sprawdzają, że każda
## poza czyta WŁAŚCIWE źródło kierunku (mysz dla akcji bojowych, WASD dla
## chodu/dasha) i trafia do właściwego wariantu/flip_h, nie że zawsze
## pokazuje "front" (to sprawdza tests/test_facing.gd na samym Facing.resolve()).

func _fresh_player(root: Node) -> Player:
	var player: Player = load("res://entities/player.tscn").instantiate()
	root.add_child(player)
	return player

func _cleanup(player: Player, root: Node) -> void:
	root.remove_child(player)
	player.queue_free()

func test_death_pose_faces_last_move_direction_source(root: Node) -> void:
	var player := _fresh_player(root)
	player.state = Player.State.DEAD
	player._last_move_direction = Vector2(0.0, -1.0) # w górę -> bucket "back"
	player._update_visuals()
	NemoraxTest.assert_eq(player.sprite.texture, Player.TEX_DEATH_BACK, "śmierć w górę powinna pokazać player_death_back.png")
	NemoraxTest.assert_eq(player.sprite.flip_h, false, "back nigdy nie jest odbite")
	_cleanup(player, root)

func test_hit_flash_faces_last_move_direction_source(root: Node) -> void:
	var player := _fresh_player(root)
	player._flash_frames = 2
	player._last_move_direction = Vector2(-1.0, 0.0) # w lewo -> bucket "side", bez odbicia
	player._update_visuals()
	NemoraxTest.assert_eq(player.sprite.texture, Player.TEX_HIT_SIDE, "błysk trafienia w lewo powinien pokazać player_hit_side.png")
	NemoraxTest.assert_eq(player.sprite.flip_h, false, "side w lewo nie jest odbite")
	_cleanup(player, root)

func test_block_pose_faces_shield_direction_source(root: Node) -> void:
	var player := _fresh_player(root)
	player._block_visual_timer = 0.1
	player._shield_dir = Vector2(0.0, 1.0) # w dół -> bucket "front"
	player._update_visuals()
	NemoraxTest.assert_eq(player.sprite.texture, Player.TEX_BLOCK, "blok w dół powinien pokazać player_block.png")
	NemoraxTest.assert_eq(player.sprite.flip_h, false, "front nigdy nie jest odbite")
	_cleanup(player, root)

## Trzymana tarcza (Paczka 3) trzyma pozę bloku przez cały czas, nie 0,15 s.
func test_held_shield_keeps_block_pose_toward_shield(root: Node) -> void:
	var player := _fresh_player(root)
	player._shield_up = true
	player._shield_dir = Vector2(0.0, -1.0) # w górę -> "back"
	player._attack_direction = Vector2(0.0, 1.0) # celowo inny kierunek — nie ten ma decydować
	player._update_visuals()
	NemoraxTest.assert_eq(player.sprite.texture, Player.TEX_BLOCK_BACK, "tarcza w górę powinna pokazać player_block_back.png")
	_cleanup(player, root)

func test_heal_pose_faces_attack_direction_source(root: Node) -> void:
	var player := _fresh_player(root)
	player._heal_visual_timer = 0.1
	player._attack_direction = Vector2(0.0, 1.0) # w dół -> bucket "front"
	player._update_visuals()
	NemoraxTest.assert_eq(player.sprite.texture, Player.TEX_HEAL, "leczenie w dół powinno pokazać player_heal.png")
	_cleanup(player, root)

func test_dash_pose_faces_dash_direction_source(root: Node) -> void:
	var player := _fresh_player(root)
	player.state = Player.State.DASHING
	player._dash_direction = Vector2(-1.0, 0.0) # w lewo -> bucket "side", bez odbicia
	player._update_visuals()
	NemoraxTest.assert_eq(player.sprite.texture, Player.TEX_DASH_SIDE, "dash w lewo powinien pokazać player_dash_side.png")
	NemoraxTest.assert_eq(player.sprite.flip_h, false, "side w lewo nie jest odbite")
	_cleanup(player, root)

func test_dash_afterimage_copies_actual_character_pose(root: Node) -> void:
	var player := _fresh_player(root)
	player.state = Player.State.DASHING
	player._dash_direction = Vector2(1.0, 0.0)
	player._spawn_trail_ghost()
	var ghost: Sprite2D = player.get_child(player.get_child_count() - 1) as Sprite2D
	NemoraxTest.assert_true(ghost != null, "dash powinien utworzyć kopię postaci")
	NemoraxTest.assert_eq(ghost.texture, Player.TEX_DASH_SIDE, "powidok w prawo powinien używać pozy dasha z boku")
	NemoraxTest.assert_eq(ghost.flip_h, true, "powidok powinien odbić pozę zgodnie z kierunkiem")
	NemoraxTest.assert_eq(ghost.scale, player.sprite.scale, "powidok musi mieć rozmiar postaci")
	NemoraxTest.assert_true(ghost.top_level, "powidok ma pozostać w miejscu, gdy gracz odjedzie")
	NemoraxTest.assert_true(ghost.modulate.a < 0.5, "powidok nie może zasłaniać gracza")
	_cleanup(player, root)

func test_sword_windup_and_active_face_attack_direction_source(root: Node) -> void:
	var player := _fresh_player(root)
	player._swing_weapon = "sword"
	player._attack_direction = Vector2(1.0, 0.0) # w prawo -> bucket "side", odbite
	player._attack_phase = "windup"
	player._update_visuals()
	NemoraxTest.assert_eq(player.sprite.texture, Player.TEX_SWORD_WINDUP_SIDE, "zamach mieczem w prawo powinien pokazać player_sword_windup_side.png")
	NemoraxTest.assert_eq(player.sprite.flip_h, true, "side w prawo jest odbite")

	player._attack_phase = "active"
	player._update_visuals()
	NemoraxTest.assert_eq(player.sprite.texture, Player.TEX_SWORD_ACTIVE_SIDE, "cięcie mieczem w prawo powinno pokazać player_sword_active_side.png")
	_cleanup(player, root)

func test_wand_windup_and_fire_use_wand_textures(root: Node) -> void:
	var player := _fresh_player(root)
	player._swing_weapon = "wand"
	player._attack_direction = Vector2(0.0, -1.0) # w górę -> bucket "back"
	player._attack_phase = "windup"
	player._update_visuals()
	NemoraxTest.assert_eq(player.sprite.texture, Player.TEX_WAND_WINDUP_BACK, "naciąganie różdżki w górę powinno pokazać player_wand_windup_back.png")

	player._attack_phase = "recovery"
	player._update_visuals()
	NemoraxTest.assert_eq(player.sprite.texture, Player.TEX_WAND_FIRE_BACK, "recovery różdżki w górę powinno nadal pokazywać player_wand_fire_back.png")
	_cleanup(player, root)

func test_idle_pose_faces_last_move_direction_source(root: Node) -> void:
	var player := _fresh_player(root)
	player.velocity = Vector2.ZERO
	player._last_move_direction = Vector2(1.0, 0.0) # w prawo -> bucket "side", odbite
	player._update_visuals()
	NemoraxTest.assert_eq(player.sprite.texture, Player.TEX_BASE_SIDE, "stanie w miejscu w prawo powinno pokazać player_base_side.png")
	NemoraxTest.assert_eq(player.sprite.flip_h, true, "side w prawo jest odbite")
	_cleanup(player, root)
