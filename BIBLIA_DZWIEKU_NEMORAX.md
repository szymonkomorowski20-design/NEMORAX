# NEMORAX — biblia dźwięku i pełna lista produkcyjna

> Cel: dźwięk ma nie tylko ozdabiać obraz. Ma mówić graczowi, co się dzieje,
> nadać walce ciężar i sprawić, że świat NEMORAXA jest fizyczny, mroczny oraz spójny.
>
> Ten dokument jest specyfikacją dla osoby dobierającej/generującej dźwięki i dla
> osoby podpinającej je w grze. Nie oznacza, że każdy punkt potrzebuje osobnego
> unikalnego nagrania: liczba w nawiasie oznacza wymaganą liczbę wariantów.

## 1. Zasady brzmienia

- **Materia zamiast arcade'u.** Kamień, kość, mokry pancerz, stare drewno, metal i
  przestrzeń podziemi są podstawą. Magia jest dodatkiem do materii, nigdy czystym
  neonowym "laserem".
- **Czytelność przed hałasem.** Ostrzeżenie ataku jest krótkie i rozpoznawalne;
  sama eksplozja nie może go zagłuszać.
- **Jedna paleta świata.** Niskie częstotliwości, kamień, odległy pogłos, zimne
  kryształy i organiczny szmer otchłani. Złoto/reward jest ciepłe, ale nie kreskówkowe.
- **Mniej, ale ciężej.** Nie używać długich efektów dla każdego kliknięcia. Najmocniejsze
  dźwięki są zachowane dla krytyka, relikwii, wejścia bossa i śmierci.
- **Brak pętli do wykrycia.** Dla powtarzalnej akcji stosować 3–5 wariantów oraz
  delikatną losową zmianę wysokości i głośności.

## 2. Docelowa paczka

| Rodzaj | Unikalne zdarzenia | Warianty | Szacunkowa liczba plików |
|---|---:|---:|---:|
| Rdzeń gracza i walka | 34 | 2–5 | 105 |
| Wrogowie i minibossowie | 43 | 2–4 | 118 |
| Nemorax | 26 | 2–4 | 73 |
| Świat, pokoje i nagrody | 35 | 2–4 | 91 |
| UI, menu i cutscenki | 31 | 2–3 | 71 |
| Ambience i muzyka | 21 | 1–3 | 42 |
| **Łącznie** | **190** |  | **około 500 WAV** |

Nie produkujemy 500 plików jednego dnia. Najpierw powstaje pakiet **P0: 50 plików**,
który sprawia, że gra natychmiast brzmi lepiej. Resztę dokładamy biomami i bossami.

## 3. Nazewnictwo i parametry

Folder: `assets/audio/<kategoria>/`. Każdy plik w formacie WAV, 48 kHz, 24-bit.

Format nazwy: `nmx_<system>_<akcja>_<wariant>.wav`

Przykłady:

- `nmx_player_sword_swing_01.wav`
- `nmx_enemy_tank_telegraph_02.wav`
- `nmx_world_chest_open_01.wav`
- `nmx_ui_relic_confirm_01.wav`

Każdy efekt dostaje metadane: `ID`, użycie, priorytet, czas trwania, warianty,
czy jest przestrzenny, oraz opis emocji. Nigdy nie dodawać pliku bez przypisanego ID.

Priorytety:

- **P0** — bez tego walka lub informacja dla gracza są nieczytelne.
- **P1** — silnie podnosi feeling, wdrażać po P0.
- **P2** — buduje bogactwo świata po ustabilizowaniu rdzenia.

## 4. P0 — pierwszy pakiet do zrobienia i podpięcia

