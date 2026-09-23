extends RefCounted
## A4: margines ruchu przy ścianie liczony z sylwetki nie może wypchnąć wroga
## poza zasięg kontaktu z graczem przyklejonym do tej samej ściany — inaczej
## ściana staje się bezpieczną strefą (tak było przez chwilę z wcieleniami:
## radius 95, margines z płótna 138 px).

const ARENA := Rect2(90, 60, 1100, 600)
const ENEMY_SCENES := [
	"res://entities/incarnations/zalazek.tscn",
	"res://entities/incarnations/cisza_incarnation.tscn",
	"res://entities/incarnations/zwloka_incarnation.tscn",
	"res://entities/incarnations/ciezar_incarnation.tscn",
	"res://entities/incarnations/glod_incarnation.tscn",
	"res://entities/incarnations/zacmienie_incarnation.tscn",
	"res://entities/random_enemies/tank.tscn",
	"res://entities/random_enemies/charger.tscn",
	"res://entities/random_enemies/summoner.tscn",
	"res://entities/random_enemies/chaser.tscn",
]

## Sam _clamp_to_arena() był poprawny, ale pościg wręcz (Incarnation) i dryf
## bossa w ogóle go nie wołały — wróg goniący gracza przy dolnej ścianie
## wchodził sylwetką w mur. Test na RUCHU, nie na samej funkcji.
func test_chasing_player_at_bottom_wall_stays_inside_visual_margin(root: Node) -> void:
	var player = load("res://entities/player.tscn").instantiate()
	root.add_child(player)
	player.global_position = Vector2(ARENA.get_center().x, ARENA.end.y - player.radius)
	for path in ENEMY_SCENES + ["res://entities/boss.tscn"]:
		var enemy = load(path).instantiate()
		enemy.arena_rect = ARENA
		enemy.global_position = ARENA.get_center()
		root.add_child(enemy)
		enemy.player = player
		enemy._update_sprite_state()
		if "keep_distance_range" in enemy and enemy.keep_distance_range >= 0.0:
			root.remove_child(enemy)
			enemy.queue_free()
			continue
		for i in range(300):
			enemy._drift_towards_player(0.05)
		var limit: float = ARENA.end.y - enemy._visual_margin().y
		NemoraxTest.assert_true(enemy.global_position.y <= limit + 0.01,
			"%s: pościg przy dolnej ścianie wyszedł poza margines (y=%.0f > %.0f)" % [path.get_file(), enemy.global_position.y, limit])
		root.remove_child(enemy)
		enemy.queue_free()
	root.remove_child(player)
	player.queue_free()

func test_every_enemy_reaches_player_hugging_each_wall(root: Node) -> void:
	var player = load("res://entities/player.tscn").instantiate()
	root.add_child(player)
	for path in ENEMY_SCENES:
		var enemy = load(path).instantiate()
		enemy.arena_rect = ARENA
		enemy.global_position = ARENA.get_center()
		root.add_child(enemy)
		enemy.player = player
		enemy._update_sprite_state()
		var reach: float = enemy.radius + player.radius
		var walls := {
			"góra": [Vector2(ARENA.get_center().x, ARENA.position.y + player.radius), Vector2(ARENA.get_center().x, ARENA.position.y - 500.0)],
			"dół": [Vector2(ARENA.get_center().x, ARENA.end.y - player.radius), Vector2(ARENA.get_center().x, ARENA.end.y + 500.0)],
			"lewo": [Vector2(ARENA.position.x + player.radius, ARENA.get_center().y), Vector2(ARENA.position.x - 500.0, ARENA.get_center().y)],
			"prawo": [Vector2(ARENA.end.x - player.radius, ARENA.get_center().y), Vector2(ARENA.end.x + 500.0, ARENA.get_center().y)],
		}
		for side in walls:
			var player_pos: Vector2 = walls[side][0]
			var enemy_pos: Vector2 = enemy._clamp_to_arena(walls[side][1])
			NemoraxTest.assert_true(enemy_pos.distance_to(player_pos) <= reach,
				"%s: przy ścianie %s gracz musi być w zasięgu kontaktu (%.0f > %.0f)" % [path.get_file(), side, enemy_pos.distance_to(player_pos), reach])
		var margin: Vector2 = enemy._visual_margin()
		NemoraxTest.assert_true(margin.x >= enemy.radius and margin.y >= enemy.radius, "%s: hitbox zawsze w arenie" % path.get_file())
		root.remove_child(enemy)
		enemy.queue_free()
	root.remove_child(player)
	player.queue_free()

func test_mordrath_reaches_player_without_entering_integrated_wall(root: Node) -> void:
	var playable := IntegratedRoomVisual.play_rect(ARENA)
	var player: Player = load("res://entities/player.tscn").instantiate()
	root.add_child(player)
	var enemy: Incarnation = load("res://entities/incarnations/cisza_incarnation.tscn").instantiate()
	enemy.arena_rect = playable
	root.add_child(enemy)
	enemy.player = player
	enemy._update_sprite_state()
	NemoraxTest.assert_true(enemy._visual_margin().y >= enemy.radius + player.radius + 8.0,
		"Mordrath potrzebuje dodatkowego odstępu od muru dla widocznych stóp")
	var positions := [
		Vector2(playable.get_center().x, playable.position.y + player.radius),
		Vector2(playable.get_center().x, playable.end.y - player.radius),
		Vector2(playable.position.x + player.radius, playable.get_center().y),
		Vector2(playable.end.x - player.radius, playable.get_center().y),
	]
	for player_pos in positions:
		player.global_position = player_pos
		enemy.global_position = playable.get_center()
		for i in range(300):
			enemy._drift_towards_player(0.05)
		var margin: Vector2 = enemy._visual_margin()
		NemoraxTest.assert_true(enemy.global_position.x >= playable.position.x + margin.x - 0.01,
			"Mordrath nie wchodzi w lewy zintegrowany mur")
		NemoraxTest.assert_true(enemy.global_position.x <= playable.end.x - margin.x + 0.01,
			"Mordrath nie wchodzi w prawy zintegrowany mur")
		NemoraxTest.assert_true(enemy.global_position.y >= playable.position.y + margin.y - 0.01,
			"Mordrath nie wchodzi w górny zintegrowany mur")
		NemoraxTest.assert_true(enemy.global_position.y <= playable.end.y - margin.y + 0.01,
			"Mordrath nie wchodzi w dolny zintegrowany mur")
		NemoraxTest.assert_true(enemy.global_position.distance_to(player_pos) <= enemy.radius + player.radius + 1.0,
			"Mordrath musi dosięgnąć gracza przy każdym z czterech murów")
	root.remove_child(enemy)
	enemy.queue_free()
	root.remove_child(player)
	player.queue_free()
