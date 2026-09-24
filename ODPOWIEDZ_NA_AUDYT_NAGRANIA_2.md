# Odpowiedź na drugi audyt nagrania (24.09, pełna zwycięska próba)

Źródło: `AUDYT_NAGRANIA_2_2026-09-24_DLA_CLAUDE.md`. Klatki obejrzałem sam we wskazanych miejscach: 11:15 statystyki, 15:30 i 16:45 fazy, 17:08–17:35 mała forma. „Przed” to nagranie, „po” to zrzuty z gry w `docs/audyt_nagrania_2/`.

Testy automatyczne: **334/334**. Zapisy gracza zabezpieczone kopią i sumą kontrolną. Suma zmieniła się tylko o 11:25, bo wtedy grałeś.

Zgodnie z audytem **nie ogłaszam „wszystko gotowe”**. Brakuje odbioru średniego buildu przez człowieka i odsłuchu.

## Pakiet A

### A1. Okno statystyk — zrobione, PASS na zrzutach 720p i 1080p

- **Przyczyny:**
  - `draw_string` z szerokością **ucina** tekst, zamiast go zawijać;
  - przy wielu efektach wysokość wierszy malała, aż tekst wchodził na stopkę;
  - tło miało 92% krycia, więc drwiny i HUD prześwitywały.
- **Zmiana:**
  - nieprzezroczyste okno w dwóch panelach (statystyki po lewej, efekty po prawej);
  - każdy opis zawinięty w całości, Pakt pokazuje osobno „Teraz” i „W finale”;
  - lista przewijana PgUp/PgDn i kółkiem myszy, z licznikiem „wpisy X–Y z N”;
  - stopka w stałym pasie.
- **Pod każdym modalnym oknem** (wszystkie pauzują grę) HUD chowa drwiny, karty relikwii i przyciski nagród.
- **Dowód:** `01` (720p) i `02` (1080p, strona 2): poziom 10, Pakt, 15 efektów, a pod spodem wisi drwina Vhar’Nokha, której nie widać. Test: `test_second_audit`.

### A2. Władza i mała forma — zrobione, ślepy test po twojej stronie

- **Boss w mroku:** sprite dalej znika, zgodnie z twoją decyzją z 23.09. Zostaje jednak **uczciwy ślad**:
  - runiczny krąg kontaktu, czyli dokładny promień kolizji ciała, nie gaśnie poniżej 35%;
  - dwa tlące się oczy.

  Kontakt z ciałem nie przychodzi już z pustki (`03`, `06`).
- **Granica sali** (krawędź i narożniki) rysuje się nad ciemnością (`03`, `04`).
- **Gracz** ma obrys i pierścień u stóp także na ciele bossa w mroku (`05`).
- **Kolejność warstw:** strefy, pieczęcie, pociski, telegrafy i liczby rysują się **nad** mrokiem. Jedynym elementem, który gasł, było ciało bossa — teraz ma ślad. Każde źródło obrażeń w Władzy jest więc widoczne na ekranie.
- **Do zrobienia przez ciebie:** ślepy test (<1 s na wskazanie gracza, bossa i ataku).

### A3. Pierścień i strefy — zrobione (`07`)

Kolizje bez zmian — rysunek krawędzi leży dokładnie na promieniu obrażeń.

- **Strefy:**
  - zapowiedź: przerywany brzeg, który wypełnia się od środka;
  - aktywna: pełny brzeg z pulsem przy każdym tyknięciu;
  - **nowy stan „wygasa”:** 0,45 s bez obrażeń, szary.
- **Pieczęcie:** brzeg na promieniu wybuchu i wypełnienie w zapowiedzi, a po wybuchu krótki rozbłysk (wcześniej znikały w klatce).
- **Telegraf bossa:** runiczne segmenty z pęknięciami zamiast gładkiego złotego okręgu.

### A4. Arena — zrobione (`08`, `09`)

- Finał ma teraz ten sam system co pokoje: salę z murem i zapieczętowanymi bramami (motyw sali rytuału, ciemny kamień).
- Spaczenie Nemoraksa to miękka warstwa przy krawędziach posadzki. Środek zostaje spokojny, bez pełnoekranowego filtra.
- Obraz jest rozciągnięty tak, że wewnętrzna krawędź muru leży **dokładnie** na dotychczasowej granicy ruchu. Kolizje i geometria walki się nie zmieniły (test).
- Grafika `nemorax_arena_floor.png` z twojego folderu jest jasna i neonowa, więc jej nie użyłem. Stara posadzka z shaderem zostaje jako rezerwa.

