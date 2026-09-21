# NEMORAX — co robisz TERAZ (przekazanie)

> Najpierw przeczytaj `KIERUNEK_WIZUALNY_REFERENCJE.md`. Jest to nadrzędna
> decyzja artystyczna po porównaniu dwóch gier referencyjnych. Nie kopiuj ich
> assetów ani UI; wdrażaj wyłącznie ich zasady czytelności, światła i skali.

## Cel najbliższego etapu

Doprowadź obecną scenę do spójnego, czytelnego wyglądu oraz wdroż tekstowy system cutscenek. **Nie generuj nowych grafik postaci i nie zaczynaj masowej animacji 343 ujęć.** Codex prowadzi produkcję/QA grafik i wróci do animacji dopiero po zatwierdzeniu wyglądu w grze.

## Stan zastany — nie dubluj

Gotowe assety istnieją w projekcie:

- losowi wrogowie: `assets/sprites/random_enemies/<nazwa>/<nazwa>_base.png`,
- aura Elite: `assets/sprites/random_enemies/elite/elite_aura.png`,
- skrzynie: `assets/sprites/pokoje/obiekty/chest/`,
- osiem motywów pokoi: `assets/sprites/pokoje/tekstury/random_rooms/`,
- siedem nowych ujęć chodu gracza oraz wpisy w `entities/player.gd`,
- pięć nowych baz faz Nemoraxa.

Gotowe elementy kodu, których nie nadpisuj:

- skrzynia już korzysta z `chest_closed.png` / `chest_open.png`,
- `Incarnation` już ładuje aurę Elite,
- `entities/contact_shadow.gd` dodano jako wspólny komponent,
- gracz, wcielenia, Nemorax, drzwi i skrzynia tworzą cień kontaktowy,
- `rooms/room.tscn` ma `WorldAmbient`,
- drzwi są odsuwane do wnętrza pokoju w `rooms/room.gd`.

Te ostatnie zmiany **nie zostały jeszcze zweryfikowane playtestem**. W środowisku Codexa nie ma dostępnego polecenia Godot CLI, więc nie ma lokalnego smoke-testu.

## Kolejność pracy

### 0. Pokój wzorcowy — blokujący etap odbioru

Zanim poprawisz wszystkie pokoje lub wygenerujesz kolejne grafiki, przygotuj
jeden widoczny w grze pokój testowy z: graczem, małym wrogiem, ciężkim wrogiem,
drzwiami, skrzynią, pociskiem i telegraph/VFX obszarowym.

Wykorzystaj istniejące `RoomAtmosphere`, `ContactShadow`, `WorldAmbient` oraz
`Walls`. Dodaj jedynie brakujące, małe rekwizyty/lokalne światło, jeśli są już
w assetach. Nie zastępuj całego świata jednym filtrem ekranu i nie zmieniaj
mechaniki. Zrób screen przed/po i dopiero po akceptacji przenieś rozwiązanie
na wszystkie typy pokoi.

### 1. Walidacja fundamentu wizualnego

Uruchom grę i zrób jeden screen: gracz + trzy różne losowe wrogowie + drzwi + telegraf ataku. Oceń:

- czy cień kontaktowy nie jest zbyt duży/czarny,
- czy ambient nie przyciemnia HUD-u,
- czy drzwi są w całości wewnątrz pokoju,
- czy player jest czytelniejszy od tła.

Popraw tylko wartości liczbowe, jeśli potrzeba. Nie usuwaj komponentu cienia bez sprawdzenia jego `z_index` i `show_behind_parent`.

### 2. Skala i powtarzalność losowych wrogów

Podłącz docelowe `*_base.png` dla 11 archetypów zamiast obecnych tymczasowych wcieleń. Na okres przed animacjami można użyć tej samej grafiki dla front/back/side, ale nie zmieniaj colliderów razem ze skalą grafiki.

Ustal `visual_scale` per archetyp, nie ręcznie w scenach:

- Chaser/Striker/Shooter/Dasher: 0.65–0.85 gracza,
- Orbiter/Ambusher/Zoner/Support: 0.80–0.95,
- Charger/Summoner/Tank: 1.05–1.35,
- wcielenia: 1.60–2.20,
- Nemorax: 2.80+.

Przy spawnie wprowadź małe, deterministyczne wariacje: `flip_h`, skala ±5%, jasność/saturacja ±5%. Nie psuj seedów ani mechaniki.

### 3. Podłogi i drzwi

Dodaj mapowanie 8 motywów z `assets/sprites/pokoje/tekstury/random_rooms/` do losowych pokoi. Zachowaj istniejące kolizje i typy pokoi.

Sprawdź w grze, czy tekstury nie mają widocznego szwu oraz czy ich kontrast nie konkuruje z VFX. Jeśli tło jest zbyt mocne, reguluj globalny ambient, nie dodawaj osobnych filtrów na każdy kafel.

### 4. VFX

Podłącz po jednym ataku i jednej umiejętności dla siedmiu istniejących wrogów z katalogu `grafiki do gry/09_room_enemies/enemy_vfx/`. Skopiuj je do przewidywalnego folderu `assets/sprites/enemy_vfx/` i użyj stałych `preload`.

Każdy VFX ma własny czas życia i `z_index`. Telegraf/damage zone musi pozostać czytelny na każdym typie podłogi. Nie używaj efektów gracza jako zastępstwa dla efektów wroga.

### 5. Cutscenki tekstowe

Wdrażaj plan z `PLAN_CUTSCENEK.md` w tej kolejności:

1. `DialogueBeat` Resource + `ui/cutscene_player.gd`: pauza, przejście do następnego beatu, przytrzymanie >0.5 s pomija całą scenę, fallback bez WAV.
2. Prolog i epilog — czarne tło, bez nowych grafik.
3. Upadek wielkiej formy Nemoraxa — użyj istniejących sprite’ów collapse/rebirth/taunt i kolorów faz w tle.
4. Rytuał ołtarza — sześć krótkich beatów przy kolejnych socketach.
5. Dopiero potem opcjonalny parametr `voice` w `ui.show_taunt` i bus `Voice`.

Nie blokuj scen na nagraniach. WAV-y są późniejszym materiałem użytkownika.

## Kryteria zakończenia Twojej części

- scena nie wygląda jak zestaw naklejek: cienie są widoczne, lecz subtelne,
- zwykły wróg nie konkuruje rozmiarem z minibossem,
- nie ma lustrzanych duplikatów wrogów,
- drzwi nie są obcięte przez brzeg,
- VFX są przypisane do walki i czytelne,
- prolog i epilog da się odtworzyć oraz pominąć bez głosów,
- mechanika, save data i hitboxy nie zmieniły się przypadkiem,
- uruchom testy/smoke-test w lokalnym Godot i przekaż wynik.

## Czego teraz nie robić

- nie generować 84 ujęć chodu wcieleń/Nemoraxa,
- nie generować 252 póz bojowych,
- nie przebudowywać AI, Content Bible, mapy ani systemu walki,
- nie zastępować istniejących assetów, jeśli da się je podpiąć i ocenić w grze.
