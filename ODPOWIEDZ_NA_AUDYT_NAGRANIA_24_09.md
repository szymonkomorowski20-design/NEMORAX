# Odpowiedź na audyt nagrania z 24.09

Źródło: `AUDYT_NAGRANIA_2026-09-24_DLA_CLAUDE.md`. Klatki nagrania obejrzałem sam w miejscach wskazanych przez audyt (1:55–2:35, 3:55–4:20, 0:20–0:28, 1:12–1:25, 3:28–3:48). Zrzuty przed/po leżą w `docs/audyt_nagrania_24_09/`. „Przed” dla pułapek i wody to nagranie we wskazanych minutach.

Testy automatyczne: **323/323**. Zapisy gracza sprawdzane sumą kontrolną po każdym uruchomieniu.

Jeden incydent: bot pomiarowy dopisał 3 zwycięstwa do `progress.json`, bo arena miała na sztywno własną ścieżkę zapisu. Plik przywróciłem z kopii z 10:00 i przyczynę usunąłem (arena idzie teraz za ścieżką `GameFlow`, jest na to test).

Commity: `32d0b3e` (P0), `d708ed7` (P1 pułapki i motywy), `0e83501` (P1 próby i Pakt), a ten raport z P2 w ostatnim commicie.

## P0 — czytelność obrażeń i sterowania

### 1. Gracz znika przy dużych bossach — zrobione, sprawdzone w renderze

**Zaobserwowane w filmie:** ciemna sylwetka na ciemnej podłodze (2:30, prawy górny róg) i pełny turkusowy dysk, który przy nakładaniu zakrywał samego gracza (3:58, 4:07). Ten dysk to moja poprawka z 23.09. Pomagała w zamyśle, a w praktyce zasłaniała postać.

**Zmiana:**

- Sylwetka dostała stały, subtelny obrys (shader `entities/player_outline.gdshader`).
- Przy nakładaniu na dużego wroga obrys się wzmacnia, sylwetka lekko jaśnieje, a u stóp pojawia się cienki pierścień.
- Dysk usunąłem. Hitbox bez zmian.

**Przed/po:** `01`/`02` (Vhar’Nokh), `03`/`04` (ciemna podłoga). Górną krawędź sprawdziłem osobnym zrzutem: gracz jest czytelny także na ciele Mordratha.

**Uwaga:** pasek HP wroga potrafi przeciąć głowę gracza przy górnej krawędzi. To drobiazg, zostawiony.

### 2. Diagnoza każdego spadku HP — zrobione

- `Juice.player_hits` loguje każdy cios, który doszedł do gracza. Pola: czas, źródło, rodzaj (kontakt, wypad, puls, pocisk, strefa, pieczęć, cień, pułapka), umiejętność, wynik (trafienie, blok, parowanie, przełamanie, poza tarczą z boku lub z tyłu, nieblokowalny, dash, nietykalność), HP i stamina przed/po, stan tarczy, dasha i i-frame, pozycja.
- Log widać pod F3 i na konsoli. Jedno źródło prawdy: wpisy powstają wyłącznie w `Player.take_damage`.

**Odtworzenie:** `debug/repro_hits.gd`, Vhar’Nokh, 3 style gry. Log pokazał, że HP zabierały głównie **wypady tuż po teleporcie** (`double_blink`, `teleport_strike`). Ruszały w tej samej klatce, w której Vhar’Nokh się pojawiał, bez żadnej zapowiedzi. To wyjaśnia wrażenie „nie wiadomo skąd”.

**Poprawka uczciwości (bez zmiany HP ani obrażeń):** po teleporcie jest 0,35 s zapowiedzi. Poza to „telegraph” plus złota strzałka kierunku, a kierunek wypadu jest zablokowany, więc wystarczy krok w bok. Dotyczy też Orryksa po powrocie z cienia. Bot przy dystansie oberwał wypadem 3× zamiast 8×.

**Przed/po:** `05`. Nadal hipotezą pozostaje, czy 0,35 s wystarcza człowiekowi.

