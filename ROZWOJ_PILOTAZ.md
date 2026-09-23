# NEMORAX — rozwój w próbie (AUDYT, Paczka 6) — stan 23.09.2026

## Odłożone nagrody (decyzja autora 23.09)
- Awans i skrzynia **nie otwierają wyboru same**. Nad relikwiarzem w HUD pulsują przyciski widoczne do skutku:
  - `[R] Runa do wyboru (n) · Punkty: n` — R/klik otwiera wybór runy, a gdy run brak — ekran punktów (Tab działa jak dawniej).
  - `[Q] Relikwia do wyboru` — otwarta skrzynia oddaje ofertę graczowi; wybór można zrobić później, także w innym pokoju i w arenie.
- W każdym oknie wyboru `Esc — później`. Niewybrane oferty są zapisywane (wczytanie gry nie losuje nowych).
- Klawisze R i Q są w ekranie zmiany klawiszy.

## Karty (A11)
- Karta runy: broń (Miecz / Różdżka / Każda broń) + tagi, `Ranga a → b`, **Teraz:** i **Po wyborze:** — tekst tej konkretnej rangi zamiast ciągów `125/150/175`.
- Opisy uzupełnione o liczby z kodu: Ostrze echa, Rozkwit, Pęknięcie, Odłamki, Rozdarcie, Przeplot. Test sprawdza zgodność kart z mechaniką (Kamienna skóra, Splot many, Krótki oddech, Szeroki zamach).
- Relikwie: polskie nazwy (A14), tagi, ikony bez `load()` w każdej klatce.

## Oferty (E3)
- Z ziarna próby: te same decyzje = te same karty.
- Gwarancja co najmniej jednej karty dla bieżącej broni.
- Jeden przerzut na próbę (klawisz 4 w oknie run).

## Statystyki i HUD (A12, A16)
- Ekran statystyk: `+1 punkt: Miecz 10.0 → 11.0` — liczone tą samą funkcją co prawdziwy awans; „Aktywne efekty” z opisem obecnej rangi i relikwiami.
- Pasek XP w HUD liczył postęp złym progiem (stałe 3 XP zamiast 2/3/4) — poprawione; na maksymalnym poziomie `MAX`.

## Intencje startowe (pilotaż E3)
- Ostrze / Różdżka / Kontra (albo Esc — bez intencji) na starcie nowej próby, po prologu.
- Działanie: trzy pierwsze oferty run zawierają kartę z puli intencji. Bez trwałego bonusu, inne drogi zostają otwarte.
- Każda pula ma ≥ 4 różne tagi działania (co najmniej dwa kierunki buildu).

## Naprawione przy okazji
- ~1 na 500 seedów generował mapę **bez ołtarza** (próby nie dało się ukończyć). Generator powtarza losowanie z tego samego ziarna, test na 400 seedach.
