extends RefCounted
## Pierwszy grywalny pakiet rozwoju. IDs są stabilne w zapisie próby.

const SKILLS := {
	"blade_twin_cut": {"name": "Podwójny cios", "ranks": 2, "description": "Drugie cięcie po 0,12 s: 55/70% obrażeń."},
	"blade_third_cut": {"name": "Trzeci rytm", "ranks": 1, "description": "Po Podwójnym ciosie trzeci zamach: 35% obrażeń."},
	"blade_wide_sweep": {"name": "Szeroki zamach", "ranks": 3, "description": "Kąt miecza: 125/150/175°."},
	"blade_long_edge": {"name": "Długa krawędź", "ranks": 3, "description": "Zasięg miecza +10/20/30%."},
	"blade_bleed": {"name": "Żywa rana", "ranks": 2, "description": "Krwawienie 12/18% obrażeń przez 3 s."},
	"blade_sunder": {"name": "Łamacz pancerza", "ranks": 2, "description": "Co 4./3. cios w cel: +75/100% obrażeń."},
	"blade_wave": {"name": "Ostrze echa", "ranks": 2, "description": "Co 3./2. zamach fala na 140 px."},
	"wand_split_bolt": {"name": "Rozszczepienie", "ranks": 2, "description": "Dwa boczne pociski: 50/65% obrażeń."},
	"wand_pierce": {"name": "Przebicie", "ranks": 3, "description": "Pocisk przechodzi przez 1/2/3 dalszych wrogów."},
	"wand_rapid_cast": {"name": "Szybkie runy", "ranks": 3, "description": "Tempo różdżki +8/16/24%."},
	"wand_mana_weave": {"name": "Splot many", "ranks": 3, "description": "Koszt strzału −2/4/6 many, min. 15."},
	"wand_echo_volley": {"name": "Echo salwy", "ranks": 2, "description": "Po 0,14 s drugi pocisk za 55/70% obrażeń."},
	"wand_homing": {"name": "Zbieżność", "ranks": 2, "description": "Pocisk skręca do celu o 70/120° na sekundę."},
	"wand_ricochet": {"name": "Rykoszet", "ranks": 2, "description": "Pocisk odbija się do 1/2 nowych celów."},
	"void_bloom": {"name": "Rozkwit Otchłani", "ranks": 3, "description": "Po zabiciu pierwotnym ciosem wybuch 65/85/105 px."},
	"void_dash_ring": {"name": "Ślad pustki", "ranks": 2, "description": "Po dashu krąg 75/95 px, 35/50% obrażeń."},
	"void_rupture": {"name": "Pęknięcie", "ranks": 2, "description": "Co 4./3. trafienie wybuch wokół celu."},
	"void_shard_orbit": {"name": "Odłamki orbity", "ranks": 2, "description": "1/2 odłamki krążą wokół gracza."},
	"void_chain_burst": {"name": "Rozprysk duszy", "ranks": 2, "description": "Po zabiciu 2/3 odłamki lecą do innych celów."},
	"void_gravity_well": {"name": "Studnia cienia", "ranks": 1, "description": "Po zabiciu 2 s spowolnienia na 100 px."},
	"void_execution": {"name": "Rozdarcie", "ranks": 2, "description": "Nadwyżka obrażeń przechodzi na pobliskich wrogów."},
	"guard_fleetfoot": {"name": "Lekkie kroki", "ranks": 3, "description": "+5/10/15% szybkości ruchu."},
	"guard_quickstep": {"name": "Krótki oddech", "ranks": 3, "description": "Odnowa dasha −8/16/24%, min. 0,35 s."},
	"guard_iron_skin": {"name": "Kamienna skóra", "ranks": 3, "description": "+15/30/45 maksymalnego życia."},
	"guard_second_breath": {"name": "Drugi oddech", "ranks": 1, "description": "Raz na pokój śmiertelny cios zostawia 1 HP."},
	"guard_counterbrand": {"name": "Znamię kontry", "ranks": 2, "description": "Idealny blok (tarcza podniesiona tuż przed ciosem) wyzwala kontratak 60/90% obrażeń."},
	"guard_battle_rhythm": {"name": "Rytm walki", "ranks": 2, "description": "Po 3 trafieniach tempo ataku +12/20% na 4 s."},
	"guard_weapon_weave": {"name": "Przeplot", "ranks": 2, "description": "Po trafieniu jedną bronią wzmocnij drugą."},
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

static func roll_offer(ranks: Dictionary, level: int) -> Array[String]:
	var pool := available(ranks, level)
	var result: Array[String] = []
	if level == 3 or level == 6:
		var higher: Array[String] = []
		for id in pool:
			if id in RARE_IDS or id in EPIC_IDS:
				higher.append(id)
		if not higher.is_empty():
			var picked: String = higher.pick_random()
			result.append(picked)
			pool.erase(picked)
	while result.size() < 3 and not pool.is_empty():
		var rarity_roll := randf()
		var preferred := "common" if rarity_roll < 0.60 else ("rare" if rarity_roll < 0.92 else "epic")
		var candidates: Array[String] = []
		for id in pool:
			if rarity(id) == preferred:
				candidates.append(id)
		var chosen: String = candidates.pick_random() if not candidates.is_empty() else pool.pick_random()
		result.append(chosen)
		pool.erase(chosen)
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