### 3. Tarcza i parowanie — zrobione. Laboratorium: `debug/shield_lab.tscn` (F6)

- Kukła uderza po kolei: przód, parowanie, bok, tył, cios nieblokowalny, przełamanie.
- Log zgadza się z regułami:
  - blok 12 + 0,9 × 18 = 28 staminy;
  - parowanie nic nie kosztuje;
  - bok, tył i cios nieblokowalny przechodzą z pełnymi obrażeniami;
  - przełamanie przy 20 < 28 zeruje staminę.
- Każdy wynik ma osobną reakcję:
  - **blok:** głuchy dźwięk i jasny łuk;
  - **parowanie:** ostrzejszy dźwięk, pierścień i napis;
  - **ześlizgnięcie:** wysoki zgrzyt (placeholder) i napis „Z boku — poza tarczą” albo „Z tyłu — poza tarczą” (wcześniej bok też pokazywał „z tyłu”);
  - **przełamanie:** niski dźwięk i pęknięty łuk.

**Przed/po:** `08`, `09`. Hipoteza do sprawdzenia przez ciebie: czy nowa osoba po kilku próbach powie, co się stało.

### 4. Postawa Nekravora — zrobione (bot). Czytelność ocenia człowiek

- **Ostrzeżenie:** od 75% progu linia postawy jest grubsza i pulsuje (`06`).
- **Przełamanie:** przez cały czas trwania wcielenie otacza przerywany turkusowy krąg w kolorze gracza, czyli okazji. Wyraźnie różni się od czerwonych liczb HP (`07`).
- **Oś czasu** (`measure_incarnation`, rozdział 3): po każdym przełamaniu Nekravor wykonuje jeszcze umiejętności — 10 (wczesny build), 11 (średni), 4 (mocny). Stun-locku nie ma: najwyżej 2 przełamania na walkę, potem 6 s odporności.

## P1 — pułapki i cztery motywy

### 5. Kryształy — zrobione

Równe trójkąty co 64 px zamieniłem na nieregularne kępy osadzone u stóp muru. Cykl: spoczynek → rozjarzenie, gdy pocisk zbliża się do ściany → błysk przy odbiciu → wygaszenie. Granica odbicia to wciąż dokładnie krawędź pokoju. **Po:** `10`.

### 6. Płyty w hali — zrobione

Płyty to teraz osadzone moduły: szczelina, śruby, głowica. Trzy stany jasności (spoczynek, świecące fugi w zapowiedzi, jasna głowica i fala pyłu przy uderzeniu) oraz stygnięcie. Kreskowanie zostało wyłącznie jako warstwa ostrzegawcza w zapowiedzi. **Po:** `11` i matryca `23`.

### 7. Brzeg wody — zrobione

- miękkie wejście w wodę (gradient 24 px);
- ciemny pas mokrego kamienia za brzegiem;
- ciągła, falująca linia brzegu;
- kręgi fal u stóp postaci stojących w wodzie.

Obszar spowolnienia bez zmian. **Po:** `12`.

### 8. Matryca motywów — zrobione. `debug/motif_matrix.gd`

Arkusz dla każdego motywu przy tym samym zoomie: pusty pokój, walka, 2 stany motywu, gracz w każdych z 4 drzwi (`20`–`23`).

Matryca znalazła dwa błędy w bibliotece:

1. Stojący regał był płaskim brązowym prostokątem.
2. Po powrocie do wyczyszczonej biblioteki regały przewracały się ponownie.

Oba naprawione. Szwów podłoga–ściana ani problemów z osadzeniem portali nie znalazłem. Globalnego rozjaśnienia nie dodawałem.

## P1 — przebieg próby i decyzje

### 9. Mnożnik ×1,6 nie jest balansem — zrobione

`debug/measure_run.gd` (ziarno + polityka) i tabela w `PROBY_I_PAKT_24_09.md`. Najważniejszy wynik: **niewydane punkty i runy wydłużają trasę ~2,5× i finał ~3×, dając 27–30 momentów bliskich śmierci zamiast 1–5.** HP bossów nie ruszałem.

