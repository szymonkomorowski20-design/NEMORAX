# NEMORAX

*Nie pamiętasz, jak tu trafiłeś. To normalne. Nikt z nas nie pamięta.*

---

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

Sala za salą, fragment za fragmentem, aż zostanie tylko ołtarz i pytanie,
które usłyszysz na końcu — zadane głosem, który naprawdę pamięta, ile razy
już je zadawał.

## Co oferuje gra

- **Losowa siatka pokoi w stylu *The Binding of Isaac*** — 30 pomieszczeń
  (1 startowe + 24 z losowym przeciwnikiem + 6 strzeżonych przez wcielenie +
  1 ołtarz) połączonych w graf, nie w korytarz. Wybierasz własną drogę i
  możesz ukończyć grę bez czyszczenia wszystkiego — wystarczy dotrzeć do
  sześciu fragmentów duszy i do ołtarza.
- **Responsywna walka wręcz/na dystans** — miecz i różdżka przełączane w
  locie, dash z chwilą nietykalności, blok odpychający wrogów, system
  leczenia bankujący się w stacki za celne trafienia. Wejście buforowane
  (naciśnięcie tuż przed odnowieniem ataku/dasha i tak się liczy), trafienia
  dają wyczuwalne zatrzymanie klatki i drżenie ekranu.
- **12 archetypów wrogów losowych** — od uporczywego Chasera i wytrzymałego
  Tanka, przez dystansowego Shootera i kontrolującego teren Zonera, po
  Summonera przywołującego posiłki i Elitarne warianty dowolnego z nich.
  Każdy z własnym zestawem zachowań (pościg, utrzymywanie dystansu,
  krążenie), nie tylko innym paskiem zdrowia.
- **Sześć wcieleń hybrydy** — miniboss na koniec każdej z sześciu ślepych
  odnóg mapy, każdy z trzema unikalnymi umiejętnościami plus jednym
  złożonym wzorcem łączącym dwie z nich, przyspieszający atak, gdy pada
  nisko na zdrowiu.
- **System poziomów i skrzynie z ulepszeniami** — poziomy 0-10 z punktami
  do ręcznego rozdania (zdrowie/stamina/mana/atak/prędkość/regeneracja) oraz
  pięć skrzyń na przebieg, każda z jednym z dziesięciu unikalnych ulepszeń
  (od uzbrajającego się ostrza po sojusz z odzyskaną duszą).
- **Finałowa walka z Nemoraksem** — sześć w pełni odrębnych faz (Motion,
  Force, Instinct, Dominion, Ruin, Sovereignty), z których każda losuje
  ważone, nie-powtarzające się wzorce ataków zamiast płaskiej listy, a
  ostatnia faza splata ruchy wszystkich poprzednich w jedną sekwencję.
- **Cały przebieg zapisywany na bieżąco** — zamknięcie gry w połowie mapy
  nie cofa do początku; minimapa z mgłą wojny zawsze pokazuje, gdzie już
  byłeś.
- **W pełni przypisywalne sterowanie** z własnym ekranem rebindingu.

## Cel gry

Przemierz losowo generowaną siatkę pokoi, znajdź i pokonaj sześć wcieleń
strzegących fragmentów rozbitej duszy, zbierz je wszystkie, a następnie
odnajdź ołtarz — zablokowany, dopóki komplet nie jest w twoich rękach.
Złożenie fragmentów przywołuje Nemoraksa: pokonaj sześć jego faz, żeby
zakończyć przebieg zwycięstwem. Porażka na dowolnym etapie cofa cię do
zupełnie nowej, świeżo wygenerowanej mapy — z niczym prócz tego, co
pamiętasz.

## Sterowanie

| Klawisz | Akcja |
|---|---|
| WASD | Ruch |
| Spacja | Dash (nietykalność w trakcie) |
| LPM | Atak aktualną bronią |
| PPM | Blok — odpycha wroga w zasięgu, koszt 3/4 max staminy |
| 1 | Miecz (atak z bliska) |
| 2 | Różdżka (atak na dystans, pocisk) |
| E | Leczenie — stack co 10 celnych trafień wroga (max 3 w banku), każde naciśnięcie zużywa jeden stack i oddaje 50% max zdrowia |
| F | Podniesienie duszy / otwarcie skrzyni |
| Tab | Ekran statystyk postaci — wydawanie punktów poziomu |
| Escape | Pauza w trakcie gry (poza ekranami game-over) |
| K | Zmiana klawiszy — z menu głównego albo z pauzy w trakcie gry |
| F3 | Podgląd debugowy (deweloperski) |

