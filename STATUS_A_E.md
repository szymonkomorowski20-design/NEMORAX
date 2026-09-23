# Status punktów A–E audytu (Paczka 11, 23.09.2026)

Legenda: **zrobione i sprawdzone** (kod + test automatyczny + zrzut/pomiar), **częściowo**, **odłożone**, **nie działa**.
„Sprawdzone” oznacza tu test automatyczny, pomiar botem albo zrzut z wyrenderowanej gry — **nie** zastępuje to próby z człowiekiem. Ta próba jest na liście dla autora na dole.

Testy automatyczne: **313 / 313** (`tests/test_runner.gd`). Zapisy gracza sprawdzane sumą MD5 po każdym uruchomieniu — nietknięte.

## A — lista z nagrania

| # | Punkt | Status | Dowód |
| --- | --- | --- | --- |
| A1 | HP > maksimum na pasku | zrobione i sprawdzone | `test_hp_display` (Paczka 1) |
| A2 | Nemorax znika za szybko | zrobione i sprawdzone | `POMIARY_WALKI.md`: miecz 18 s → 57 s (bot), 4–7 wzorców na fazę |
| A3 | Warstwy scenki ołtarza | zrobione i sprawdzone | `test_altar_state`, `test_arena_finale` (Paczka 1) |
| A4 | Duży sprite przy ścianie | zrobione i sprawdzone | `test_wall_reach`, `test_wall_point` (Paczka 1) |
| A5 | Tempo pokoi | zrobione i sprawdzone | przepisy spotkań, `test_rooms_pilot` (Paczka 5) |
| A6 | Odróżnialny drugi zamach podwójnego ciosu | częściowo | lustrzany łuk VFX (Paczka 3); osobny dźwięk drugiego zamachu — brak pliku |
| A7 | Gracz ginie wizualnie przy bossie | częściowo | gracz nad wrogami (z-index), poświata przy nakładaniu, ciała bez przenikania (`test_body_physics`); nowy cień kontaktowy — odłożone |
| A8 | Materiał areny/ołtarza | odłożone | potrzebne nowe tekstury (lista w `PREZENTACJA_PACZKA_10.md`) |
| A9 | Techniczne okręgi wokół bossa | zrobione i sprawdzone | krąg runiczny, `test_presentation_pass`, zrzut |
| A10 | Fazy różnią się głównie kolorem | zrobione i sprawdzone | `WZORCE_WCIELEN_I_FAZ.md`, test A10 w `test_encounter_tuning` |
| A11 | Drobny tekst kart | zrobione i sprawdzone | karty „Teraz / Po wyborze”, `test_rewards_pilot` |
| A12 | Niewydane punkty, pasek XP „MAX”, podgląd +1 | zrobione i sprawdzone | przyciski w HUD, `test_rewards_pilot`, `test_stats_screen` |
| A13 | Minimapa | zrobione i sprawdzone | markery, duża mapa (M), `test_routes_pilot` |
| A14 | Mieszane języki, podwójna nazwa fazy | częściowo | nazwy faz po polsku z jednego źródła, bez dublowania; **nazwy do potwierdzenia**; pozostałe angielskie napisy spoza faz nie były przeglądane plik po pliku |
| A15 | Typografia napisów | zrobione i sprawdzone | Cinzel/Garamond, pergamin z obrysem, zrzuty `p10_*` |
| A16 | Pusty ekran statystyk | zrobione i sprawdzone | „Aktywne efekty”, podgląd punktu (Paczka 6) |
| A17 | Ekran zwycięstwa | zrobione i sprawdzone | historia próby i rada, `test_return_pilot` (Paczka 9) |
| — | Pociski przy ścianach | zrobione i sprawdzone | **błąd znaleziony w Paczce 11**: chybione pociski przelatywały nad murem poza pokój; teraz gasną na ścianie (`test_integration_run`) |
| — | 45/60/120 FPS | zrobione i sprawdzone | ta sama walka: 56,2 / 57,1 / 56,6 s, obrażenia ±0,1% — logika nie zależy od klatkażu |
| — | Obciążenie | zrobione i sprawdzone | 12 wrogów + ~290 pocisków, render: średnio 430 FPS, p99 3,1 ms (ta maszyna; słabszy sprzęt — nie sprawdzony) |
| — | Dźwięk: maskowanie, ambient | częściowo | ściszanie muzyki pod telegrafami, limit 3 kopii dźwięku; ambient — brak plików; odsłuch — autor |

## B — trudni, ale uczciwi bossowie

| Punkt | Status | Dowód |
| --- | --- | --- |
| Czas Nemoraksa: mocny 90–150 s, średni 150–240 s | zrobione (bot) | miecz 57 s, hybryda 60 s, różdżka 72–94 s, średni 153 s; przelicznik ×1,6 na człowieka daje ~90–150 s i ~245 s |
| Czas wcieleń: mocny 25–50 s, średni 45–75 s | zrobione (bot) | mocny miecz 17–19 s (~28 s człowiek), średni 41–45 s (~70 s); różdżka 12 s (~20 s) — **lekko poniżej celu** |
| Instrumentacja (czas faz, DPS wg źródła, odmowy) | zrobione i sprawdzone | `debug/measure_*.gd`, `Juice.damage_events` |
| Przelicznik bot → człowiek | niepotwierdzone | ×1,6 wzięty z jednego nagrania — potrzebne nagranie autora |

## C — zasoby i obrona

