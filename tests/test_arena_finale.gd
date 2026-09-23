extends RefCounted
## Sekwencja finałowa (arena.gd, po kolapsie dużej formy Nemoraksa):
## - drwina bossa skalowana `deaths` (FABULA_I_DIALOGI.md sekcja 3.5)
## - reguła 7 (Odwrócenie) jako OKRESOWY cykl, nie trwałe ustawienie
## Obie części testowane wprost (wywołanie funkcji), bez czekania na realne
## sekundy — ta sama konwencja co reszta menu/ekranów w tym projekcie.

func _fresh_arena(root: Node) -> Node:
	var arena = load("res://arena.tscn").instantiate()
	arena.SAVE_PATH = "user://test_arena_finale.json" # przed add_child(), zanim _ready() zdąży odczytać prawdziwy zapis
	root.add_child(arena)
	return arena

func _cleanup(arena: Node, root: Node) -> void:
	root.remove_child(arena)
	arena.queue_free()

func test_finale_taunt_matches_canonical_early_tiers(root: Node) -> void:
	var arena := _fresh_arena(root)
	arena.deaths = 0
	NemoraxTest.assert_eq(arena._finale_taunt_text(), "Czy pamiętasz, ile razy już mnie pokonałeś?", "deaths<3 powinno dać oryginalny, kanoniczny tekst")
	arena.deaths = 5
	NemoraxTest.assert_eq(arena._finale_taunt_text(), "Czy pamiętasz, ile razy już mnie pokonałeś? Bo ja pamiętam każdy.", "deaths 3-9 powinno dać drugi kanoniczny tekst")
	_cleanup(arena, root)

## Każdy próg 10-89 powinien dać SWÓJ, różny tekst — nie ma sensu wypisywać
## wszystkich dziesięciu osobno, ale sama różnorodność (drwina faktycznie się
## zmienia, nie zamraża po 10) jest tym, co autor prosił o dodanie.
func test_finale_taunt_has_a_distinct_line_for_every_ten_deaths_up_to_100(root: Node) -> void:
	var arena := _fresh_arena(root)
	var seen_lines: Dictionary = {}
	for death_count in [0, 5, 15, 25, 35, 45, 55, 65, 75, 85, 95]:
		arena.deaths = death_count
		var line: String = arena._finale_taunt_text()
		NemoraxTest.assert_true(line != "", "każdy próg powinien mieć niepusty tekst (deaths=%d)" % death_count)
		seen_lines[line] = true
	NemoraxTest.assert_eq(seen_lines.size(), 11, "11 progów od 0 do 95 powinno dać 11 RÓŻNYCH linii, nie powtórki")
	_cleanup(arena, root)

func test_finale_taunt_reaches_a_stable_final_line_at_100_and_beyond(root: Node) -> void:
	var arena := _fresh_arena(root)
	arena.deaths = 100
	var at_100: String = arena._finale_taunt_text()
	arena.deaths = 250
	var at_250: String = arena._finale_taunt_text()
	NemoraxTest.assert_eq(at_100, arena.FINALE_TAUNT_AT_100, "deaths=100 powinno dać ostatnią, stałą linię")
	NemoraxTest.assert_eq(at_250, at_100, "powyżej 100 tekst powinien zostać ten sam, nie rosnąć w nieskończoność")
	_cleanup(arena, root)

## Reguła 7 (Odwrócenie): dawniej player.input_reversed = true na resztę
## walki. Teraz ma być okresowa — ten test to właśnie ta różnica: cykl zaczyna
## się OD sterowania normalnego, a input_reversed faktycznie skacze
## true/false/true na kolejnych przejściach timera, nie tylko raz.
func test_reversal_cycle_toggles_input_reversed_periodically(root: Node) -> void:
	var arena := _fresh_arena(root)
	arena._start_reversal_cycle()
	NemoraxTest.assert_true(not arena.player.input_reversed, "cykl powinien zaczynać się od sterowania normalnego")

	arena._on_reversal_timer_timeout() # koniec pierwszego okresu normalnego
	NemoraxTest.assert_true(arena.player.input_reversed, "pierwsze przejście timera powinno włączyć odwrócenie")

	arena._on_reversal_timer_timeout() # koniec epizodu odwrócenia
	NemoraxTest.assert_true(not arena.player.input_reversed, "drugie przejście timera powinno wrócić do normalnego sterowania")

	arena._on_reversal_timer_timeout() # cykl się powtarza, nie kończy po jednym okrążeniu
	NemoraxTest.assert_true(arena.player.input_reversed, "cykl powinien się powtarzać, nie zatrzymywać po jednym okrążeniu")
	_cleanup(arena, root)

## Koniec walki (śmierć/zwycięstwo) musi przerwać cykl — inaczej sterowanie
## zostałoby odwrócone (albo w połowie przełączania) na ekranie game-over.
func test_reversal_cycle_stops_once_battle_is_over(root: Node) -> void:
	var arena := _fresh_arena(root)
	arena._start_reversal_cycle()
	arena._on_reversal_timer_timeout() # wejście w epizod odwrócenia
	NemoraxTest.assert_true(arena.player.input_reversed, "powinniśmy być w trakcie epizodu odwrócenia przed końcem walki")

	arena._battle_over = true
	arena._on_reversal_timer_timeout()
	NemoraxTest.assert_true(arena.player.input_reversed, "po _battle_over kolejne wywołanie nie powinno już nic przełączać")
	_cleanup(arena, root)
