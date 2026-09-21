# NEMORAX — plan podniesienia jakości oprawy do poziomu gry premium

## Rola i zasada pracy

Jesteś odpowiedzialny za **integrację i polish wizualny**, nie za tworzenie nowych mechanik walki. Celem jest, aby elementy przestały wyglądać jak osobne PNG położone na tle i zaczęły funkcjonować jako jeden świat.

Najpierw pracuj na obecnych assetach. Nie generuj masowo nowych postaci ani animacji, dopóki scena bazowa nie będzie spójna. Każdą fazę zweryfikuj w uruchomionej grze oraz headless testami, jeśli dotyka kodu.

## Diagnoza ze stanu obecnego

Na referencyjnym ekranie widać pięć problemów:

1. Postacie nie mają cienia kontaktowego ani wspólnego kierunku światła — wyglądają jak naklejki.
2. Skala jest niespójna: gracz jest za mały względem losowych wrogów, a zwykli przeciwnicy konkurują rozmiarem z minibossem.
3. Identyczne wrogie sprite’y są widoczne jako duplikaty (ta sama poza i symetryczne ustawienie).
4. Podłoga ma zbyt wysoki kontrast i detal; odbiera czytelność postaciom, pociskom oraz telegrafom.
5. Drzwi leżą na granicy obrazu i wyglądają jak część ramki/HUD-u, zamiast obiektów osadzonych w pokoju.

## Docelowy styl

- Kamera: czytelny dark-fantasy top-down, gra akcji; gracz i zagrożenia muszą być ważniejsze niż dekoracja.
- Światło: chłodny zielono-fioletowy ambient, przygaszone otoczenie; akcenty kolorystyczne są zarezerwowane dla mechanik, VFX i ważnych przeciwników.
- Hierarchia: gracz > aktualne zagrożenie i telegraf > aktywny miniboss > drzwi/interakcje > podłoga i ściany.
- Tło nie może mieć jaśniejszych kontrastów niż sylwetka gracza w centrum pokoju.

## Faza A — fundament sceny (najwyższy priorytet)

### A1. Wspólny cień kontaktowy

Dodaj jeden reużywalny komponent `entities/contact_shadow.gd` oraz małą scenę/komponent `ContactShadow` oparty o `Sprite2D` albo `_draw()` elipsy. Nie twórz osobnego cienia dla każdego typu potwora.

Wymagania:

- Miękka czarna elipsa pod stopami/środkiem masy (`Color(0,0,0,0.30–0.45)`), bez ostrej obwódki.
- Cień ma być poniżej sprite’a (`z_index` niższy), ale nad podłogą.
- Skala cienia zależna od rozmiaru postaci; mały wróg ~0.45–0.60 szerokości sprite’a, miniboss ~0.60–0.75.
- Niski alfa dla istot lewitujących, wyższy dla ciężkich (Tank, Summoner, Nemorax).
- Lekko spłaszczony pionowo, przesunięty kilka pikseli w dół ekranu.

Podepnij komponent do: gracza, Nemoraxa, sześciu wcieleń, 11 losowych wrogów, skrzyni i drzwi. Nie podpinaj go do pocisków, promieni ani czystych VFX.

### A2. Jednolity ambient i kontrast tła

Dodaj prostą globalną warstwę kolorystyczną sceny (`CanvasModulate` lub `WorldEnvironment`, zależnie od obecnej architektury), nie nakładaj ręcznych `modulate` na każdy sprite.

Punkt startowy do korekty:

- ambient chłodny zielonkawo-fioletowy,
- podłoga/ściany: mniej nasycenia i mniej kontrastu niż obecnie,
- nie przyciemniaj VFX, HUD-u ani tekstu,
- nie niszcz kolorów faz Nemoraxa, `Palette.DANGER`, cyjanu gracza i złota nagród.

Jeśli `CanvasModulate` obejmuje UI, umieść je we właściwej warstwie, aby HUD pozostał czytelny.

### A3. Materiał „osadzenia” postaci

Nie dodawaj ciężkich shaderów do każdego sprite’a. Po cieniu kontaktowym dodaj tylko subtelny efekt wspólny:

- delikatny przyciemniony obrys/ambient occlusion przy dolnych krawędziach postaci, **albo**
- bardzo lekki shader desaturujący/tonujący assety postaci do wspólnego ambientu.

Efekt ma być prawie niewidoczny samodzielnie; ma działać tylko w połączeniu z cieniem i tłem.

## Faza B — skala, pozycjonowanie i kompozycja

### B1. Skala jako dane, nie przypadkowe ustawienia

Ustal gracza jako punkt odniesienia. Dodaj per-archetyp eksportowaną wartość `visual_scale` albo tabelę skali, zamiast ręcznie zmieniać rozmiar w scenach.

Docelowy punkt startowy do playtestu:

| Kategoria | Skala względem gracza |
| --- | --- |
| Chaser / Striker / Shooter / Dasher | 0.65–0.85 |
| Orbiter / Ambusher / Zoner / Support | 0.80–0.95 |
| Charger / Summoner / Tank | 1.05–1.35 |
| Wcielenie | 1.60–2.20 |
| Nemorax | 2.80+ |

Wartości wymagają testu z prawdziwymi colliderami i telegrafami. Zmiana skali wizualnej nie może potajemnie zmieniać hitboxów.

### B2. Spawning bez widocznych duplikatów

W `rooms/room.gd` lub miejscu spawnów wprowadź deterministyczną drobną wariację wizualną:

