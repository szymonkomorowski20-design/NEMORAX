# NEMORAX — Plan: postacie obracające się o 360° (ruch/atak w każdym kierunku)

Odpowiedź na pytanie z rozmowy: "czy to wykonalne i co trzeba zrobić". Ten
dokument to kompletna baza — stan obecny, dlaczego samo "obrócić sprite'a" nie
zadziała, trzy warianty rozwiązania z realnymi kosztami, oraz konkretny plan
etapowy z listą brakujących rzeczy.

**Skrócona odpowiedź: TAK, wykonalne, ale nie przez zwykłą rotację. Wymaga
dodatkowych obrazków (widok z tyłu + z boku) do części póz, plus mała zmiana
w kodzie wyboru tekstury. Da się to zrobić etapami, zaczynając od jednej,
najbardziej opłacalnej pozy (chód), zamiast wszystkiego naraz.**

**Aktualizacja (2026-09-21) — Faza 1b**: pilotaż z Fazy 1 (3 kąty, 1
zamrożona klatka na kąt) dał efekt "chodzenia w rozkroku" — postać zawsze
pokazuje tę samą, statyczną, szeroko rozstawioną pozę zamiast naprzemiennego
kroku, a przy skosach (np. ruch północny-wschód) skacze od razu między
przód/bok zamiast płynnie skręcać. Autor poprosił o dwie rzeczy naraz: **więcej
kątów** (żeby obracanie się wyglądało realniej) i **prawdziwy cykl chodu**
(żeby wyglądało, że postać faktycznie stawia kroki, nie sunie w miejscu).
Sekcje 4-8 poniżej są **przepisane pod tę rozszerzoną wersję** — stara treść
(3 kąty, 1 klatka) zostaje jako historia w sekcjach 1-3, reszta dokumentu
opisuje już docelowy, rozszerzony system.

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
| chód | `player_walk.png` | **5 kątów × 2 klatki od Fazy 1b** (patrz sekcja 8) |
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
kodzie, nie trzeba niczego nowego liczyć, tylko go użyć. `walk` dostaje od
Fazy 1b te same 5 kątów × 2 klatki co gracz.

### Nemorax (`entities/boss.gd`) — 17 stanów użytych w grze, sterowane kierunkiem do gracza / celu wypadu

6 baz fazowych (`phase-1_base`...`phase-6_narrow-vision`) + `telegraph`,
`lunge`, `cast-pulse`, `pull`, `hit`, `phase-transform`,
`large-form-collapse`, `small-form-rebirth`, `small-form-taunt`,
`small-form-true-death`. Baza fazowa to jego "chód"/idle-dryf na stałe —
dostaje te same 5 kątów × 2 klatki co gracz/wcielenia, dla KAŻDEJ z 6 faz
osobno. (Uwaga poboczna, nie temat tego dokumentu: `nemorax_walk.png`,
`nemorax_death.png` i `nemorax.png` leżą w katalogu, ale nie są dziś
podpięte pod żaden stan w kodzie.)

**Razem: ok. 76 unikalnych, używanych w grze "stanów ciała" bez wariantu
kierunkowego — z czego 13 (gracz + 6 wcieleń + 6 faz Nemoraksa, wszystkie to
poza "chód") dostaje od Fazy 1b pełne 5 kątów × 2 klatki.**

---

## 3. Trzy warianty rozwiązania

### Wariant A — odbicie lewo/prawo (`flip_h`)

- **Koszt:** zero nowej grafiki. Jedna linijka na plik postaci (9 plików:
  gracz + 6 wcieleń + Nemorax), np. `sprite.flip_h = kierunek.x < 0.0`.
- **Efekt:** postać "patrzy" w lewo albo w prawo zamiast zawsze w tę samą
  stronę. Brak rozróżnienia góra/dół, brak prawdziwego obrotu.
- **Ryzyko:** żadne. Zrobione już w Fazie 0.

### Wariant B — prawdziwe warianty kierunkowe (nowa grafika + wybór tekstury)

- Obecna grafika = widok "od przodu" (postać patrzy w stronę kamery). Pełne
  360° przy 8 kierunkach (przód/przód-skos/bok/tył-skos/tył, lewo=prawo
  odbite) wymaga **4 NOWYCH kątów widoku** poza już posiadanym przodem —
  patrz sekcja 4 (to jest rozszerzenie względem oryginalnej wersji tego
  dokumentu, która liczyła tylko 2 nowe kąty: tył+bok).