| Punkt | Status | Dowód |
| --- | --- | --- |
| Trzymana tarcza 140°, koszt za cios, przełamanie gardy | zrobione i sprawdzone | `test_shield` (Paczka 3) |
| Idealny blok = parowanie (decyzja autora) | zrobione i sprawdzone | `test_shield`, parowanie przerywa atak i odbija pocisk |
| Mana: zwrot tylko za pierwotne trafienie | zrobione i sprawdzone | `test_combat_accounting` |
| Mana maga w walce | zrobione — zostawione decyzją autora | dno 5/s do kosztu jednego strzału; różdżka czeka na manę 62–83 s z 72–94 s walki |
| Leczenie wariant C (30% / 12 trafień / 2 zapasy / 0,55 s) | zrobione i sprawdzone | `test_heal_stacks` |
| Jedno źródło liczb | zrobione i sprawdzone | opisy kart z `rank_text`, podgląd statystyk z tej samej formuły |

## D — pokoje i powody, by wracać

| Punkt | Status | Dowód |
| --- | --- | --- |
| Jeden pilotażowy pokój pułapek | zrobione i sprawdzone | prasy w zardzewiałej hali, podgląd pierwszego cyklu, `test_rooms_pilot` |
| Trasy z widoczną decyzją | zrobione i sprawdzone | markery i tabliczki nad drzwiami, odpoczynki (Paczka 7) |
| Ziarno próby, powtórka tego samego układu | zrobione i sprawdzone | `test_integration_run` (to samo ziarno = ta sama mapa), klawisz S po śmierci |
| Pakt fragmentu — jeden pilot | zrobione i sprawdzone | Mordrath ↔ faza Siła, `test_pact_pilot`; pozostałe 5 — **odłożone do akceptacji pilotażu** |
| Komnata Echa | zrobione i sprawdzone | `test_return_pilot` |
| Pętla Otchłani | częściowo | szczebel I; szczeble II–V — odłożone do akceptacji |
| Klątwy Ołtarza | odłożone | E3: w konflikcie z Paktem zachować Pakt |
| Sekrety, wyzwania, dzienne ziarno | odłożone | poza zakresem pilotaży |

## E — feeling i powtarzalność

| Punkt | Status | Dowód |
| --- | --- | --- |
| E1 język zagrożeń, przyczyna nieudanego bloku | zrobione i sprawdzone | napisy bloku (kierunek / brak staminy / nieblokowalny), dźwięk przełamania |
| E1 postawa minibossa | częściowo | pilotaż na Nekravorze; porównanie z wersją bez postawy — autor |
| E2 przepisy spotkań, układy, 4 motywy | zrobione i sprawdzone | `test_rooms_pilot`, `POKOJE_PILOTAZ.md` |
| E2 długość trasy | zrobione (pomiar) | 200 ziaren: pełna 32 pokoje, minimalna 18–29 (mediana 23), poziom 8–10 przed finałem |
| E2 realny „skrót” | odłożone | pytanie do autora |
| E3 intencje, tagi, przerzut | zrobione i sprawdzone | `test_rewards_pilot` |
| E4 Pakt | jak w D | — |
| E5 ekran śmierci/zwycięstwa, Kronika | zrobione i sprawdzone | `test_return_pilot` |
| E5 „Ślad Otchłani”, poziomy progres | odłożone | — |
| E6 ściszanie pod telegrafem, limit hałasu | zrobione i sprawdzone | `test_presentation_pass` |
| E6 nierówność klatek | zrobione (pomiar) | p95/p99 w teście obciążenia |

## Tabela metryk (odpowiednik Paczki 0), bot, 60 FPS

| Starcie | Przed (P2) | Teraz | Uwagi |
| --- | --- | --- | --- |
| Nemorax — miecz mocny | 18,3 s | 57,0 s | 4–7 wzorców/fazę |
| Nemorax — hybryda | 23,9 s | 60,4 s | |
| Nemorax — różdżka | nie kończy | 72–94 s | 3 próby; rozrzut z losowości wzorców |
| Nemorax — średni | — | 152,9 s | |
| Nemorax — goły, poz. 1 | 92,4 s | 354,3 s | punkt odniesienia, nie realny build |
| Wcielenie — średni (16 pokoi) | 1,8–3,8 s | 41–45 s | |
| Wcielenie — mocny miecz (26 pokoi) | 1,8–3,8 s | 17–19 s | |
| Leczenie — naładowane zapasy/min | 3 zapasy natychmiast | 0,8–2,0 / min | |
| Trasa minimalna | — | 18–29 pokoi | |

Poprawka pomiaru w Paczce 11: bot ustawiał gracza 260 px od bossa bez względu na mury. Przy bossie w rogu gracz „stał w ścianie”, a pociski gasną teraz w murze, więc różdżka pozornie utknęła w fazie 1. Bot trzyma teraz gracza w arenie, tak jak prawdziwy mur.

## Dla autora (jutro)

1. Próba z człowiekiem: tarcza i parowanie, postawa Nekravora, pokój pułapek, 4 motywy. Czy rozumiesz, skąd przyszły obrażenia?
2. Nagranie pełnej próby mocnym i średnim buildem — potwierdzi przelicznik ×1,6 i cele z B.
3. Potwierdzić polskie nazwy faz: Ruch, Siła, Instynkt, Dominium, Ruina, Władza.
4. Pakt na Mordracie: czy obie drogi są wartościowe? Dopiero wtedy pozostałe 5 wcieleń.
5. Czy potrzebna jest prawdziwa trasa „skrót”?
6. Odsłuch na słuchawkach: ściszanie muzyki pod telegrafem, fala pocisków, przełamanie gardy.
7. Brakujące assety: `PREZENTACJA_PACZKA_10.md`.
8. `test_room_music` bywał niestabilny (ok. 2 na 8 uruchomień wcześniej; w tej sesji zawsze zielony) — przyczyna nieznana.