- losowe `flip_h` dla sylwetek, które mogą być odbite,
- niewielkie odchylenie skali ±5%,
- niewielka zmiana jasności/saturacji ±5%,
- unikaj ustawiania dwóch identycznych archetypów w lustrzanej symetrii,
- minimalny dystans spawnów zależny od rozmiaru wizualnego.

Nie losuj kierunku/wariacji w sposób psujący seed/run determinism, jeśli projekt go używa.

### B3. Drzwi jako część świata

W `rooms/door.gd` i `rooms/room.gd`:

- Przesuń drzwi kilka–kilkanaście pikseli do wnętrza pokoju; nigdy nie mogą być obcięte przez granicę ekranu.
- Dodaj pod nimi cień kontaktowy i małą kamienną/ciemną podstawę albo subtelny płaski VFX portalu.
- Zachowaj czytelny obszar wejścia; grafika nie może zasłaniać kolizji ani sugerować fałszywej ściany.
- Dopasuj `z_index`, aby drzwi były nad podłogą, ale pod HUD-em i efektami priorytetowymi.

## Faza C — czytelność walki

### C1. Warstwowanie

Spisz i wdroż jedną konwencję `z_index` / warstw:

1. podłoga,
2. cienie kontaktowe,
3. dekoracje niskie,
4. postacie i drzwi,
5. pociski/VFX nad postaciami,
6. telegrafy ataków, gdy muszą być czytelne,
7. HUD i cutscenki.

Sprawdź, czy telegrafy nigdy nie chowają się pod podłogą lub dużym sprite’em.

### C2. VFX

Są już gotowe osobne VFX w `grafiki do gry/09_room_enemies/enemy_vfx/`. Podepnij je etapami do siedmiu istniejących wrogów:

- jeden zwykły atak + jedna umiejętność na archetyp,
- VFX ma mieć własny czas życia, skalę i `z_index`,
- nie używaj jednego efektu gracza jako zastępstwa dla ataku wroga,
- testuj czy kolor ataku nie myli się z `Palette.DANGER` oraz kolorami faz.

### C3. Minimalny juice

Po wdrożeniu VFX dodaj tylko lekkie sprzężenie zwrotne:

- krótkie flash/scale punch przy trafieniu,
- krótki screen shake wyłącznie dla ciężkich ataków,
- bez ciągłego trzęsienia kamery i bez dodatkowych błysków zasłaniających gracza.

## Faza D — gotowe assety do podpięcia

Nie generuj nowych wersji, dopóki istniejące nie zostaną sprawdzone w grze.

- Losowi wrogowie: `assets/sprites/random_enemies/<nazwa>/<nazwa>_base.png`.
- Aura elity: `assets/sprites/random_enemies/elite/elite_aura.png`.
- Skrzynie: `assets/sprites/pokoje/obiekty/chest/chest_closed.png` i `chest_open.png`.
- Tekstury pokoi: `assets/sprites/pokoje/tekstury/random_rooms/`.
- Wrogi VFX: katalog oceny `grafiki do gry/09_room_enemies/enemy_vfx/`; po akceptacji skopiuj je do przewidywalnego folderu assetów projektu i użyj stałych `preload`.

`rooms/chest.gd` nadal wymaga zastąpienia tymczasowego `_draw()` przez dwa `Sprite2D` przełączane po `_opened`. Zachowaj obecną mechanikę, zasięg interakcji i sygnał `opened`.

## Faza E — cutscenki po fundamencie wizualnym

Nie blokuj polishu świata czekaniem na głosy. Wdrażaj tekst i istniejące portrety/sprite’y:

1. `DialogueBeat` Resource + `ui/cutscene_player.gd` z pauzą, skipem beatu i skipem całej sceny.
2. Prolog oraz epilog: czarne tło, tekst, bez nowych grafik.
3. Upadek wielkiej formy Nemoraxa: użyj istniejących `collapse`, `rebirth` i `taunt`; kolory faz w tle, bez tworzenia nowej postaci.
4. Rytuał: sześć krótkich beatów z istniejącymi sprite’ami wcieleń przy zapalaniu gniazd.
5. Dopiero później osobny bus `Voice` i WAV-y.

## Faza F — animacje kierunkowe, ale dopiero po akceptacji

Pilotaż gracza ma już siedem nowych ujęć. Uruchom go, oceń w rzeczywistym ruchu i dopiero wtedy:

1. chód sześciu wcieleń,
2. chód sześciu faz Nemoraxa,
3. dopiero później 252 kierunkowe pozy bojowe.

Nie generuj ani nie podpinaj 343 obrazków animacji przed potwierdzeniem, że skala, cień, ambient oraz styl pilotażu są zaakceptowane.

## Kryteria odbioru po każdej fazie

- Gracz jest rozpoznawalny w mniej niż sekundę w każdym pokoju i podczas walki.
- Żadna postać nie wygląda jak lewitująca naklejka; ma cień kontaktowy.
- Zwykły wróg nie konkuruje wizualnie z minibossem.
- Ten sam archetyp nie wygląda jak lustrzana kopia drugiego wroga.
- Drzwi są obiektem świata, nie elementem ramki ekranu.
- Telegrafy i VFX są czytelne na wszystkich ośmiu teksturach pokoi.
- HUD pozostaje jasny i nie dostaje globalnego przyciemnienia.
- Testy gry przechodzą; nie ma zmian mechaniki, hitboxów ani save data bez świadomej decyzji.

## Zakaz zakresowego puchnięcia

Nie przebudowuj walki, mapy, AI, Content Bible ani systemu animacji szkieletowej w ramach tego zadania. Najpierw dowieź tani, wspólny fundament renderowania i pokaż porównanie przed/po na jednym pokoju z graczem, trzema różnymi wrogami, drzwiami oraz telegrafem.