- **Realne ryzyko: spójność.** Referencyjny obrazek pokazuje tylko przód —
  poproszenie o widok z innego kąta każe modelowi "wymyślić" elementy,
  których nie widać na referencji (skrzydła, ogon, plecy pancerza). To jest
  największa niewiadoma całego planu, nie sama liczba obrazków.
- **Zmiana w kodzie:** patrz sekcja 5.

### Wariant C — szkielet 2D (Skeleton2D/Bone2D, jak Spine/DragonBones)

- Silnikowo Godot to wspiera w pełni. ALE wymaga postaci jako osobnych,
  warstwowych części (tułów/głowa/kończyny/skrzydła) zamiast jednego płaskiego
  obrazka na pozę — czyli innego pipeline'u grafiki od zera, niekompatybilnego
  z już wygenerowanymi assetami.
- **Niezalecane** przy obecnym stanie projektu — oznaczałoby odrzucenie
  całej dotychczasowej inwestycji w grafikę na rzecz innego podejścia. Dałoby
  PRAWDZIWY cykl chodu "za darmo" (interpolacja kości), ale kosztem przebudowy
  całego pipeline'u — nieproporcjonalne do problemu ("chód wygląda sztywno").

---

## 4. Plan etapowy (zaktualizowany o Fazę 1b)

| Faza | Zakres | Nowa grafika | Zmiana kodu | Status |
|---|---|---|---|---|
| **0** | `flip_h` na wszystkich 9 postaciach | 0 | mała | ✅ zrobione |
| **1 — pilotaż** | Chód, 3 kąty (przód/tył/bok), 1 klatka/kąt | 16 obrazków | `facing.gd` v1 | ✅ zrobione, ale zastąpione przez 1b niżej |
| **1b — więcej kątów + cykl chodu** | Chód, **5 kątów** (przód/przód-skos/bok/tył-skos/tył) × **2 klatki** (neutralna/krok) | **91 obrazków** (patrz sekcja 8) | `facing.gd` v2 + timer cyklu chodu na każdej postaci | 🔲 do zrobienia — TEN dokument |
| **2** | Ocena jakości po 1b → decyzja czy iść dalej | — | — | otwarte |
| **3-5** | Pozostałe pozy (atak/trafienie/śmierć itd.) dostają te same 5 kątów | ~330 obrazków (5 kątów zamiast 2, więc więcej niż w oryginalnej wersji planu) | rozszerzenie tej samej struktury | otwarte, niezależne od 1b |

Fazy 3-5 są **nadal opcjonalne i niezależne** — Faza 1b kończy się na samym
chodzie. Akcje bojowe (atak/trafienie/śmierć) zostają "zawsze do kamery" jak
dziś, chyba że po ocenie efektu 1b autor zdecyduje inaczej.

---

## 5. Co trzeba zmienić w kodzie

### 5.1 Bucket kierunku — z 3 na 5 kątów (`facing.gd`)

Podział pełnego koła na 8 wycinków po 45°, zwinięty do 5 nazw przez
odbicie lewo/prawo (dokładnie ta sama zasada co dziś dla "side" — tylko
teraz dotyczy też skosów):

```gdscript
static func _bucket(direction: Vector2) -> String:
	if direction.length() < 0.001:
		return "front"
	var angle_from_front := rad_to_deg(absf(direction.angle_to(Vector2.DOWN))) # 0..180
	if angle_from_front < 22.5:
		return "front"
	elif angle_from_front < 67.5:
		return "front_diagonal"
	elif angle_from_front < 112.5:
		return "side"
	elif angle_from_front < 157.5:
		return "back_diagonal"
	else:
		return "back"
```

`flip_h` (lewo/prawo) dotyczy teraz trzech bucketów zamiast jednego:
`side`, `front_diagonal`, `back_diagonal` (wszystko poza czystym
przód/tył) — flipowane, gdy `direction.x > 0.0`, dokładnie jak dziś.

**Kompatybilność wsteczna — łańcuch fallbacków.** Pozy, które NIE dostały
jeszcze wariantów 5-kątowych (czyli dziś wszystko poza chodem, a nawet chód
przed dowiezieniem nowej grafiki) nie mogą się wysypać, gdy zapytane o
`front_diagonal`/`back_diagonal`, których nie mają:

```gdscript
const BUCKET_FALLBACKS := {
	"front": ["front"],
	"front_diagonal": ["front_diagonal", "side", "front"],
	"side": ["side", "front"],
	"back_diagonal": ["back_diagonal", "side", "back", "front"],
	"back": ["back", "front"],
}
```

