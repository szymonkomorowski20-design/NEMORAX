# NEMORAX — Plan: postacie obracające się o 360° (ruch/atak w każdym kierunku)

Odpowiedź na pytanie z rozmowy: "czy to wykonalne i co trzeba zrobić". Ten
dokument to kompletna baza — stan obecny, dlaczego samo "obrócić sprite'a" nie
zadziała, trzy warianty rozwiązania z realnymi kosztami, oraz konkretny plan
etapowy z listą brakujących rzeczy.

**Skrócona odpowiedź: TAK, wykonalne, ale nie przez zwykłą rotację. Wymaga
dodatkowych obrazków (widok z tyłu + z boku) do części póz, plus mała zmiana
w kodzie wyboru tekstury. Da się to zrobić etapami, zaczynając od jednej,
najbardziej opłacalnej pozy (chód), zamiast wszystkiego naraz.**

---

## 1. Dlaczego zwykła rotacja nie wystarczy

W silniku dziś rotują się TYLKO efekty bez wyróżnionego "przodu": łuk cięcia
mieczem (`slash_arc`), strzałka ostrzegająca przed wypadem Nemoraksa
(`lunge_warning`), pocisk różdżki. Kod: `sprite.rotation = kierunek.angle()`.

Ciała postaci (gracz, 6 wcieleń, Nemorax) NIGDY się nie obracają ani nie
odbijają — zawsze pokazują tę samą, płaską grafikę wygenerowaną jako "widok od
przodu / z góry", niezależnie od kierunku ruchu czy celowania. To działa,
dopóki postać naturalnie idzie "w stronę kamery" — ale obrócenie takiej płaskiej
grafiki o 90°/180° sprawia, że postać wygląda, jakby się położyła na boku,
zamiast odwrócić się plecami czy bokiem. Dlatego to nie jest bug do naprawienia
jedną linijką — to brak grafiki na pozostałe kierunki.

---

## 2. Stan obecny — pełna inwentaryzacja póz "ciała" (tam gdzie brakuje kierunków)

### Gracz (`entities/player.gd`) — 11 stanów, sterowane `_attack_direction` (cel myszy) i `velocity` (WASD)

| Stan | Plik | Kierunek dziś |
|---|---|---|
| idle | `player_base.png` | zawsze przód |
| chód | `player_walk.png` | zawsze przód |
| dash | `player_dash.png` | zawsze przód |
| zamach mieczem | `player_sword_windup.png` | zawsze przód |
| cięcie mieczem | `player_sword_active.png` | zawsze przód |
| naciąganie różdżki | `player_wand_windup.png` | zawsze przód |
| strzał różdżką | `player_wand_fire.png` | zawsze przód |
| blok | `player_block.png` | zawsze przód |
| leczenie | `player_heal.png` | zawsze przód |
| trafienie | `player_hit.png` | zawsze przód |
| śmierć | `player_death.png` | zawsze przód |

Gracz ma DWA niezależne kierunki wejścia: `_attack_direction` (mysz — steruje
łukiem cięcia, pociskiem) i `velocity` (WASD — steruje chodem). To ważne przy
projektowaniu: naturalnie "przód postaci" powinien iść za celowaniem myszą w
akcjach bojowych, a za ruchem WASD w chodzie/dashu.

### Sześć wcieleń (`entities/incarnations/*.gd`) — po ~8 stanów każde, sterowane kierunkiem do gracza

