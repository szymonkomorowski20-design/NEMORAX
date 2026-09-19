# NEMORAX — Finalna lista wszystkich obrazków do wygenerowania

Scalenie [ASSETY_SWIATA_I_UI.md](ASSETY_SWIATA_I_UI.md) w gotowe, kompletne
prompty (każdy już ma wklejony styl — nic nie trzeba doklejać ręcznie).
Nie obejmuje 7 głównych postaci (Vhar'Nokh...Nemorax, już zrobione) ani ich
póz do animacji — to osobno w [LORE_I_ASSETY.md](LORE_I_ASSETY.md) i
[POZY_ANIMACJI.md](POZY_ANIMACJI.md).

**Razem: 34 obrazki**, w 8 grupach. Checklisty do odhaczania w miarę robienia.

---

## Uwaga techniczna przed startem — tileable tekstury

Sekcja D (podłogi/ściany, 15 obrazków) musi się **bezszwowo powtarzać**
(tileable) — większość botów NIE gwarantuje tego domyślnie, nawet jeśli
prompt mówi "seamless". Po wygenerowaniu ustaw obrazek jako powtarzający się
kafelek (np. w GIMP/Photoshopie: Filter → Offset o połowę szerokości/wysokości
i sprawdź, czy szew jest widoczny) — jeśli tak, dopytaj bota o poprawkę albo
wygeneruj ponownie. Reszta kategorii (VFX, UI, postacie) nie musi się kafelkować.

Format wszystkiego: PNG, przezroczyste lub jednolite ciemne tło, kwadrat
(1:1) — łatwo przyciąć/przeskalować w Godocie.

---

## A. Ataki bossów (3 obrazki)

- [ ] **A1. Pieczęć (Szósty Rytm)**
  > A hexagonal rune-seal burned into the ground, six jagged spokes radiating
  > from a cracked stone ring, glowing warning-yellow (#FFC857), a faint
  > spiraling clockwork-like pattern inside as if counting down to detonation,
  > ancient and ominous. Dark fantasy 2D game VFX / prop icon, glowing against
  > near-black background (#1A1026), clean bold readable silhouette, single
  > dominant neon accent color, no text, no watermark, no character,
  > transparent or plain background.

- [ ] **A2. Ząb Zera** (uwaga: w grze kontur zmienia kolor dynamicznie zależnie
  od fazy bossa — generuj z NEUTRALNYM BIAŁYM konturem, żeby dało się go
  zabarwiać w silniku zamiast robić 6 wersji kolorystycznych)
  > A perfectly circular void rift in the ground, its rim made of jagged
  > glass-like broken tooth shapes pointing inward, almost pure black interior
  > swirling like starless smoke, thin glowing neutral white outline (meant to
  > be color-tinted later), feels like it swallows motion rather than deals
  > damage. Dark fantasy 2D game VFX / prop icon, glowing against near-black
  > background (#1A1026), clean bold readable silhouette, no text, no
  > watermark, no character, transparent or plain background.

- [ ] **A3. Zapowiedź wypadu (pazur)**
  > A sharp jagged claw-mark scratch of glowing light dragged across the
  > ground in a straight line, warning-yellow (#FFC857), three parallel
  > scratch streaks fading at the tail end, violent and fast. Dark fantasy 2D
  > game VFX / prop icon, glowing against near-black background (#1A1026),
  > clean bold readable silhouette, single dominant neon accent color, no
  > text, no watermark, no character, transparent or plain background.

*(Cień — Kradzież Intencji — nie potrzebuje osobnego obrazka: to sprite
gracza z 50% przezroczystością i żółtym konturem, robione w silniku.)*

## B. Efekty gracza (3 obrazki)

- [ ] **B1. Ślad dasha**
  > A crescent-shaped streak of cyan light (#5BE0C8) like a blade of wind,
  > sharp bright leading edge fading into wispy translucent particles at the
  > tail, motion-blur afterimage effect. Dark fantasy 2D game VFX / prop icon,
  > glowing against near-black background (#1A1026), clean bold readable
  > silhouette, single dominant neon accent color, no text, no watermark, no
  > character, transparent or plain background.

- [ ] **B2. Wycinek ataku mieczem**
  > A crescent-moon shaped sword-slash arc of glowing warning-yellow
  > (#FFC857) light, one sharp clean edge, the opposite edge dissolving into
  > faint mist, wide fast swing shape. Dark fantasy 2D game VFX / prop icon,
  > glowing against near-black background (#1A1026), clean bold readable
  > silhouette, single dominant neon accent color, no text, no watermark, no
  > character, transparent or plain background.

- [ ] **B3. Ładowanie różdżki**
  > A small tightly-wound orb of crackling yellow (#FFC857) electric energy
  > at a wand's tip, tiny sparks and motes of light spiraling inward toward
  > the center, building tension. Dark fantasy 2D game VFX / prop icon,
  > glowing against near-black background (#1A1026), clean bold readable
  > silhouette, single dominant neon accent color, no text, no watermark, no
  > character, transparent or plain background.

## C. Przedmioty i obiekty pokoi (3 obrazki)

- [ ] **C1. Drzwi**
  > A jagged archway threshold fused from twisted black bone and rock, no
  > actual door panel — just an empty rift-like opening rimmed with faintly
  > glowing pale runes (#C9C2B4), imposing and ancient, looks torn open
  > rather than built. Dark fantasy 2D game VFX / prop icon, glowing against
  > near-black background (#1A1026), clean bold readable silhouette, single
  > dominant neon accent color, no text, no watermark, no character,
  > transparent or plain background.

- [ ] **C2. Dusza wcielenia** (neutralna/biała — w silniku tintowana kolorem
  konkretnego wcielenia, żeby nie robić 6 osobnych wersji)
  > A small teardrop-shaped ember of light trapped inside a cracked
  > translucent crystal shard, flickering like a dying candle flame, neutral
  > white-gold glow (meant to be color-tinted later), slowly rotating,
  > fragile and sorrowful. Dark fantasy 2D game VFX / prop icon, glowing
  > against near-black background (#1A1026), clean bold readable silhouette,
  > no text, no watermark, no character, transparent or plain background.

- [ ] **C3. Gniazdo ołtarza** (jeden obrazek wystarczy — "zapełnione" zrobimy
  w silniku jako ten sam obrazek z dodanym blaskiem)
  > A hexagonal carved stone recess in an altar, thin crack-like grooves
  > radiating outward from its center, dormant and matte gray, ready to
  > receive a glowing soul fragment. Dark fantasy 2D game VFX / prop icon,
  > glowing against near-black background (#1A1026), clean bold readable
  > silhouette, no text, no watermark, no character, transparent or plain
  > background.

## D. Otoczenie pokoi — podłogi i ściany (15 obrazków)

- [ ] **D1. Vhar'Nokh — podłoga**
  > Seamless tileable top-down dungeon floor texture: rough, freshly-hewn
  > dark stone slabs with visible chisel marks, hairline cracks glowing faint
  > magenta-pink (#F0447A) from within, thin dust and rubble scattered across
  > the surface. Viewed from directly above, no characters, no text, no
  > watermark, moody and oppressive.

- [ ] **D2. Vhar'Nokh — ściana**
  > Seamless tileable dungeon wall texture: unfinished raw quarry rock,
  > jagged and irregular, fragments of scaffolding-like geometry embedded and
  > half-collapsed into the wall, faint magenta-pink (#F0447A) glow bleeding
  > from deep fissures, thick low fog clinging near the base. No characters,
  > no text, no watermark, moody and oppressive.

- [ ] **D3. Mordrath — podłoga**
  > Seamless tileable top-down dungeon floor texture: dark leathery padded
  > panels stitched together with thick visible black seams, slightly spongy
  > and sound-deadening in appearance, faint orange (#FF8A3D) veins pulsing
  > faintly beneath the surface like breathing skin. Viewed from directly
  > above, no characters, no text, no watermark, moody and oppressive.

- [ ] **D4. Mordrath — ściana**
  > Seamless tileable dungeon wall texture: thick quilted black leather-like
  > padding covering the stone beneath, heavy stitched seams, faint pulsing
  > orange (#FF8A3D) veins visible under the padding, utterly muffling and
  > claustrophobic. No characters, no text, no watermark, moody and oppressive.

- [ ] **D5. Zha'Ruun — podłoga**
  > Seamless tileable top-down dungeon floor texture: cracked dark marble
  > embedded with shattered clock gears and broken hourglass glass shards,
  > fine purple-magenta (#C44FD6) dust settled into every crack and groove.
  > Viewed from directly above, no characters, no text, no watermark, moody
  > and oppressive.

- [ ] **D6. Zha'Ruun — ściana**
  > Seamless tileable dungeon wall texture: rows of stopped, decaying
  > grandfather-clock husks fused into dark stone, cracked clock faces frozen
  > at different times, faint purple-magenta (#C44FD6) glow leaking from
  > broken clockwork innards. No characters, no text, no watermark, moody and
  > oppressive.

- [ ] **D7. Nekravor — podłoga**
  > Seamless tileable top-down dungeon floor texture: heavy dark flagstones
  > under crushing pressure, hairline stress-fractures glowing faint
  > blue-violet (#6C63FF), scattered bone shard fragments pressed into the
  > mortar between stones. Viewed from directly above, no characters, no
  > text, no watermark, moody and oppressive.

- [ ] **D8. Nekravor — ściana**
  > Seamless tileable dungeon wall texture: massive stone support columns
  > bowed and bent inward like ribs under crushing weight, bone shards
  > embedded in the cracked mortar, deep fissures seeping blue-violet
  > (#6C63FF) light. No characters, no text, no watermark, moody and
  > oppressive.

- [ ] **D9. Thal'Gor — podłoga**
  > Seamless tileable top-down organic floor texture: fleshy, faintly
  > pulsing membrane-like surface, thin sickly green (#7ED957) veins running
  > just beneath a translucent skin layer, damp and unsettling. Viewed from
  > directly above, no characters, no text, no watermark, moody and
  > oppressive.

- [ ] **D10. Thal'Gor — ściana**
  > Seamless tileable organic wall texture: ribbed, muscular throat-like
  > walls gently pulsing, thin taut membrane stretched between rib-like
  > support beams, glowing sickly green (#7ED957) veins tracing along the
  > ridges. No characters, no text, no watermark, moody and oppressive.

- [ ] **D11. Orryx — podłoga**
  > Seamless tileable top-down floor texture: near-total matte black surface
  > absorbing almost all light, only the faintest hint of uneven stone
  > texture visible at extreme close range, otherwise pure oppressive
  > darkness. Viewed from directly above, no characters, no text, no
  > watermark.

- [ ] **D12. Orryx — ściana**
  > Seamless tileable wall texture: matte black stone that seems to swallow
  > light entirely, edges and corners barely distinguishable from one
  > another, an extremely faint pale (#C9C2B4) outline hinting at the wall's
  > shape. No characters, no text, no watermark.

- [ ] **D13. Ołtarz — podłoga**
  > Seamless tileable top-down floor texture: smooth ancient ritual stone
  > worn pale and glassy by centuries of use, thin carved channel-grooves
  > radiating from the center outward toward six hexagonal sockets, faint
  > multicolored residual glow (#F0447A #FF8A3D #C44FD6 #6C63FF #7ED957
  > #C9C2B4) in the grooves. Viewed from directly above, no characters, no
  > text, no watermark, moody and oppressive.

- [ ] **D14. Ołtarz — ściana**
  > Seamless tileable dungeon wall texture: solid carved ceremonial dark
  > stone, smooth and deliberate compared to other dungeon rooms, faint
  > circular engravings echoing a ring motif. No characters, no text, no
  > watermark, moody and oppressive.

- [ ] **D15. Tło poza areną**
  > A near-black void background texture, extremely subtle distant
  > nebula-like wisps, almost solid dark purple-black (#1A1026), barely
  > perceptible motion. Seamless tileable, no characters, no text, no
  > watermark.

## E. UI (7 obrazków)

- [ ] **E1. Pasek życia gracza**
  > A horizontal fantasy game health bar frame made of dark jagged
  > bone/obsidian shards, uneven organic edges, filled with rippling
  > liquid-light cyan glow (#5BE0C8). Dark fantasy game UI element, ornate
  > worn dark metal/bone/obsidian frame, flat clean bar style readable at
  > small size, no text, transparent background.

- [ ] **E2. Pasek życia bossa**
  > A wide, imposing horizontal boss health bar frame made of cracked black
  > stone with sharp jagged inlaid edges, spans nearly the full screen width,
  > neutral white-gold fill glow (meant to be color-tinted per phase later).
  > Dark fantasy game UI element, ornate worn dark stone frame, flat clean
  > bar style readable at small size, no text, transparent background.

- [ ] **E3. Pasek staminy**
  > A thin horizontal stat bar frame woven from dark leather straps and
  > sinew, filled with glowing ember-amber (#E8A33D) light. Dark fantasy game
  > UI element, flat clean bar style readable at small size, no text,
  > transparent background.

- [ ] **E4. Pasek many**
  > A thin horizontal stat bar frame encased in cracked crystal shards,
  > filled with shimmering blue (#4FA8E8) liquid light. Dark fantasy game UI
  > element, flat clean bar style readable at small size, no text,
  > transparent background.

- [ ] **E5. Ikona dasha** (gotowa/pełna wersja — przygaszenie na cooldownie i
  krzyżyk blokady dorobimy w silniku jako nakładki na ten sam obrazek)
  > A small hexagonal rune tile icon engraved with a stylized motion-blur
  > streak symbol, glowing cyan (#5BE0C8), dark stone/metal frame. Dark
  > fantasy game UI element, flat clean icon style readable at small size, no
  > text, transparent background.

- [ ] **E6. Ikona leczenia**
  > A small circular rune icon with a thin heartbeat-pulse line engraved
  > around its rim, glowing green (#6FCF7A), dark stone/metal frame. Dark
  > fantasy game UI element, flat clean icon style readable at small size, no
  > text, transparent background.

- [ ] **E7. Krzyżyk blokady** (osobna mała nakładka na ikonę dasha, gdy
  zablokowana Zębem Zera)
  > A crude scratched-out X mark made of two rough claw-like slashes, pale
  > white (#FFFFFF), overlay icon element. Dark fantasy game UI element, flat
  > clean icon style, no text, transparent background.

## F. Menu (2 obrazki)

- [ ] **F1. Logo NEMORAX**
  > A dark fantasy game logo wordmark "NEMORAX", jagged uneven
  > claw-scratched lettering of varying heights, thin cracks running through
  > the letterforms, gradient glow from player-cyan (#5BE0C8) into deep
  > incarnation magenta-violet, imposing and ominous, transparent background,
  > no other text.

- [ ] **F2. Tło menu**
  > A vast dark cavern/abyss background illustration, a barely-visible
  > colossal silhouette of a hybrid monster looming far in the background
  > (mostly pure shadow, low detail), six tiny distant colored glowing
  > pinpricks scattered in the darkness, heavy foreground mist, composition
  > leaves the center calm and uncluttered for UI text. No characters in
  > focus, no text, no watermark.

## G. Ekrany końcowe (2 obrazki, niski priorytet)

- [ ] **G1. Ramka ekranu śmierci**
  > A decorative dark vignette frame for a game death screen, cracked
  > crumbling bone creeping in from the screen corners, dripping near-black
  > dark red essence, center left plain and dark for text. No text itself, no
  > watermark.

- [ ] **G2. Ramka ekranu zwycięstwa**
  > A decorative vignette frame for a game victory screen, ornate corner
  > shapes intact and calm, glowing cyan-gold (#5BE0C8 to warm gold) light,
  > triumphant. No text itself, no watermark.

---

## Podsumowanie liczby obrazków

| Grupa | Ile |
|---|---|
| A — Ataki bossów | 3 |
| B — Efekty gracza | 3 |
| C — Przedmioty pokoi | 3 |
| D — Otoczenie (podłogi/ściany) | 15 |
| E — UI | 7 |
| F — Menu | 2 |
| G — Ekrany końcowe | 2 |
| **RAZEM** | **35** |

Sugerowana kolejność: **D (otoczenie)** najpierw — najbardziej pracochłonne
(sprawdzanie tileable) i najbardziej widoczne cały czas w grze — potem
**A/B/C** (efekty i przedmioty), na końcu **E/F/G** (UI/menu/ekrany), bo te
najłatwiej dorobić na sam koniec.