## Pakiet B

### B1. Tempo faz — zmierzone. Jedna zmiana bez wpływu na balans

Polecenie: `debug/measure_phases.gd -- <build> 4242`. Stałe ziarno wzorców, bot bez nieśmiertelności. „Wzorce” oznacza, ile własnych wzorców faza pokazała, zanim padła.

| Faza | Miecz (mocny) | Hybryda | Średni | Kontra (defensywny) |
|---|---|---|---|---|
| Ruch | 4,1 s · **2/3** | 7,2 s · 3/3 | 15,7 s · 3/3 | 14,0 s · 3/3 |
| Siła | 8,2 s · 3/3 | 7,7 s · 3/3 *(przed zmianą: 2/3, 6 ataków bez F2)* | 21,2 s · 3/3 | 22,1 s · 3/3 |
| Instynkt | 9,2 s · 3/3 | 8,6 s · 3/3 | 21,6 s · 3/3 | 21,0 s · 3/3 |
| Dominium | 9,0 s · 5/5 | 8,7 s · 5/5 | 23,1 s · 5/5 | 23,1 s · 5/5 |
| Ruina | 9,1 s · 3/3 | 9,1 s · 3/3 | 25,1 s · 3/3 | 24,1 s · 3/3 |
| Władza | 11,3 s · 4/4 | 13,1 s · 4/4 | 27,3 s · 4/4 | 26,3 s · 4/4 |
| Mała forma | 9,3 s · 4/4 | 11,4 s · 4/4 | 26,9 s · 4/4 | 27,5 s · 4/4 |
| **Razem** | **60 s** | **66 s** | **161 s** | **158 s** |

Pełny raport (ciosy przyjęte i zadane, leczenia, HP/stamina/mana na wejściu i wyjściu) daje ten sam skrypt.

**Zmiana — „chroniony pierwszy cykl”:** w każdej fazie boss najpierw zagrywa każdy swój wzorzec raz, a dopiero potem losuje. Nie dodaje to czasu, HP ani nietykalności — zmienia tylko kolejność.

**Nie zmieniałem:** Ruch u mocnego miecza trwa 4,1 s, czyli 2 ataki, a faza ma 3 wzorce. To kwestia czasu, a audyt każe nie zmieniać balansu bez porównania. Średni build i Kontra widzą każdy wzorzec 2–9 razy. Czy Ruch u mocnego buildu ma trwać dłużej (np. pierwszy atak szybciej po wejściu), jest do twojej decyzji.

### B2. Log = obraz = dźwięk = liczby — zrobione (`test_contact_consistency`)

- 10 kolejnych kontaktów w każdej z 7 klas: blok, parowanie, bok, tył, nieblokowalny, przełamanie, bez tarczy.
- Dla każdego kontaktu zgadzają się wynik w logu, napis nad graczem, osobny dźwięk, HP i stamina: **0 rozjazdów w 70 kontaktach**.
- Kontrola negatywna (celowo zły napis) jest wykrywana, więc test nie przechodzi na pusto.
- Nekravor: 2 pełne przełamania, odporność i powrót — test.
- Klip z UI i próbę „kiedy mam okno” z człowiekiem zostawiam tobie (laboratoria: `debug/shield_lab.tscn`, F6).

### B3. Oferty run — potwierdzona hipoteza audytu, naprawione

Gwarancja przydatnej karty liczyła Przeplot jako przydatny dla gracza grającego jedną bronią.

| Styl | Martwe oferty — stara gwarancja | Martwe oferty — nowa gwarancja |
|---|---|---|
| Tylko miecz | **8 / 1000** | **0 / 1000** |
| Tylko różdżka | **4 / 1000** | **0 / 1000** |

- Hybryda i intencje bez zmian.
- To samo ziarno daje tę samą ofertę (test).
- Przy 10/10 pasek pokazuje „Poz. 10 · MAX”. Niewydane punkty sygnalizuje plakietka w walce i przypomnienie po walce.

### B4. Pakt — zmierzony, wartości w grze bez zmian

Techniczny wariant „Zwiąż 220 px / 1,6 s” jest za flagą testową (`PactCatalog.test_bind_boost`), w grze wyłączony.

Nowe znalezisko: parowanie przy „Zwiąż” opóźnia też **następny atak Nemoraksa** (`boss.silence`). Poprzedni pomiar tego nie złapał, bo bot nigdy nie parował.

Wyniki (build średni, stałe ziarno):