`resolve()` idzie po tej liście i bierze pierwszy klucz, jaki faktycznie
istnieje w słowniku danej pozy — dzięki temu stary słownik `{"front",
"back", "side"}` (albo nawet goła `Texture2D` bez żadnych wariantów) działa
bez zmian pod nowym 5-kątowym bucketem, po prostu z grubszym przybliżeniem
kąta, dopóki nie dowiezie się właściwej grafiki na dany kąt.

### 5.2 Cykl chodu — klatki zamiast jednej zamrożonej pozy

Każdy kąt chodu dostaje 2 klatki: `neutral` (to, co jest dziś) i `stride`
(nowa — środek kroku, ciężar przeniesiony na jedną nogę, druga wysunięta do
przodu). Struktura danych: zamiast `{"front": Texture2D}` →
`{"front": [Texture2D_neutral, Texture2D_stride]}` — tablica zamiast
pojedynczej tekstury, TYLKO dla pozy "chód"; wszystkie pozostałe pozy
zostają pojedynczymi `Texture2D` jak dziś.

`Facing.resolve()` dostaje trzeci, opcjonalny parametr `frame: int = 0`
(domyślnie 0 = zero zmian w istniejących wywołaniach bez cyklu):

```gdscript
static func resolve(tex_or_variants, direction: Vector2, frame: int = 0) -> Dictionary:
	if tex_or_variants is Dictionary:
		var key := _bucket(direction)
		var entry = _lookup_with_fallback(tex_or_variants, key)
		var tex: Texture2D = entry[frame % entry.size()] if entry is Array else entry
		var flips := key == "side" or key == "front_diagonal" or key == "back_diagonal"
		return {"texture": tex, "flip_h": flips and direction.x > 0.0}
	return {"texture": tex_or_variants, "flip_h": false}
```

**Tempo kroku zależne od prędkości** (to jest "realniejsza fizyka", o którą
prosił autor — szybszy ruch = szybsze stawianie kroków, jak w prawdziwym
biegu, nie tylko szybsze przesuwanie się w miejscu). Każda animowana postać
(gracz, `Incarnation`, `Boss`) dostaje mały, identyczny mechanizm:

```gdscript
@export var walk_cycle_speed: float = 6.0 ## pełnych cykli/s przy pełnej prędkości
var _walk_cycle_phase: float = 0.0

func _update_walk_cycle(delta: float, current_speed: float, reference_speed: float) -> void:
	var ratio := clamp(current_speed / reference_speed, 0.0, 1.0) if reference_speed > 0.0 else 0.0
	if ratio > 0.05:
		_walk_cycle_phase += delta * walk_cycle_speed * ratio
	# BRAK resetu fazy do zera po zatrzymaniu — postać "zamraża się" na
	# klatce, na której akurat stanęła, zamiast strzelać z powrotem do
	# neutralnej pozy w jednej klatce (mniej sztuczne wizualnie).

func _walk_cycle_frame() -> int:
	return int(_walk_cycle_phase) % 2
```

Gracz woła to z `current_speed = velocity.length()`, `reference_speed =
max_speed`. Wcielenia/Nemorax (stały `drift_speed`, bez rozpędzania) wołają
z `current_speed` = 0 podczas telegrafu/wypadu/etc. i `drift_speed` w
trakcie zwykłego dryfowania — czyli cyklują tylko wtedy, gdy faktycznie
idą, zamrożone w pozostałych stanach (tak jak dziś zamrożone są w ogóle).

### 5.3 Źródło kierunku per postać — bez zmian względem Fazy 1

- Gracz: `velocity` dla chodu/dashu.
- Wcielenia i Nemorax: wektor "do gracza", już liczony w
  `_drift_towards_player`/zapisany w `_facing_direction`.

---

## 6. Szablon promptu do generowania nowych ujęć

### 6.1 Nowy kąt widoku (front-skos / tył-skos) — ta sama zasada co tył/bok

> Using the attached image as the exact reference for [NAZWA]'s design — same
> proportions, same colors, same materials, same markings, same accent glow
> color — regenerate this EXACT same creature in the EXACT same pose and
> action (mid-stride walking pose, neutral standing weight), but seen from
> [FRONT-DIAGONAL VIEW: a three-quarter view, angled 45 degrees between the
> front view and the side profile, still facing generally toward the camera
> but turned to one side / BACK-DIAGONAL VIEW: a three-quarter view, angled
> 45 degrees between the back view and the side profile, still facing
> generally away from the camera but turned to one side]. Keep the identical
> art style, lighting proportions and color palette as the reference — invent
> any details not visible in the reference (back of armor, wings, tail) in a
> way consistent with the rest of the design. Transparent background, no
> text, single character, no other changes to the design.

