extends RefCounted
## _choose_attack_name (boss.gd) i _choose_skill_index (incarnation.gd) — czysta
## logika losowania bez efektów ubocznych (bez spawnowania scen ataku/wywoływania
## Callable), testowalna na gołym Boss.new()/Incarnation.new() bez drzewa sceny,
## gracza czy areny (patrz komentarz nad obiema funkcjami w źródle).

const ITERATIONS := 2000

func test_boss_attack_never_repeats(_root: Node) -> void:
	var boss := Boss.new()
	var options := ["seal", "void", "shadow", "lunge"]
	var previous := "lunge"
	for i in range(ITERATIONS):
		var choice: String = boss._choose_attack_name(options, previous)
		NemoraxTest.assert_true(choice != previous, "wybór (%s) nie powinien powtórzyć poprzedniego (%s)" % [choice, previous])
		NemoraxTest.assert_true(choice in options, "wybór (%s) musi być jedną z opcji" % choice)
		previous = choice

func test_incarnation_skill_never_repeats(_root: Node) -> void:
	var incarnation := Incarnation.new()
	var count := 3
	var previous := 0
	for i in range(ITERATIONS):
		var index: int = incarnation._choose_skill_index(count, previous)
		NemoraxTest.assert_true(index != previous, "indeks (%d) nie powinien powtórzyć poprzedniego (%d)" % [index, previous])
		NemoraxTest.assert_true(index >= 0 and index < count, "indeks (%d) poza zakresem 0..%d" % [index, count - 1])
		previous = index

func test_incarnation_difficulty_scale_multiplies_health_and_damage(_root: Node) -> void:
	var incarnation := Incarnation.new()
	incarnation.max_health = 100.0
	incarnation.health = 100.0
	incarnation.contact_damage = 10.0
	incarnation.apply_difficulty_scale(1.5)
	NemoraxTest.assert_almost_eq(incarnation.max_health, 150.0, 0.01, "max_health powinien wzrosnąć o mnożnik")
	NemoraxTest.assert_almost_eq(incarnation.health, 150.0, 0.01, "health powinien zostać przeliczony na nowe max_health")
	NemoraxTest.assert_almost_eq(incarnation.contact_damage, 15.0, 0.01, "contact_damage powinien wzrosnąć o ten sam mnożnik")
