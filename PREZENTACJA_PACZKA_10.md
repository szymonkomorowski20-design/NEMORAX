# Paczka 10 — spójność wizualna, dźwięk i interfejs świata

Stan: **częściowo** (kod zrobiony i sprawdzony; części zależne od nowych grafik/dźwięków odłożone — lista na dole).

## Co zmieniono

| Punkt | Zmiana | Dowód |
| --- | --- | --- |
| A14 | Jedno miejsce nazw faz: `Palette.PHASE_NAMES` = Ruch, Siła, Instynkt, Dominium, Ruina, Władza. Z tej samej listy korzystają baner, pasek bossa, ekran końca i karta Paktu (usunięty duplikat `PHASE_NAMES_PL` w `arena.gd`). **Nazwy do potwierdzenia przez autora.** | `test_boss_new_phases`, zrzut `p10_banner` |
| A14 | Kiedy baner fazy jest na ekranie, pasek bossa pokazuje samo „Nemorax” — nazwa fazy nie wisi dwa razy u góry. | `test_presentation_pass`, zrzuty `p10_banner` / `p10_taunt` |
| A15 | Napis środkowy: zamiast systemowej czcionki w czystej bieli — Cinzel (baner fazy/komnaty) albo EB Garamond (kwestie), kolor pergaminu `#EDE3CF`, ciemny obrys, łagodne zejście w ostatnich 0,35 s, obsługa wielu linii. Pasek bossa tą samą czcionką. | zrzuty |
| A9 | Krąg kontaktu bossa jest runiczny: 12 łuków z przerwami i nacięcia run, obracające się powoli (0,25 rad/s). Hitbox bez zmian. Telegraf wypadu dalej jest pełną, grubą linią w kolorze zagrożenia — czytelność ponad klimat. | `test_presentation_pass`, zrzut `p10_banner` |
| A16 | Przełamanie gardy ma własny, niski dźwięk (zastępczo P14 z obniżoną wysokością, osobny odtwarzacz — dźwięk bólu go nie ucina). | `test_presentation_pass` |
| A16 | Muzyka ustępuje telegrafom wcieleń i nieudanemu blokowi: −8 dB na czas zapowiedzi, powrót w 0,5 s. Ściszany jest węzeł muzyki, **nie** bus — głośność busa to ustawienie gracza w Opcjach. | `test_presentation_pass` |
| A16 | Ten sam dźwięk świata gra najwyżej 3 razy naraz, każda kolejna kopia o 3 dB ciszej — fala pocisków lub kilku wrogów ginących naraz nie zlewa się w hałas. | `test_presentation_pass` |

Arena bossa nie ma muzyki (tak było wcześniej), więc ściszanie działa w pokojach z wcieleniami. Faza Siła w dalszym ciągu wycisza Master, chyba że gracz wybrał Pakt „Oczyść ciszę”.

## Odłożone — wymagają nowych assetów albo decyzji autora

| Co | Dlaczego odłożone | Czego potrzeba |
| --- | --- | --- |
| Materiał ołtarza/finału i granica areny (A7–A8) | Obecna arena używa tekstury podłogi; przyciemnienie tej samej podłogi jest zakazane w planie. | Tekstura krawędzi areny oraz materiał podłogi ołtarza (kafel 512×512, ta sama paleta co komnaty). |
| Ambient czterech pilotażowych motywów | Katalog `assets/audio/ambient/` jest pusty. | 4 pętle ambientu 30–60 s: zalana katakumba (kapanie, woda), biblioteka (skrzypienie regałów), kryształowa grota (dzwonienie), zardzewiała hala (metal, prasy). |
| Dźwięk przełamania gardy | Jest zastępczy (P14 z obniżoną wysokością). | Plik `P15_guard_break.wav`: pęknięcie tarczy, 0,4–0,6 s. |
| Dźwięk ześlizgnięcia z tarczy (bok/tył) | **Aktualizacja 24.09:** jest zastępczy — P14 wysoko (×1,9) i ciszej, osobny odtwarzacz. | Plik `P16_block_slip.wav`: krótki metaliczny zgrzyt, 0,2–0,3 s. |
| Odsłuch na słuchawkach | Automatyczny test nie zastąpi ucha. | Autor: `debug/audio_lab.tscn` (F6) — sceny 1–3; ściszanie −8 dB pod telegrafem, najwyżej 3 kopie tego samego dźwięku. |

## Dopisane po audycie nagrania 24.09 (P1.5–P1.7, P2.15)

Pułapki i woda mają teraz stany rysowane kodem (bez nowych plików). Grafiki poniżej są opcjonalne: poprawią materiał, ale nie są potrzebne do czytelności.

| Co | Stan teraz | Docelowy asset (opcjonalnie) |
| --- | --- | --- |
| Kryształy przy murze (grota) | kępy rysowane wielokątami, rozjarzenie przy zbliżeniu pocisku, błysk przy odbiciu | 3–4 sprite’y kęp kryształu 64–96 px, przezroczyste tło, paleta groty; opcjonalnie wariant „świecący” |
| Moduł prasy (hala) | płyta ze szczeliną, śrubami i głowicą rysowana kodem; 3 stany jasności | kafel 128×128 osadzonej płyty prasy (spoczynek) + nakładka świecących fug (zapowiedź) + głowica (uderzenie) |
| Brzeg wody (zalana katakumba) | gradient wejścia, mokry kamień, falująca linia brzegu, kręgi u stóp | pasek 512×32 mokrego brzegu (kafelkowany) i drobna tekstura tafli 256×256 z kaustyką |
| Stojący regał (biblioteka) | tekstura muru przyciemniona na drewno + linie półek | sprite frontu regału z książkami 64×160 |
