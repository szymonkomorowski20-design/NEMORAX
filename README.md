# NEMORAX

Gra akcji 2D z widokiem z góry. Godot 4, GDScript. Sześć pomieszczeń z sześcioma
wcieleniami hybrydy Nemorax, każde zostawia fragment duszy — po zebraniu
wszystkich sześciu, ołtarz przywołuje finałowego bossa. Kod gry jest kompletny
i przetestowany; grafika i dźwięk są w pełni podpięte (sprite'y, nie
`_draw()`) — jedyny znany brak to dedykowana tekstura finałowej areny, patrz
sekcja [Assety](#assety-grafika-i-dźwięk) niżej.

## Wymagania

- Godot 4.3 lub nowszy (rozwijane i testowane na 4.7.2)

## Uruchomienie

1. Otwórz folder projektu w Godot (`project.godot`).
2. Uruchom scenę główną (F5) — main scene to `menu.tscn` (prawdziwy ekran
   startowy). Spacja na ekranie startowym woła `GameFlow.resume_scene_path()`,
   który wznawia dokładnie tam, gdzie gracz skończył: `rooms/room.tscn`
   (pierwsze wcielenie albo zapisany postęp w trakcie sześciu pokoi) lub
   `arena.tscn`, jeśli ołtarz został już ukończony.

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
| F | Podniesienie duszy pokonanego wcielenia |
| Escape | Pauza w trakcie gry (poza ekranami game-over) |
| K | Zmiana klawiszy — z menu głównego albo z pauzy w trakcie gry |

Wszystkie powyższe klawisze (poza samą pauzą/K) da się przypisać na nowo na
ekranie rebindingu (`ui/keybind_screen.gd`) — strzałki wybierają akcję, Enter
przechodzi w tryb nasłuchiwania, dowolny klawisz albo przycisk myszy go
przypisuje, Escape wraca. Przypisania zapisują się w `user://settings.json`
(`autoload/keybinds.gd`) i nakładają się na domyślną mapę z `palette.gd` przy
starcie gry.

## Sześć wcieleń → ołtarz → Nemorax

- Sześć pomieszczeń (`rooms/room.tscn`, ta sama scena za każdym razem —
  `GameFlow` autoload mówi, które wcielenie zespawnować), każde z jednym
  wcieleniem hybrydy i jego trzema umiejętnościami (losowane bez powtórzeń,
  nawiązują do jednej z faz Nemoraxa — `entities/incarnations/`, wspólny
  szkielet w `entities/incarnation.gd`).
- Przebieg pokoju: pusty przedsionek → drzwi (podejście uruchamia wcielenie) →
  walka → dusza wypada jako przedmiot (`rooms/soul.gd`) → podnosisz ją klawiszem
  F → pojawiają się nowe drzwi (`rooms/door.gd`) → kolejny pokój.
- Zdrowie, stamina, mana i ładunek leczenia gracza przenoszą się między pokojami
  bez darmowego resetu (`GameFlow.capture_player_state`/`apply_player_state`) —
  to samo dotyczy retry po śmierci w danym pokoju.
- Po szóstym pokoju: `rooms/altar.gd` — podejście do ołtarza przywołuje Nemoraxa
  i przenosi do `arena.tscn`, czyli istniejącej walki opisanej niżej.
- Postęp przez sześć pokoi (który jest aktualny, zebrane fragmenty, migawka
  statystyk gracza) jest zapisywany na dysk (`user://gauntlet_progress.json`,
  `autoload/game_flow.gd`) — zamknięcie gry w trakcie gauntletu nie cofa do
  pokoju 1, menu wznawia dokładnie tam, gdzie gracz skończył
  (`GameFlow.resume_scene_path()`).

## Boss — Nemorax

- 6 faz, każda z własnym pełnym paskiem życia — dopiero pełne wyczerpanie danej
  fazy zmienia kolor bossa i odsłania kolejną (kumulującą się) zasadę: cisza dźwięku,
  dłuższy cooldown dasha, przyciąganie w stronę bossa, regeneracja bossa, zawężone
  pole widzenia.
- Cztery ataki losowane bez powtórzeń pod rząd: pieczęcie (Szósty Rytm), strefa
  blokująca dash (Ząb Zera), cień odtwarzający ruchy gracza sprzed kilku sekund
  (Kradzież Intencji) oraz fizyczny wypad z krótką zapowiedzią.
- Po pierwszym pokonaniu duża forma "umiera" i po chwili wraca jako mniejsza,
  szybsza forma finałowa z odwróconym sterowaniem i wszystkimi modyfikatorami
  fazowymi naraz.
- **Przegrana z Nemoraksem** resetuje cały przebieg (`GameFlow.reset_run()`) i
  odsyła gracza z powrotem do pokoju 1 — nowe fragmenty, świeży gracz.
  **Zwycięstwo** to prawdziwy koniec gry (endgame): ekran ze statystykami,
  Escape zamyka grę — bez pętli z powrotem do początku.

## Gracz

- Stamina napędza miecz i dash, regeneruje się w spoczynku.
- Mana napędza różdżkę, regeneruje się wyłącznie za trafienia wroga.
- Dash zostawia zanikający ślad i daje pełną nietykalność na czas trwania.
- Atak można zacząć w dowolnym momencie dasha — nie przerywają się nawzajem.

## Assety (grafika i dźwięk)

Cały content design (co ma wyglądać/brzmieć jak, gotowe prompty do wklejenia w
generatory) jest rozpisany w dokumentach w tym repo — same wygenerowane pliki
(obrazy/dźwięki) leżą poza repo, w osobnych folderach roboczych na dysku, i są
podpinane do Godota dopiero na etapie integracji.

**Grafika** — katalog i status w [LORE_I_ASSETY.md](LORE_I_ASSETY.md) (sześć
wcieleń + Nemorax + gracz/miecz/różdżka), [ASSETY_SWIATA_I_UI.md](ASSETY_SWIATA_I_UI.md)
(wszystko poza postaciami: VFX, otoczenie, UI, menu), [PROMPTY_FINALNE_WSZYSTKO.md](PROMPTY_FINALNE_WSZYSTKO.md)
(scalona, gotowa do odklikania checklista), [POZY_ANIMACJI.md](POZY_ANIMACJI.md)
(pełny zestaw póz animacji per postać) i [GRACZ_KOMPLETNY.md](GRACZ_KOMPLETNY.md)
(baza + 10 póz gracza + ekwipunek). Stan: 149/149 wygenerowanych plików
podpiętych (123 bazowych + 26 z pilotażu kierunków 360°, patrz
[PLAN_ANIMACJE_KIERUNKOWE.md](PLAN_ANIMACJE_KIERUNKOWE.md)); dawne dwie
usterki (przezroczystość `death_screen_frame.png`, kolory podłóg/ścian
Mordrath/Thal'Gor/Orryx) są już naprawione w podpiętych plikach.

**Znany brak** — finałowa arena (`arena.gd`) reużywa podłogę/ścianę ołtarza
jako zastępstwo (tło poza areną, D15, jest już generyczne i wspólne dla
wszystkich pomieszczeń, więc to nie problem). Prompty D16/D17 (podłoga/ściana
areny — ta sama komnata ołtarza, ale opanowana przez energię Nemoraksa) są
już dopisane w `PROMPTY_FINALNE_WSZYSTKO.md` — czeka tylko na wygenerowanie i
podpięcie plików.

**Dźwięk** — pełny katalog (muzyka, SFX, ambient, ~82 pozycje) w
[AUDIO_KATALOG.md](AUDIO_KATALOG.md), płaska kolejka gotowych promptów pod
ElevenLabs w [ELEVENLABS_KOLEJKA.md](ELEVENLABS_KOLEJKA.md). Stan: cały
niezbędny szkielet audio (rdzeń wcieleń, gracz, Nemorax, kluczowe momenty
fabularne) jest już wygenerowany/znaleziony w darmowej paczce dźwięków —
reszta to opcjonalny polish (unikalne umiejętności, muzyka, ambient pokoi).

## Struktura projektu

- `autoload/` — `palette.gd` (kolory + domyślna mapa wejścia), `keybinds.gd`
  (rebinding — nakłada się na mapę z palette.gd, zapisuje do
  `user://settings.json`), `juice.gd` (hitstop, trzęsienie ekranu),
  `game_flow.gd` (postęp przez sześć pokoi i zebrane fragmenty duszy)
- `entities/` — `player.gd`, `boss.gd` (Nemorax), ataki bossa (`seal.gd`, `void_zone.gd`,
  `shadow.gd`), pocisk gracza (`projectile.gd`), oraz `incarnation.gd` (wspólny szkielet
  wcieleń) z podklasami w `entities/incarnations/`
- `rooms/` — `room.gd`/`room.tscn` (jedna scena reużywana dla wszystkich sześciu
  pokoi), `door.gd`/`door.tscn` (przejścia), `soul.gd`/`soul.tscn` (przedmiot do
  podniesienia po pokonaniu wcielenia), `altar.gd`/`altar.tscn` (siódmy pokój,
  most do `arena.tscn`)
- `ui/` — `ui.gd` (paski/ikony gry), `pause_menu.gd` (Escape w trakcie gry,
  reużywalny w `room.tscn`/`arena.tscn`), `keybind_screen.gd` (ekran
  rebindingu, reużywalny z menu głównego i z pauzy)
- `facing.gd` — wspólny wybór wariantu kierunkowego sprite'a (przód/tył/bok +
  flip_h), pilotaż 360° (patrz `PLAN_ANIMACJE_KIERUNKOWE.md`)
- `arena.gd` / `arena.tscn` — finałowa walka z Nemoraksem: ściany, spawn, orkiestracja
  faz, licznik prób
- `walls.gd` — współdzielone budowanie ścian areny (używane przez `arena.gd` i `room.gd`)

Wszystkie liczby wpływające na odczucia z gry (prędkości, obrażenia, czasy,
koszty zasobów) są `@export` — do dostrojenia bezpośrednio w Inspectorze Godota.
