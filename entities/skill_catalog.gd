extends RefCounted
## Pierwszy grywalny pakiet rozwoju. IDs są stabilne w zapisie próby.

const SKILLS := {
	"blade_twin_cut": {"name": "Podwójny cios", "ranks": 2, "description": "Drugie cięcie po 0,12 s: 55/70% obrażeń."},
	"blade_third_cut": {"name": "Trzeci rytm", "ranks": 1, "description": "Po Podwójnym ciosie trzeci zamach: 35% obrażeń."},
	"blade_wide_sweep": {"name": "Szeroki zamach", "ranks": 3, "description": "Kąt miecza: 125/150/175°."},
	"blade_long_edge": {"name": "Długa krawędź", "ranks": 3, "description": "Zasięg miecza +10/20/30%."},
	"blade_bleed": {"name": "Żywa rana", "ranks": 2, "description": "Krwawienie 12/18% obrażeń przez 3 s."},
	"blade_sunder": {"name": "Łamacz pancerza", "ranks": 2, "description": "Co 4./3. cios w cel: +75/100% obrażeń."},
	"blade_wave": {"name": "Ostrze echa", "ranks": 2, "description": "Co 3./2. zamach fala na 140 px: 50/65% obrażeń."},
	"wand_split_bolt": {"name": "Rozszczepienie", "ranks": 2, "description": "Dwa boczne pociski: 50/65% obrażeń."},
	"wand_pierce": {"name": "Przebicie", "ranks": 3, "description": "Pocisk przechodzi przez 1/2/3 dalszych wrogów."},
	"wand_rapid_cast": {"name": "Szybkie runy", "ranks": 3, "description": "Tempo różdżki +8/16/24%."},
	"wand_mana_weave": {"name": "Splot many", "ranks": 3, "description": "Koszt strzału −2/4/6 many, min. 15."},
	"wand_echo_volley": {"name": "Echo salwy", "ranks": 2, "description": "Po 0,14 s drugi pocisk za 55/70% obrażeń."},
	"wand_homing": {"name": "Zbieżność", "ranks": 2, "description": "Pocisk skręca do celu o 70/120° na sekundę."},
	"wand_ricochet": {"name": "Rykoszet", "ranks": 2, "description": "Pocisk odbija się do 1/2 nowych celów."},
	"void_bloom": {"name": "Rozkwit Otchłani", "ranks": 3, "description": "Po zabiciu pierwotnym ciosem wybuch 65/85/105 px: 35/45/55% obrażeń."},
	"void_dash_ring": {"name": "Ślad pustki", "ranks": 2, "description": "Po dashu krąg 75/95 px, 35/50% obrażeń."},
	"void_rupture": {"name": "Pęknięcie", "ranks": 2, "description": "Co 4./3. trafienie w cel wybuch 55/70 px: 80/110% obrażeń."},
	"void_shard_orbit": {"name": "Odłamki orbity", "ranks": 2, "description": "1/2 odłamki krążą wokół gracza: 25% obrażeń ataku."},
	"void_chain_burst": {"name": "Rozprysk duszy", "ranks": 2, "description": "Po zabiciu 2/3 odłamki lecą do innych celów."},
	"void_gravity_well": {"name": "Studnia cienia", "ranks": 1, "description": "Po zabiciu 2 s spowolnienia na 100 px."},
	"void_execution": {"name": "Rozdarcie", "ranks": 2, "description": "Nadwyżka obrażeń 35/50% przechodzi na wrogów w 85 px."},
	"guard_fleetfoot": {"name": "Lekkie kroki", "ranks": 3, "description": "+5/10/15% szybkości ruchu."},
	"guard_quickstep": {"name": "Krótki oddech", "ranks": 3, "description": "Odnowa dasha −8/16/24%, min. 0,35 s."},
	"guard_iron_skin": {"name": "Kamienna skóra", "ranks": 3, "description": "+15/30/45 maksymalnego życia."},
	"guard_second_breath": {"name": "Drugi oddech", "ranks": 1, "description": "Raz na pokój śmiertelny cios zostawia 1 HP."},
	"guard_counterbrand": {"name": "Znamię kontry", "ranks": 2, "description": "Parowanie (tarcza podniesiona tuż przed ciosem) wyzwala kontratak 60/90% obrażeń."},
	"guard_battle_rhythm": {"name": "Rytm walki", "ranks": 2, "description": "Po 3 trafieniach tempo ataku +12/20% na 4 s."},
	"guard_weapon_weave": {"name": "Przeplot", "ranks": 2, "description": "Trafienie jedną bronią: następny atak drugą +15/25%."},
}

