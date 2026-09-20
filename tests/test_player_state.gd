extends RefCounted
## capture_player_state/apply_player_state (game_flow.gd) — round-trip pięciu
## pól migawki gracza. Player musi wejść do drzewa (root), żeby _ready()
## zainicjował health/stamina/manę z @export-ów przed nadpisaniem ich tutaj.

func test_player_state_round_trip(root: Node) -> void:
	var player: Player = load("res://entities/player.tscn").instantiate()
	root.add_child(player)

	player.health = 55.0
	player.stamina = 30.0
	player.mana = 12.0
	player.set_heal_charge_hits(7)
	player.current_weapon = "wand"

	GameFlow.capture_player_state(player)
	# capture_player_state pisze do GameFlow.saved_player_state — kopiujemy
	# migawkę natychmiast, żeby kolejne mutacje playera jej nie nadpisały.
	var snapshot: Dictionary = GameFlow.saved_player_state.duplicate()

	player.health = 1.0
	player.stamina = 1.0
	player.mana = 1.0
	player.set_heal_charge_hits(0)
	player.current_weapon = "sword"

	GameFlow.saved_player_state = snapshot
	GameFlow.apply_player_state(player)

	NemoraxTest.assert_eq(player.health, 55.0, "health po round-tripie")
	NemoraxTest.assert_eq(player.stamina, 30.0, "stamina po round-tripie")
	NemoraxTest.assert_eq(player.mana, 12.0, "mana po round-tripie")
	NemoraxTest.assert_eq(player.get_heal_charge_hits(), 7, "heal_charge_hits po round-tripie")
	NemoraxTest.assert_eq(player.current_weapon, "wand", "current_weapon po round-tripie")

	root.remove_child(player)
	player.queue_free()
	GameFlow.saved_player_state = {}
