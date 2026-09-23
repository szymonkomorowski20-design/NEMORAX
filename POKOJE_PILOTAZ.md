# NEMORAX — pilotaż pokoi (AUDYT, Paczka 5)

Stan na 23.09.2026. Kod: `rooms/encounter_plan.gd` (reguły, dane), `rooms/room_terrain.gd` (teren w pokoju), `autoload/game_flow.gd` (ziarno, plan pokoi). Testy: `tests/test_rooms_pilot.gd`.

## Ziarno próby
- `GameFlow.run_seed` — cała mapa, motywy, układy, pokój pułapek i skrzynie wynikają z jednego ziarna; zapisywane w pliku postępu. `reset_run(seed)` odtwarza konkretną próbę.
- Losowanie wewnątrz pokoju (wybór przepisu, zastępca wroga, elita) — z `room_rng(pozycja)`, więc nie zależy od kolejności odwiedzania innych pokoi.

## Przepisy spotkań (3)
| Przepis | Skład | Od pokoju | Presja |
|---|---|---|---|
| Młot i kowadło | Tank (front) + Shooter (tył) | 3 | 5 |
| Wzmocniony nóż | Striker (front) + Support (tył) | 3 | 3 |
| Sfora | 2× Chaser (front) + Dasher (tył) | 8 | 6 |

- **Limit presji:** `3 + pokoje/3`, maks. 7. Pojedynczy wróg zawsze się mieści.
- **Spawn z dala od wejścia:** wrogowie zawsze stoją po drugiej stronie pokoju, ≥ 330 px od punktu wejścia. Wcześniej grupa stawała ~120 px od gracza przy wejściu z północy.
- **Różnorodność:** trzeci taki sam „podpis” walki z rzędu jest zamieniany (inny przepis albo wróg innej kategorii: wręcz / dystans / kontrola). Historia jest liczona w kolejności odwiedzania i zapisywana.
- **Rytm:** pokoje grupowe jak dotąd co 4. wyczyszczony pokój (od 3.); pozostałe to jeden wróg.

## Układy geometrii (3)
`dwa_filary` (dwa filary po przekątnej), `oslona` (dwie niskie osłony), `kolumnada` (cztery kolumny). 45% pokoi RANDOM dostaje układ, reszta jest otwarta.
- Przeszkody zatrzymują gracza (kolizja), wrogów (wypychanie w `_clamp_to_arena`) i pociski obu stron.
- Rysowane teksturą muru danego motywu, pod postaciami (nie zasłaniają telegrafów).
- **Walidacja:** nic w promieniu 120 px od drzwi, każde przejście ≥ 130 px (średnica Tanka + zapas), wszystkie drzwi i spawny połączone. Test sprawdza 20 seedów × każdy pokój × 4 wejścia × każdy skład.

## Pokój pułapek (1, pilotaż) — Rdzawa hala
- Dokładnie jeden na próbę, nigdy tuż za startem; tylko proste role wrogów (Chaser/Striker/Shooter/Orbiter).
- Płyty-prasy w środku pokoju, dwie grupy kolumn na zmianę. Cykl 2,6 s: **telegraf 0,8 s** (kreskowanie + kurczący się kwadrat + dźwięk), uderzenie 0,45 s, nigdy obie grupy naraz.
- **Bezpieczny pas 115 px przy ścianach i przy drzwiach** — trasa bez obrażeń i bez dasha zawsze istnieje.
- 1,2 s łaski po wejściu + **pierwszy pełny cykl jako podgląd bez obrażeń**.
- Nieblokowalne (strefa pod nogami — inny wygląd niż ciosy); ranią też wrogów (można ich zwabić).
- Po oczyszczeniu pokoju prasy stają.

