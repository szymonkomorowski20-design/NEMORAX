extends RefCounted
## ui/ui.gd — logika HUD niezależna od _draw()/rysowania (nie da się jej
## sensownie sprawdzić zrzutem ekranu w tym zestawie testów, więc pokrywane
## tutaj wprost). Krok 7 (TERAZ_DLA_CLAUDE_ARENA_UI_I_FEELING.md): "mapa
## pamięci" zamiast tęczy Palette.PHASE_COLORS na minimapie, cień utraconego
## HP na pasku gracza.

## ui.tscn ma ROOT "UILayer" (CanvasLayer) — skrypt GameUI siedzi na DZIECKU
## "UI" (Control), dokładnie jak arena.gd go pobiera (@onready var ui:
## GameUI = $UILayer/UI), nie na samym roocie sceny.
func _fresh_ui(root: Node) -> GameUI:
	var ui_layer: Node = load("res://ui/ui.tscn").instantiate()
	root.add_child(ui_layer)
	return ui_layer.get_node("UI") as GameUI

func _fresh_player(root: Node) -> Player:
	var player: Player = load("res://entities/player.tscn").instantiate()
	root.add_child(player)
	return player

func _cleanup(node: Node, root: Node) -> void:
	root.remove_child(node)
	node.queue_free()

## `ui` (GameUI) nie jest bezpośrednim dzieckiem `root` — jego rodzicem jest
## UILayer (CanvasLayer), TO jest bezpośrednie dziecko `root` (patrz _fresh_ui).
func _cleanup_ui(ui: GameUI, root: Node) -> void:
	var layer := ui.get_parent()
	root.remove_child(layer)
	layer.queue_free()

func test_minimap_pip_color_dark_for_ordinary_visited_room(root: Node) -> void:
	var ui := _fresh_ui(root)
	var color: Color = ui._minimap_pip_color({"type": GameFlow.RoomType.RANDOM, "cleared": true}, true, false)
	NemoraxTest.assert_true(color.is_equal_approx(GameUI.MINIMAP_VISITED_COLOR), "zwykły odwiedzony pokój powinien być ciemny, nie kolorowy")
	_cleanup_ui(ui, root)

func test_minimap_pip_color_teal_for_current_room_regardless_of_type(root: Node) -> void:
	var ui := _fresh_ui(root)
	var color: Color = ui._minimap_pip_color({"type": GameFlow.RoomType.SOUL, "chapter": 3, "cleared": false}, true, true)
	NemoraxTest.assert_true(color.is_equal_approx(Palette.PLAYER_BODY), "bieżący pokój powinien być turkusowy niezależnie od typu")
	_cleanup_ui(ui, root)

## Dawniej SOUL dostawał Palette.PHASE_COLORS[chapter] — inny kolor na każdy z
## 6 rozdziałów duszy (tęcza). Dokument wprost każe to usunąć na rzecz "mapy
## pamięci": jedyna pozostała wskazówka o nieodebranej duszy to cienka
## obwódka (rysowana osobno w _draw_minimap, nie w tej funkcji).
func test_minimap_pip_color_soul_room_no_longer_uses_rainbow_phase_colors(root: Node) -> void:
	var ui := _fresh_ui(root)
	var color: Color = ui._minimap_pip_color({"type": GameFlow.RoomType.SOUL, "chapter": 5, "cleared": true}, true, false)
	NemoraxTest.assert_true(color.is_equal_approx(GameUI.MINIMAP_VISITED_COLOR), "SOUL powinien wyglądać jak każdy inny odwiedzony pokój")
	_cleanup_ui(ui, root)

func test_minimap_pip_color_altar_is_the_only_accent(root: Node) -> void:
	var ui := _fresh_ui(root)
	var color: Color = ui._minimap_pip_color({"type": GameFlow.RoomType.ALTAR}, true, false)
	NemoraxTest.assert_true(not color.is_equal_approx(GameUI.MINIMAP_VISITED_COLOR), "Ołtarz to jedyny 'cel/boss' na mapie — musi się wizualnie wyróżniać")
	_cleanup_ui(ui, root)

## Krok 7: "pasek ma pokazywać zmianę utraconego HP przez chwilowy cień
## starej wartości" — cień dogania SPADEK stopniowo (obrażenia mają wagę), ale
## skacze w górę natychmiast przy WZROŚCIE (leczenie nie dostaje efektu cienia).
func test_player_hp_shadow_lags_behind_damage_but_snaps_up_on_heal(root: Node) -> void:
	var ui := _fresh_ui(root)
	var player := _fresh_player(root)
	ui.player = player
	ui._update_bars(0.0) # ustala punkt startowy cienia na pełnym HP

	player.health = player.max_health * 0.5
	ui._update_bars(0.1) # mały krok czasu — cień NIE powinien jeszcze dogonić
	NemoraxTest.assert_true(ui._player_hp_shadow_ratio > 0.5, "cień powinien zostać w tyle zaraz po obrażeniach")

	ui._update_bars(10.0) # dużo czasu — cień powinien dogonić spadek
	NemoraxTest.assert_almost_eq(ui._player_hp_shadow_ratio, 0.5, 0.01, "po dłuższej chwili cień powinien dogonić prawdziwe HP")

	player.health = player.max_health * 0.9 # leczenie
	ui._update_bars(0.0) # zero czasu — a mimo to cień ma skoczyć w górę NATYCHMIAST
	NemoraxTest.assert_almost_eq(ui._player_hp_shadow_ratio, 0.9, 0.01, "leczenie nie powinno zostawiać cienia — skok w górę natychmiastowy")

	_cleanup(player, root)
	_cleanup_ui(ui, root)

## Krok 9: "panel: ZOSTAŁEŚ ODRZUCONY / inny wybrany tekst świata, przyczyna
## lub pokój, przyciski: spróbuj ponownie / menu" — wspólne formatowanie dla
## arena.gd (reason="Próba: N") i room.gd (reason=nazwa pokoju albo "").
func test_show_death_overlay_includes_reason_and_both_buttons(root: Node) -> void:
	var ui := _fresh_ui(root)
	ui.show_death_overlay("Próba: 3")
	NemoraxTest.assert_true("Zostałeś odrzucony" in ui._overlay_text, "panel powinien mieć tytuł świata, nie gołe 'Zginąłeś'")
	NemoraxTest.assert_true("Próba: 3" in ui._overlay_text, "panel powinien pokazać przekazaną przyczynę")
	NemoraxTest.assert_true("spróbuj ponownie" in ui._overlay_text, "panel musi wspominać opcję ponowienia")
	NemoraxTest.assert_true("wyjdź do menu" in ui._overlay_text, "panel musi wspominać opcję wyjścia do menu")
	_cleanup_ui(ui, root)

func test_show_death_overlay_without_reason_omits_blank_reason_line(root: Node) -> void:
	var ui := _fresh_ui(root)
	ui.show_death_overlay("")
	NemoraxTest.assert_true("Zostałeś odrzucony" in ui._overlay_text, "panel bez przyczyny powinien wciąż pokazać tytuł")
	NemoraxTest.assert_eq(ui._overlay_text.count("\n\n\n"), 0, "brak przyczyny nie powinien zostawiać potrójnej pustej linii")
	_cleanup_ui(ui, root)