| ID | Zdarzenie | Warianty | Krótki charakter |
|---|---|---:|---|
| PLAYER_SWORD_SWING | zamach mieczem | 4 | szybki świst metalu i powietrza |
| PLAYER_SWORD_HIT_FLESH | trafienie w ciało | 4 | ciężki, krótki impakt organiczny |
| PLAYER_SWORD_HIT_ARMOR | trafienie w pancerz | 4 | metal/kamień, bez wysokiego "ping" |
| PLAYER_WAND_CAST | rzut czaru | 3 | zimny szept + skupienie energii |
| PLAYER_WAND_HIT | trafienie czarem | 3 | przytłumione pęknięcie magii |
| PLAYER_DASH | unik | 3 | płaszcz, pył i powietrze |
| PLAYER_HURT | obrażenia gracza | 3 | niski, czytelny sygnał bólu/uderzenia |
| PLAYER_DEATH | śmierć gracza | 1 | ciężki upadek + gasnąca energia |
| ENEMY_TELEGRAPH | ostrzeżenie wroga | 4 | krótki, odróżnialny sygnał zagrożenia |
| ENEMY_HIT | obrażenia wroga | 4 | zależne od materiału, nie komiczne |
| ENEMY_DEATH | śmierć zwykłego wroga | 4 | masa zanika w kamieniu/mgle |
| ENEMY_ELITE_AURA | pojawienie elity | 2 | niski puls, zimna magia |
| BOSS_INTRO | wejście bossa | 1 | niski stinger, oddech areny |
| BOSS_TELEGRAPH | silny atak bossa | 3 | wyraźny, nisko-średni alarm |
| BOSS_HIT | trafienie bossa | 3 | pancerz/kość z ogromem masy |
| BOSS_PHASE | zmiana fazy | 1 | świat pęka, krótki oddech ciszy |
| BOSS_DEATH | śmierć bossa | 1 | pęknięcie, zapadanie, wydech |
| WORLD_DOOR_OPEN | otwarcie drzwi | 2 | kamień przesuwa się po kamieniu |
| WORLD_DOOR_CLOSE | zamknięcie drzwi | 2 | ciężki rygiel i głuchy impakt |
| WORLD_PORTAL_IDLE | portal — pętla | 1 | delikatny, nieregularny szmer otchłani |
| WORLD_PORTAL_USE | wejście w portal | 2 | zasysanie, kamień, krótka pustka |
| WORLD_CHEST_DROP | skrzynia pojawia się | 2 | drewno/metal osiada na podłodze |
| WORLD_CHEST_OPEN | otwarcie skrzyni | 2 | zamek, zawias, ciepłe złote echo |
| REWARD_RELIC_REVEAL | pokaz relikwii | 2 | przyziemny stinger z magicznym ogonem |
| REWARD_RELIC_CONFIRM | wybór relikwii | 2 | satysfakcjonujące domknięcie, nie fanfara |
| UI_NAVIGATE | zmiana wyboru | 3 | krótki kamienno-metaliczny ruch |
| UI_CONFIRM | zatwierdzenie | 2 | ciężki, pewny klik |
| UI_BACK | powrót | 2 | stłumiony ruch w dół |
| UI_ERROR | brak możliwości | 2 | zimny, krótki dysonans |
| UI_LEVEL_UP | zdobycie poziomu | 1 | narastająca energia, bez jaskrawości |
| UI_ALTAR_OPEN | wejście do Ołtarza | 1 | kamień, runy, niski pogłos |
| UI_ALTAR_POINT | dodanie punktu | 2 | runiczny klik + mały rezonans |
| UI_STATS_OPEN | Księga Runu | 1 | skóra/kamień, szept kart |
| AMB_ROOM_COMBAT | pętla walki | 1 | cichy puls napięcia, bez melodii |
| AMB_ROOM_CLEAR | pokój wyczyszczony | 1 | walka gaśnie, zostaje przestrzeń |

## 5. Gracz — pełna lista

### Ruch i kondycja

- `PLAYER_FOOTSTEP_STONE` (5, P1) — kamienny pokój.
- `PLAYER_FOOTSTEP_WET` (5, P1) — zalane katakumby.
- `PLAYER_FOOTSTEP_WOOD` (4, P2) — biblioteka/ruiny.
- `PLAYER_FOOTSTEP_CRYSTAL` (4, P1) — kryształowa grota.
- `PLAYER_FOOTSTEP_ASH` (4, P2) — popiół/pobojowisko.
- `PLAYER_CLOTH_MOVE` (3, P2) — bardzo cichy ruch szat, tylko przy wolnym ruchu.
- `PLAYER_DASH_START`, `PLAYER_DASH_TRAVEL`, `PLAYER_DASH_END` (po 3, P0/P1/P1).
- `PLAYER_BLOCK_RAISE`, `PLAYER_BLOCK_HOLD`, `PLAYER_BLOCK_HIT`, `PLAYER_BLOCK_BREAK`
  (2/1/3/1, P1).
- `PLAYER_HEAL_START`, `PLAYER_HEAL_LOOP`, `PLAYER_HEAL_END` (2/1/2, P1).
- `PLAYER_HURT_LIGHT`, `PLAYER_HURT_HEAVY`, `PLAYER_LOW_HP_LOOP` (3/3/1, P0/P1/P1).
- `PLAYER_DEATH`, `PLAYER_REVIVE` (1/1, P0/P1).

### Broń i magia

- `PLAYER_SWORD_SWING`, `PLAYER_SWORD_HIT_FLESH`, `PLAYER_SWORD_HIT_ARMOR`,
  `PLAYER_SWORD_CRIT`, `PLAYER_SWORD_MISS` (4/4/4/3/2, P0/P0/P0/P1/P2).