## Akcenty motywów (4)
| Motyw | Akcent | Zapowiedź po wejściu |
|---|---|---|
| Zalana katakumba | pas płycizny: −35% prędkości gracza i wrogów | „Płycizna spowalnia” |
| Zatopiona biblioteka | regały przewracają się po wejściu i stają się osłonami zatrzymującymi pociski | „Regały zatrzymują pociski” |
| Kryształowa grota | ściany odbijają każdy pocisk raz (błysk + dźwięk) | „Kryształ odbija pocisk raz” |
| Rdzawa hala | pokój pułapek (wyżej) | „Prasy w rytmie” |

Pozostałe 4 motywy (krypta, sala rytuału, ruiny, pole bitwy) — bez akcentu do czasu oceny pilotażu.

## Długość trasy (`debug/measure_route.gd`, 20 seedów)
- Pełna próba: 32 pokoje (start + 24 RANDOM + 6 SOUL + ołtarz).
- **Minimalna trasa do 6 dusz i ołtarza: 20–26 pokoi (mediana 22).** Najgłębszy cel 5–10 przejść od startu.
- Pokój pułapek leży na minimalnej trasie w 12/20 seedów.
- **Wniosek dla Paczki 7:** skrót praktycznie nie istnieje — dusze wiszą na końcach długich gałęzi, więc gracz i tak czyści ~70–80% mapy. Rozgałęzienia z wyborem ryzyka/nagrody trzeba zaprojektować w Paczce 7.

## Do oceny w grze (autor)
- Czy przeszkody i płycizna są czytelne podczas walki; czy pokój pułapek da się przejść bez obrażeń bez dasha.
- Czy rozpoznajesz mechanicznie co najmniej dwa motywy (warunek odbioru).

# Paczka 7 — trasy, mapa, ziarno

## Ryzyko i nagroda widoczne przed wejściem
- Symbole typów pokoju (kształt + kolor): **dusza** (okrąg), **ołtarz** (romb), **skrzynia** (złoty prostokąt, dopóki nieotwarta), **pułapka** (trójkąt), **elita** (korona), **odpoczynek** (krzyż). Te same na minimapie, dużej mapie i **nad drzwiami** (obok otworu, z podpisem).
- **Elita decydowana przy generowaniu mapy** (szansa rośnie z odległością od startu, 5–35%) — widać ją zanim się wejdzie; dawniej rzut przy wejściu. Mediana 4 elity na mapę.
- **2 pokoje odpoczynku** (≥ 3 przejścia od startu, nie pułapka/skrzynia/elita): bez walki, jednorazowo +30% życia, bez XP. To „oddech” i realny wybór trasy.
- Sąsiednie komnaty nie dostają tego samego motywu (bez serii identycznie wyglądających pokoi).

## Mapa (A13)
- Minimapa: pola 14 px, obecny / odwiedzony (kropka) / znany (obrys) + symbol typu; przycięta do promienia 3 pokoi (nie wychodzi poza pole).
- **Duża mapa pod M** (bez pauzy) z legendą.

## Ziarno i zapis
- Ten sam seed + te same decyzje = ta sama mapa, motywy, układy, elity, odpoczynki, pułapka i oferty run.
- Zapis zawiera `seed`, `map_version` (3), plan pokoi (elita, odpoczynek, motyw, pułapka) i stan odpoczynku; wczytanie niczego nie losuje ponownie. Starsze zapisy wczytują się z wartościami domyślnymi.

## Tempo (`debug/measure_route.gd`, 20 seedów)
- Minimalna trasa do 6 dusz + ołtarza: 20–26 pokoi (mediana 22) z 32.
- **Poziom gracza po minimalnej trasie: 8–10 (mediana 9)** — skrót nie prowadzi do finału, którego nie da się wygrać (strojenie z Paczki 4 zakłada poziom 7–10).
- Otwarte: prawdziwy „skrót” (krótsza droga za mniej nagród) wymaga zmiany kształtu mapy — dusze wiszą na długich gałęziach. Do decyzji po teście, czy wystarcza wybór między elitą/pułapką/odpoczynkiem na rozgałęzieniach.
