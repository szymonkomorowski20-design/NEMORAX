extends RefCounted
class_name RunSummary
## Paczka 9 (AUDYT E5/A17): krótka historia próby na ekran śmierci/zwycięstwa
## i do Kroniki — przyczyna porażki, etap, kluczowe wybory, czas, ziarno oraz
## JEDNA konkretna rzecz do sprawdzenia następnym razem. Informacja do nauki,
## nie ocena gracza.

const SkillCatalog := preload("res://entities/skill_catalog.gd")

const ENEMY_NAMES := {
	"chaser": "Ścigacz", "striker": "Siekacz", "shooter": "Strzelec", "charger": "Taran",
	"orbiter": "Krążący", "dasher": "Skoczek", "ambusher": "Czyhacz", "zoner": "Strefiarz",
	"summoner": "Przywoływacz", "tank": "Kolos", "support": "Wspierający",
	"seal": "pieczęć Nemoraksa", "damage_zone": "strefa na podłożu", "shadow": "cień Nemoraksa",
	"enemy_projectile": "pocisk",
}
const ENEMY_ADVICE := {
	"melee": "Wrogowie wręcz: trzymaj tarczę w ich stronę, a parowanie w dobrym momencie przerywa ich atak.",
	"ranged": "Strzelcy: osłony zatrzymują pociski, a sparowany pocisk wraca do nadawcy.",
	"control": "Wrogowie kontroli: nie walcz w ich strefach — zejdź z podłoża i wróć po zapowiedzi.",
}
const SPECIAL_ADVICE := {
	"pieczęć Nemoraksa": "Pieczęci nie da się zablokować — wyjdź z kręgu, zanim rozbłyśnie.",
	"strefa na podłożu": "Strefy pod nogami ignorują tarczę — zejdź z nich, zamiast blokować.",
	"prasa pułapki": "Prasy: pas przy ścianach jest zawsze bezpieczny, a pierwszy cykl to podgląd.",
	"cień Nemoraksa": "Cienie: dash przez nie albo parowanie je rozwiewa.",
	"pocisk": "Pociski: parowanie odbija je z powrotem, osłony je zatrzymują.",
}
const INCARNATION_ADVICE := [
	"Vhar'Nokh: po teleporcie odskocz od miejsca, w którym się pojawił.",
	"Mordrath: przyciąganie przerwij dashem, zanim przyjdzie puls.",
	"Zha'Ruun: po pierwszym pulsie przyjdzie echo — nie wracaj od razu.",
	"Nekravor: szanuj duży promień miażdżenia; po miażdżeniu masz okno na kontrę.",
	"Thal'Gor: każde przyjęte ugryzienie go leczy — blokuj albo unikaj.",
	"Orryx: w czasie zniknięcia ruszaj się, nie czekaj w miejscu.",
]
const PHASE_ADVICE := [
	"Motion: czytaj tor wypadu i schodź z niego w bok, nie do tyłu.",
	"Force: bez dźwięku patrz na pozy bossa — pieczęcie świecą przed wybuchem.",
	"Instinct: dash ma dłuższy cooldown — oszczędzaj go na zmyłki.",
	"Dominion: przyciąganie ciągnie do bossa — idź pod prąd i zbijaj dodatki.",
	"Ruin: długie serie — cofnij się po pierwszym ciosie, zanim przyjdzie łańcuch.",
	"Sovereignty: w mroku boss znika poza kręgiem — nasłuchuj telegrafu i trzymaj dystans.",
]

## Opis sprawcy ostatniego ciosu (Player.take_damage zapisuje go w last_hit_source).
static func describe_attacker(attacker: Node, blockable: bool) -> String:
	if attacker == null or not is_instance_valid(attacker):
		return "strefa pod nogami" if not blockable else "nieznane źródło"
	if attacker is Boss:
		return "Nemorax"
	if attacker is RoomTerrain:
		return "prasa pułapki"
	var fragment = attacker.get("fragment_name")
	if fragment != null and str(fragment) != "":
		return str(fragment).split(",")[0]
	var key := attacker.scene_file_path.get_file().get_basename()
	return ENEMY_NAMES.get(key, str(attacker.name))