- `PLAYER_WAND_CHARGE`, `PLAYER_WAND_CAST`, `PLAYER_WAND_PROJECTILE_LOOP`,
  `PLAYER_WAND_HIT`, `PLAYER_WAND_CRIT` (2/3/2/3/2, P1/P0/P1/P0/P1).
- `PLAYER_SKILL_READY`, `PLAYER_SKILL_CAST`, `PLAYER_SKILL_IMPACT`,
  `PLAYER_SKILL_COOLDOWN_READY` (2/3/3/2, P1).
- `PLAYER_SECOND_IMPACT` (3, P0) — drugi cios musi brzmieć jak osobna, realna akcja.
- `PLAYER_DAMAGE_UP`, `PLAYER_ATTACK_SPEED_UP`, `PLAYER_CRIT_UP`, `PLAYER_MAX_HP_UP`
  (po 1, P1) — krótkie sygnały tylko w ekranie nagrody/statystyk.

## 6. Zwykli wrogowie i elity — pełna lista

Dla każdego z 11 archetypów obowiązuje ten sam zestaw: `SPAWN`, `IDLE`, `ALERT`,
`ATTACK`, `SKILL`, `HURT`, `DEATH`. Nie wszystkie potrzebują głosu; różnica może
wynikać z pancerza, kroków, kości, energii i oddechu.

### Wspólny system

- `ENEMY_SPAWN_PORTAL` (3, P1), `ENEMY_ROOM_LOCK` (1, P1), `ENEMY_ROOM_CLEAR` (1, P1).
- `ENEMY_ELITE_SPAWN`, `ENEMY_ELITE_AURA_LOOP`, `ENEMY_ELITE_DEATH` (2/1/2, P0/P1/P1).
- `ENEMY_PROJECTILE_WHOOSH`, `ENEMY_PROJECTILE_IMPACT`, `ENEMY_AOE_WARNING`,
  `ENEMY_AOE_IMPACT` (3/4/3/4, P0/P0/P0/P0).

### Role — charaktery i obowiązkowe sygnały

- **Tank:** ciężkie kroki, kamienny zamach, zbrojny impakt, krótki niski telegraph.
- **Striker:** szybki oddech/ślizg przed szarżą, gwałtowny impakt końcowy.
- **Ambusher:** cichy szmer pojawienia, charakterystyczny sygnał tuż przed skokiem.
- **Summoner:** runiczna inkantacja, osobne brzmienie przywołania, słabszy dźwięk sługi.
- **Support:** chłodny ton wzmacniania, rozpoznawalne leczenie/tarcza.
- **Ranged:** napięcie pocisku, lot, impakt w ziemię/postać.
- **Swarm:** cichy, organiczny tłum zamiast dziesiątek pełnych głośności efektów.

Dla nazwanych archetypów (`Striker`, `Ambusher`, `Summoner`, `Support` oraz siedmiu
istniejących) tworzymy osobne pliki w `enemy/<archetyp>/`, ale zachowujemy powyższą
gramatykę, by gracz uczył się systemu.

## 7. Sześciu minibossów i Nemorax

### Każdy miniboss

- `INTRO`, `IDLE_LOOP`, `TELEGRAPH_LIGHT`, `TELEGRAPH_HEAVY`, `ATTACK_LIGHT`,
  `ATTACK_HEAVY`, `SKILL`, `HURT_ARMOR`, `HURT_WEAKPOINT`, `PHASE_CHANGE`, `DEATH`
  (razem 11 zdarzeń × 6 bossów, P0 dla telegraphów/ataków, P1 dla reszty).
- Atak ma trzy części: ostrzeżenie → wykonanie → efekt na podłodze. Muszą być
  słyszalne osobno, inaczej walka będzie nieuczciwa.

### Nemorax

- `NEMORAX_ARENA_ENTER`, `NEMORAX_BREATH_LOOP`, `NEMORAX_ROAR`, `NEMORAX_STEP`,
  `NEMORAX_TENTACLE_MOVE` (1/1/2/3/3, P1).
- `NEMORAX_TELEGRAPH_MELEE`, `NEMORAX_TELEGRAPH_AOE`, `NEMORAX_TELEGRAPH_PROJECTILE`,
  `NEMORAX_TELEGRAPH_DARKNESS` (po 3, P0).
- `NEMORAX_ATTACK_MELEE`, `NEMORAX_ATTACK_AOE`, `NEMORAX_PROJECTILE_CAST`,
  `NEMORAX_PROJECTILE_LOOP`, `NEMORAX_PROJECTILE_IMPACT` (3/3/3/2/3, P0).
