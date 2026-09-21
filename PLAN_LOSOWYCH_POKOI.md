# NEMORAX — Plan: mapa pokoi w stylu "The Binding of Isaac" (30 pokoi)

Ustalenia z rozmowy z autorem (2026-09-20/21), zanim assety od drugiego bota
(7 przeciwników + 8 wyglądów pokoi) będą gotowe. Architektura i logika są już
**wdrożone i grywalne dziś** na tymczasowych zastępczych assetach — ten
dokument mówi dokładnie, co podmienić, żeby przejść na docelowe.

**Historia**: pierwsza wersja tego dokumentu opisywała LINIOWĄ sekwencję 30
pokoi (6 rozdziałów × [4 losowe + 1 z duszą] jeden za drugim). Autor poprosił
o przebudowę na prawdziwą SIATKĘ 2D w stylu Isaaca — ten dokument opisuje
FINALNĄ, siatkową wersję; sekcja historyczna usunięta, żeby nie mylić.

## 1. Ustalona struktura

- **Mapa 2D**, nie liniowa sekwencja — pokoje jako węzły grafu na siatce
  `Vector2i`, połączone drzwiami N/S/W/E. Gracz sam wybiera, którędy iść.
- **30 pokoi razem**: 1 START (bezpieczny, bez przeciwnika) + 24 RANDOM
  (losowy przeciwnik, rosnąca trudność) + 6 SOUL (po jednym na wcielenie,
  dają fragment duszy) + 1 ALTAR.
- **SOUL i ALTAR to ślepe zaułki** — dokładnie jedno połączenie z resztą
  mapy każdy, jak drzwi bossa w Isaacu, żeby czuły się jak cel wyprawy, nie
  przystanek na trasie.
- **Drzwi pokoju z żywym przeciwnikiem są zamknięte** (RANDOM/SOUL,
  niepokonany) — nie da się wyjść, dopóki się go nie pokona (ustalone z
  autorem, dokładnie jak w Isaacu). Dzięki temu **da się ukończyć grę bez
  czyszczenia wszystkich 30 pokoi** — wystarczy trafić na 6 z duszą i na
  ołtarz jakąkolwiek ścieżką po siatce, reszta jest opcjonalna.
- **Ołtarz to osobny pokój na mapie, zablokowany do kompletu 6 fragmentów**
  (ustalone z autorem) — drzwi prowadzące do niego są zamknięte, dopóki
  `fragments_collected.size() < 6`, niezależnie od tego, czy sąsiedni pokój
  jest już wyczyszczony.
- System fragmentów duszy **bez zmian** co do treści — dają je wyłącznie
  pokoje SOUL (6 na cały przebieg), losowi przeciwnicy NIE dają fragmentów
  ani duszy do podniesienia — po ich pokonaniu drzwi po prostu się otwierają.
- Losowi przeciwnicy: **rosnąca trudność** z `rooms_cleared_count` (licznik
  WYCZYSZCZONYCH pokoi w całym przebiegu, nie pozycja na mapie — gracz może
  iść w dowolnej kolejności) — mnożnik `1.0 + rooms_cleared_count * 0.08`.
- Bez powtórzenia tego samego losowego przeciwnika w dwóch SĄSIEDNIO
  POSTAWIONYCH podczas generacji pokojach (ta sama zasada co ataki
  bossa/umiejętności wcieleń w całej reszcie gry) — ustalane RAZ przy
  generacji mapy, nie przy każdym wejściu (pokój ma stały przydział, nie
  losuje się na nowo przy powrocie).

## 2. Co już działa (kod wdrożony w tej sesji)

- `autoload/game_flow.gd`: **całkowicie przepisane** z liniowego
  `current_room_index` na graf `room_map: Dictionary<Vector2i, Dictionary>`.
  - `_generate_map()`: losowy spacer od `Vector2i.ZERO` (START) stawia 24
    RANDOM, potem 6 SOUL + 1 ALTAR dołączone jako ślepe zaułki przez
    `_pick_leaf_attachment_point()` — **uwaga, dwa subtelne bugi złapane i
    naprawione testem `test_soul_and_altar_rooms_are_dead_ends`**: (1)
    kandydat na nowy pokój musi mieć dokładnie JEDNEGO zajętego sąsiada, nie
    tylko "być pusty" — inaczej mógł przypadkiem stykać się z innym już
    postawionym pokojem; (2) już postawiony pokój SOUL/ALTAR nie może sam
    zostać "rodzicem" kolejnego specjalnego pokoju, inaczej straciłby status
    ślepego zaułka. Test robi 30 regeneracji z rzędu, bo to losowe — jedno
    udane uruchomienie nic nie gwarantuje.
  - `is_direction_open(direction)`: łączy obie blokady (walka + ołtarz).
  - `wall_for_direction()`/`opposite_wall_for_direction()`: mapowanie
    NORTH/SOUTH/WEST/EAST na ściany `Walls.wall_point()` i na ścianę, przy
    której gracz ląduje w NOWYM pokoju (przeciwna do kierunku ruchu).
  - `clear_current_room()`, `move_to_neighbor(direction)`, `enter_altar()` —
    odpowiedniki dawnego `complete_current_room()`, teraz świadome pozycji
    na siatce, nie tylko rosnącego indeksu.
  - Zapis/odczyt (`_save_progress`/`_load_progress`) serializuje
    `room_map`/`current_room_pos`/`entry_direction`/`visited_rooms` przez
    proste słowniki `{"x":.., "y":..}` (JSON nie zna `Vector2i` wprost).
    `_load_progress()` zwraca teraz `bool` (false = brak/zepsuty zapis →
    wołający generuje nową mapę), zamiast po cichu zostawiać domyślne
    wartości.
