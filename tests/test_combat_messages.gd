extends RefCounted
## Krok 8 (komunikaty w walce, TERAZ_DLA_CLAUDE_ARENA_UI_I_FEELING.md /
## PLAN_UI_UX_NAGRODY_DLA_CLAUDE.md): Player.resource_denied (błąd/brak
## zasobu — "przy odpowiednim pasku HUD"), DamageNumber na obrażeniach
## OTRZYMYWANYCH i leczeniu (dotąd tylko obrażenia ZADAWANE miały liczbę —
## Second Impact, tests/test_upgrades.gd), i GameUI.show_upgrade_toast/
## flash_resource_denied (kanały niezależne od _center_message).

func _fresh_player(root: Node) -> Player:
	var player: Player = load("res://entities/player.tscn").instantiate()
	root.add_child(player)
	return player

func _fresh_ui(root: Node) -> GameUI:
	var ui_layer: Node = load("res://ui/ui.tscn").instantiate()
	root.add_child(ui_layer)
	return ui_layer.get_node("UI") as GameUI

func _cleanup(node: Node, root: Node) -> void:
	root.remove_child(node)
	node.queue_free()

func _cleanup_ui(ui: GameUI, root: Node) -> void:
	var layer := ui.get_parent()
	root.remove_child(layer)
	layer.queue_free()

func test_attack_denial_reports_stamina_for_sword(root: Node) -> void:
	var player := _fresh_player(root)
	player.current_weapon = "sword"
	player.stamina = 0.0
	var received: Array = []
	player.resource_denied.connect(func(kind): received.append(kind))

	Input.action_press("attack")
	player._handle_attack_input(0.0)
	Input.action_release("attack")

	NemoraxTest.assert_eq(received, ["stamina"], "brak staminy na atak mieczem powinien zgłosić 'stamina'")
	_cleanup(player, root)

func test_attack_denial_reports_mana_for_wand(root: Node) -> void:
	var player := _fresh_player(root)
	player.current_weapon = "wand"
	player.mana = 0.0
	player.stamina = player.max_stamina # miecz miałby stać go — sprawdzamy, że to broń decyduje, nie przypadkowy brak staminy
	var received: Array = []
	player.resource_denied.connect(func(kind): received.append(kind))

	Input.action_press("attack")
	player._handle_attack_input(0.0)
	Input.action_release("attack")

	NemoraxTest.assert_eq(received, ["mana"], "brak many na różdżkę powinien zgłosić 'mana', nie 'stamina'")
	_cleanup(player, root)

func test_attack_with_enough_resource_does_not_report_denial(root: Node) -> void:
	var player := _fresh_player(root)
	player.current_weapon = "sword"
	player.stamina = player.max_stamina
	var received: Array = []
	player.resource_denied.connect(func(kind): received.append(kind))

	Input.action_press("attack")
	player._handle_attack_input(0.0)
	Input.action_release("attack")

	NemoraxTest.assert_eq(received.size(), 0, "wystarczająca stamina nie powinna zgłaszać odmowy")
	_cleanup(player, root)

func test_block_denial_reports_stamina(root: Node) -> void:
	var player := _fresh_player(root)
	player.stamina = 0.0
	var received: Array = []
	player.resource_denied.connect(func(kind): received.append(kind))

	Input.action_press("block")
	player._handle_block_input()
	Input.action_release("block")

	NemoraxTest.assert_eq(received, ["stamina"], "brak staminy na blok powinien zgłosić 'stamina'")
	_cleanup(player, root)

func test_heal_denial_reports_heal(root: Node) -> void:
	var player := _fresh_player(root)
	player.set_heal_stacks(0)
	var received: Array = []
	player.resource_denied.connect(func(kind): received.append(kind))

	Input.action_press("heal")
	player._handle_heal_input()
	Input.action_release("heal")

	NemoraxTest.assert_eq(received, ["heal"], "brak stacków leczenia powinien zgłosić 'heal'")
	_cleanup(player, root)

## Dotąd take_damage() dawał tylko flash_white+hitstop — żadnej liczby przy
## samym graczu, w odróżnieniu od obrażeń ZADAWANYCH (Second Impact już to miało).
func test_take_damage_spawns_a_damage_number(root: Node) -> void:
	var player := _fresh_player(root)
	var children_before := root.get_child_count()
	player.take_damage(15.0)
	NemoraxTest.assert_true(root.get_child_count() > children_before, "obrażenia otrzymane powinny dodać widoczną liczbę obrażeń do sceny")
	_cleanup(player, root)