- `NEMORAX_DARKNESS_START`, `NEMORAX_DARKNESS_LOOP`, `NEMORAX_DARKNESS_END`
  (1/1/1, P0) — krąg widzenia nie może zagłuszać gracza; dźwięk ma pomagać odnaleźć kierunek.
- `NEMORAX_PHASE_01` do `NEMORAX_PHASE_06` (po 1, P1) — każda faza dostaje własny
  krótki znak muzyczny i materialny oddech.
- `NEMORAX_HURT`, `NEMORAX_WEAKPOINT_HIT`, `NEMORAX_DEATH_START`, `NEMORAX_DEATH_END`
  (3/3/1/1, P0/P0/P1/P1).

## 8. Świat, pokoje i nagrody

### Drzwi, portal i przejścia

- `WORLD_DOOR_LOCK`, `WORLD_DOOR_UNLOCK`, `WORLD_DOOR_OPEN`, `WORLD_DOOR_CLOSE`
  (2/2/2/2, P0/P1/P0/P0).
- `WORLD_PORTAL_IDLE`, `WORLD_PORTAL_NEAR`, `WORLD_PORTAL_USE`, `WORLD_PORTAL_EXIT`
  (1/1/2/1, P0/P2/P0/P1).
- `WORLD_ROOM_ENTER`, `WORLD_ROOM_COMBAT_START`, `WORLD_ROOM_CLEAR`, `WORLD_ROOM_EXIT`
  (1/1/1/1, P1).

### Skrzynie, ołtarz i relikwie

- `WORLD_CHEST_DROP`, `WORLD_CHEST_LAND`, `WORLD_CHEST_OPEN`, `WORLD_CHEST_EMPTY`
  (2/2/2/1, P0/P1/P0/P2).
- `WORLD_ALTAR_IDLE`, `WORLD_ALTAR_APPROACH`, `WORLD_ALTAR_OPEN`, `WORLD_ALTAR_POINT`,
  `WORLD_ALTAR_CONFIRM`, `WORLD_ALTAR_CLOSE` (1/1/1/2/2/1, P0/P1).
- `REWARD_RELIC_REVEAL`, `REWARD_RELIC_HOVER`, `REWARD_RELIC_CONFIRM`,
  `REWARD_RELIC_REJECT`, `REWARD_RARE_REVEAL` (2/2/2/1/2, P0/P1).
- `REWARD_LEVEL_UP`, `REWARD_CURRENCY_GAIN`, `REWARD_HEALTH_PICKUP`,
  `REWARD_KEY_ITEM` (1/3/3/2, P0/P1).

### Pułapki i obiekty

- `WORLD_TRAP_ARM`, `WORLD_TRAP_TELEGRAPH`, `WORLD_TRAP_FIRE`, `WORLD_TRAP_RESET`
  (2/2/3/1, P1).
- `WORLD_BREAKABLE_HIT`, `WORLD_BREAKABLE_DESTROY`, `WORLD_SECRET_REVEAL`
  (3/3/1, P2).

## 9. Ambience, biomy i muzyka

Każdy ambient jest cichy, nieregularny i złożony z minimum dwóch pętli o różnej
długości, aby nie zdradzał powtórzenia.

- `AMB_MENU_CAVERN` (1, P1) — odległy wiatr, ogrom pustki, pojedyncze krople.
- `AMB_HUB_ALTAR` (1, P1) — kamień, runy, prawie niesłyszalny szept.
- `AMB_FLOODED_CATACOMBS`, `AMB_SUNKEN_LIBRARY`, `AMB_FROZEN_CRYPT`,
  `AMB_BLOOD_RITUAL_HALL`, `AMB_OVERGROWN_RUINS`, `AMB_ASH_BATTLEFIELD`,
  `AMB_CRYSTAL_CAVERN`, `AMB_RUSTED_MACHINE_HALL` (po 2, P1).
- `MUSIC_MENU`, `MUSIC_EXPLORATION`, `MUSIC_COMBAT`, `MUSIC_ELITE`,
  `MUSIC_MINIBOSS`, `MUSIC_NEMORAX_PHASE_01..06`, `MUSIC_VICTORY`, `MUSIC_DEFEAT`
  (P1; muzyka ma mieć wersje/stemy, nie obowiązkowo odrębne pełne utwory).
- `STINGER_RUN_START`, `STINGER_BOSS_INTRO`, `STINGER_PHASE_CHANGE`,
  `STINGER_RELIC_RARE`, `STINGER_VICTORY` (po 1–2, P1).

