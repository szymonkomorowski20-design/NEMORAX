# NEMORAX

*Nie pamiętasz, jak tu trafiłeś. To normalne. Nikt z nas nie pamięta.*

**Wersja finalna 1.0 — 24.09.2026** · Windows 64-bit · roguelike akcji w rzucie z góry · Godot 4.7

---

## Pobierz i graj

1. Pobierz `NEMORAX_Windows_2026-09-24.zip` z zakładki **Releases** tego repozytorium.
2. Rozpakuj **całą** paczkę do wybranego folderu (nie uruchamiaj gry ze środka ZIP).
3. Uruchom `NEMORAX.exe`. Pliki `NEMORAX.exe` i `NEMORAX.pck` muszą leżeć obok siebie.

Gra nie wymaga instalacji. Postęp zapisuje się automatycznie w `%APPDATA%\Godot\app_userdata\NEMORAX`.

## O grze

Budzisz się w pierwszej sali labiryntu bez wspomnienia, jak się tu znalazłeś
— i bez pytania, czy to już który raz. Gdzieś w plątaninie sal czeka sześć
istot, każda niegdyś czymś więcej niż potworem: Wygnany z Otchłani, Ten Bez
Wymiaru, Pożeracz Granic, Odrzucony, Pęknięty Pomiędzy Światami, Cień
Nicości. Dawno temu zostały złączone w jedno ciało — świadomie, nie
przypadkiem — żeby to, czym się staną razem, nigdy nie zdążyło się w pełni
obudzić.

Twoje zadanie jest proste do wypowiedzenia: znajdź sześć fragmentów duszy,
zanieś je do ołtarza, złóż w całość to, co próbowało zostać rozdzielone na
zawsze, i utnij to, zanim się dokończy. Zrobiłeś to już wcześniej. Coś w
tobie o tym wie, nawet jeśli ty nie wiesz.

## Cel gry

Przemierz losową siatkę pokoi, pokonaj sześć wcieleń strzegących fragmentów
duszy i zanieś komplet do ołtarza. Rytuał przywołuje Nemoraksa: sześć faz
dużej formy, zwrot akcji i walka z małą formą. Śmierć kończy próbę — możesz
zacząć od nowa na świeżej mapie albo powtórzyć **tę samą** mapę z tego samego
ziarna, żeby sprawdzić inną decyzję.

## Co oferuje gra

- **Losowa mapa jak w *The Binding of Isaac*** — 32 pokoje (start, 24 pokoje
  z walką, 6 pokoi wcieleń, ołtarz) połączone w graf. Nad drzwiami i na mapie
  widać, co czeka dalej: elita, pułapka, skrzynia, odpoczynek, wcielenie.
  Każda próba ma **ziarno** — można ją powtórzyć 1:1.
- **Walka mieczem i różdżką** przełączanymi w locie, dash z chwilą
  nietykalności i **trzymana tarcza** (łuk 140°). Blok kosztuje staminę za
  każdy przyjęty cios, **parowanie** w dobrym momencie jest darmowe, przerywa
  atak i odbija pociski. Zbyt mało staminy = **przełamanie gardy**. Każdy
  wynik ma własny napis i dźwięk.
- **Leczenie** z zapasów ładowanych celnymi trafieniami (30% HP, 2 zapasy).
- **Pokoje z charakterem** — przepisy spotkań zamiast przypadkowych grup,
  układy z osłonami, cztery motywy z mechaniką (spowalniająca woda,
  przewracane regały-osłony, kryształy odbijające pociski, pokój pułapek
  z prasami w rytmie).
- **11 archetypów wrogów** i ich elitarne warianty.
- **Sześć wcieleń** — każde z własnymi wzorcami i zapowiedziami ataków;
  Nekravor ma dodatkowo **postawę**, którą można przełamać.
- **Rozwój w próbie** — poziomy 0–10 z punktami statystyk, **28 run**
  z opisem „teraz → po wyborze”, **10 relikwii** ze skrzyń, trzy
  **intencje startowe** (Ostrze, Różdżka, Kontra). Wybory nie otwierają się
  same — przyciski w HUD czekają, aż zechcesz.
- **Pakt fragmentu** (Mordrath) — dwie drogi użycia mocy fragmentu, każda
  z jawną konsekwencją w finale.
- **Finał z Nemoraksem** — fazy Ruch, Siła, Instynkt, Dominium, Ruina
  i Władza, każda z własną regułą i muzyką; w każdej fazie boss najpierw
  pokazuje każdy swój wzorzec raz.