## Rada dopasowana do przyczyny porażki (albo do zwycięstwa).
static func advice(result: String, cause: String, phase_index: int = -1) -> String:
	if result == "victory":
		if PactCatalog.choice() != "":
			var other := PactCatalog.ZWIAZ if PactCatalog.is_cleansed() else PactCatalog.OCZYSC
			return "Następnym razem wybierz drugi Pakt Mordratha (%s) — faza Force zagra inaczej." % PactCatalog.OPTIONS[other]["name"]
		if GameFlow.loop_level == 0:
			return "Odblokowana Pętla Otchłani I — włącz ją przy wyborze intencji (L)."
		return "Spróbuj innej intencji startowej i innej broni jako głównej."
	if cause == "Nemorax" and phase_index >= 0 and phase_index < PHASE_ADVICE.size():
		return PHASE_ADVICE[phase_index]
	if SPECIAL_ADVICE.has(cause):
		return SPECIAL_ADVICE[cause]
	for i in GameFlow.INCARNATION_NAMES.size():
		if GameFlow.INCARNATION_NAMES[i].begins_with(cause):
			return INCARNATION_ADVICE[i]
	for key in ENEMY_NAMES:
		if ENEMY_NAMES[key] == cause:
			var idx := GameFlow.RANDOM_ENEMY_SCENES.find("res://entities/random_enemies/%s.tscn" % key)
			if idx >= 0:
				return ENEMY_ADVICE[EncounterPlan.ENEMY_CATEGORY[idx]]
	return "Obejrzyj telegraf przed ciosem — każdy atak ma zapowiedź formą i dźwiękiem."

static func format_time(seconds: float) -> String:
	var s := int(seconds)
	return "%d:%02d" % [s / 60, s % 60]

## Wpis Kroniki (zapisywany trwale) — ten sam słownik zasila ekran końca.
static func build(player: Player, result: String, stage: String, phase_index: int = -1) -> Dictionary:
	var skills: Array = player.skill_ranks.keys()
	skills.sort_custom(func(a, b): return int(player.skill_ranks[a]) > int(player.skill_ranks[b]))
	var top: Array = []
	for id in skills.slice(0, 3):
		if SkillCatalog.SKILLS.has(id):
			top.append("%s %d" % [SkillCatalog.SKILLS[id]["name"], player.skill_rank(id)])
	var relics: Array = []
	for r in player.owned_upgrades:
		relics.append(GameUI.RELIC_NAMES.get(r, r))
	var cause := player.last_hit_source if result == "death" else ""
	return {
		"date": Time.get_datetime_string_from_system(false, true),
		"result": result, "stage": stage, "cause": cause,
		"advice": advice(result, cause, phase_index),
		"seed": GameFlow.run_seed, "time": GameFlow.run_time,
		"level": player.level, "fragments": GameFlow.fragments_collected.size(),
		"rooms": GameFlow.rooms_cleared_count,
		"intent": str(SkillCatalog.INTENTS.get(GameFlow.run_intent, {}).get("name", "brak")),
		"pact": str(PactCatalog.OPTIONS.get(PactCatalog.choice(), {}).get("name", "—")),
		"loop": GameFlow.loop_level, "skills": top, "relics": relics,
	}

## Tekst ekranu końca (śmierć albo zwycięstwo) — nagłówek + historia + rada.
static func screen_lines(e: Dictionary) -> Array[String]:
	var out: Array[String] = []
	out.append("Zwycięstwo" if e["result"] == "victory" else "Zostałeś odrzucony")
	out.append("")
	if e["result"] == "death":
		out.append(("Ostatni cios: %s   ·   %s" % [e["cause"], e["stage"]]) if str(e["stage"]) != "" else "Ostatni cios: %s" % e["cause"])
	else:
		out.append(e["stage"])
	out.append("Czas próby %s   ·   poziom %d   ·   fragmenty %d/6   ·   pokoje %d" % [format_time(float(e["time"])), int(e["level"]), int(e["fragments"]), int(e["rooms"])])
	var choices := "Intencja: %s   ·   Pakt: %s" % [e["intent"], e["pact"]]
	if int(e["loop"]) > 0:
		choices += "   ·   Pętla Otchłani %d" % int(e["loop"])
	out.append(choices)
	if not (e["skills"] as Array).is_empty():
		out.append("Runy: " + ", ".join(e["skills"]))
	if not (e["relics"] as Array).is_empty():
		out.append("Relikwie: " + ", ".join(e["relics"]))
	out.append("")
	out.append("Następnym razem: " + str(e["advice"]))
	out.append("")
	out.append("Ziarno próby: %d" % int(e["seed"]))
	return out
