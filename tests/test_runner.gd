extends SceneTree
## Uruchamiane: godot --headless --script res://tests/test_runner.gd
## Odkrywa wszystkie tests/test_*.gd (poza sobą i test_util.gd), woła każdą
## metodę zaczynającą się od "test_" w każdym z nich (sygnatura: func
## test_xxx(root: Node) -> void — root to SceneTree.root, dla testów którym
## potrzebny jest żywy węzeł, np. instancja Playera/Areny), zlicza PASS/FAIL.
##
## _initialize() (nie _init()) — SceneTree.root musi być w pełni gotowe zanim
## testy dodające węzły do drzewa zaczną działać; _init() odpala za wcześnie.
## Dodatkowo: pierwszy add_child() wywołany z _initialize() wchodzi PRZED
## pierwszą klatką głównej pętli, więc _ready()/@onready dzieci jeszcze się
## nie propaguje synchronicznie (węzeł już jest w drzewie, ale bez _ready()) —
## jedno await process_frame na starcie naprawia to raz na cały przebieg;
## kolejne add_child() wewnątrz testów działają już normalnie/synchronicznie.

func _initialize() -> void:
	await process_frame
	# room.tscn odpala prolog (GameFlow.has_seen_prolog()) samo z siebie w
	# _ready() dla pokoju typu START — bez tej izolacji KAŻDY test ładujący
	# świeży room.tscn (dziesiątki w tym zestawie) ryzykowałby przypadkowe
	# odpalenie cutscenki i spauzowanie drzewa jako efekt uboczny, niezależnie
	# od tego, czego dany test faktycznie dotyczy. Osobna, tymczasowa ścieżka
	# (nie realny zapis użytkownika) + od razu oznaczone jako "widziany".
	# get_node("/root/GameFlow"), NIE identyfikator `GameFlow` wprost — ten
	# plik jest samym argumentem --script, więc kompiluje się PRZED
	# zarejestrowaniem autoloadów jako globalnych identyfikatorów (ten sam,
	# ustalony wcześniej w tej sesji problem co bezpośrednie odwołania do
	# Juice/GameFlow w innych plikach --script; load()-owane pliki testowe
	# wewnątrz _initialize() nie mają tego problemu, bo kompilują się później).
	var game_flow: Node = root.get_node("GameFlow")
	game_flow.PERSISTENT_SAVE_PATH = "user://test_persistent_progress.json"
	# To samo dla zapisu BIEŻĄCEGO przebiegu: reset_run(), clear_current_room(),
	# skrzynie, ołtarz itd. w testach zapisywały dotąd prawdziwy
	# user://gauntlet_progress.json gracza przy każdym uruchomieniu zestawu.
	game_flow.SAVE_PATH = "user://test_gauntlet_progress.json"
	game_flow.mark_prolog_seen()
	var passed := 0
	var failed := 0
	var dir := DirAccess.open("res://tests")
	var file_names := dir.get_files()
	file_names.sort() # deterministyczna kolejność między uruchomieniami
	for file_name in file_names:
		if not file_name.begins_with("test_") or not file_name.ends_with(".gd"):
			continue
		if file_name == "test_runner.gd" or file_name == "test_util.gd":
			continue
		var script: GDScript = load("res://tests/%s" % file_name)
		var instance = script.new()
		for method in script.get_script_method_list():
			if not method.name.begins_with("test_"):
				continue
			NemoraxTest.reset()
			instance.call(method.name, root)
			if NemoraxTest.last_failed:
				failed += 1
				print("[FAIL] %s.%s" % [file_name, method.name])
			else:
				passed += 1
				print("[ OK ] %s.%s" % [file_name, method.name])
	print("--- %d passed, %d failed ---" % [passed, failed])
	quit(1 if failed > 0 else 0)
