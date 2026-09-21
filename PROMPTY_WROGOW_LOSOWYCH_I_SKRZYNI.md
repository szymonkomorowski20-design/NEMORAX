# NEMORAX — prompty: 12 archetypów wrogów, skrzynia, 8 wyglądów losowych pokoi

Zastępuje plan "drugiego bota" z `PLAN_LOSOWYCH_POKOI.md` sekcja 3 — te
grafiki idą teraz przez GPT. Format i styl dokładnie jak w
`LORE_I_ASSETY.md`/`PROMPTY_FINALNE_WSZYSTKO.md`, żeby wszystko trzymało
się jednej estetyki. Kopiuj-wklej każdy prompt osobno.

**Techniczne**: PNG, przezroczyste tło (poza sekcją C — tekstury pokoi,
tam jednolite/kafelkowalne, bez przezroczystości). Wrogowie: sugerowana
wysokość sprite'a 150-250px (mniejsi/skromniejsi niż 6 wcieleń — to
"zwykłe" zagrożenia, nie unikalni bossowie). Foldery docelowe:
`assets/sprites/random_enemies/<nazwa>/`, `assets/sprites/pokoje/tekstury/`,
`assets/sprites/pokoje/obiekty/`.

---

## 0. Przewodnik stylu — wrogowie losowi (dokleić do KAŻDEGO promptu w sekcji A)