- **Powody, by wrócić** — ekran końca z historią próby i jedną radą,
  **Kronika** ostatnich prób, **Komnata Echa** (trening spotkanych wcieleń)
  i **Pętla Otchłani I** po pierwszym zwycięstwie.
- **Pełna oprawa dźwiękowa** — motyw przewodni, muzyka eksploracji, walki,
  elit, wcieleń, rytuału, sześciu faz finału, epilogu i porażki; efekty dla
  tarczy, pułapek, stref i mroku.
- **Dostępność** — ograniczenie migania i wstrząsów, pełne przypisywanie
  klawiszy, głośność osobno dla muzyki, efektów i interfejsu.

## Sterowanie

| Klawisz | Akcja |
|---|---|
| WASD | Ruch |
| Spacja | Dash (nietykalność w trakcie) |
| LPM | Atak aktualną bronią |
| PPM (trzymany) | Tarcza — blok z przodu; podniesiona tuż przed ciosem = parowanie |
| 1 / 2 | Miecz / Różdżka |
| E | Leczenie (zużywa jeden zapas) |
| F | Podniesienie duszy / otwarcie skrzyni |
| R | Wybór runy i punktów po awansie |
| Q | Wybór relikwii ze skrzyni |
| P | Pakt fragmentu |
| M | Duża mapa z legendą |
| Tab | Statystyki postaci (PgUp/PgDn — lista efektów) |
| Escape | Pauza |

Wszystkie klawisze gry można przypisać na nowo w opcjach.

---

## Dla deweloperów

- Godot **4.7.2** (projekt otwierany przez `project.godot`, scena główna `menu.tscn`).
- `autoload/` — `palette.gd` (kolory, nazwy faz, domyślne klawisze),
  `keybinds.gd`, `juice.gd` (hitstop, wstrząsy, muzyka scen, log ciosów
  w gracza pod F3), `game_flow.gd` (mapa, ziarno, zapis, Pakt, Kronika).
- `entities/` — gracz, Nemorax (`boss.gd`), ataki bossa, wspólny szkielet
  wcieleń i wrogów (`incarnation.gd`) z podklasami, katalogi run i Paktu.
- `rooms/` — pokój (`room.gd`), teren i pułapki (`room_terrain.gd`),
  przepisy spotkań (`encounter_plan.gd`), ołtarz, drzwi, skrzynie.
- `ui/` — HUD, minimapa, karty wyborów, statystyki, ekrany końca.
- `debug/` — narzędzia pomiarowe i laboratoria (poniżej).

### Testy

```
Godot_v4.7.2-stable_win64_console.exe --headless --script res://tests/test_runner.gd
```

albo `./run_tests.ps1` w PowerShellu. **341 testów**; runner izoluje zapisy
testowe od zapisu gracza.

### Narzędzia pomiarowe i laboratoria

| Plik | Do czego |
|---|---|
| `debug/measure_run.gd` | pełna próba z ziarna, polityka wydawania punktów |
| `debug/measure_phases.gd` | tempo faz Nemoraksa i pełne cykle wzorców |
| `debug/measure_boss_fight.gd`, `measure_incarnation.gd` | czasy walk dla buildów |
| `debug/measure_pact.gd` | porównanie dróg Paktu |
| `debug/repro_hits.gd` | skąd gracz traci HP (log ciosów) |
| `debug/motif_matrix.gd` | arkusz zrzutów czterech motywów pokoi |
| `debug/shield_lab.tscn` | laboratorium tarczy (F6 w edytorze) |
| `debug/audio_lab.tscn` | laboratorium dźwięku (F6 w edytorze) |

### Dokumentacja projektu

- `STATUS_A_E.md` — status punktów pierwszego audytu i metryki.
- `ODPOWIEDZ_NA_AUDYT_NAGRANIA_24_09.md`, `ODPOWIEDZ_NA_AUDYT_NAGRANIA_2.md`
  — odpowiedzi na audyty nagrań, zrzuty w `docs/`.
- `PROBY_I_PAKT_24_09.md`, `POMIARY_WALKI.md` — pomiary balansu.
- `LISTA_DZWIEKOW.md` — spis dźwięków i ich użycia.
- `CHANGELOG.md` — historia zmian.

## Twórcy i licencje

- Projekt, kierunek i testy gry: **Szymon Komorowski**.
- Kod: rozwijany z pomocą Claude Code (Anthropic); grafiki generowane
  z pomocą narzędzi AI według dokumentów w repozytorium.
- Muzyka i część efektów dźwiękowych: **Pixabay** (Pixabay Content License).
- Czcionki: Cinzel i EB Garamond (SIL Open Font License).
