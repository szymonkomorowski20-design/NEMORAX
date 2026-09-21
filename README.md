# NEMORAX

Gra akcji 2D z widokiem z góry. Godot 4, GDScript. Mapa pokoi 2D w stylu "The
Binding of Isaac" (30 pokoi: 1 startowy + 24 z losowym przeciwnikiem + 6 z
wcieleniem hybrydy Nemorax + 1 ołtarz) — gracz sam wybiera drogę po siatce,
nie trzeba czyścić wszystkich pokoi. Każde wcielenie zostawia fragment duszy —
po zebraniu wszystkich sześciu, ołtarz (zablokowany do tego czasu) przywołuje
finałowego bossa. Kod gry jest kompletny i przetestowany; grafika i dźwięk są
w pełni podpięte (sprite'y, nie `_draw()`) dla gracza/wcieleń/Nemoraksa — 7
dedykowanych przeciwników losowych i ich 8 wyglądów pokoi są w trakcie
generowania, patrz [PLAN_LOSOWYCH_POKOI.md](PLAN_LOSOWYCH_POKOI.md) (dziś
zastępczo reużywają assety wcieleń, w pełni grywalne).

## Wymagania

- Godot 4.3 lub nowszy (rozwijane i testowane na 4.7.2)

## Uruchomienie

1. Otwórz folder projektu w Godot (`project.godot`).
2. Uruchom scenę główną (F5) — main scene to `menu.tscn` (prawdziwy ekran
   startowy). Spacja na ekranie startowym woła `GameFlow.resume_scene_path()`,
   który wznawia dokładnie tam, gdzie gracz skończył: `rooms/room.tscn`
   (pierwszy pokój albo zapisany postęp w trakcie 30 pokoi) lub `arena.tscn`,
   jeśli ołtarz został już ukończony.

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

## Mapa 30 pokoi (styl "The Binding of Isaac") → ołtarz → Nemorax

- `rooms/room.tscn` (ta sama scena za każdym razem) przeładowuje się przy
  każdym przejściu przez drzwi — `GameFlow` autoload trzyma mapę jako graf
  (`Dictionary<Vector2i, Dictionary>`, pokoje N/S/W/E), nie liniową
  sekwencję. Generowana proceduralnie przy starcie/resecie: 1 pokój
  **startowy** (bezpieczny) + 24 z **losowym przeciwnikiem**
  (`GameFlow.RANDOM_ENEMY_SCENES`, rosnąca trudność z liczbą wyczyszczonych
  pokoi, patrz `GameFlow.RANDOM_ENEMY_DIFFICULTY_STEP`) + 6 z **wcieleniem**
  hybrydy i jego trzema umiejętnościami (losowane bez powtórzeń, nawiązują do
  jednej z faz Nemoraxa — `entities/incarnations/`, wspólny szkielet w
  `entities/incarnation.gd`) + 1 **ołtarz**. Pokoje z wcieleniem i ołtarz są
  ślepymi zaułkami (dokładnie jedno połączenie z resztą mapy) — trzeba je
  faktycznie znaleźć, nie trafiają się po drodze. Docelowy zestaw 7 losowych
  przeciwników (4 wręcz + 3 dystansowych) i ich 8 wyglądów pokoi jest w trakcie
  generowania — patrz [PLAN_LOSOWYCH_POKOI.md](PLAN_LOSOWYCH_POKOI.md) po
  dokładny stan i checklistę podpięcia.
- **Drzwi pokoju z żywym przeciwnikiem są zamknięte** (nie zespawnowane),
  dopóki się go nie pokona — jak w Isaacu. Dzięki temu da się ukończyć grę
  bez czyszczenia wszystkich 30 pokoi, wystarczy dotrzeć do 6 z duszą i do
  ołtarza jakąkolwiek ścieżką. **Ołtarz jest dodatkowo zablokowany, dopóki
  nie zebrano wszystkich 6 fragmentów** — drzwi do niego widać dopiero po
  komplecie.
- Przebieg pokoju: gracz pojawia się przy ścianie, którą wszedł (środek w
  pokoju startowym) → jeśli jest przeciwnik, drzwi zamknięte → po pokonaniu
  (**wcielenie**: dusza wypada jako przedmiot (`rooms/soul.gd`), podnosisz ją
  klawiszem F, dopiero potem drzwi; **losowy przeciwnik**: bez duszy/fragmentu,
  drzwi od razu) → drzwi na WSZYSTKICH teraz otwartych ścianach
  (`rooms/door.gd`, zawsze dokładnie na ścianie, `Walls.wall_point()`) →
  wybierasz, którędy dalej.
- Minimapa w prawym górnym rogu ekranu (`ui.gd`) pokazuje odkrytą część mapy
  z mgłą wojny — pokoje odwiedzone w pełnym kolorze, sąsiedzi odwiedzonych
  jako przygaszony zarys, bieżący pokój zawsze wyśrodkowany.
- Zdrowie, stamina, mana i stacki leczenia gracza przenoszą się między pokojami
  bez darmowego resetu (`GameFlow.capture_player_state`/`apply_player_state`) —
  to samo dotyczy retry po śmierci w danym pokoju.
- Po skompletowaniu 6 fragmentów i dotarciu do ołtarza: `rooms/altar.gd` —
  podejście do ołtarza przywołuje Nemoraxa i przenosi do `arena.tscn`, czyli
  istniejącej walki opisanej niżej.
- Cały stan mapy (graf pokoi, pozycja, odwiedzone, zebrane fragmenty, migawka
  statystyk gracza) jest zapisywany na dysk (`user://gauntlet_progress.json`,
  `autoload/game_flow.gd`) — zamknięcie gry w trakcie przebiegu nie cofa do
  początku, menu wznawia dokładnie tam, gdzie gracz skończył
  (`GameFlow.resume_scene_path()`). Przegrana z Nemoraksem generuje
  całkowicie nową mapę od zera (`GameFlow.reset_run()`).

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
  `game_flow.gd` (mapa 30 pokoi jako graf, postęp i zebrane fragmenty duszy)
- `entities/` — `player.gd`, `boss.gd` (Nemorax), ataki bossa (`seal.gd`, `void_zone.gd`,
  `shadow.gd`), pocisk gracza (`projectile.gd`), oraz `incarnation.gd` (wspólny szkielet
  wcieleń I losowych przeciwników) z podklasami w `entities/incarnations/`
- `rooms/` — `room.gd`/`room.tscn` (jedna scena reużywana dla wszystkich 30
  pokoi), `door.gd`/`door.tscn` (przejścia, zawsze na ścianie), `soul.gd`/`soul.tscn`
  (przedmiot do podniesienia po pokonaniu wcielenia), `altar.gd`/`altar.tscn` (31. pokój,
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
