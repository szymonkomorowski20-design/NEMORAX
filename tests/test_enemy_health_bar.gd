extends RefCounted
## Zdrowie przeciwników (TERAZ_DLA_CLAUDE_ARENA_UI_I_FEELING.md): zwykły wróg
## losowy chowa pasek do pierwszego trafienia i chowa go z powrotem po braku
## obrażeń; elita/miniboss mają pasek widoczny od startu walki na stałe.
## entities/enemy_health_bar.gd sprawdza is_elite/is_miniboss NA BIEŻĄCO w
## _process() (nie raz w configure()), bo oba ustawiają się PO tym, jak bazowe
## Incarnation._ready() już zdążyło skonfigurować pasek — stąd w testach
## poniżej jawne wywołanie _process() zamiast polegania samym stanem po
## add_child().

func _fresh_enemy(root: Node, scene_path: String) -> Incarnation:
	var enemy: Incarnation = load(scene_path).instantiate()
	root.add_child(enemy)
	enemy.arena_rect = Rect2(0, 0, 2000, 2000)
	return enemy

func _find_bar(enemy: Incarnation) -> EnemyHealthBar:
	for child in enemy.get_children():
		if child is EnemyHealthBar:
			return child
	return null

func _cleanup(enemy: Incarnation, root: Node) -> void:
	root.remove_child(enemy)
	enemy.queue_free()

func test_plain_enemy_health_bar_hidden_until_first_hit(root: Node) -> void:
	var enemy := _fresh_enemy(root, "res://entities/random_enemies/chaser.tscn")
	var bar := _find_bar(enemy)
	NemoraxTest.assert_true(bar != null, "Incarnation powinien dostać EnemyHealthBar w _ready()")
	bar._process(0.0)
	NemoraxTest.assert_true(not bar.visible, "zwykły wróg nie powinien pokazywać paska przed pierwszym trafieniem")

	enemy.take_damage(10.0)
	bar._process(0.0)
	NemoraxTest.assert_true(bar.visible, "pasek powinien pojawić się od razu po pierwszym trafieniu")
	_cleanup(enemy, root)

func test_plain_enemy_health_bar_fades_after_no_damage_window(root: Node) -> void:
	var enemy := _fresh_enemy(root, "res://entities/random_enemies/chaser.tscn")
	var bar := _find_bar(enemy)
	enemy.take_damage(10.0)
	bar._process(0.0)
	NemoraxTest.assert_true(bar.visible, "pasek powinien być widoczny zaraz po trafieniu")

	bar._process(EnemyHealthBar.FADE_AFTER_NO_DAMAGE + 0.1) # symuluje upływ czasu bez kolejnych obrażeń
	NemoraxTest.assert_true(not bar._shown, "pasek powinien zacząć znikać po oknie bez obrażeń (1,5-2,5s z dokumentu)")
	_cleanup(enemy, root)

func test_elite_enemy_health_bar_visible_from_start(root: Node) -> void:
	var enemy := _fresh_enemy(root, "res://entities/random_enemies/chaser.tscn")
	enemy.apply_elite_modifier()
	var bar := _find_bar(enemy)
	bar._process(0.0)
	NemoraxTest.assert_true(bar.visible, "elita powinna pokazywać pasek od startu walki, bez czekania na trafienie")

	bar._process(EnemyHealthBar.FADE_AFTER_NO_DAMAGE + 0.5)
	NemoraxTest.assert_true(bar.visible, "pasek elity nie powinien znikać mimo braku obrażeń")
	_cleanup(enemy, root)

func test_miniboss_health_bar_visible_from_start(root: Node) -> void:
	var enemy := _fresh_enemy(root, "res://entities/incarnations/zalazek.tscn")
	NemoraxTest.assert_true(enemy.is_miniboss, "wcielenia (Vhar'Nokh itd.) powinny mieć is_miniboss=true")
	var bar := _find_bar(enemy)
	bar._process(0.0)
	NemoraxTest.assert_true(bar.visible, "miniboss powinien pokazywać pasek od startu walki, bez czekania na trafienie")
	_cleanup(enemy, root)

func test_health_bar_shadow_trails_behind_real_health_after_damage(root: Node) -> void:
	var enemy := _fresh_enemy(root, "res://entities/random_enemies/chaser.tscn")
	var bar := _find_bar(enemy)
	bar._process(0.0)
	NemoraxTest.assert_almost_eq(bar._shadow_ratio, 1.0, 0.001, "cień powinien startować w pełni HP")

	enemy.take_damage(enemy.max_health * 0.5)
	bar._process(0.016) # jedna klatka — cień nie powinien jeszcze dogonić prawdziwego HP
	var ratio_now: float = enemy.health / enemy.max_health
	NemoraxTest.assert_true(bar._shadow_ratio > ratio_now, "cień powinien chwilowo zostać w tyle za spadkiem HP, żeby cios miał wagę")

	bar._process(10.0) # dużo czasu — cień powinien dogonić
	NemoraxTest.assert_almost_eq(bar._shadow_ratio, ratio_now, 0.001, "po dłuższej chwili cień powinien dogonić prawdziwe HP")
	_cleanup(enemy, root)
