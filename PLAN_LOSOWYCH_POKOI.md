# NEMORAX — Plan: 24 pokoje z losowymi przeciwnikami (+ 6 pokoi z duszami = 30)

Ustalenia z rozmowy z autorem (2026-09-20), zanim assety od drugiego bota
(7 przeciwników + 8 wyglądów pokoi) będą gotowe. Architektura i logika są już
**wdrożone i grywalne dziś** na tymczasowych zastępczych assetach — ten
dokument mówi dokładnie, co podmienić, żeby przejść na docelowe.

## 1. Ustalona struktura

- **30 pokoi razem**, nie 24 ani 6 — sześć rozdziałów, każdy: **4 pokoje z
  losowym przeciwnikiem → 1 pokój z wcieleniem/duszą** (24÷6=4 pasuje idealnie
  do 6 rozdziałów × 5 = 30).
- System fragmentów duszy **bez zmian** — dają je wyłącznie pokoje z
  wcieleniami (jak dotychczas, 6 fragmentów na cały przebieg), losowi
  przeciwnicy NIE dają fragmentów ani duszy do podniesienia — po ich pokonaniu
  drzwi dalej pojawiają się od razu.
- Losowi przeciwnicy: **rosnąca trudność** z numerem pokoju (nie stały,
  przewidywalny cykl) — mnożnik `1.0 + current_room_index * 0.08`, czyli
  +8%/pokój, zastosowany do `max_health`/`contact_damage` (albo odpowiedników,
  gdy 7 docelowych przeciwników dostanie własne pola).
- Bez powtórzenia tego samego losowego przeciwnika dwa pokoje z rzędu (ta sama
  zasada co ataki bossa/umiejętności wcieleń w całej reszcie gry).

## 2. Co już działa (kod wdrożony w tej sesji)

- `autoload/game_flow.gd`: `current_room_index` teraz 0-29 (nie 0-5).
  `is_random_enemy_room()`, `current_chapter_index()`, `total_room_count()`,
  `choose_random_enemy_scene_path()` — cała logika 4:1 gotowa i przetestowana
  (`tests/test_game_flow_chapters.gd`).
- `entities/incarnation.gd`: `apply_difficulty_scale(multiplier)` — skaluje
  `max_health`/`health`/`contact_damage`. Wywoływane TYLKO dla losowych
  przeciwników, wcielenia z duszami zachowują swoje ręcznie dobrane stałe
  statystyki.
- `rooms/room.gd`: `_on_start_door_entered()` rozgałęzia się na
  `GameFlow.is_random_enemy_room()` — losuje przeciwnika z puli albo bierze
  wcielenie rozdziału jak dotychczas. `_on_incarnation_died()` pomija krok z
  duszą dla losowych przeciwników.
- `walls.gd`: `wall_point(rect, side)` — przy okazji naprawione też "drzwi
  tylko na ścianach" (patrz commit `ccf126c`), używane też przez nowy system.

## 3. Tymczasowe zastępstwa — DO PODMIANY, gdy assety będą gotowe

### 3.1 Przeciwnicy (docelowo 7: 4 wręcz + 3 dystansowych)

`autoload/game_flow.gd`, stała `RANDOM_ENEMY_SCENES`:
```gdscript
const RANDOM_ENEMY_SCENES: Array[String] = INCARNATION_SCENES
```
Dziś reużywa 6 scen wcieleń jako zastępczych losowych przeciwników (grywalne,
ale to NIE jest docelowy zestaw). **Podmienić na 7 realnych ścieżek**, np.:
```gdscript
const RANDOM_ENEMY_SCENES: Array[String] = [
	"res://entities/random_enemies/melee_1.tscn",
	"res://entities/random_enemies/melee_2.tscn",
	"res://entities/random_enemies/melee_3.tscn",
	"res://entities/random_enemies/melee_4.tscn",
	"res://entities/random_enemies/ranged_1.tscn",
	"res://entities/random_enemies/ranged_2.tscn",
	"res://entities/random_enemies/ranged_3.tscn",
]
```
(dokładne nazwy plików wg tego, co faktycznie dostarczy drugi bot — to tylko
przykładowa konwencja).

**Kontrakt, jaki musi spełniać każda z 7 scen**, żeby zadziałała bez dalszych
zmian w `room.gd`:
- Skrypt **rozszerza `Incarnation`** (`entities/incarnation.gd`) — `room.gd`
  robi `scene.instantiate() as Incarnation`. Daje za darmo: zdrowie, sygnał
  `died(fragment_name)`, kontakt zawsze rani, telegraf, sprite/facing
  (przód/tył/bok), dźwięk trafienia/śmierci, losowanie umiejętności bez
  powtórzeń, `apply_difficulty_scale()`.
