# NEMORAX

Gra akcji 2D z widokiem z góry, jeden gracz kontra jeden boss. Godot 4, GDScript,
bez plików graficznych — wszystko rysowane kodem (koła, prostokąty, proste kształty).

## Wymagania

- Godot 4.3 lub nowszy (rozwijane i testowane na 4.7.2)

## Uruchomienie

1. Otwórz folder projektu w Godot (`project.godot`).
2. Uruchom scenę główną (F5) — `arena.tscn` jest ustawiona jako main scene.

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

- `autoload/` — `palette.gd` (kolory + mapa wejścia), `juice.gd` (hitstop, trzęsienie ekranu)
- `entities/` — `player.gd`, `boss.gd`, oraz spawnowane przez bossa/gracza ataki
  (`seal.gd`, `void_zone.gd`, `shadow.gd`, `projectile.gd`)
- `ui/` — `ui.gd`, cały interfejs rysowany na jednym `Control`
- `arena.gd` / `arena.tscn` — scena główna: ściany, spawn, orkiestracja faz, licznik prób

Wszystkie liczby wpływające na odczucia z gry (prędkości, obrażenia, czasy,
koszty zasobów) są `@export` — do dostrojenia bezpośrednio w Inspectorze Godota.
