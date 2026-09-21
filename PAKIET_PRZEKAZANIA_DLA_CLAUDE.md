# NEMORAX — pakiet przekazania od Codexa dla Claude'a

Przeczytaj kolejno:

1. `TERAZ_DLA_CLAUDE.md` — Twoje bieżące zadania i kolejność pracy.
2. `PLAN_POLISH_WIZUALNY_DLA_CLAUDE.md` — pełny standard jakości, kryteria odbioru i ograniczenia zakresu.
3. `PLAN_CUTSCENEK.md` — specyfikacja cutscenek.

## Co Codex już zrobił

### Assety

- 5 baz nowych faz Nemoraxa, podmienionych pod istniejącymi ścieżkami faz w `assets/sprites/nemorax/`.
- 14 osobnych PNG VFX dla ataków i umiejętności siedmiu wrogów; katalog oceny: `grafiki do gry/09_room_enemies/enemy_vfx/`.
- 11 baz losowych wrogów w `assets/sprites/random_enemies/<nazwa>/`.
- `elite_aura.png` w `assets/sprites/random_enemies/elite/`.
- `chest_closed.png` i `chest_open.png` w `assets/sprites/pokoje/obiekty/chest/`.
- 16 nieprzezroczystych tekstur ośmiu typów pokoi w `assets/sprites/pokoje/tekstury/random_rooms/`.
- 7 ujęć pilotażu chodu gracza (5 kierunków × 2 klatki łącznie z istniejącymi neutralnymi); wpisy są już dodane do `entities/player.gd`.

### Kod / polish

- `entities/contact_shadow.gd`: wspólny, rysowany kodem miękki cień kontaktowy.
- Cień jest tworzony w: `entities/player.gd`, `entities/incarnation.gd`, `entities/boss.gd`, `rooms/door.gd`, `rooms/chest.gd`.
- `rooms/room.tscn`: dodany `WorldAmbient` (`CanvasModulate`).
- `rooms/room.gd`: drzwi są przesuwane o 26 px do wnętrza pokoju.
- `rooms/chest.gd`: skrzynia korzysta z właściwych sprite'ów zamknięta/otwarta.
- `entities/incarnation.gd`: aura Elite jest ładowana z właściwego assetu.

## Ważne ograniczenia

- Nie zakładaj, że ostatnie zmiany polishu są zatwierdzone: wymagają uruchomienia gry i screena porównawczego.
- Nie twórz nowych grafik ani nie generuj 84/252/343 kierunkowych póz. To zostaje po stronie Codexa po akceptacji pilotażu.
- Nie zmieniaj hitboxów, save data, AI ani zasad walki pod pretekstem polishu.
- Codex nie miał dostępnego Godot CLI, więc lokalne testy i playtest wykonaj po swojej stronie.

## Jak przekazać wynik

Po każdym z etapów: visual foundation, asset integration, cutscenes — zapisz krótkie podsumowanie: zmienione pliki, wynik testów i jeden screen z gry. Nie przechodź do kolejnego etapu, gdy scena nadal wygląda jak zestaw naklejek na tle.