const EPIC_IDS := ["blade_third_cut", "blade_wave", "wand_echo_volley", "void_shard_orbit", "void_chain_burst", "void_gravity_well", "guard_second_breath"]
const RARE_IDS := ["blade_twin_cut", "blade_bleed", "blade_sunder", "wand_split_bolt", "wand_homing", "wand_ricochet", "void_bloom", "void_rupture", "void_dash_ring", "void_execution", "guard_counterbrand", "guard_battle_rhythm", "guard_weapon_weave"]

static func available(ranks: Dictionary, level: int = 10) -> Array[String]:
	var result: Array[String] = []
	for id in SKILLS:
		if level < 3 and id in EPIC_IDS:
			continue
		if id == "blade_third_cut" and int(ranks.get("blade_twin_cut", 0)) < 2:
			continue
		if int(ranks.get(id, 0)) < int(SKILLS[id]["ranks"]):
			result.append(id)
	return result

## Paczka 6 (AUDYT E3): broń, której dotyczy umiejętność ("sword" / "wand" /
## "any") i tagi działania. Katalog też dla 10 relikwii (RELIC_TAGS).
const SKILL_WEAPON := {
	"blade_twin_cut": "sword", "blade_third_cut": "sword", "blade_wide_sweep": "sword", "blade_long_edge": "sword",
	"blade_bleed": "sword", "blade_sunder": "sword", "blade_wave": "sword",
	"wand_split_bolt": "wand", "wand_pierce": "wand", "wand_rapid_cast": "wand", "wand_mana_weave": "wand",
	"wand_echo_volley": "wand", "wand_homing": "wand", "wand_ricochet": "wand",
}
const SKILL_TAGS := {
	"blade_twin_cut": ["kontakt", "wtórne"], "blade_third_cut": ["kontakt", "wtórne"], "blade_wide_sweep": ["kontakt", "obszar"],
	"blade_long_edge": ["kontakt", "zasięg"], "blade_bleed": ["kontakt", "DoT"], "blade_sunder": ["kontakt", "rytm"],
	"blade_wave": ["kontakt", "obszar"], "wand_split_bolt": ["pocisk", "obszar"], "wand_pierce": ["pocisk", "grupa"],
	"wand_rapid_cast": ["pocisk", "tempo"], "wand_mana_weave": ["pocisk", "mana"], "wand_echo_volley": ["pocisk", "wtórne"],
	"wand_homing": ["pocisk", "celność"], "wand_ricochet": ["pocisk", "grupa"], "void_bloom": ["zabójstwo", "obszar"],
	"void_dash_ring": ["dash", "obszar"], "void_rupture": ["rytm", "obszar"], "void_shard_orbit": ["obszar", "stałe"],
	"void_chain_burst": ["zabójstwo", "grupa"], "void_gravity_well": ["zabójstwo", "kontrola"], "void_execution": ["zabójstwo", "grupa"],
	"guard_fleetfoot": ["ruch"], "guard_quickstep": ["dash", "ruch"], "guard_iron_skin": ["obrona", "życie"],
	"guard_second_breath": ["obrona"], "guard_counterbrand": ["obrona", "parowanie"], "guard_battle_rhythm": ["tempo", "rytm"],
	"guard_weapon_weave": ["obie bronie", "tempo"],
}
const RELIC_TAGS := {
	"blood_edge": ["kontakt", "tempo"], "void_step": ["dash", "ruch"], "iron_heart": ["obrona", "życie"],
	"hunters_mark": ["jeden cel"], "second_impact": ["wtórne", "obszar"], "razor_wind": ["kontakt", "zasięg"],
	"momentum": ["ruch", "unik"], "last_resolve": ["niskie HP", "tempo"], "soul_echo": ["zabójstwo", "tempo"],
	"soul_bond": ["dusze", "różne"],
}