Wspólne 7 stanów (Vhar'Nokh, Mordrath, Zha'Ruun, Nekravor, Thal'Gor, Orryx):
`walk`, `telegraph`, `hit`, `death`, `lunge`, `pull`, `cast-pulse` + jedna
unikalna umiejętność na postać (`teleport`/`reappear`+`vanish`/`crush`/
`lifesteal_bite`/`silence_pulse`/`echo_pulse`). Wszystkie sterowane wektorem
"do gracza" (`_drift_towards_player`, `_lunge_direction`) — już policzonym w
kodzie, nie trzeba niczego nowego liczyć, tylko go użyć.

### Nemorax (`entities/boss.gd`) — 17 stanów użytych w grze, sterowane kierunkiem do gracza / celu wypadu

6 baz fazowych (`phase-1_base`...`phase-6_narrow-vision`) + `telegraph`,
`lunge`, `cast-pulse`, `pull`, `hit`, `phase-transform`,
`large-form-collapse`, `small-form-rebirth`, `small-form-taunt`,
`small-form-true-death`. (Uwaga poboczna, nie temat tego dokumentu:
`nemorax_walk.png`, `nemorax_death.png` i `nemorax.png` leżą w katalogu, ale
nie są dziś podpięte pod żaden stan w kodzie.)

**Razem: ok. 76 unikalnych, używanych w grze "stanów ciała" bez wariantu
kierunkowego.**

---

## 3. Trzy warianty rozwiązania

### Wariant A — odbicie lewo/prawo (`flip_h`)

- **Koszt:** zero nowej grafiki. Jedna linijka na plik postaci (9 plików:
  gracz + 6 wcieleń + Nemorax), np. `sprite.flip_h = kierunek.x < 0.0`.
- **Efekt:** postać "patrzy" w lewo albo w prawo zamiast zawsze w tę samą
  stronę. Brak rozróżnienia góra/dół, brak prawdziwego obrotu.
- **Ryzyko:** żadne. Można zrobić od razu, niezależnie od reszty planu.

### Wariant B — prawdziwe warianty kierunkowe (nowa grafika + wybór tekstury)

- Obecna grafika = widok "od przodu" (postać patrzy w stronę kamery). Żeby
  pokryć pełne 360° w 4 kierunkach (przód/tył/lewo/prawo), **wystarczą 2 NOWE
  obrazki na pozę** — "z tyłu" i "z boku" (bok odbijamy `flip_h` na drugą
  stronę, więc lewo i prawo to ta sama grafika). Przód już mamy.
- **Koszt przy pełnym pokryciu wszystkich 76 stanów: ~152 nowe obrazki**
  (76 × 2). To największa pojedyncza operacja generowania grafiki w całym
  projekcie — więcej niż wszystkie dotychczasowe 123 pliki razem wzięte.
- **Realne ryzyko: spójność.** Referencyjny obrazek pokazuje tylko przód —
  poproszenie o widok z tyłu każe modelowi "wymyślić" elementy, których nie
  widać na referencji (skrzydła, ogon, plecy pancerza). To jest największa
  niewiadoma całego planu, nie sama liczba obrazków.
- **Zmiana w kodzie:** patrz sekcja 5.

### Wariant C — szkielet 2D (Skeleton2D/Bone2D, jak Spine/DragonBones)

- Silnikowo Godot to wspiera w pełni. ALE wymaga postaci jako osobnych,
  warstwowych części (tułów/głowa/kończyny/skrzydła) zamiast jednego płaskiego
  obrazka na pozę — czyli innego pipeline'u grafiki od zera, niekompatybilnego
  z już wygenerowanymi ~123 plikami.
- **Niezalecane** przy obecnym stanie projektu — oznaczałoby odrzucenie
  całej dotychczasowej inwestycji w grafikę na rzecz innego podejścia.

---

## 4. Rekomendowany plan etapowy

Zamiast robić Wariant B dla wszystkich 76 stanów naraz (~152 obrazki, duże
ryzyko niespójności), zacząć od stanu, który widać na ekranie NAJDŁUŻEJ i
NAJCZĘŚCIEJ — chodu/dryfowania — i dopiero po ocenie jakości/spójności
decydować, czy rozszerzać na pozy bojowe (zamach, cięcie, trafienie itd.),
które trwają ułamek sekundy i mają mniejszy "zwrot z inwestycji".

| Faza | Zakres | Nowa grafika | Zmiana kodu |
|---|---|---|---|
| **0** | `flip_h` na wszystkich 9 postaciach (Wariant A) | 0 | mała, w każdym z 9 plików |
| **1 — pilotaż** | Tylko pozy "chód"/"idle-dryf": gracz (`player_walk`), 6 wcieleń (`*_walk`), Nemorax (6× `phase-N_base`, bo to jego "chód" na stałe) | 8 pozycji × 2 warianty = **16 obrazków** | struktura danych z sekcji 5, tylko dla stanu "walk" |
| **2** | Ocena jakości pilotażu → decyzja czy iść dalej | — | — |
| **3 — rozszerzenie** | Pozostałe pozy gracza (10 × 2 = 20 obrazków) | 20 | rozszerzenie tej samej struktury |
| **4 — rozszerzenie** | Pozostałe pozy wcieleń (6×7 × 2 ≈ 84 obrazków) | 84 | j.w. |
| **5 — rozszerzenie** | Pozostałe pozy Nemoraksa (11 × 2 = 22 obrazki) | 22 | j.w. |

Fazy 3-5 są **opcjonalne i niezależne od siebie** — można zatrzymać się na
samym pilotażu (Faza 1), jeśli efekt "postać skręca podczas chodu" już
wystarczy, i zostawić pozy akcji (atak/trafienie/śmierć) zawsze "od przodu"
tak jak dziś (to zresztą częsta konwencja w grach top-down: chód kierunkowy,
akcje zawsze czytelne "do kamery").

---

## 5. Co trzeba zmienić w kodzie

1. **Dane:** `_sprite_textures` (incarnation.gd, boss.gd) i odpowiednik w
   player.gd zmieniają się z `{pose: Texture2D}` na `{pose: {"front":
   Texture2D, "back": Texture2D, "side": Texture2D}}` — TYLKO dla póz objętych
   daną fazą (pozy spoza zakresu fazy mają tylko `"front"`, reszta pozostaje
   jak dziś).
2. **Bucket kierunku:** nowa mała funkcja pomocnicza (np. w `Juice` albo nowym
   pliku `facing.gd`), przyjmuje wektor kierunku, zwraca `("front"/"back"/
   "side", flip_h: bool)` na podstawie kąta:
   - `front`: kierunek "w dół" względem kamery (domyślny, już mamy).
   - `back`: kierunek "w górę".
   - `side` + `flip_h=false/true`: kierunek w lewo/prawo.
3. **Źródło kierunku per postać:**
   - Gracz: `_attack_direction` dla póz bojowych (miecz/różdżka/blok/leczenie),
     `velocity` dla chodu/dashu (to już dwa osobne wektory w kodzie, nic nowego
     nie trzeba liczyć).
   - Wcielenia i Nemorax: wektor "do gracza", już liczony w
     `_drift_towards_player`/`_lunge_direction` — trzeba go tylko zapisać do
     pola i odczytać w `_update_sprite_state()`.
4. **Wybór tekstury:** `_update_sprite_state()`/`_update_visuals()` po
   ustaleniu `pose` (jak dziś) dodatkowo ustala `facing` i pobiera
   `_sprite_textures[pose].get(facing, _sprite_textures[pose]["front"])` —
   fallback na `"front"`, żeby pozy bez wariantów kierunkowych (poza zakresem
   danej fazy) działały bez zmian.
5. **`sprite.flip_h`** ustawiane obok wyboru tekstury, tak jak dziś
   `lunge_warning.rotation`.

To wszystko mechaniczne, bez ryzyka — największa niewiadoma leży w punkcie
niżej (grafika), nie w kodzie.

---

## 6. Szablon promptu do generowania nowych ujęć

Dokładnie ta sama zasada co w `POZY_ANIMACJI.md` (referencja, nie opis od
zera) — tu zastosowana do KĄTA WIDOKU zamiast POZY:

> Using the attached image as the exact reference for [NAZWA]'s design — same
> proportions, same colors, same materials, same markings, same accent glow
> color — regenerate this EXACT same creature in the EXACT same pose and
> action ([OPIS POZY, np. "mid-stride walking pose"]), but seen from
> [BACK VIEW: "directly behind, back facing the camera" / SIDE VIEW: "exact
> left-side profile view, facing left"]. Keep the identical art style,
> lighting proportions and color palette as the reference — invent any
> details not visible in the reference (back of armor, wings, tail) in a way
> consistent with the rest of the design. Transparent background, no text,
> single character, no other changes to the design.

Jedna generacja = jeden obrazek = jeden kąt, tak jak przy pozach — łączenie
kilku kątów w jednym zapytaniu kończy się tak samo źle jak łączenie póz.

---

## 7. Lista brakujących rzeczy przed startem (checklist)

**Faza 1 (pilotaż chodu) — ZROBIONE (2026-09-20).** Wygenerowano i podpięto
wszystkie 26 obrazków (player + 6 wcieleń + 6 faz Nemoraksa × back/side), bez
żadnej z nich "popłynięcia" wymagającego regeneracji. Kod: `facing.gd`
(root, nie `entities/`) + `Facing.resolve(tex_or_variants, direction) ->
{"texture","flip_h"}`, wołane z `player.gd` (`_update_visuals`),
`incarnation.gd` (`_update_sprite_state`, wspólne dla wszystkich 6 podklas —
kierunek trzymany w nowym polu `_facing_direction`) i `boss.gd` (analogicznie,
`PHASE_BASE_TEXTURES` jest teraz `Array[Dictionary]`). Zweryfikowane headless
testem czterech kierunków kardynalnych dla gracza/wcielenia/Nemoraksa,
włącznie ze zmianą fazy i czyszczeniem `flip_h` przy przejściu na pozę bez
wariantów. Smoke testy wszystkich scen czyste.

- [ ] Realny playtest — ocena, czy efekt jest wart rozszerzenia na Fazy 3-5
      (pozostałe obrazki, patrz sekcja 4 i pełna lista w sekcji 8). To jedyna
      otwarta decyzja.

---

## 8. Fazy 3-5 — pełna lista plików do wygenerowania (decyzja: rozszerzamy)

Na życzenie autora — pełny backlog, gotowy do odklikania jak
`PROMPTY_FINALNE_WSZYSTKO.md`. Nie duplikuję tu treści opisów póz (już
istnieją i są poprawne w `GRACZ_KOMPLETNY.md`/`POZY_ANIMACJI.md`) — każdy
wiersz mówi, KTÓRY opis wstawić do szablonu z sekcji 6 tego dokumentu jako
`[OPIS POZY]`, i z jakiego pliku wziąć referencję (zawsze aktualny plik `front`
tej pozy, NIGDY plik back/side innej pozy — inaczej błąd się skumuluje).

Dla każdego wiersza: **2 obrazki** (`_back`, `_side`), tym samym szablonem z
sekcji 6, zmieniając tylko [BACK VIEW]/[SIDE VIEW].

### 8.1 Gracz — 10 póz × 2 = 20 obrazków

| Poza | Plik referencyjny (front) | Opis pozy z |
|---|---|---|
| Idle (stanie) | `player_base.png` | `GRACZ_KOMPLETNY.md` §1.1 |
| Dash | `player_dash.png` | `GRACZ_KOMPLETNY.md` §4.2 |
| Zamach mieczem — windup | `player_sword_windup.png` | `GRACZ_KOMPLETNY.md` §4.3 |
| Zamach mieczem — active | `player_sword_active.png` | `GRACZ_KOMPLETNY.md` §4.4 |
| Ładowanie różdżki | `player_wand_windup.png` | `GRACZ_KOMPLETNY.md` §4.5 |
| Wystrzał różdżki | `player_wand_fire.png` | `GRACZ_KOMPLETNY.md` §4.6 |
| Blok | `player_block.png` | `GRACZ_KOMPLETNY.md` §4.7 |
| Leczenie | `player_heal.png` | `GRACZ_KOMPLETNY.md` §4.8 |
| Trafiony | `player_hit.png` | `GRACZ_KOMPLETNY.md` §4.9 |
| Śmierć | `player_death.png` | `GRACZ_KOMPLETNY.md` §4.10 |

### 8.2 Sześć wcieleń — 43 pozy × 2 = 86 obrazków

Uniwersalne 6 póz (opisy w `POZY_ANIMACJI.md` §3.2-3.7, ta sama treść dla
wszystkich sześciu — referencja i tak wymusi właściwy wygląd) × 6 postaci =
36, plus unikalne pozy umiejętności (§4.1-4.7) = 7 (Orryx ma DWIE unikalne:
vanish + reappear). Razem 43.

| Postać | Telegraph | Lunge | Cast-pulse | Pull | Hit | Death | Unikalna(e) |
|---|---|---|---|---|---|---|---|
| Vhar'Nokh | `vhar-nokh_telegraph.png` | `vhar-nokh_lunge.png` | `vhar-nokh_cast-pulse.png` | `vhar-nokh_pull.png` | `vhar-nokh_hit.png` | `vhar-nokh_death.png` | `vhar-nokh_teleport.png` — §4.1 |
| Mordrath | `mordrath_telegraph.png` | `mordrath_lunge.png` | `mordrath_cast-pulse.png` | `mordrath_pull.png` | `mordrath_hit.png` | `mordrath_death.png` | `mordrath_silence-pulse.png` — §4.2 |
| Zha'Ruun | `zha-ruun_telegraph.png` | `zha-ruun_lunge.png` | `zha-ruun_cast-pulse.png` | `zha-ruun_pull.png` | `zha-ruun_hit.png` | `zha-ruun_death.png` | `zha-ruun_echo-pulse.png` — §4.3 |
| Nekravor | `nekravor_telegraph.png` | `nekravor_lunge.png` | `nekravor_cast-pulse.png` | `nekravor_pull.png` | `nekravor_hit.png` | `nekravor_death.png` | `nekravor_crush.png` — §4.4 |
| Thal'Gor | `thal-gor_telegraph.png` | `thal-gor_lunge.png` | `thal-gor_cast-pulse.png` | `thal-gor_pull.png` | `thal-gor_hit.png` | `thal-gor_death.png` | `thal-gor_lifesteal-bite.png` — §4.5 |
| Orryx | `orryx_telegraph.png` | `orryx_lunge.png` | `orryx_cast-pulse.png` | `orryx_pull.png` | `orryx_hit.png` | `orryx_death.png` | `orryx_reappear.png` — §4.6, `orryx_vanish.png` — §4.7 |

(Uniwersalne opisy: Telegraph=§3.2, Lunge=§3.3, Cast-pulse=§3.4, Pull=§3.5,
Hit=§3.6, Death=§3.7 — ta sama kolumna dla wszystkich sześciu wierszy.)

### 8.3 Nemorax — 10 póz × 2 = 20 obrazków

Uniwersalne 5 (bez "death" — Nemorax nie ma generycznej śmierci w kodzie,
tylko dwa specyficzne stany niżej) + 5 unikalnych stanów finałowych.

| Poza | Plik referencyjny (front) | Opis pozy z |
|---|---|---|
| Telegraph | `nemorax_telegraph.png` | `POZY_ANIMACJI.md` §3.2 |
| Lunge | `nemorax_lunge.png` | `POZY_ANIMACJI.md` §3.3 |
| Cast-pulse | `nemorax_cast-pulse.png` | `POZY_ANIMACJI.md` §3.4 |
| Pull | `nemorax_pull.png` | `POZY_ANIMACJI.md` §3.5 |
| Hit | `nemorax_hit.png` | `POZY_ANIMACJI.md` §3.6 |
| Transformacja fazy | `nemorax_phase-transform.png` | `POZY_ANIMACJI.md` §5.1 |
| Upadek dużej formy | `nemorax_large-form-collapse.png` | `POZY_ANIMACJI.md` §5.2 |
| Odrodzenie małej formy | `nemorax_small-form-rebirth.png` | `POZY_ANIMACJI.md` §5.3 |
| Kpina / pytanie finałowe | `nemorax_small-form-taunt.png` | `POZY_ANIMACJI.md` §5.4 |
| Prawdziwa śmierć | `nemorax_small-form-true-death.png` | `POZY_ANIMACJI.md` §5.5 |

### 8.4 Razem

20 (gracz) + 86 (wcielenia) + 20 (Nemorax) = **126 obrazków**. Generować i
integrować w tej samej kolejności co dotąd — partiami po jednej
postaci/kategorii, testować headless po każdej partii, nie na raz.
