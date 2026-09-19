# NEMORAX

Gra akcji 2D z widokiem z góry. Godot 4, GDScript. Sześć pomieszczeń z sześcioma
wcieleniami hybrydy Nemorax, każde zostawia fragment duszy — po zebraniu
wszystkich sześciu, ołtarz przywołuje finałowego bossa. Wizualnie na razie
proste kształty rysowane kodem (docelowo podmieniane na sprite'y — patrz
[LORE_I_ASSETY.md](LORE_I_ASSETY.md)).

## Wymagania

- Godot 4.3 lub nowszy (rozwijane i testowane na 4.7.2)

## Uruchomienie

1. Otwórz folder projektu w Godot (`project.godot`).
2. Uruchom scenę główną (F5) — `rooms/room.tscn` jest ustawiona jako main scene
   i startuje od pierwszego wcielenia.

## Sterowanie

| Klawisz | Akcja |
|---|---|
| WASD | Ruch |
| Spacja | Dash (nietykalność w trakcie) |
| LPM | Atak aktualną bronią |
| PPM | Blok — odpycha wroga w zasięgu, koszt 3/4 max staminy |
| 1 | Miecz (atak z bliska) |
| 2 | Różdżka (atak na dystans, pocisk) |
| E | Leczenie — aktywne po 40 celnych trafieniach wroga, oddaje 50% max zdrowia |
| F | Podniesienie duszy pokonanego wcielenia |

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

## Gracz

- Stamina napędza miecz i dash, regeneruje się w spoczynku.
- Mana napędza różdżkę, regeneruje się wyłącznie za trafienia wroga.
- Dash zostawia zanikający ślad i daje pełną nietykalność na czas trwania.
- Atak można zacząć w dowolnym momencie dasha — nie przerywają się nawzajem.

## Struktura projektu

- `autoload/` — `palette.gd` (kolory + mapa wejścia), `juice.gd` (hitstop, trzęsienie ekranu),
  `game_flow.gd` (postęp przez sześć pokoi i zebrane fragmenty duszy)
- `entities/` — `player.gd`, `boss.gd` (Nemorax), ataki bossa (`seal.gd`, `void_zone.gd`,
  `shadow.gd`), pocisk gracza (`projectile.gd`), oraz `incarnation.gd` (wspólny szkielet
  wcieleń) z podklasami w `entities/incarnations/`
- `rooms/` — `room.gd`/`room.tscn` (jedna scena reużywana dla wszystkich sześciu
  pokoi), `door.gd`/`door.tscn` (przejścia), `soul.gd`/`soul.tscn` (przedmiot do
  podniesienia po pokonaniu wcielenia), `altar.gd`/`altar.tscn` (siódmy pokój,
  most do `arena.tscn`)
- `ui/` — `ui.gd`, cały interfejs rysowany na jednym `Control`
- `arena.gd` / `arena.tscn` — finałowa walka z Nemoraksem: ściany, spawn, orkiestracja
  faz, licznik prób
- `walls.gd` — współdzielone budowanie ścian areny (używane przez `arena.gd` i `room.gd`)

Wszystkie liczby wpływające na odczucia z gry (prędkości, obrażenia, czasy,
koszty zasobów) są `@export` — do dostrojenia bezpośrednio w Inspectorze Godota.