## 10. UI, menu, mapa i cutscenki

### Menu i nawigacja

- `UI_BOOT`, `UI_PRESS_ANY_KEY`, `UI_NAVIGATE`, `UI_CONFIRM`, `UI_BACK`, `UI_ERROR`,
  `UI_TAB_OPEN`, `UI_TAB_CLOSE`, `UI_SLIDER_MOVE`, `UI_TOGGLE_ON`, `UI_TOGGLE_OFF`
  (P0 dla nawigacji/potwierdzenia, P1 reszta).
- `UI_PAUSE_OPEN`, `UI_PAUSE_CLOSE`, `UI_OPTIONS_OPEN`, `UI_SAVE`, `UI_LOAD`
  (P1).

### Księga Runu, HUD i mapa

- `UI_STATS_OPEN`, `UI_STATS_CLOSE`, `UI_RELIC_SELECT`, `UI_RELIC_INSPECT`,
  `UI_RELIC_ACTIVE`, `UI_RELIC_TRIGGER`, `UI_STAT_INCREASE` (P1).
- `UI_MAP_OPEN`, `UI_MAP_CLOSE`, `UI_MAP_ROOM_DISCOVER`, `UI_MAP_BOSS_MARKER`
  (P1/P1/P2/P1).
- `UI_HP_LOW`, `UI_BOSS_BAR_APPEAR`, `UI_BOSS_BAR_PHASE`, `UI_NOTIFICATION_LIGHT`,
  `UI_NOTIFICATION_IMPORTANT` (P0/P1).

### Cutscenki

- `CUTSCENE_PROLOG_START`, `CUTSCENE_TEXT_REVEAL`, `CUTSCENE_TEXT_ADVANCE`,
  `CUTSCENE_RITUAL_START`, `CUTSCENE_INCARNATION_REVEAL`, `CUTSCENE_TWIST`,
  `CUTSCENE_EPILOGUE_START`, `CUTSCENE_END` (P1).
- Tekst nie może klikać jak zwykłe UI — to powinien być dyskretny, organiczny szelest
  lub odległy szept używany oszczędnie.

## 11. Miks i wdrożenie w grze

### Bussy

- `Master`
  - `Music`
  - `Ambient`
  - `World`
  - `Player`
  - `Enemies`
  - `Boss`
  - `UI`
  - `Cutscene`

### Reguły miksu

- W momencie telegraphu bossa muzyka i ambient są obniżone o około 3–5 dB.
- W chwili potężnego trafienia na 80–150 ms lekko ściszyć całość poza impaktem.
- Maksymalnie trzy pełnogłośne impulsy w tej samej chwili; reszta jest limitowana
  albo zastępowana wariantem cichszym.
- UI jest zawsze poza pozycjonowaniem przestrzennym. Ataki, portal i wrogowie mogą
  być pozycjonowane, ale kluczowy sygnał zagrożenia nigdy nie może zniknąć całkiem
  tylko dlatego, że jest przy krawędzi ekranu.
- Dźwięk nie informuje o tajemnicy, zanim gracz nie ma podstaw, by ją zobaczyć.

## 12. Kolejność prac

1. **P0 / pierwsza sesja:** 50 plików z tabeli P0; podpiąć do jednej testowej trasy.
2. **Walidacja:** nagrać 10 minut gry i sprawdzić, czy z zamkniętymi oczami da się
   rozpoznać unik, trafienie, atak wroga, nagrodę i zagrożenie bossa.
3. **P1 / drugi etap:** pełny gracz, czterej brakujący archetypy, skrzynie, ołtarz,
   portal, miniboss i pierwsza faza Nemoraxa.
4. **P2 / trzeci etap:** biomy, menu, cutscenki, detale obiektów, warianty i miks.
5. **Finalny test:** grać 30 minut wyłącznie na słuchawkach. Każdy dźwięk, który
   drażni, powtarza się zbyt często albo zagłusza ostrzeżenie, zmieniać/usunąć.

## 13. Kryterium akceptacji

Dźwięk jest gotowy nie wtedy, gdy "każda rzecz coś gra", ale gdy:

- gracz rozumie źródło obrażeń bez spoglądania na liczby;
- krytyk, relikwia i pokonanie elity dają odczuwalną nagrodę;
- w pokoju nie ma ciszy technicznej, ale też nie ma nieustannego hałasu;
- Nemorax budzi napięcie zanim zaatakuje;
- po wyłączeniu muzyki gra nadal ma masę, przestrzeń i rytm;
- po włączeniu muzyki nadal słychać najważniejszą informację z walki.