Wszystkie powyższe klawisze (poza pauzą/K/F3) da się przypisać na nowo na
ekranie rebindingu — strzałki wybierają akcję, Enter przechodzi w tryb
nasłuchiwania, dowolny klawisz albo przycisk myszy go przypisuje, Escape
wraca. Przypisania zapisują się trwale i nakładają na domyślną mapę przy
starcie gry.

---

## Stan projektu

Cała mechanika opisana wyżej jest zaimplementowana i pokryta testami
automatycznymi (uruchamianymi headless w Godocie). Grafika i dźwięk gracza,
sześciu wcieleń, map pokoi z duszami, wszystkich 6 faz Nemoraksa, 11
archetypów wrogów losowych (+ poświata modyfikatora Elite), skrzyni i 8
motywów pokoi RANDOM są już podpięte na dedykowanych, wygenerowanych
assetach. Zostają do wygenerowania pełne zestawy kierunkowe/pozowe (dziś
każdy z 11 archetypów ma jeden statyczny obraz na wszystkie pozy) — pełny
spis promptów i kolejność w
[PACZKA_DLA_GPT_NEMORAX_I_RESZTA.md](PACZKA_DLA_GPT_NEMORAX_I_RESZTA.md),
[PROMPTY_WROGOW_LOSOWYCH_I_SKRZYNI.md](PROMPTY_WROGOW_LOSOWYCH_I_SKRZYNI.md)
i [PLAN_ANIMACJE_KIERUNKOWE.md](PLAN_ANIMACJE_KIERUNKOWE.md).

Fabuła i scenariusz dialogów (jeszcze niewdrożone w kodzie) opisane w
[FABULA_I_DIALOGI.md](FABULA_I_DIALOGI.md); plan cutscenek pokazujący, jak
mają wyglądać poszczególne sceny, w [PLAN_CUTSCENEK.md](PLAN_CUTSCENEK.md).

## Wymagania i uruchomienie

- Godot 4.3 lub nowszy (rozwijane i testowane na 4.7.2).
- Otwórz folder projektu w Godot (`project.godot`) i uruchom scenę główną
  (F5, `menu.tscn`). Spacja na ekranie startowym wznawia dokładnie tam,
  gdzie gra została przerwana — zapisany przebieg albo świeży start.

## Dla deweloperów

- `autoload/` — `palette.gd` (kolory + domyślna mapa wejścia), `keybinds.gd`
  (rebinding), `juice.gd` (hitstop, trzęsienie ekranu, wspólne trafienia,
  podgląd debugowy F3), `game_flow.gd` (siatka pokoi jako graf, zapis
  przebiegu, skrzynie, ulepszenia gracza)
- `entities/` — `player.gd`, `boss.gd` (Nemorax, 6 faz), ataki bossa
  (`seal.gd`, `void_zone.gd`, `shadow.gd`, `damage_zone.gd`,
  `enemy_projectile.gd`), `incarnation.gd` (wspólny szkielet wcieleń i
  wrogów losowych) z podklasami w `entities/incarnations/` (sześć wcieleń)
  i `entities/random_enemies/` (12 archetypów)
- `rooms/` — `room.gd`/`room.tscn` (jedna scena reużywana dla wszystkich
  pokoi), `door.gd`, `soul.gd`, `chest.gd`, `altar.gd` (maszyna stanów
  LOCKED/READY/ACTIVATING)
- `ui/` — HUD, minimapa, ekran pauzy, ekran statystyk, ekran rebindingu
- `facing.gd` — wspólny wybór wariantu kierunkowego sprite'a (5 kątów +
  cykl chodu), patrz `PLAN_ANIMACJE_KIERUNKOWE.md`
- `tests/` — pełny zestaw testów headless (`godot --headless --script
  res://tests/test_runner.gd`)

### Testy w Godot na Windows

Z katalogu projektu uruchom w PowerShellu `./run_tests.ps1`. Skrypt korzysta
z `Godot_v4.7.2-stable_win64_console.exe` na pulpicie albo z polecenia
`godot`/`godot4`, najpierw importuje zasoby, potem uruchamia wszystkie testy
bez otwierania okna gry. Zwraca kod błędu, gdy testy nie przejdą. Inna
instalacja: `./run_tests.ps1 -GodotExecutable 'C:\sciezka\do\Godot.exe'`.
Gdy zasoby są już zaimportowane, można użyć `-SkipImport`. Runner zapisuje
testowe postępy pod osobnymi nazwami, nie nadpisuje zwykłego zapisu gry.

Wszystkie liczby wpływające na odczucia z gry (prędkości, obrażenia, czasy,
koszty zasobów) są `@export` — do dostrojenia bezpośrednio w Inspectorze
Godota.