- `entities/incarnation.gd`: `apply_difficulty_scale(multiplier)` — bez zmian
  względem poprzedniej wersji, tylko wołający (`room.gd`) używa teraz
  `GameFlow.rooms_cleared_count` zamiast pozycji w sekwencji.
- `rooms/room.gd`: **przepisane** — `_ready()` czyta
  `GameFlow.current_room_data()` (typ/rozdział/enemy_index), pozycjonuje
  gracza przy ścianie PRZECIWNEJ do `GameFlow.entry_direction` (albo na
  środku w pokoju startowym), spawnuje przeciwnika (albo od razu drzwi, jeśli
  START). `_spawn_doors_for_open_directions()` stawia realne drzwi na
  KAŻDEJ ścianie, którą `GameFlow.is_direction_open()` uzna za otwartą —
  do 4 naraz, nie jedne stałe "drzwi startowe/wyjściowe" jak w liniowej
  wersji. Drzwi prowadzące do sąsiada typu ALTAR dostają inny callback
  (`_on_altar_door_entered` → `GameFlow.enter_altar()`, zmiana sceny na
  `altar.tscn`) niż zwykłe drzwi (`_on_move_door_entered` →
  `GameFlow.move_to_neighbor()`, reload tej samej sceny na nowej pozycji).
- `ui/ui.gd`: minimapa przepisana na mgłę wojny — pokazuje pokoje odwiedzone
  (pełny kolor) i sąsiadów odwiedzonych (przygaszony zarys, nieodwiedzone),
  bieżący pokój zawsze wyśrodkowany w 6×6-polowym oknie, podświetlony
  obwódką; SOUL/ALTAR dostają dodatkową obwódkę.
- `walls.gd`: `wall_point(rect, side)` obsługuje już wszystkie 4 strony
  (top/bottom/left/right) — potrzebne teraz, bo drzwi mogą być na
  dowolnej z 4 ścian, nie tylko góra/dół jak w liniowej wersji.

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
przykładowa konwencja). Przydział `enemy_index` per pokój dzieje się RAZ, w
`_generate_map()` — podmiana tej listy automatycznie działa z całą resztą
systemu (generacja, brak powtórzeń, trudność), zero dalszych zmian potrzebnych
w `_generate_map()` samym.

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
elif _room_data.get("type") == GameFlow.RoomType.RANDOM:
	var theme_index: int = int(_room_data.get("enemy_index", 0)) % ROOM_FLOOR_TEXTURES.size()
	floor_tex = ROOM_FLOOR_TEXTURES[theme_index]
	wall_tex = ROOM_WALL_TEXTURES[theme_index]
```
Dziś reużywa 6 istniejących tekstur pokoi wcieleń (modulo 6, indeksowane po
`enemy_index` zapisanym w danym pokoju), NIE docelowych 8 motywów. Gdy 16
plików (8× floor+wall) będzie gotowych:
1. Dodać nowe stałe, analogicznie do `ROOM_FLOOR_TEXTURES`:
   ```gdscript
   const RANDOM_ROOM_FLOOR_TEXTURES: Array[Texture2D] = [ ... 8 wpisów ... ]
   const RANDOM_ROOM_WALL_TEXTURES: Array[Texture2D] = [ ... 8 wpisów ... ]
   ```
2. W `_ready()`, w gałęzi `RoomType.RANDOM`, podmienić
   `ROOM_FLOOR_TEXTURES`/`ROOM_WALL_TEXTURES` na
   `RANDOM_ROOM_FLOOR_TEXTURES`/`RANDOM_ROOM_WALL_TEXTURES` (rozmiar puli
   sam się zmieni z 6 na 8 dzięki `.size()` w module).
3. Pokój START też dziś reużywa `ROOM_FLOOR_TEXTURES[0]` jako placeholder
   (gałąź `else` w `_ready()`) — do rozważenia osobny, neutralny wygląd
   "przedsionka" przy okazji tej samej podmiany, jeśli drugi bot coś takiego
   przygotuje (nie było jawnie zamówione, więc placeholder wystarczy na razie).

## 4. Co NIE wymaga zmian

- `rooms/altar.gd` — nie odwołuje się do struktury mapy w ogóle, działa
  identycznie niezależnie od tego, ile/które pokoje je poprzedziły. 6
  fragmentów zostaje 6 fragmentami.
- `arena.gd`/walka z Nemoraksem — bez zmian.

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
- [ ] Przetestować headless (nowy test round-trip każdej z 7 scen,
      `apply_difficulty_scale` na realnych statystykach) + pełny smoke test
      wszystkich scen + `tests/test_game_flow_map.gd` (powinien przejść bez
      zmian, bo nie zależy od TREŚCI `RANDOM_ENEMY_SCENES`, tylko od jej
      rozmiaru/generacji).
- [ ] Realny playtest całej mapy pod kątem tempa/trudności — mnożnik
      +8%/pokój to wartość startowa do dostrojenia, nie ostateczna.
