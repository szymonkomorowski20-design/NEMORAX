# NEMORAX — Sześć Wcieleń: katalog assetów do wygenerowania

Ten plik to katalog gotowych opisów/promptów dla bota generującego grafikę.
Każda pozycja jest osobna, skopiuj-wklej.

Status: **nazwy i kolejność pokoi zatwierdzone** — reszta (dokładny wygląd) wciąż
do poprawek, jeśli coś nie pasuje po zobaczeniu pierwszych generacji.

---

## 0. Przewodnik stylu (dokleić do KAŻDEGO promptu poniżej)

Żeby wszystko trzymało się jednej estetyki mimo generowania osobno, każdy prompt
kończ tym samym dopiskiem:

> Dark fantasy 2D game character concept art, painterly digital illustration,
> dramatic rim lighting, body horror, unsettling and dreadful, clean readable
> silhouette for game sprite use, plain near-black background (#1A1026), no
> text, no watermark, front-facing or 3/4 view idle pose, single dominant neon
> accent color glowing against darkness.

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
- W kodzie nazwy plików/klas zostały po starszych roboczych nazwach faz
  (`zalazek.gd`, `cisza_incarnation.gd` itd.) — to tylko wewnętrzne identyfikatory,
  gracz widzi WYŁĄCZNIE nazwy własne z sekcji 2 poniżej (`fragment_name`).

---

## 2. Sześć wcieleń

Kolejność pokoi 1-6 = kolejność poniżej. Każde wcielenie ma trzy losowe
umiejętności (już zaimplementowane w kodzie), tu opisany jest tylko koncept
i wygląd.

### 2.1 ZARODNIK (`#F0447A`)

- **Koncept**: surowa, niedokończona esencja hybrydy, wciąż się kształtująca —
  embrion czegoś, co jeszcze nie zdecydowało, czym będzie.
- **Prompt**:
  > A fetal humanoid curled unnaturally in on itself, skin like wet raw
  > magenta-pink membrane (#F0447A) stretched taut over visibly shifting,
  > unfinished bones that look like they are still cracking and reforming, no
  > face — only a smooth blank indentation where one should be, thin
  > umbilical-like black obsidian tendrils trailing from its spine into empty
  > air, glistening wet texture.
  > [+ przewodnik stylu z sekcji 0]
- **Pokój**: surowa, nieukończona architektura — ściany jakby wciąż w budowie,
  fragmenty geometrii wiszące w powietrzu, mgła.
- **Fragment duszy**: nieforemna, pulsująca kropla światła w kolorze `#F0447A`.

### 2.2 KRZYKOŻERCA (`#FF8A3D`)

- **Koncept**: pożera krzyk i dźwięk — nie ma ust, a to, co połknęła, wciąż
  próbuje się wydostać spod skóry.
- **Prompt**:
  > A gaunt, unnaturally tall humanoid wrapped in wrappings that look like torn
  > vocal cords stretched into bandages, where a mouth should be there is only
  > smooth sealed skin with faint orange-gold veins (#FF8A3D) pulsing beneath
  > like trapped screams still glowing under the surface, ears fused shut with
  > thick scar tissue, the air around it visibly warping in total silence.
  > [+ przewodnik stylu z sekcji 0]
- **Pokój**: wyciszona, jakby wyściełana komnata — grube, tłumiące fałdy
  materiału/kamienia na ścianach, brak echa.
- **Fragment duszy**: mały, owinięty bandażem kokon, przez szczeliny sączy się
  pomarańczowe światło.

### 2.3 ROZKŁADNIK (`#C44FD6`)

- **Koncept**: zwłoki zamrożone w środku własnego rozkładu — czas wokół niego
  się zaciął, więc gnije w pętli, wlokąc za sobą urwane klatki własnego ruchu.
- **Prompt**:
  > A rotting corpse-like humanoid frozen mid-decay, skin sloughing off in
  > stiff frozen strips revealing purple-magenta light (#C44FD6) instead of
  > muscle underneath, dragging 2-3 stiff jerky afterimages of itself like a
  > broken film reel repeating the same dying motion, joints fused with rusted
  > cracked clock gears jutting through torn skin.
  > [+ przewodnik stylu z sekcji 0]
- **Pokój**: ruiny z rozbitymi zegarami/klepsydrami wmurowanymi w ściany,
  wrażenie zapętlonego czasu.
- **Fragment duszy**: mały odłamek szkła zegarowego, w środku widać zapętloną,
  powtarzającą się iskrę światła.

### 2.4 ZIEMIODŁAW (`#6C63FF`)

- **Koncept**: zapada się pod własnym ciężarem i zabiera ze sobą wszystko
  dookoła — w piersi ma pustkę, która po cichu połyka światło i pył.
- **Prompt**:
  > A massively hunched, impossibly dense humanoid, skin cracked like
  > drought-parched earth glowing deep blue-violet (#6C63FF) from within the
  > fissures, visibly sinking into the ground with each step under its own
  > weight, a small collapsing void embedded in its chest silently swallowing
  > dust and faint light, knuckles dragging, spine bent under crushing
  > invisible pressure.
  > [+ przewodnik stylu z sekcji 0]
- **Pokój**: przygniecione, zapadnięte sklepienie, kolumny wygięte do środka
  jakby przyciągane do centrum.
- **Fragment duszy**: mały, bardzo "ciężki" wyglądający kamień, wokół niego
  unoszący się pył wciągany do środka.

### 2.5 TRZEWIOŻER (`#7ED957`)

- **Koncept**: wiecznie głodny — dziesiątki drobnych, kłujących pysków
  otwierają się na całym jego ciele, żerując na wszystkim w zasięgu.
- **Prompt**:
  > An emaciated humanoid with ribs and spine grotesquely visible through
  > paper-thin skin, dozens of small lamprey-like mouths lined with needle
  > teeth opening and closing across its arms, torso and palms, sickly green
  > glow (#7ED957) leaking from raw wounds between the mouths, unnaturally long
  > arms ending in fingers that split open into more small feeding mouths.
  > [+ przewodnik stylu z sekcji 0]
- **Pokój**: organiczne, mięsiste ściany przypominające wnętrze przełyku,
  drobne otwory/usta w murach.
- **Fragment duszy**: mały, pulsujący jak serce fragment, otoczony drobnymi
  zębami.

### 2.6 ŚWIATŁOGASZ (`#C9C2B4`)

- **Koncept**: gasi światło wokół siebie — jego głowa to umierające zaćmienie,
  a ciało rozpływa się w gasnący popiół tam, gdzie powinny być nogi.
- **Prompt**:
  > A humanoid silhouette that is pure light-devouring black, its head a
  > perfect solar-eclipse disk rimmed by a thin dying corona of pale light
  > (#C9C2B4), its body unraveling into slow drifting cinder-like shadow below
  > the waist instead of legs, faint dying starlight flickering and being
  > snuffed out in a growing radius around it.
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
- **Rytuał**: gracz wrzuca 6 fragmentów w gniazda, światła się łączą w
  centrum, z podłogi/cokołu wyłania się Nemorax.

## 4. Nemorax — finałowa hybryda

- **Koncept**: chaotyczna, asymetryczna sylwetka łącząca cechy wszystkich
  sześciu wcieleń — Zarodnika, Krzykożercy, Rozkładnika, Ziemiodławia,
  Trzewiożera i Światłogasza naraz — największa i najbardziej niepokojąca
  forma w grze, kolor przechodzący cyklicznie przez wszystkie sześć barw.
- **Prompt**:
  > A massive chaotic hybrid creature stitched together from six different
  > monstrous aspects: one arm dissolving into raw pink-magenta fetal mist, a
  > sealed mouthless face with a glowing orange throat-seam hiding trapped
  > screams, a trail of flickering purple decaying afterimages, a dense
  > blue-violet crystalline shoulder collapsing into a small void, a torso
  > covered in small hungry green-glowing needle-toothed mouths, and a head
  > partly eclipsed by a black light-devouring disk rimmed in dying pale light
  > — all fused into one towering, asymmetric, unstable body, color shifting
  > between all six hues.
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