- **Uwaga dla przeciwników dystansowych**: `Incarnation._drift_towards_player`
  zawsze idzie WPROST na gracza (dobre dla wręcz, złe dla dystansowych, które
  powinny raczej trzymać odległość i strzelać). Dla 3 dystansowych trzeba
  albo nadpisać `_drift_towards_player()` w podklasie (zachowując resztę
  szkieletu), albo dodać do bazy `Incarnation` wspólny tryb "keep_distance"
  — decyzja do podjęcia, gdy będzie znany dokładny mechanika/telegraph z
  dokumentu przekazaniowego drugiego bota (sekcja "mechaniki, telegraphy").
- `fragment_name` ustawione w `_ready()` podklasy — dla losowych przeciwników
  jego wartość i tak jest ignorowana przez `room.gd` (`_on_incarnation_died`
  nie używa go w gałęzi losowej), więc może być czymkolwiek/pusty.
- Poza wymogami — reszta pól (@export) to zwykłe wartości startowe z
  dokumentu przekazaniowego drugiego bota.

### 3.2 Wyglądy pokoi (docelowo 8 par podłoga/ściana = 16 tekstur, na 24 pokoje)

`rooms/room.gd`, `_ready()`:
```gdscript
if GameFlow.is_random_enemy_room():
	var theme_index := GameFlow.current_room_index % ROOM_FLOOR_TEXTURES.size()
	floor_tex = ROOM_FLOOR_TEXTURES[theme_index]
	wall_tex = ROOM_WALL_TEXTURES[theme_index]
```
Dziś reużywa 6 istniejących tekstur pokoi wcieleń (modulo 6), NIE docelowych 8
motywów. Gdy 16 plików (8× floor+wall) będzie gotowych:
1. Dodać nowe stałe, analogicznie do `ROOM_FLOOR_TEXTURES`:
   ```gdscript
   const RANDOM_ROOM_FLOOR_TEXTURES: Array[Texture2D] = [ ... 8 wpisów ... ]
   const RANDOM_ROOM_WALL_TEXTURES: Array[Texture2D] = [ ... 8 wpisów ... ]
   ```
2. W `_ready()` podmienić `ROOM_FLOOR_TEXTURES.size()`/`ROOM_FLOOR_TEXTURES[theme_index]`
   na `RANDOM_ROOM_FLOOR_TEXTURES.size()`/`RANDOM_ROOM_FLOOR_TEXTURES[theme_index]`
   (i analogicznie dla ściany) w gałęzi `is_random_enemy_room()`.
   Mapowanie `current_room_index % 8` już samo rozłoży 8 motywów na 24 pokoje
   (3 pokoje na motyw) — nie trzeba dalszej logiki.

## 4. Co NIE wymaga zmian

- `rooms/altar.gd` — nie odwołuje się do `current_room_index`/liczby pokoi w
  ogóle, działa identycznie niezależnie od tego, ile pokoi je poprzedziło.
  6 fragmentów zostaje 6 fragmentami.
- `arena.gd`/walka z Nemoraksem — bez zmian.
- Zapis/odczyt postępu (`user://gauntlet_progress.json`) — już rozszerzony o
  `last_random_enemy_index`, reszta pól bez zmian.

## 5. Checklist podpięcia (gdy assety + dokument przekazaniowy dotrą)

- [ ] Przeczytać dokument przekazaniowy drugiego bota (mechaniki, telegraphy,
      wartości startowe, nazwy plików, prompty, sposób podpięcia).
- [ ] Zaimportować 63 grafiki postaci + 16 tekstur pokoi do projektu (ten sam
      proces co pilotaż 360°/pokoje: skopiować, `--headless --editor --import
      --quit`, sprawdzić że się zaimportowały).
- [ ] Napisać 7 skryptów/scen przeciwników jako podklasy `Incarnation` (albo
      wspólnej bazy z dodanym trybem "keep_distance" dla dystansowych, jeśli
      dokument tego wymaga).
- [ ] Podmienić `RANDOM_ENEMY_SCENES` w `game_flow.gd` na 7 realnych ścieżek.
- [ ] Dodać `RANDOM_ROOM_FLOOR_TEXTURES`/`RANDOM_ROOM_WALL_TEXTURES` (8+8) i
      podmienić `_ready()` w `room.gd` zgodnie z sekcją 3.2.
- [ ] Przetestować headless (nowy `tests/test_random_enemies.gd` — round-trip
      każdej z 7 scen, `apply_difficulty_scale` na realnych statystykach) +
      pełny smoke test wszystkich scen.
- [ ] Realny playtest całych 30 pokoi pod kątem tempa/trudności — mnożnik
      +8%/pokój to wartość startowa do dostrojenia, nie ostateczna.