## Intencje startowe (E3, pilotaż): lekkie ukierunkowanie pierwszych ofert.
## Bez trwałej przewagi — tylko gwarancja jednej karty z puli na 3 pierwsze awanse.
const INTENTS := {
	"ostrze": {"name": "Ostrze", "desc": "Pierwsze runy częściej wzmacniają miecz.", "pool": ["blade_twin_cut", "blade_wide_sweep", "blade_long_edge", "blade_bleed", "blade_sunder", "blade_wave"]},
	"rozdzka": {"name": "Różdżka", "desc": "Pierwsze runy częściej wzmacniają różdżkę.", "pool": ["wand_split_bolt", "wand_pierce", "wand_rapid_cast", "wand_mana_weave", "wand_homing", "wand_ricochet"]},
	"kontra": {"name": "Kontra", "desc": "Pierwsze runy częściej wspierają tarczę i przetrwanie.", "pool": ["guard_counterbrand", "guard_iron_skin", "guard_quickstep", "guard_battle_rhythm", "guard_second_breath", "guard_fleetfoot"]},
}
const INTENT_GUIDED_OFFERS := 3 ## ile pierwszych awansów dostaje kartę z puli intencji

static func weapon_of(id: String) -> String:
	return SKILL_WEAPON.get(id, "any")

## Czy karta realnie działa dla gracza używającego `weapon` („sword”/„wand”)
## bez zmiany stylu. Runy drugiej broni i Przeplot (wymaga naprzemiennej
## zmiany broni) są dla stylu jednej broni martwe; „hybrid” = obie bronie.
const NEEDS_BOTH_WEAPONS := ["guard_weapon_weave"]

static func useful_for(id: String, weapon: String) -> bool:
	if weapon == "hybrid" or weapon == "":
		return true
	if id in NEEDS_BOTH_WEAPONS:
		return false
	return weapon_of(id) in [weapon, "any"]

## Opis dla KONKRETNEJ rangi: każdą grupę "a/b/c" zastępuje wartością tej rangi
## (z tego samego tekstu co karta, więc karta, Księga i ekran statystyk mówią
## to samo). Rangi liczone od 1.
static func rank_text(id: String, rank: int) -> String:
	var text: String = SKILLS[id]["description"]
	var re := RegEx.new()
	re.compile("\\d+(?:[.,]\\d+)?\\.?(?:/\\d+(?:[.,]\\d+)?\\.?)+")
	var out := ""
	var last := 0
	for m in re.search_all(text):
		var parts := m.get_string().split("/")
		out += text.substr(last, m.get_start() - last) + parts[clampi(rank - 1, 0, parts.size() - 1)]
		last = m.get_end()
	return out + text.substr(last)

## rng: generator z ziarna próby (Paczka 7: te same decyzje = te same oferty);
## weapon: broń, której gracz używa — co najmniej jedna karta musi jej służyć;
## intent/guided: intencja startowa i czy ta oferta jeszcze nią sterowana.
static func roll_offer(ranks: Dictionary, level: int, rng: RandomNumberGenerator = null, weapon: String = "", intent: String = "", guided: bool = false, exclude: Array = []) -> Array[String]:
	var r := rng
	if r == null:
		r = RandomNumberGenerator.new()
		r.randomize()
	var pool := available(ranks, level)
	for id in exclude:
		if pool.size() > 3:
			pool.erase(id)
	var result: Array[String] = []
	if guided and INTENTS.has(intent):
		var intent_pool: Array[String] = []
		for id in pool:
			if id in INTENTS[intent]["pool"]:
				intent_pool.append(id)
		if not intent_pool.is_empty():
			var picked_intent: String = intent_pool[r.randi() % intent_pool.size()]
			result.append(picked_intent)
			pool.erase(picked_intent)
	if level == 3 or level == 6:
		var higher: Array[String] = []
		for id in pool:
			if id in RARE_IDS or id in EPIC_IDS:
				higher.append(id)
		if not higher.is_empty():
			var picked: String = higher[r.randi() % higher.size()]
			result.append(picked)
			pool.erase(picked)
	while result.size() < 3 and not pool.is_empty():
		var rarity_roll := r.randf()
		var preferred := "common" if rarity_roll < 0.60 else ("rare" if rarity_roll < 0.92 else "epic")
		var candidates: Array[String] = []
		for id in pool:
			if rarity(id) == preferred:
				candidates.append(id)
		var source: Array[String] = candidates if not candidates.is_empty() else pool
		var chosen: String = source[r.randi() % source.size()]
		result.append(chosen)
		pool.erase(chosen)
	# Gwarancja użytecznej karty: jeśli żadna nie służy bieżącemu stylowi,
	# ostatnią podmieniamy na taką (patrz useful_for — Przeplot nie liczy się
	# jako przydatny dla gry jedną bronią, drugi audyt B3).
	if weapon != "" and not result.is_empty():
		var useful := false
		for id in result:
			if useful_for(id, weapon):
				useful = true
		if not useful:
			var fitting: Array[String] = []
			for id in pool:
				if useful_for(id, weapon):
					fitting.append(id)
			if not fitting.is_empty():
				result[result.size() - 1] = fitting[r.randi() % fitting.size()]
	return result