### 10. Przypomnienie o nagrodach — zrobione

- W walce przyciski zwijają się do przygaszonej plakietki (`13`).
- Po oczyszczeniu pokoju pojawia się jedno wyraźne przypomnienie na 2,5 s, nie częściej niż co 45 s dla tego samego stanu (`14`).
- Nic nie otwiera się samo.

### 11. Pakt — zmierzone, bez zmian wartości

- „Zwiąż” kosztuje w fazie Siła +60–90 HP i 1 moment bliski śmierci.
- Pole ciszy łapało w pokojach 1 wroga, czyli tyle, ile przerywa już samo parowanie.

Propozycje (promień 220 px i 1,6 s albo cisza także na zwykłym bloku) czekają na twoją decyzję. Szczegóły w `PROBY_I_PAKT_24_09.md`. Paktu nie kopiowałem na inne wcielenia.

### 12. Skrót — odłożony z danymi

Rekomenduję na razie go nie wdrażać. Szczegóły w `PROBY_I_PAKT_24_09.md`.

## P1/P2 — prezentacja i audio

### 13. Nazwy faz

Bez zmian (Ruch, Siła, Instynkt, Dominium, Ruina, Władza), jedno źródło: `Palette.PHASE_NAMES`.

### 14. Odsłuch — scena gotowa. PASS wymaga twojego ucha

`debug/audio_lab.tscn` (F6):

1. telegraf (M przełącza muzykę);
2. fala 10 pocisków;
3. blok → parowanie → przełamanie.

Na ekranie widać poziom muzyki i szczyt jednoczesnych efektów. Tryb auto zmierzył:

- telegraf: muzyka −8 dB;
- fala: najwyżej 3 dźwięki naraz;
- przełamanie: ściszenie muzyki.

### 15. Assety — lista zaktualizowana w `PREZENTACJA_PACZKA_10.md`

Placeholdery są podpięte: zgrzyt ześlizgnięcia, dźwięk przełamania i stany pułapek oraz wody rysowane kodem. Nowe pliki są opcjonalne. Żaden z wymienionych plików jeszcze nie istnieje.

### 16. Niestabilny test muzyki — przyczyna ustalona, 100/100

- **Mechanizm:** gdy prolog nie był oznaczony jako obejrzany, pokój startowy go odpalał. Cutscenka pauzowała drzewo, a muzyka pokoju pauzowała się razem z nim, więc `playing = false`.
- **Odtworzenie:** 100/100 porażek przy nieobejrzanym prologu, 0/100 przy obejrzanym.
- **To też prawdziwa usterka:** **pod prologiem muzyka milkła.**
- **Naprawa:** muzyka pokoju gra niezależnie od pauzy (także w menu pauzy — zmiana zachowania do oceny).
- **Test:** rozdzielony na „utwór i pętla”, „odtwarzanie ruszyło” i „muzyka pod prologiem”, każdy z własnymi warunkami wstępnymi. 100 powtórzeń przy losowym stanie prologu: 0 porażek.

## Do twojej decyzji albo próby

1. **Zagraj z Vhar’Nokhem:** czy 0,35 s zapowiedzi po teleporcie wystarcza i czy teraz widzisz, skąd przychodzi cios?
2. **Laboratorium tarczy:** czy rozróżniasz blok, parowanie, ześlizgnięcie i przełamanie bez patrzenia w log?
3. **Laboratorium dźwięku na słuchawkach:** oceń telegraf, falę i przełamanie. Powiedz też, czy muzyka ma grać w menu pauzy, czy tylko pod cutscenkami.
4. **Pakt:** zostawić, czy przetestować wzmocnione „Zwiąż” (220 px / 1,6 s albo cisza na zwykłym bloku)?
5. **Skrót:** potwierdź, że na razie odkładamy.
6. **Dwie pełne próby na nagraniu:** mocna i średnia. Dopiero one zatwierdzą albo obalą przelicznik bot → człowiek.