## Leczenie dotąd nie miało ŻADNEGO dowodu poza dźwiękiem i jaśniejszą ikonką
## (stan naładowania, nie sam moment użycia) — krok 8 wymaga liczby nad graczem.
func test_heal_use_spawns_a_positive_damage_number(root: Node) -> void:
	var player := _fresh_player(root)
	player.set_heal_stacks(1)
	player.max_health = 100.0
	player.health = 10.0
	var children_before := root.get_child_count()

	Input.action_press("heal")
	player._handle_heal_input()
	Input.action_release("heal")

	NemoraxTest.assert_true(root.get_child_count() > children_before, "użycie leczenia powinno dodać widoczną liczbę odzyskanego HP")
	NemoraxTest.assert_almost_eq(player.health, 60.0, 0.01, "sam efekt leczenia (50% max) nie powinien się zmienić przez dodanie liczby")
	_cleanup(player, root)

func test_show_relic_card_uses_separate_channel_from_center_message(root: Node) -> void:
	var ui := _fresh_ui(root)
	ui.show_form_name("Sovereignty") # górny środek — baner fazy bossa/pokoju
	ui.show_relic_card("second_impact") # dolny środek
	NemoraxTest.assert_true(ui._center_message == "Sovereignty", "baner fazy nie powinien zostać nadpisany przez kartę relikwii")
	NemoraxTest.assert_eq(ui._relic_card_id, "second_impact", "karta relikwii powinna trafić na SWÓJ kanał (dolny środek)")
	_cleanup_ui(ui, root)

## Krok 4: "ikona + nazwa + jedno zdanie efektu" dla WSZYSTKICH 10 relikwii —
## brakująca ikona/opis dla choćby jednej cofnęłoby audyt z tego samego kroku.
func test_all_ten_relics_have_an_icon_and_description(root: Node) -> void:
	var ui := _fresh_ui(root)
	for upgrade_id in Player.UPGRADE_IDS:
		NemoraxTest.assert_true(GameUI.RELIC_ICONS.has(upgrade_id), "brak ikony dla relikwii '%s'" % upgrade_id)
		NemoraxTest.assert_true(GameUI.RELIC_DESCRIPTIONS.has(upgrade_id), "brak opisu dla relikwii '%s'" % upgrade_id)
	_cleanup_ui(ui, root)

func test_show_relic_card_ignores_unknown_id(root: Node) -> void:
	var ui := _fresh_ui(root)
	ui.show_relic_card("nie_istnieje")
	NemoraxTest.assert_eq(ui._relic_card_id, "", "nieznane ID relikwii nie powinno nic pokazać")
	_cleanup_ui(ui, root)

func test_flash_resource_denied_only_affects_matching_kind(root: Node) -> void:
	var ui := _fresh_ui(root)
	ui.flash_resource_denied("stamina")
	var flashed := ui._resource_flash_modulate(Color.WHITE, "stamina")
	var unaffected := ui._resource_flash_modulate(Color.WHITE, "mana")
	NemoraxTest.assert_true(not flashed.is_equal_approx(Color.WHITE), "pasek staminy powinien być podświetlony zaraz po odmowie")
	NemoraxTest.assert_true(unaffected.is_equal_approx(Color.WHITE), "flash 'stamina' nie powinien dotykać paska many")
	_cleanup_ui(ui, root)

## "Krótki tytuł miejsca" (krok 8) — room.gd normalnie czyta typ pokoju z
## GameFlow, ale to globalny, współdzielony stan; ustawiamy _room_data wprost
## zamiast manipulować GameFlow.room_map/current_room_pos, żeby nie wyciekało
## do innych testów w tym samym przebiegu.
func test_room_display_name_for_each_type(root: Node) -> void:
	var room = load("res://rooms/room.tscn").instantiate()
	root.add_child(room)

	room._room_data = {"type": GameFlow.RoomType.RANDOM}
	NemoraxTest.assert_eq(room._room_display_name(), "Komnata", "RANDOM powinien pokazać generyczną nazwę")

	room._room_data = {"type": GameFlow.RoomType.SOUL, "chapter": 0}
	NemoraxTest.assert_eq(room._room_display_name(), GameFlow.INCARNATION_NAMES[0], "SOUL powinien pokazać imię wcielenia z tego rozdziału")

	room._room_data = {"type": GameFlow.RoomType.ALTAR}
	NemoraxTest.assert_eq(room._room_display_name(), "Ołtarz", "ALTAR powinien pokazać nazwę z LORE_I_ASSETY.md")

	room._room_data = {"type": GameFlow.RoomType.START}
	NemoraxTest.assert_eq(room._room_display_name(), "", "START nie powinien pokazywać banera (ma własny prolog)")

	_cleanup(room, root)
