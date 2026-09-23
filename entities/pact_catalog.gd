extends RefCounted
class_name PactCatalog
## Paczka 8 (AUDYT E4): Pakt fragmentów — PILOTAŻ na jednym wcieleniu.
## Fragment duszy gracz dostaje zawsze; pakt decyduje, JAK użyje jego mocy
## w tej próbie. Obie drogi zmieniają decyzje w walce, a konsekwencja w finale
## jest pokazana PRZED wyborem.

const PILOT_CHAPTER := 1 ## Mordrath (Cisza) ↔ faza finału Force (indeks 1)
const OCZYSC := "oczysc"
const ZWIAZ := "zwiaz"
const OCZYSC_STAMINA_BONUS := 20.0
const ZWIAZ_SILENCE_RADIUS := 160.0
const ZWIAZ_SILENCE_TIME := 1.2

const OPTIONS := {
	OCZYSC: {
		"name": "Oczyść ciszę",
		"now": "+20 maks. staminy — więcej bloków i dashy.",
		"finale": "Faza Siła NIE wycisza dźwięku: usłyszysz zapowiedzi Nemoraksa.",
	},
	ZWIAZ: {
		"name": "Zwiąż ciszę",
		"now": "Parowanie wywołuje falę ciszy: wrogowie w 160 px przerywają atak na 1,2 s.",
		"finale": "Faza Siła dostaje nowy atak: pierścień pieczęci z jedną luką — wyjdź przez lukę.",
	},
}

static func choice(chapter: int = PILOT_CHAPTER) -> String:
	return str(GameFlow.pacts.get(str(chapter), ""))

static func is_bound() -> bool:
	return choice() == ZWIAZ

static func is_cleansed() -> bool:
	return choice() == OCZYSC
