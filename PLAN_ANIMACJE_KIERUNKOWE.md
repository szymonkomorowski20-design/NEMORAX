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
      (pozostałe ~126 obrazków, patrz sekcja 4). To jedyna otwarta decyzja.