| Wariant | Styl bota | Faza Siła: przyjęte HP | Dolewki w Sile | Parowania w walce |
|---|---|---|---|---|
| Oczyść | atak | 154 | 0 | — |
| Zwiąż | atak | 198 | 1 | — |
| Oczyść | tarcza (0,30 s ataku / 0,45 s tarczy) | 186 | 1 | 0 |
| Zwiąż | tarcza | 184 | 1 | 3 |
| Zwiąż 220 / 1,6 | tarcza | 162 | 0 | 4 |

**Kiedy A, a kiedy B:**

- **Oczyść** dla gracza, który rzadko paruje i gra agresywnie: +20 staminy i prostsza faza Siła (bez pierścienia pieczęci, ok. −40 HP przyjętych).
- **Zwiąż** dla gracza, który paruje świadomie: każde parowanie ucisza wrogów w 160 px i opóźnia następny atak bossa o 1,2 s. Koszt to pierścień pieczęci w Sile.

Bot paruje 3–4 razy na walkę, bo brakuje mu staminy na tarczę, więc wartości „Zwiąż” w rękach człowieka nie rozstrzyga. Decyzję (zostawić czy włączyć 220/1,6) podejmiesz po próbie obu dróg.

## Pakiet C

### C1. Minimapa — poprawione (`10`)

Mapa leżała wprost na grafice muru i była mała. Teraz ma ciemne tło z ramką, komórki 18 px zamiast 14 i podpowiedź „[M] mapa” pod panelem. Algorytm odwiedzin i symbole bez zmian. Test „wskaż trasę bez pamięci” należy do ciebie.

### C2. Prasy i woda — granica obrazu = fizyka

- **Woda:** przejście tafli było wcześniej przezroczyste akurat na granicy spowolnienia. Teraz jest wyśrodkowane na tej granicy (w połowie widoczne), a linia brzegu leży dokładnie na krawędzi strefy.
- **Prasy:** kolizja to prostokąt płyty minus 4 px (środek gracza), a obraz ma szczelinę 3 px na zewnątrz. Zapowiedź jest więc minimalnie większa niż strefa, zgodnie z zasadą „telegraf nigdy mniejszy”. Prasy rysują się pod postaciami (z −3), więc nie zakrywają wrogów.

### C3. Dźwięk — PASS wymaga twojego ucha

`debug/audio_lab.tscn` ma sceny:

1. telegraf pod muzyką;
2. fala pocisków;
3. blok / parowanie / przełamanie;
4. **nowa:** prasa — zapowiedź i uderzenie;
5. **nowa:** cisza fazy Siła.

Brakuje dźwięku wejścia w wodę. Dopisuję go do listy assetów: `S_water_step.wav`, chlupot 0,2 s, 2–3 warianty.

### C4. Ekrany końca — znaleziony i naprawiony błąd

- **Błąd:** ekran śmierci i zwycięstwa przyjmował klawisze w klatce pojawienia się. Na dodatek S („ta sama próba”) był sprawdzany jako **trzymany**, a S to ruch w dół. Gracz idący w dół w chwili śmierci lub zwycięstwa **natychmiast restartował próbę**, nie widząc podsumowania. Enter pomijający ostatni dialog epilogu mógł z kolei od razu zacząć nową próbę. To prawdopodobnie tłumaczy szybki start o 17:37.
- **Naprawa:** `EndScreenGate`:
  - 1,2 s na przeczytanie wyniku;
  - S działa dopiero po puszczeniu klawisza od chwili pokazania ekranu;
  - dotyczy areny i pokoi, także treningu.

  Test: `test_second_audit`.
- **Bez zmian i sprawdzone:** reset poziomu i punktów przy nowej próbie oraz zachowana Kronika i liczba ukończeń (istniejące testy).

## Dla ciebie — potrzebne do PASS

1. **Ślepy test Władzy i małej formy:** czy w <1 s wskazujesz gracza, bossa (krąg i oczy), nadchodzący atak i bezpieczny kierunek?
2. **Próba średnim buildem na nagraniu.** To nadal brakujący dowód.
3. **Pakt:** zagrać „Zwiąż” i powiedzieć, czy parujesz dość często, żeby się opłacał. Na tej podstawie zdecydować, czy włączyć 220 px / 1,6 s.
4. **Ruch u mocnego buildu:** 2 z 3 wzorców w 4 s — zostawić czy wydłużyć otwarcie?
5. **Laboratorium dźwięku** (sceny 1–5) na słuchawkach.
6. **Minimapa:** czy wskażesz trasę bez pamięci?