> Dark fantasy 2D game creature concept art, painterly digital illustration,
> dramatic rim lighting, gaunt and feral, worn bone-grey and ash-black
> materials with cracked dry skin texture, ONE glowing neon accent color
> applied only to a specific detail (eyes, a wound, a weapon edge, joints) —
> not the whole body, clean bold readable silhouette designed to be
> recognizable even as a small top-down icon, plain near-black background
> (#1A1026), no text, no watermark, 3/4 view idle pose. Deliberately more
> feral and disposable-looking than a unique named boss — these are common
> lesser threats, not singular monsters.

Kamera jest top-down — przy każdym wrogu jest notatka "z góry", co gracz ma
rozpoznać patrząc prosto w dół. To ważniejsze niż detale przedniego widoku.

---

## A. Dwanaście archetypów (CLAUDE_CODE_GAME_CONTENT_BIBLE.md sekcja 6)

### A1. Chaser — koszt 5, podstawowy pościg
**Sylwetka**: mały, chudy, pochylony do przodu biegacz — najmniejszy z
całej dwunastki. **Z góry**: wąska, ostro pochylona sylwetka, wyraźnie
"biegnie na wprost".
> A small gaunt hunched creature built purely for running, unnaturally long
> thin legs bent forward mid-sprint, arms trailing back, small feral head
> low to the ground, sickly grey-green glowing eyes (#8FBF6B) as the only
> accent. [+ przewodnik stylu sekcja 0]

### A2. Striker — koszt 6, burst wręcz
**Sylwetka**: chudy duelista z jednym długim, ostrym pazurem/ostrzem u
przedramienia. **Z góry**: wydłużone jedno ramię z ostrzem wyraźnie dłuższe
niż drugie, łatwe do odróżnienia od Chasera.
> A lean duelist-like creature crouched in a ready stance, one forearm
> ending in a single long curved bone blade held back for a lunge, the
> other arm short and clawed for balance, glowing amber-orange (#E8933D)
> along the blade's edge only. [+ przewodnik stylu sekcja 0]

### A3. Shooter — koszt 7, presja dystansowa
**Sylwetka**: chudy, z wydętą, bulwiastą klatką piersiową jak organiczna
wyrzutnia. **Z góry**: okrągły, wybrzuszony tors odróżnia go od
smuklejszych wręcz-wrogów.
> A thin frail-limbed creature with a grotesquely swollen, bulbous
> translucent chest sac like an organic launcher, faint glowing spores
> visible pulsing inside it, small vestigial arms, glowing sickly yellow-
> green (#C9D96B) light inside the chest sac as the only accent.
> [+ przewodnik stylu sekcja 0]

### A4. Charger — koszt 8, zagrożenie liniowe
**Sylwetka**: niski środek ciężkości, szerokie plecy, opuszczona głowa z
rogiem. **Z góry**: szeroki, klinowaty kształt "grotu" — natychmiast
czytelny jako coś, co pcha się na wprost.
> A low, wide-shouldered brutish quadruped-like beast with its head lowered,
> a single thick curved horn on its forehead, short powerful legs coiled to
> charge, thick armored hide, glowing dull red (#C4453A) along the horn's
> tip only. [+ przewodnik stylu sekcja 0]

### A5. Orbiter — koszt 8, presja kątowa
**Sylwetka**: unosi się nad ziemią, wokół ciała krąży pierścień/odłamki.
**Z góry**: okrągła sylwetka z widocznym obracającym się pierścieniem —
jedyny wróg z tego zestawu, który wygląda na "krążący", nie biegnący.
> A small floating hunched creature hovering just above the ground, a ring
> of jagged broken bone shards orbiting slowly around its body like a
> makeshift halo, tucked vestigial legs, glowing cool teal (#4FA6A0) along
> the orbiting shards only. [+ przewodnik stylu sekcja 0]

### A6. Dasher — koszt 9, burst/przemieszczenie
**Sylwetka**: smukły, z widocznymi "śladami ruchu" wtopionymi w ciało
(rozmazane kończyny). **Z góry**: wyraźne motion-blur wplecione w samą
sylwetkę, jedyny wróg z wbudowanym efektem prędkości.
> A slender wiry creature whose limbs blur into afterimage-like streaks even
> at rest, as if permanently mid-dash, narrow predatory head, glowing
> electric violet (#9B6BF0) trailing off its blurred limb-tips only.
> [+ przewodnik stylu sekcja 0]

### A7. Ambusher — koszt 9, zagrożenie reakcyjne
**Sylwetka**: spłaszczona, przywarta do ziemi postawa, jakby stale się
czaiła. **Z góry**: bardzo niski, szeroki, "przyklejony do podłoża" kształt
— kontrastuje z pionowymi sylwetkami reszty.
> A flattened, low-crawling creature pressed close to the ground, long
> segmented limbs splayed wide for ambush, large light-sensitive pale eyes,
> mottled grey camouflage-like skin, glowing dim violet-grey (#8A7EA6) eyes
> as the only accent, feels like it belongs half-hidden in shadow.
> [+ przewodnik stylu sekcja 0]

### A8. Zoner — koszt 10, kontrola obszaru
**Sylwetka**: nienaturalnie wychudzony rytualista z wiszącymi, drgającymi
symbolami wokół dłoni. **Z góry**: szerokie, rozłożyste sylwetka od
unoszących się wokół rąk run — czytelnie "coś rzuca na ziemię".
> A gaunt ritualistic creature with unnaturally long thin arms held out to
> the sides, small jagged rune-fragments hovering and slowly rotating around
> each open hand, hollow sunken face, glowing sickly purple (#9B4F8C) on the
> hovering runes only. [+ przewodnik stylu sekcja 0]

### A9. Summoner — koszt 12, przywoływanie
**Sylwetka**: większy, garbaty, z otwartą raną/portalem na plecach, z
którego "wylewają się" mniejsze kształty. **Z góry**: wyraźnie największy
tors w grupie kosztowej 10-12, z widocznym otworem na plecach.
> A hunched heavyset creature with a gaping rift-like wound on its back from
> which faint smaller shapes seem to be forming and pulling free, dragging
> long arms, bowed head, glowing sickly magenta (#B23A6B) from within the
> back-wound only. [+ przewodnik stylu sekcja 0]

### A10. Support — koszt 12, wzmacniacz
**Sylwetka**: wysoki, chudy, z długim "przewodem"/mackowatym łącznikiem
zwisającym z dłoni, gotowym połączyć się z sojusznikiem. **Z góry**: cienka
sylwetka z wyraźnym, długim wężowatym wyrostkiem — jedyny wróg z
"linkującym się" elementem.
> A tall gaunt attendant-like creature, hollow-eyed and passive, a long
prehensile tendril-like appendage extending from its palm ending in an
open tether-node, otherwise still and non-aggressive posture, glowing soft
cyan-white (#8ED9C9) along the tendril only. [+ przewodnik stylu sekcja 0]

### A11. Tank — koszt 13, blokada/kotwica
**Sylwetka**: najszerszy i najniższy z całej dwunastki, pokryty grubym
pancerzem płytowym. **Z góry**: masywny, niemal kwadratowy zarys — od razu
czytelny jako "to zablokuje przejście".
> A massive, squat, heavily armored creature covered in overlapping thick
> stone-like plates, short thick limbs, no visible neck, small deep-set
> eyes barely visible under a plated brow, glowing dull orange (#B8622E) in
> the gaps between armor plates only. [+ przewodnik stylu sekcja 0]

### A12. Elite Modifier — aura, NIE osobne ciało
Dokument (sekcja 6.2) opisuje to jako pakiet dołączany do istniejącego
archetypu, nie nowe ciało — potrzebny jeden uniwersalny efekt nakładany w
silniku (modulate/dodatkowy sprite na wierzchu), pasujący do KAŻDEGO z 11
powyższych.
> A jagged crackling outline aura made of sharp angular energy shards
> tightly hugging a creature's silhouette, restless and unstable, glowing
> intense warning-yellow (#FFC857 — ten sam kolor co Zagrożenie w grze).
> Dark fantasy 2D game VFX / prop icon, glowing against near-black
> background (#1A1026), clean bold readable silhouette, single dominant
> neon accent color, no text, no watermark, no character, transparent
> background — MUSI być samodzielnym efektem bez ciała pod spodem, do
> nałożenia na dowolnego wroga w silniku.

---

## B. Skrzynia (sekcja 9 dokumentu) — 2 obrazki

### B1. Skrzynia zamknięta
> A small weathered wooden chest bound with corroded dark iron bands, faint
> warm gold-brown glow (#C9962C) seeping from the seam between lid and body
> as if something valuable pulses inside, ancient and slightly ajar-looking
> despite being shut. Dark fantasy 2D game VFX / prop icon, glowing against
> near-black background (#1A1026), clean bold readable silhouette, single
> dominant neon accent color, no text, no watermark, no character,
> transparent or plain background.

### B2. Skrzynia otwarta (moment odebrania ulepszenia)
> The same weathered iron-bound wooden chest, lid thrown open, a bright
> warm gold-brown (#C9962C) light erupting upward from inside like a small
> burst of energy, a few loose motes of light drifting up out of it. Dark
> fantasy 2D game VFX / prop icon, glowing against near-black background
> (#1A1026), clean bold readable silhouette, single dominant neon accent
> color, no text, no watermark, no character, transparent or plain
> background.

*(Podmiana w kodzie: `rooms/chest.gd` dziś rysuje prostokąt kodem —
`_draw()` do zastąpienia dwoma `Sprite2D` przełączanymi po `_opened`, tak
jak `rooms/soul.gd` już to robi jedną teksturą.)*

---

## C. Osiem wyglądów losowych pokoi (16 obrazków, `PLAN_LOSOWYCH_POKOI.md` sekcja 3.2)

Format: **seamless tileable, top-down, PNG, bez przezroczystości** — jak
sekcja D w `PROMPTY_FINALNE_WSZYSTKO.md`. Sprawdzić kafelkowanie po
wygenerowaniu (offset o połowę wymiaru, szukać widocznego szwu).

### C1. Zatopione katakumby — podłoga
> Seamless tileable top-down dungeon floor texture: ankle-deep dark
> stagnant water pooling between uneven flagstones, faint sickly green
> bioluminescent algae (#5A8F5A) glowing along the waterline cracks, slow
> ripples frozen in the texture. Viewed from directly above, no characters,
> no text, no watermark, moody and oppressive.

### C2. Zatopione katakumby — ściana
> Seamless tileable dungeon wall texture: damp moss-covered stone bricks
> streaked with mineral water stains, faint sickly green bioluminescent
> algae (#5A8F5A) growing in the deepest grooves, dripping condensation. No
> characters, no text, no watermark, moody and oppressive.

### C3. Zapadnięta biblioteka — podłoga
> Seamless tileable top-down dungeon floor texture: charred wooden
> floorboards littered with burnt scattered book pages and ash, faint
> embers glowing dull orange (#B8622E) in the deepest char marks. Viewed
> from directly above, no characters, no text, no watermark, moody and
> oppressive.

### C4. Zapadnięta biblioteka — ściana
> Seamless tileable dungeon wall texture: collapsed wooden bookshelves
> fused into the stone wall, charred spines and ash, faint dull orange
> (#B8622E) embers glowing between the wreckage. No characters, no text, no
> watermark, moody and oppressive.

### C5. Zamarznięta krypta — podłoga
> Seamless tileable top-down dungeon floor texture: thick frost-covered
> stone slabs with hairline ice cracks, faint pale blue glow (#7FB0C9)
> radiating from beneath the ice, small drifts of frost dust. Viewed from
> directly above, no characters, no text, no watermark, moody and
> oppressive.

### C6. Zamarznięta krypta — ściana
> Seamless tileable dungeon wall texture: thick jagged ice sheets fused
> over old stone brick, faint pale blue (#7FB0C9) light diffusing through
> the ice, small icicles hanging from cracks. No characters, no text, no
> watermark, moody and oppressive.

### C7. Zakrwawiona sala rytualna — podłoga
> Seamless tileable top-down dungeon floor texture: dark cracked stone
> slabs stained with old dried blood in radiating ritual patterns, faint
> dull red glow (#C4453A) pulsing along the deepest stains. Viewed from
> directly above, no characters, no text, no watermark, moody and
> oppressive.

### C8. Zakrwawiona sala rytualna — ściana
> Seamless tileable dungeon wall texture: rough stone carved with shallow
> ritual sigils stained dark with old blood, faint dull red (#C4453A) glow
> emanating from the carved grooves. No characters, no text, no watermark,
> moody and oppressive.

### C9. Zarośnięte ruiny — podłoga
> Seamless tileable top-down dungeon floor texture: cracked stone
> flagstones overtaken by thick dark vines and small pale fungal growths,
> faint glowing spores (#8FBF6B) scattered across the vines. Viewed from
> directly above, no characters, no text, no watermark, moody and
> oppressive.

### C10. Zarośnięte ruiny — ściana
> Seamless tileable dungeon wall texture: crumbling stone wall consumed by
> thick dark vines and pale fungal growths, faint glowing spores (#8FBF6B)
> clustered in the deepest cracks. No characters, no text, no watermark,
> moody and oppressive.

### C11. Popielne pobojowisko — podłoga
> Seamless tileable top-down dungeon floor texture: scorched cracked earth
> and ash-grey stone slabs littered with fine drifting ash, faint dying
> embers glowing dull amber (#E8933D) in the deepest cracks. Viewed from
> directly above, no characters, no text, no watermark, moody and
> oppressive.

### C12. Popielne pobojowisko — ściana
> Seamless tileable dungeon wall texture: blackened scorched stone with
> deep heat-cracks, fine ash clinging to every ledge, faint dying embers
> glowing dull amber (#E8933D) in the deepest fissures. No characters, no
> text, no watermark, moody and oppressive.

### C13. Kryształowa jaskinia — podłoga
> Seamless tileable top-down dungeon floor texture: rough dark cave stone
> studded with small embedded crystal shards, faint glowing violet (#9B6BF0)
> light pulsing from within the crystal clusters. Viewed from directly
> above, no characters, no text, no watermark, moody and oppressive.

### C14. Kryształowa jaskinia — ściana
> Seamless tileable dungeon wall texture: jagged dark cave rock with large
> embedded crystal veins, faint glowing violet (#9B6BF0) light diffusing
> outward from deep within the veins. No characters, no text, no watermark,
> moody and oppressive.

### C15. Zardzewiała hala maszyn — podłoga
> Seamless tileable top-down dungeon floor texture: corroded rusted metal
> grating fused with cracked stone, thick orange-brown rust stains, faint
> sickly yellow-green (#C9D96B) glow leaking from gaps beneath the grating.
> Viewed from directly above, no characters, no text, no watermark, moody
> and oppressive.

### C16. Zardzewiała hala maszyn — ściana
> Seamless tileable dungeon wall texture: corroded rusted metal plating
> bolted over old stone, streaked with heavy rust stains, faint sickly
> yellow-green (#C9D96B) glow seeping from seams between plates. No
> characters, no text, no watermark, moody and oppressive.

---

## Podpięcie w kodzie (gdy grafiki wrócą z GPT)

Dokładnie checklist z `PLAN_LOSOWYCH_POKOI.md` sekcja 5, z jedną zmianą:
pomiń krok "przeczytać dokument przekazaniowy drugiego bota" — te 12
archetypów już ma pełną mechanikę opisaną w
`CLAUDE_CODE_GAME_CONTENT_BIBLE.md` sekcja 6, więc mogę pisać skrypty
wrogów (podklasy `Incarnation`, jak dziś 6 wcieleń) równolegle z
generowaniem grafik — nie trzeba czekać na obrazki, żeby zacząć kod.