### 6.2 Nowa klatka cyklu chodu (ta sama poza+kąt, inna faza kroku)

> Using the attached image as the exact reference for [NAZWA]'s design AND
> exact camera angle — same proportions, same colors, same materials, same
> viewing angle as the reference — regenerate this EXACT same creature from
> the EXACT same camera angle, but in a mid-stride WALKING pose instead of
> the reference's pose: weight shifted onto one leg, that leg planted and
> bent, the other leg lifted and extended forward mid-step, a natural
> walking motion, arms swinging slightly in opposition if the design has
> visible arms. Keep the identical art style, lighting, viewing angle and
> color palette as the reference — no other changes to the design.
> Transparent background, no text, single character.

Jedna generacja = jedna zmienna na raz (albo kąt, albo klatka kroku, nigdy
oba naraz) — dokładnie ta sama zasada co przy pozach w `POZY_ANIMACJI.md`.

---

## 7. Status

**Faza 0 i 1 — ZROBIONE (2026-09-20)**, zastąpione przez Fazę 1b poniżej.

- [ ] **Faza 1b — w trakcie.** Lista dokładnych plików do wygenerowania: sekcja 8.
- [ ] Po dowiezieniu grafiki: rozszerzyć `facing.gd` (sekcja 5.1-5.2),
      dodać `_walk_cycle_phase`/`_update_walk_cycle`/`_walk_cycle_frame` do
      `player.gd`, `entities/incarnation.gd`, `entities/boss.gd`.
- [ ] Realny playtest Fazy 1b → decyzja czy iść dalej w Fazy 3-5 (pozostałe
      pozy, patrz sekcja 4).

---

## 8. Faza 1b — pełna lista obrazków do wygenerowania (91 sztuk)

13 "chodzących" ciał (gracz + 6 wcieleń + 6 faz bazowych Nemoraksa) × 7
nowych obrazków każde = 91. Dla KAŻDEGO ciała:

- **2 zupełnie nowe kąty** (front-skos, tył-skos) × **2 klatki** (neutralna +
  krok) = 4 nowe obrazki. Referencja do kąta: dzisiejszy plik `_front`
  (albo baza fazowa dla Nemoraksa). Referencja do klatki kroku w NOWYM
  kącie: obrazek tego samego kąta dopiero co wygenerowany (neutralna →
  krok), nie stary front.
- **1 nowa klatka kroku** dla KAŻDEGO z 3 już istniejących kątów
  (front/tył/bok) = 3 nowe obrazki. Referencja: dzisiejszy plik tego kąta
  (on sam staje się klatką "neutralną").

Razem 4 + 3 = **7 nowych obrazków na ciało**.

### 8.1 Gracz

| Kąt | Klatka | Referencja | Prompt |
|---|---|---|---|
| front | stride (NOWA) | `player_walk.png` | szablon 6.2 |
| front_diagonal | neutral (NOWA) | `player_base.png` (front, idle) | szablon 6.1 |
| front_diagonal | stride (NOWA) | front_diagonal/neutral dopiero wygenerowany | szablon 6.2 |
| side | stride (NOWA) | `player_walk_side.png` | szablon 6.2 |
| back_diagonal | neutral (NOWA) | `player_base.png` | szablon 6.1 (back-diagonal) |
| back_diagonal | stride (NOWA) | back_diagonal/neutral dopiero wygenerowany | szablon 6.2 |
| back | stride (NOWA) | `player_walk_back.png` | szablon 6.2 |

### 8.2 Sześć wcieleń — ta sama tabela × 6 postaci (Vhar'Nokh, Mordrath, Zha'Ruun, Nekravor, Thal'Gor, Orryx)

Dla każdej: referencje to `<nazwa>_walk.png` / `<nazwa>_walk_back.png` /
`<nazwa>_walk_side.png` (już istnieją z Fazy 1) — te same 7 wierszy co
tabela 8.1, podmieniając plik referencyjny na wariant danej postaci.

### 8.3 Sześć faz Nemoraksa — ta sama tabela × 6 faz

Referencje: `nemorax_phase-N_base.png` / `_back.png` / `_side.png` (N=1..6,
już istnieją z Fazy 1) — te same 7 wierszy, plik referencyjny to baza danej
fazy (Nemorax nie ma osobnej "walk", baza fazowa PEŁNI tę rolę — to jego
pozycja dryfowania).

### 8.4 Razem

13 ciał × 7 obrazków = **91 obrazków**. Generować partiami po jednym ciele,
testować headless po każdej partii (jak dotąd), nie na raz.