static func rarity(id: String) -> String:
	if id in EPIC_IDS:
		return "epic"
	if id in RARE_IDS:
		return "rare"
	return "common"

## load() (nie preload) tutaj renderowało się jako czysty biały kwadrat dla
## KAŻDEJ z 28 ikon w skill_draft.gd/stats_screen.gd — nie dla pojedynczej
## ikony osobno (zweryfikowane: 1-2 na raz renderują się poprawnie), tylko gdy
## _draw() woła load() na wielu różnych, dużych teksturach w tej samej klatce,
## co dzieje się co klatkę, bo queue_redraw() leci z _process(). Podmiana na
## raz-załadowany słownik (ten sam wzorzec co GameUI.RELIC_ICONS) usuwa
## powtarzalne load() z _draw() całkowicie, zamiast tylko zmniejszać jego skalę.
const ICONS := {
	"blade_twin_cut": preload("res://assets/sprites/ui/skills_preproduction/skill_blade_twin_cut.png"),
	"blade_third_cut": preload("res://assets/sprites/ui/skills_preproduction/skill_blade_third_cut.png"),
	"blade_wide_sweep": preload("res://assets/sprites/ui/skills_preproduction/skill_blade_wide_sweep.png"),
	"blade_long_edge": preload("res://assets/sprites/ui/skills_preproduction/skill_blade_long_edge.png"),
	"blade_bleed": preload("res://assets/sprites/ui/skills_preproduction/skill_blade_bleed.png"),
	"blade_sunder": preload("res://assets/sprites/ui/skills_preproduction/skill_blade_sunder.png"),
	"blade_wave": preload("res://assets/sprites/ui/skills_preproduction/skill_blade_wave.png"),
	"wand_split_bolt": preload("res://assets/sprites/ui/skills_preproduction/skill_wand_split_bolt.png"),
	"wand_pierce": preload("res://assets/sprites/ui/skills_preproduction/skill_wand_pierce.png"),
	"wand_rapid_cast": preload("res://assets/sprites/ui/skills_preproduction/skill_wand_rapid_cast.png"),
	"wand_mana_weave": preload("res://assets/sprites/ui/skills_preproduction/skill_wand_mana_weave.png"),
	"wand_echo_volley": preload("res://assets/sprites/ui/skills_preproduction/skill_wand_echo_volley.png"),
	"wand_homing": preload("res://assets/sprites/ui/skills_preproduction/skill_wand_homing.png"),
	"wand_ricochet": preload("res://assets/sprites/ui/skills_preproduction/skill_wand_ricochet.png"),
	"void_bloom": preload("res://assets/sprites/ui/skills_preproduction/skill_void_bloom.png"),
	"void_dash_ring": preload("res://assets/sprites/ui/skills_preproduction/skill_void_dash_ring.png"),
	"void_rupture": preload("res://assets/sprites/ui/skills_preproduction/skill_void_rupture.png"),
	"void_shard_orbit": preload("res://assets/sprites/ui/skills_preproduction/skill_void_shard_orbit.png"),
	"void_chain_burst": preload("res://assets/sprites/ui/skills_preproduction/skill_void_chain_burst.png"),
	"void_gravity_well": preload("res://assets/sprites/ui/skills_preproduction/skill_void_gravity_well.png"),
	"void_execution": preload("res://assets/sprites/ui/skills_preproduction/skill_void_execution.png"),
	"guard_fleetfoot": preload("res://assets/sprites/ui/skills_preproduction/skill_guard_fleetfoot.png"),
	"guard_quickstep": preload("res://assets/sprites/ui/skills_preproduction/skill_guard_quickstep.png"),
	"guard_iron_skin": preload("res://assets/sprites/ui/skills_preproduction/skill_guard_iron_skin.png"),
	"guard_second_breath": preload("res://assets/sprites/ui/skills_preproduction/skill_guard_second_breath.png"),
	"guard_counterbrand": preload("res://assets/sprites/ui/skills_preproduction/skill_guard_counterbrand.png"),
	"guard_battle_rhythm": preload("res://assets/sprites/ui/skills_preproduction/skill_guard_battle_rhythm.png"),
	"guard_weapon_weave": preload("res://assets/sprites/ui/skills_preproduction/skill_guard_weapon_weave.png"),
}

static func icon(id: String) -> Texture2D:
	return ICONS.get(id)
