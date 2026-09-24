extends RefCounted
## Drugi audyt nagrania (24.09, B2): przy każdym ciosie cztery kanały mówią to
## samo — wynik w logu (Juice.player_hits), napis nad graczem, dźwięk i zmiana
## HP/staminy. 10 kolejnych kontaktów w każdej klasie, zero rozjazdów.
## (Obraz/klip i odsłuch: debug/shield_lab.tscn, debug/audio_lab.tscn.)

const DAMAGE := 18.0
const REPEATS := 10

func _setup(root: Node) -> Array:
	var holder := Node2D.new()
	root.add_child(holder)
	var player: Player = load("res://entities/player.tscn").instantiate()
	holder.add_child(player)
	player.global_position = Vector2(500.0, 400.0)
	return [holder, player]

func _clear_feedback(holder: Node2D, player: Player) -> void:
	for c in holder.get_children():
		if c != player:
			holder.remove_child(c)
			c.queue_free()

func _texts(holder: Node2D) -> Array:
	var out: Array = []
	for c in holder.get_children():
		if c is DamageNumber:
			out.append(c._text)
	return out

func _pitches_2d(holder: Node2D) -> Array:
	var out: Array = []
	for c in holder.get_children():
		if c is AudioStreamPlayer2D:
			out.append(snappedf(c.pitch_scale, 0.01))
	return out

func _prepare(player: Player, shield: bool, parry: bool, stamina: float) -> void:
	player._invuln_timer = 0.0
	player.health = player.max_health
	player.stamina = stamina
	player._shield_up = shield
	player._shield_dir = Vector2.RIGHT
	player._shield_time = 0.05 if parry else 1.0
	player._parry_ready = parry

## [nazwa, tarcza, parowanie, stamina, kierunek źródła, blokowalny,
##  wynik w logu, napis, wysokość osobnego dźwięku (-1 = brak), HP spada?, stamina po]
const CASES := [
	["przód-blok", true, false, 100.0, Vector2(80, 0), true, "blok", "Blok", -1.0, false, "koszt"],
	["parowanie", true, true, 100.0, Vector2(80, 0), true, "parowanie", "Parowanie!", -1.0, false, "bez zmian"],
	["bok", true, false, 100.0, Vector2(0, 80), true, "poza tarczą — bok", "Z boku — poza tarczą", 1.9, true, "bez zmian"],
	["tył", true, false, 100.0, Vector2(-80, 0), true, "poza tarczą — tył", "Z tyłu — poza tarczą", 1.9, true, "bez zmian"],
	["nieblokowalny", true, false, 100.0, Vector2(80, 0), false, "nieblokowalny", "Nie do zablokowania", -1.0, true, "bez zmian"],
	["przełamanie", true, false, 10.0, Vector2(80, 0), true, "przełamanie gardy", "Garda przełamana", 0.55, true, "zero"],
	["bez tarczy", false, false, 100.0, Vector2(80, 0), true, "trafienie", "", -1.0, true, "bez zmian"],
]

func test_ten_contacts_per_class_all_channels_agree(root: Node) -> void:
	var pair := _setup(root)
	var holder: Node2D = pair[0]
	var player: Player = pair[1]
	var mismatches: Array[String] = []
	for c in CASES:
		for i in REPEATS:
			_clear_feedback(holder, player)
			Juice.player_hits.clear()
			_prepare(player, c[1], c[2], c[3])
			var hp := player.health
			var st := player.stamina
			player.take_damage(DAMAGE, player.global_position + c[4], c[5], null, "test")
			var e: Dictionary = Juice.player_hits[-1] if not Juice.player_hits.is_empty() else {}
			var texts := _texts(holder)
			var pitches := _pitches_2d(holder)
			if e.get("outcome", "") != c[6]:
				mismatches.append("%s #%d: log %s zamiast %s" % [c[0], i, e.get("outcome", "?"), c[6]])
			if c[7] != "" and not texts.has(c[7]):
				mismatches.append("%s #%d: brak napisu „%s” (są: %s)" % [c[0], i, c[7], texts])
			if bool(c[9]) != (player.health < hp - 0.01):
				mismatches.append("%s #%d: HP %s" % [c[0], i, "nie spadło" if c[9] else "spadło"])
			if bool(c[9]) and not texts.has(str(int(DAMAGE))):
				mismatches.append("%s #%d: brak liczby obrażeń" % [c[0], i])
			if float(c[8]) > 0.0 and not pitches.has(snappedf(float(c[8]), 0.01)):
				mismatches.append("%s #%d: brak dźwięku o wysokości %.2f (są %s)" % [c[0], i, c[8], pitches])
			match c[10]:
				"koszt":
					if absf((st - player.stamina) - player.shield_block_cost(DAMAGE)) > 0.01:
						mismatches.append("%s #%d: stamina %.1f→%.1f, koszt ≠ reguła" % [c[0], i, st, player.stamina])
				"bez zmian":
					if absf(st - player.stamina) > 0.01:
						mismatches.append("%s #%d: stamina się zmieniła" % [c[0], i])
				"zero":
					if player.stamina > 0.01:
						mismatches.append("%s #%d: stamina nie wyzerowana" % [c[0], i])
			if float(e.get("hp_before", -1)) != hp or absf(float(e.get("hp_after", -1)) - player.health) > 0.01:
				mismatches.append("%s #%d: HP w logu ≠ HP gracza" % [c[0], i])
	NemoraxTest.assert_eq(mismatches, [] as Array[String], "log = napis = dźwięk = liczby dla 10 kontaktów w każdej z %d klas" % CASES.size())
	_clear_feedback(holder, player)
	root.remove_child(holder)
	holder.queue_free()

## Postawa: dwa pełne przełamania i powrót odporności (B2). Stan widoczny
## (krąg odsłonięcia, przerywana linia odporności) wynika z tych samych flag.
func test_nekravor_two_breaks_and_immunity_return(root: Node) -> void:
	var enemy: Incarnation = load(GameFlow.INCARNATION_SCENES[3]).instantiate()
	root.add_child(enemy)
	var t1 := enemy.stance_threshold()
	enemy.add_stance_damage(t1)
	NemoraxTest.assert_true(enemy.is_stance_broken(), "pierwsze przełamanie")
	enemy._tick_stance(enemy.stance_break_duration + 0.01)
	NemoraxTest.assert_true(not enemy.is_stance_broken() and enemy.is_stance_immune(), "po odsłonięciu: odporność (brak stun-locku)")
	enemy.add_stance_damage(9999.0)
	NemoraxTest.assert_eq(enemy.stance_breaks, 1, "w odporności postawa nie rośnie")
	enemy._tick_stance(enemy.stance_immunity + 0.01)
	NemoraxTest.assert_true(not enemy.is_stance_immune(), "odporność wraca do zwykłego stanu")
	var t2 := enemy.stance_threshold()
	NemoraxTest.assert_true(t2 > t1, "drugie przełamanie wymaga więcej")
	enemy.add_stance_damage(t2)
	NemoraxTest.assert_eq(enemy.stance_breaks, 2, "drugie pełne przełamanie")
	root.remove_child(enemy)
	enemy.queue_free()
