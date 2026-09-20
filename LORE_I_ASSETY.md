# NEMORAX — Sześć Wcieleń: katalog assetów do wygenerowania

Ten plik to katalog gotowych opisów/promptów dla bota generującego grafikę.
Każda pozycja jest osobna, skopiuj-wklej.

Status: **modele w pełni zaprojektowane** (sylwetka, element rozpoznawczy,
animacje, czytelność z góry) — gotowe do generowania.

---

## 0. Przewodnik stylu (dokleić do KAŻDEGO promptu poniżej)

> Dark fantasy 2D game creature concept art, painterly digital illustration,
> dramatic rim lighting, body horror, unsettling and dreadful, dark neutral
> materials (obsidian black, bone white, charcoal, dried blood), ONE glowing
> neon accent color applied only to a specific detail (a crack, veins, eyes, a
> weapon edge) — not the whole body, clean bold readable silhouette designed to
> be recognizable even as a small top-down icon, plain near-black background
> (#1A1026), no text, no watermark, 3/4 view idle pose.

Gra jest widziana z góry (kamera top-down, bez obrotu) — dlatego przy każdej
istocie jest osobna notatka "z góry", opisująca, co gracz ma rozpoznać patrząc
prosto w dół podczas walki, gdy detale twarzy są niewidoczne. To ważniejsze niż
detale przedniego widoku.

Paleta gry (kolor akcentu = kolor przypisany do wcielenia, patrz sekcja 2):
- Tło poza areną: `#1A1026`
- Podłoga areny: `#2A1B3D`
- Ściany areny: `#3E2A57`
- Gracz (cyjan): `#5BE0C8`
- Zagrożenie/obrażenia (żółty): `#FFC857`
- Błysk trafienia: `#FFFFFF`

## 1. Techniczne (specyfikacja pod Godota — do doprecyzowania przy imporcie)

- Format: PNG, przezroczyste tło.
- Boss/wcielenie: sugerowana wysokość sprite'a ok. 200-300px (skalowalne w Godocie).
- Gracz: sugerowana wysokość ok. 64-96px.
- Stany animacji: `idle`, `telegraph` (zapowiedź ataku), `attack`, `hit`
  (błysk trafienia — silnik już to robi kodem, niski priorytet), `death`.
  Każda istota ma niżej listę animacji specyficznych dla siebie (chód, ryk,
  ładowanie ataku itd.) — to megajszy priorytet niż uniwersalne stany.
- Foldery docelowe: `assets/sprites/wcielenia/<nazwa>/`, `assets/sprites/gracz/`,
  `assets/sprites/nemorax/`, `assets/sprites/pokoje/`.
- W kodzie nazwy plików/klas zostały po najstarszych roboczych nazwach faz
  (`zalazek.gd`, `cisza_incarnation.gd` itd.) — to tylko wewnętrzne identyfikatory,
  niewidoczne w grze. Gracz widzi WYŁĄCZNIE właściwe imiona poniżej.

---

## 2. Sześć wcieleń

Kolejność pokoi 1-6 = kolejność poniżej.

### 2.1 VHAR’NOKH, WYGNANY Z OTCHŁANI (`#F0447A`)

**Sylwetka**: ogromny, ciężki humanoid. Z góry przypomina czarną bestię o
szerokich barkach i wielkich rogach.

**Model**:
- 2,5–3 m wysokości, bardzo szerokie barki, krótka gruba szyja
- głowa pochylona do przodu, dwa wielkie rogi zakrzywione do tyłu
- cztery palce zakończone pazurami, bardzo długie przedramiona
- nogi grube, jak u demona; plecy pokryte dużymi płytami pancerza
- pionowa szczelina na klatce piersiowej, z której wydobywa się czarna mgła

**Element rozpoznawczy**: rogi — nawet jako mała ikona gracz ma je rozpoznać od razu.

**Animacje**: ciężkie chodzenie, pochylanie się w ruchu, uderzenia pięściami,
ryk, krótkie "ładowanie" przed potężnym ciosem.

**Prompt**:
> A massive 2.5-3m tall demonic beast-humanoid, extremely wide shoulders,
> thick short neck, head hunched forward, two huge backward-curving horns,
> four clawed fingers, very long forearms, thick demon-like legs, back covered
> in large armor plates, a vertical crack running down its chest leaking black
> mist that glows faint magenta-pink (#F0447A) from within. Silhouette must
> read instantly from directly above as a wide-shouldered black beast with
> two prominent curved horns.
> [+ przewodnik stylu z sekcji 0]

**Pokój**: surowa, nieukończona architektura — ściany jakby wciąż w budowie,
fragmenty geometrii wiszące w powietrzu, mgła. **Fragment duszy**: nieforemna,
pulsująca kropla światła w kolorze `#F0447A`.

### 2.2 MORDRATH BEZ-WYMIARU (`#9B4DFF` — poprawione po dostarczonej grafice, było `#FF8A3D`)

**Sylwetka**: przeciwieństwo Vhar'Nokha — wysoki, chudy, nienaturalnie rozciągnięty.

**Model**:
- ok. 3 m wysokości, bardzo cienki tors
- ogromnie długie ręce, dłonie prawie dotykają ziemi, sześć palców
- głowa pozbawiona twarzy — tylko jedno ogromne oko na środku
- plecy lekko wygięte, cienkie nogi zakończone trzema pazurami
- ciało to NIE mięso — czarna materia owinięta wokół kości

**Efekt charakterystyczny**: podczas chodzenia kończyny zostawiają za sobą
krótkie glitche przestrzeni — kilka półprzezroczystych efektów cząsteczkowych
wystarczy, nie trzeba komplikować.

**Element rozpoznawczy**: jedno wielkie oko + absurdalnie długie ręce.

**Prompt**:
> An unnaturally tall (~3m), impossibly thin humanoid, faceless head with one
> single enormous eye in the center, extremely long arms with six-fingered
> hands nearly touching the ground, a slightly hunched spine, thin legs ending
> in three claws. Its body is not flesh but black warped matter wrapped around
> a skeleton, faintly glowing violet (#9B4DFF) from within cracks. Leaves
> faint translucent space-glitch particle trails behind its limbs when moving.
> [+ przewodnik stylu z sekcji 0]

**Pokój**: wyciszona, jakby wyściełana komnata — grube, tłumiące fałdy
materiału/kamienia na ścianach, brak echa. **Fragment duszy**: mały, owinięty
bandażem kokon, przez szczeliny sączy się pomarańczowe światło.

### 2.3 ZHA’RUUN, POŻERACZ GRANIC (`#C44FD6`)

**Sylwetka**: najbardziej zwierzęcy z szóstki — czworonożna bestia, nie humanoid.

**Model**:
- ogromna przednia część ciała, małe tylne nogi
- bardzo długa szyja, wydłużona czaszka, ogromna szczęka
- sześć oczu ustawionych po bokach głowy, ogon zakończony kolcem
- paszcza normalnie wygląda jak zwykła szczęka, ale podczas ataku otwiera się
  znacznie szerzej, niż pozwalałaby anatomia (osobny animowany element)

**Element rozpoznawczy**: ogromna paszcza — z góry wygląda jak czarna dziura
w głowie potwora.

**Prompt**:
> A quadrupedal beast with a massive muscular front half and small hind legs,
> an extremely long neck, an elongated skull, six eyes arranged along the
> sides of its head, a spiked tail. Its enormous jaw is the defining feature —
> normally closed, but able to unhinge and stretch open far beyond natural
> anatomy when attacking, glowing purple-magenta (#C44FD6) inside the throat.
> From directly above, the wide-open jaw should read as a stark black void in
> the center of its head.
> [+ przewodnik stylu z sekcji 0]

**Pokój**: ruiny z rozbitymi zegarami/klepsydrami wmurowanymi w ściany,
wrażenie zapętlonego czasu. **Fragment duszy**: mały odłamek szkła zegarowego
z zapętloną, powtarzającą się iskrą światła w środku.

### 2.4 NEKRAVOR, TEN KTÓREGO ODRZUCONO (`#6C63FF`)

**Sylwetka**: najbardziej "rycerski" z szóstki.

**Model**:
- ok. 2,7 m, szeroki tors, ciężkie barki, kościany pancerz
- dłonie zakończone pazurami, głowa przypominająca czaszkę, brak oczu — tylko
  dwa małe czerwone punkty w oczodołach
- na środku klatki piersiowej drugie serce: czarna dziura + pulsujące
  czerwone serce (nie musi być skomplikowane)

**Broń**: ogromny kościany miecz — nie realistyczne ostrze, tylko wielka kość
przypominająca kształtem miecz.

**Element rozpoznawczy**: kościany miecz + serce w klatce piersiowej.

**Prompt**:
> A large (~2.7m) knight-like armored humanoid, wide torso, heavy shoulders,
> bone-plate armor, clawed hands, a skull-like face with no eyes save two tiny
> red points glowing in the sockets. A second heart is visible through a black
> hollow in its chest, pulsing red. It wields an oversized crude sword carved
> from a single massive bone rather than a forged blade, faintly glowing
> blue-violet (#6C63FF) along its edge.
> [+ przewodnik stylu z sekcji 0]

**Pokój**: przygniecione, zapadnięte sklepienie, kolumny wygięte do środka
jakby przyciągane do centrum. **Fragment duszy**: mały, bardzo "ciężki"
wyglądający kamień, wokół niego unoszący się pył wciągany do środka.

### 2.5 THAL’GOR, PĘKNIĘTY POMIĘDZY ŚWIATAMI (`#E8524A` — poprawione po dostarczonej grafice, było `#7ED957`)

**Sylwetka**: najbardziej dynamiczny z szóstki — smukły humanoid z ogromnymi
skrzydłami.

**Model**:
- 2,5 m wysokości, bardzo wąska talia, długie ręce i nogi, mała głowa
- cztery skrzydła, każde INNE: 1) kościane, 2) błoniaste, 3) z czarnej
  energii, 4) wyglądające jak kawałek kosmosu

**Efekt**: skrzydła "klatkują" podczas animacji — nie poruszają się płynnie,
model co kilka klatek zmienia pozycję skrzydeł, jakby się zacinał.

**Element rozpoznawczy**: cztery różne skrzydła — z góry wyglądają jak ogromny,
czteroramienny krzyż.

**Prompt**:
> A slender (~2.5m) humanoid with an extremely narrow waist, long arms and
> legs, a small head, and four wings that are each completely different: one
> made of bone, one membranous like a bat's, one made of solidified black
> energy, one that looks like a fragment of starry cosmos. Faint dark red
> (#E8524A) glowing veins run along its narrow torso. From directly above, the
> four spread wings should read as a large four-armed cross shape.
> [+ przewodnik stylu z sekcji 0]

**Pokój**: organiczne, mięsiste ściany przypominające wnętrze przełyku, drobne
otwory/usta w murach. **Fragment duszy**: mały, pulsujący jak serce fragment,
otoczony drobnymi zębami.

### 2.6 ORRYX, CIEŃ-NICOŚCI (`#8C9AC2` — poprawione po dostarczonej grafice, było `#C9C2B4`)

**Sylwetka**: najbardziej nietypowy z całej szóstki — bez normalnych nóg.

**Model**:
- unosząca się masa czarnego cienia, w środku niewielkie ciało humanoidalne
- ok. 8 długich kończyn wyrastających z masy, każda inna: korzeń, macka,
  kość, cień — wszystkie dotykają ziemi
- głowa mała, prawie całkowicie ukryta, tylko dwa białe punkty jako oczy

**Efekt najważniejszy**: Orryx ma własny cień poruszający się NIEZALEŻNIE od
niego — prosty, osobny płaski mesh/sprite pod modelem, poruszający się z
lekkim opóźnieniem/własną trajektorią.

**Element rozpoznawczy**: osiem kończyn + niezależny cień.

**Prompt**:
> A hovering mass of black shadow with a small humanoid body barely visible at
> its core, from which roughly eight long limbs extend and touch the ground —
> each limb looking different, like a root, a tentacle, a bone, or pure
> shadow. A tiny, almost fully hidden head shows only two small white dots as
> eyes. Faintly rimmed in cool blue-gray (#8C9AC2) light.
> [+ przewodnik stylu z sekcji 0]

**Pokój**: całkowicie ciemna komnata, jedyne źródło światła to sama istota
(krąg poświaty wokół niej, reszta czarna). **Fragment duszy**: mały czarny
dysk z cienką jasną obwódką, jak miniaturowe zaćmienie.

---

## 3. Pokój 7 — Ołtarz

- **Koncept**: okrągła komnata z sześcioma gniazdami/wnękami na fragmenty
  duszy, ułożonymi w krąg wokół centralnego cokołu.
- **Prompt**:
  > A circular ancient altar chamber, six empty glowing sockets arranged in a
  > ring around a central pedestal, each socket faintly colored to match a
  > different soul fragment (#F0447A, #9B4DFF, #C44FD6, #6C63FF, #E8524A,
  > #8C9AC2), dark stone architecture, converging beams of light aiming at the
  > center from all six sockets.
  > [+ przewodnik stylu z sekcji 0]
- **Rytuał**: gracz wrzuca 6 fragmentów w gniazda, światła się łączą w
  centrum, z podłogi/cokołu wyłania się Nemorax.

## 4. NEMORAX — model końcowy

Świadomie zbudowana hybryda, NIE bezkształtna sklejka sześciu modeli.

**Sylwetka**: ok. 8–9 metrów wysokości.
- Środek: ciężki tors Vhar’Nokha
- Lewa strona: ramię Mordratha — długie i nienaturalne
- Prawa strona: ramię Nekravora — opancerzone, zakończone pazurami
- Przód: głowa Zha’Ruuna z ogromną szczęką
- Plecy: cztery skrzydła Thal’Gora
- Dół: osiem kończyn Orryxa
- Całe ciało popękane przestrzennie energią Mordratha

**Głowa** — najważniejszy element: zamiast jednej twarzy, sześć małych twarzy,
po jednej na istotę (nie muszą być szczegółowe, wystarczy rozpoznawalny
kształt): 👁️ oko, 💀 czaszka, 🦷 paszcza, 🕳️ czarna twarz, 😈 demoniczna twarz,
🌌 twarz jak fragment kosmosu.

**Ataki per część** (na przyszłość — gdy dojdzie animacja, każdy atak bossa w
kodzie może wizualnie "pochodzić" z odpowiedniej części ciała, żeby gracz z
kamery top-down rozpoznawał, co zaraz uderzy, po samej sylwetce):
- Vhar’Nokh → potężne uderzenie w ziemię
- Mordrath → teleportacja / znikanie
- Zha’Ruun → szarża i pożeranie
- Nekravor → atak kościanym ostrzem
- Thal’Gor → atak skrzydłami / fala energii
- Orryx → macki wychodzące z ziemi

**Prompt**:
> A towering 8-9m chaotic hybrid creature, deliberately assembled rather than
> a shapeless blob: a heavy horned torso at the center, an unnaturally long
> thin arm on the left, an armored clawed arm on the right, an elongated
> jawed beast head at the front, four completely different mismatched wings
> spreading from the back, eight shadow-root-tentacle limbs beneath. The
> whole body is visibly cracked with rifts of dark dimensional energy leaking
> orange light. Instead of one face, the head shows six small distinct faces
> side by side: one eye, one skull, one gaping jaw, one featureless black
> face, one demonic face, one face like a fragment of starry cosmos. Color
> cycling between magenta-pink, orange, purple, blue-violet, green and pale
> gray glows across the different body parts.
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
