# NEMORAX — Sześć Wcieleń: katalog assetów do wygenerowania

Ten plik to katalog gotowych opisów/promptów dla bota generującego grafikę.
Każda pozycja jest osobna, skopiuj-wklej. To PROPOZYCJA — nazwy, wygląd i motywy
są do zmiany, popraw co chcesz zanim zaczniesz generować.

Status: propozycja robocza, jeszcze nie zaakceptowana.

---

## 0. Przewodnik stylu (dokleić do KAŻDEGO promptu poniżej)

Żeby wszystko trzymało się jednej estetyki mimo generowania osobno, każdy prompt
kończ tym samym dopiskiem:

> Dark fantasy 2D game character concept art, painterly digital illustration,
> dramatic rim lighting, clean readable silhouette for game sprite use, plain
> near-black background (#1A1026), no text, no watermark, front-facing or 3/4
> view idle pose, single dominant neon accent color glowing against darkness.

Paleta gry (dla spójności kolorów w promptach):
- Tło poza areną: `#1A1026`
- Podłoga areny: `#2A1B3D`
- Ściany areny: `#3E2A57`
- Gracz (cyjan): `#5BE0C8`
- Zagrożenie/obrażenia (żółty): `#FFC857`
- Błysk trafienia: `#FFFFFF`

## 1. Techniczne (specyfikacja pod Godota — do doprecyzowania przy imporcie)

- Format: PNG, przezroczyste tło (poza tłem sceny generowanej dla klimatu — do
  wycięcia/usunięcia tła przed importem).
- Boss/wcielenie: sugerowana wysokość sprite'a ok. 200-300px (skalowalne w Godocie).
- Gracz: sugerowana wysokość ok. 64-96px.
- Stany animacji do przewidzenia na istotę: `idle`, `telegraph` (zapowiedź ataku),
  `attack`, `hit` (błysk trafienia), `death`. Można zacząć od samego `idle`
  (pojedyncza klatka) i dokładać resztę później — silnik już wspiera migotanie/
  błysk trafienia kodem, więc `hit` nie jest priorytetem.
- Foldery docelowe: `assets/sprites/wcielenia/<nazwa>/`, `assets/sprites/gracz/`,
  `assets/sprites/nemorax/`, `assets/sprites/pokoje/`.

---

## 2. Sześć wcieleń

Każde wcielenie to dosłownie uosobienie jednej reguły/fazy Nemoraxa — nazwa
wcielenia = nazwa fazy. Sygnaturalna umiejętność to ta sama reguła, tylko jako
aktywny, jednorazowy atak zamiast biernego modyfikatora.

### 2.1 ZALĄŻEK (nawiązanie do fazy "bez formy" — `#F0447A`)

- **Koncept**: surowa, niedokończona esencja hybrydy — to, czym Nemorax był,
  zanim rozdzielił się na sześć aspektów. Pierwsze, najprostsze pozornie wcielenie.
- **Umiejętność sygnaturalna (propozycja)**: "Niedokończony cios" — krótkie,
  nieprzewidywalne teleportujące szarpnięcie w stronę gracza (bez reguły fazowej
  do nawiązania, więc czysto ruchowa, chaotyczna umiejętność pasująca do "braku
  formy").
- **Prompt**:
  > A translucent, half-formed humanoid creature made of swirling magenta-pink
  > mist (#F0447A) and cracked black obsidian shards, asymmetric unfinished face
  > with only one eye fully formed, wisps trailing behind it like incomplete
  > limbs still growing, looks like raw unshaped potential given fragile,
  > unstable form.
  > [+ przewodnik stylu z sekcji 0]
- **Pokój (propozycja)**: surowa, nieukończona architektura — ściany jakby wciąż
  w budowie, fragmenty geometrii wiszące w powietrzu, mgła.
- **Fragment duszy**: nieforemna, pulsująca kropla światła w kolorze `#F0447A`.

### 2.2 CISZA (`#FF8A3D`)

- **Koncept**: pożera dźwięk, nie ma ust, wszystko wokół niej milknie.
- **Umiejętność sygnaturalna**: aktywne, chwilowe wyciszenie/ogłuszenie gracza —
  krótkie okno, w którym telegrafy innych zagrożeń są trudniejsze do zauważenia
  (np. przygaszone wizualnie), zamiast biernego wyciszenia dźwięku na całą walkę.
- **Prompt**:
  > A tall, slender humanoid figure wrapped in dark bandaged cloth, no mouth,
  > ears sealed shut with fused skin, a vertical glowing seam of orange-gold
  > light (#FF8A3D) running down its throat and chest, faint visual distortion
  > around it suggesting it is inhaling all nearby sound.
  > [+ przewodnik stylu z sekcji 0]
- **Pokój**: wyciszona, jakby wyściełana komnata — grube, tłumiące fałdy
  materiału/kamienia na ścianach, brak echa.
- **Fragment duszy**: mały, owinięty bandażem kokon, przez szczeliny sączy się
  pomarańczowe światło.

### 2.3 ZWŁOKA (`#C44FD6`)

- **Koncept**: czas wokół niej się zacina, ciągnie za sobą własne opóźnione echa.
- **Umiejętność sygnaturalna**: aktywnie spowalnia gracza na chwilę (zamiast
  biernie podwajać cooldown dasha) — np. pole spowolnienia wokół istoty.
- **Prompt**:
  > A humanoid figure trailing 2-3 flickering translucent afterimages of itself
  > slightly offset in time, purple-magenta glow (#C44FD6), joints fused with
  > cracked hourglass and broken clock-gear fragments, floating shattered clock
  > shards orbiting slowly around it.
  > [+ przewodnik stylu z sekcji 0]
- **Pokój**: ruiny z rozbitymi zegarami/klepsydrami wmurowanymi w ściany,
  wrażenie zapętlonego czasu.
- **Fragment duszy**: mały odłamek szkła zegarowego, w środku widać zapętloną,
  powtarzającą się iskrę światła.

### 2.4 CIĘŻAR (`#6C63FF`)

- **Koncept**: nieznośnie gęsta, zakrzywia przestrzeń wokół siebie.
- **Umiejętność sygnaturalna**: aktywny impuls przyciągający gracza gwałtownie
  bliżej (zamiast stałego, biernego przyciągania przez całą fazę).
- **Prompt**:
  > A hunched, extremely dense-looking humanoid creature made of dark crystalline
  > mass, deep blue-violet glow (#6C63FF) radiating from cracks in its body,
  > warped-space visual distortion bending the air around it, a small
  > black-hole-like void embedded in its chest pulling in faint light and dust.
  > [+ przewodnik stylu z sekcji 0]
- **Pokój**: przygniecione, zapadnięte sklepienie, kolumny wygięte do środka
  jakby przyciągane do centrum.
- **Fragment duszy**: mały, bardzo "ciężki" wyglądający kamień, wokół niego
  unoszący się pył wciągany do środka.

### 2.5 GŁÓD (`#7ED957`)

- **Koncept**: wiecznie głodna, pokryta ustami, żeruje na wszystkim w zasięgu.
- **Umiejętność sygnaturalna**: aktywny "kęs" — wypad z ugryzieniem zadającym
  obrażenia i leczącym istotę (zamiast biernej regeneracji po 3s bez trafienia).
- **Prompt**:
  > A gaunt, skeletal humanoid creature with visible ribs, covered in small
  > extra mouths with sharp teeth across its arms and torso, sickly green glow
  > (#7ED957) leaking from its wounds, long thin reaching tendril-like limbs,
  > always leaning forward as if starving.
  > [+ przewodnik stylu z sekcji 0]
- **Pokój**: organiczne, mięsiste ściany przypominające wnętrze przełyku,
  drobne otwory/usta w murach.
- **Fragment duszy**: mały, pulsujący jak serce fragment, otoczony drobnymi
  zębami.

### 2.6 ZAĆMIENIE (`#C9C2B4`)

- **Koncept**: pochłania światło, dosłowna ciemność w ludzkiej-ish postaci.
- **Umiejętność sygnaturalna**: aktywnie zaciemnia całe pole widzenia gracza
  na chwilę poza małym kręgiem wokół niej (zamiast stałego zawężenia przez
  całą fazę).
- **Prompt**:
  > A humanoid figure whose head is a perfect black disk rimmed with a thin pale
  > corona of light (#C9C2B4), like a total solar eclipse, body dissolving into
  > soft drifting shadow below the waist instead of legs, faint halo light
  > flickering around the disk.
  > [+ przewodnik stylu z sekcji 0]
- **Pokój**: całkowicie ciemna komnata, jedyne źródło światła to sama istota
  (krąg poświaty wokół niej, reszta czarna).
- **Fragment duszy**: mały czarny dysk z cienką jasną obwódką, jak miniaturowe
  zaćmienie.

---

## 3. Pokój 7 — Ołtarz

- **Koncept**: okrągła komnata z sześcioma gniazdami/wnękami na fragmenty
  duszy, ułożonymi w krąg wokół centralnego cokołu.
- **Prompt**:
  > A circular ancient altar chamber, six empty glowing sockets arranged in a
  > ring around a central pedestal, each socket faintly colored to match a
  > different soul fragment (#F0447A, #FF8A3D, #C44FD6, #6C63FF, #7ED957,
  > #C9C2B4), dark stone architecture, converging beams of light aiming at the
  > center from all six sockets.
  > [+ przewodnik stylu z sekcji 0]
- **Rytuał (propozycja)**: gracz wrzuca 6 fragmentów w gniazda, światła się
  łączą w centrum, z podłogi/cokołu wyłania się Nemorax.

## 4. Nemorax — finałowa hybryda

- **Koncept**: chaotyczna, asymetryczna sylwetka łącząca fragmenty wszystkich
  sześciu wcieleń — największa i najbardziej niepokojąca forma w grze, kolor
  przechodzący cyklicznie przez wszystkie sześć barw faz.
- **Prompt**:
  > A massive chaotic hybrid creature stitched together from six different
  > monstrous aspects: one arm dissolving into pink-magenta mist, a sealed
  > mouthless face with a glowing orange throat-seam, a trail of flickering
  > purple afterimages, a dense blue-violet crystalline shoulder with a small
  > void at its core, a torso covered in small hungry green-glowing mouths, and
  > a head partly eclipsed by a black disk rimmed in pale light — all fused
  > into one towering, asymmetric, unstable body, color shifting between all
  > six hues.
  > [+ przewodnik stylu z sekcji 0]

## 5. Gracz i ekwipunek

### 5.1 Postać gracza
- **Koncept**: zwinny, drobny w porównaniu do bossów, cyjanowy akcent (jedyna
  cyjanowa postać w grze — zasada z dokumentu bazowego).
- **Prompt**:
  > A small, agile hooded adventurer, dark cloak, glowing cyan (#5BE0C8) eyes
  > and cyan energy veins faintly visible under the skin/cloth, lean silhouette,
  > built for speed and dodging rather than brute strength.
  > [+ przewodnik stylu z sekcji 0]

### 5.2 Miecz
- **Prompt**:
  > A simple, elegant short sword with a thin glowing cyan (#5BE0C8) edge,
  > minimalist hilt, no ornate decoration, clean silhouette readable mid-swing.
  > [+ przewodnik stylu z sekcji 0]

### 5.3 Różdżka i pocisk
- **Prompt**:
  > A slender dark wand with a small floating glowing yellow (#FFC857) crystal
  > orb at its tip, the orb matching the color of the projectile it fires,
  > minimalist design.
  > [+ przewodnik stylu z sekcji 0]

---

## 6. Otwarte pytania do Ciebie

1. Nazwy wcieleń — zostawiamy jak w sekcji 2 (nazwane wprost jak fazy), czy
   chcesz bardziej "własne" imiona?
2. Umiejętności sygnaturalne — pasują opisane propozycje, czy wolisz inne?
3. Kolejność pokoi 1-6 — dowolna czy chcesz konkretną progresję trudności/motywu?
4. Czy generujemy jednego bota naraz przez wszystkie 8 promptów (wcielenia + hybryda
   + gracz + broń), czy wolisz zacząć od jednego wcielenia jako próbki stylu?
