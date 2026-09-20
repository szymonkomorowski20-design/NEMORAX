# NEMORAX — Kompletny katalog tekstur (świat, efekty, UI, menu)

Uzupełnienie [LORE_I_ASSETY.md](LORE_I_ASSETY.md), które pokrywa TYLKO sześć
wcieleń, Nemoraxa, gracza, miecz i różdżkę. Ten plik to WSZYSTKO INNE, co dziś
jest rysowane kodem i docelowo powinno dostać teksturę — każda pozycja ma teraz
konkretny, wymyślony wygląd (nie ogólny szablon), gotowy do wklejenia w bota.

Status: pełne opisy gotowe, czekają na wygenerowanie.

---

## 0. Style guide (osobny dla każdej kategorii, dokleić do promptu)

**Efekty/ataki/przedmioty** (sekcje 1-3):
> Dark fantasy 2D game VFX / prop icon, glowing against near-black background
> (#1A1026), clean bold readable silhouette, single dominant neon accent
> color, no text, no watermark, no character, transparent or plain background.

**Otoczenie/tekstury podłoża i ścian** (sekcja 4):
> Seamless tileable dark fantasy dungeon texture, viewed from directly above
> (top-down game texture), subtle glowing accent color worked into cracks or
> details, no characters, no text, no watermark, moody and oppressive.

**UI** (sekcja 5):
> Dark fantasy game UI element, ornate worn dark metal, bone or obsidian
> frame, glowing neon accent fill, flat clean icon/bar style readable at small
> size, no text, transparent background.

Paleta: tło `#1A1026`, podłoga `#2A1B3D`, ściany `#3E2A57`, gracz `#5BE0C8`,
obrażenia/zagrożenie `#FFC857`, błysk `#FFFFFF`. Kolory wcieleń: `#F0447A`
`#9B4DFF` `#C44FD6` `#6C63FF` `#E8524A` `#8C9AC2` (Mordrath/Thal'Gor/Orryx
poprawione po dostarczonej grafice — patrz `autoload/palette.gd`).

---

## 1. Ataki bossów

### 1.1 Pieczęć — Szósty Rytm (`seal.gd`)
Sześcioramienna runa (nawiązanie do "Szóstego Rytmu") wypalona w ziemi,
pękająca kamienna otoczka, w środku wirujący wzór jak zegar odliczający do
wybuchu.
> A hexagonal rune-seal burned into the ground, six jagged spokes radiating
> from a cracked stone ring, glowing warning-yellow (#FFC857), a faint
> spiraling clockwork-like pattern inside as if counting down to detonation,
> ancient and ominous. [+ styl efektów]

### 1.2 Ząb Zera (`void_zone.gd`)
Nie zadaje obrażeń — celowo NIE żółta. Krawędź portalu wygląda jak pierścień
połamanych, szklistych "zębów" skierowanych do środka (dosłowne nawiązanie do
nazwy), wnętrze to bezgwiezdna, wirująca czerń.
> A perfectly circular void rift in the ground, its rim made of jagged
> glass-like broken tooth shapes pointing inward, almost pure black interior
> (#0B0810) swirling like starless smoke, thin glowing outline in a shifting
> neon accent color, feels like it swallows motion rather than deals damage.
> [+ styl efektów]

### 1.3 Cień — Kradzież Intencji (`shadow.gd`)
**Uwaga**: to dosłownie "gracz z przeszłości" — najprościej ODTWORZYĆ sprite
gracza (LORE_I_ASSETY.md 5.1) z 50% przezroczystością i żółtym konturem,
zamiast projektować osobną istotę. Bez osobnego promptu.

### 1.4 Wypad / kontakt fizyczny bossa (telegraf)
Ostry, kierunkowy pazur światła wypalony w ziemi, jakby coś przeciągnęło po
niej szponem tuż przed uderzeniem.
> A sharp jagged claw-mark scratch of glowing light dragged across the ground
> in a straight line, warning-yellow (#FFC857), three parallel scratch
> streaks fading at the tail end, violent and fast. [+ styl efektów]

---

## 2. Gracz — dodatkowe efekty

### 2.1 Ślad dasha (`player.gd`, `_trail`)
Nie kopie sylwetki — smuga jak ostrze wiatru: sierpowaty kształt z jaśniejszą
krawędzią z przodu i rozmywającym się ogonem, pięć takich smug gasnących w tle.
> A crescent-shaped streak of cyan light (#5BE0C8) like a blade of wind, sharp
> bright leading edge fading into wispy translucent particles at the tail,
> motion-blur afterimage effect. [+ styl efektów]

### 2.2 Wycinek ataku mieczem (`_draw_attack_sector`)
Sierpowate cięcie światła — ostra, czysta krawędź od strony ostrza, rozmyta
mgiełka od strony rękojeści.
> A crescent-moon shaped sword-slash arc of glowing warning-yellow (#FFC857)
> light, one sharp clean edge, the opposite edge dissolving into faint mist,
> wide fast swing shape. [+ styl efektów]

### 2.3 Ładowanie różdżki (`_draw_wand_charge`)
Ciasno skręcona kulka trzaskającej energii z drobnymi iskrami wciąganymi
spiralnie do środka.
> A small tightly-wound orb of crackling yellow (#FFC857) electric energy at a
> wand's tip, tiny sparks and motes of light spiraling inward toward the
> center, building tension. [+ styl efektów]

---

## 3. Przedmioty i obiekty interaktywne pokoi

### 3.1 Drzwi (`rooms/door.gd`)
Nie drzwi w sensie skrzydła — pęknięty w rzeczywistości próg. Łuk zbity z
poskręcanej czarnej kości/skały zrośniętej w nienaturalny sposób, bez skrzydła
drzwiowego — samo przejście świeci run wzdłuż krawędzi.
> A jagged archway threshold fused from twisted black bone and rock, no actual
> door panel — just an empty rift-like opening rimmed with faintly glowing
> pale runes (#C9C2B4), imposing and ancient, looks torn open rather than
> built. [+ styl efektów]

### 3.2 Dusza wcielenia (`rooms/soul.gd`)
Nie kula światła — łza/iskra uwięziona wewnątrz przezroczystego, pękniętego
odłamka kryształu, migocząca jak dogasająca świeca. Kolor zależny od wcielenia
(sekcja 2 LORE_I_ASSETY.md ma już wygląd per-istota — to wersja generyczna/
technicznego rdzenia, jeśli wolisz jeden sprite tintowany w silniku zamiast
sześciu osobnych).
> A small teardrop-shaped ember of light trapped inside a cracked translucent
> crystal shard, flickering like a dying candle flame, slowly rotating,
> fragile and sorrowful. [+ styl efektów]

### 3.3 Gniazdo ołtarza (`rooms/altar.gd`)
Sześciokątne wgłębienie (echo "Szóstego Rytmu"), z cienkimi rowkami
promieniującymi na zewnątrz jak pęknięcia, puste = matowe, zapełnione = świeci
kolorem fragmentu.
> A hexagonal carved stone recess in an altar, thin crack-like grooves
> radiating outward from its center, dormant and matte when empty, glowing
> softly in an assigned accent color when filled with a soul fragment.
> [+ styl efektów]

---

## 4. Otoczenie pokoi (podłoga/ściany) — każdy pokój osobno

Każdy pokój ma dwa elementy do wygenerowania: **podłogę** (tileable, widok z
góry, bo kamera w grze jest top-down) i **ścianę** (widoczną jako ramka wokół
areny — mniej krytyczne, żeby była tileable, bo to głównie ozdobna ramka).

### 4.1 Pokój Vhar’Nokha — Kamieniołom Wygnania
Surowy, nieukończony kamieniołom, jakby budowa stanęła w pół ruchu w chwili,
gdy coś wygnało Vhar'Nokha do tego wymiaru.

**Podłoga**:
> Seamless tileable top-down dungeon floor texture: rough, freshly-hewn dark
> stone slabs with visible chisel marks, hairline cracks glowing faint
> magenta-pink (#F0447A) from within, thin dust and rubble scattered across
> the surface. [+ styl otoczenia]

**Ściana**:
> Seamless tileable dungeon wall texture: unfinished raw quarry rock, jagged
> and irregular, fragments of scaffolding-like geometry embedded and
> half-collapsed into the wall, faint magenta-pink (#F0447A) glow bleeding
> from deep fissures, thick low fog clinging near the base. [+ styl otoczenia]

### 4.2 Pokój Mordratha — Komnata Bez Echa
Całkowicie wyciszona komnata, jakby dźwięk sam bał się w niej istnieć.
**POPRAWKA**: dostarczona grafika Mordratha jest fioletowa, nie pomarańczowa
— zmienione w kodzie (`autoload/palette.gd`), poniższe prompty już zaktualizowane.

**Podłoga**:
> Seamless tileable top-down dungeon floor texture: dark leathery padded
> panels stitched together with thick visible black seams, slightly spongy
> and sound-deadening in appearance, faint violet (#9B4DFF) veins pulsing
> faintly beneath the surface like breathing skin. [+ styl otoczenia]

**Ściana**:
> Seamless tileable dungeon wall texture: thick quilted black leather-like
> padding covering the stone beneath, heavy stitched seams, faint pulsing
> violet (#9B4DFF) veins visible under the padding, utterly muffling and
> claustrophobic. [+ styl otoczenia]

### 4.3 Pokój Zha’Ruuna — Sala Złamanych Zegarów
Czas w tym pokoju się zaciął — wszystko tu jest zatrzymane w momencie awarii.

**Podłoga**:
> Seamless tileable top-down dungeon floor texture: cracked dark marble
> embedded with shattered clock gears and broken hourglass glass shards,
> fine purple-magenta (#C44FD6) dust settled into every crack and groove.
> [+ styl otoczenia]

**Ściana**:
> Seamless tileable dungeon wall texture: rows of stopped, decaying
> grandfather-clock husks fused into dark stone, cracked clock faces frozen
> at different times, faint purple-magenta (#C44FD6) glow leaking from
> broken clockwork innards. [+ styl otoczenia]

### 4.4 Pokój Nekravora — Zapadnięta Krypta
Sklepienie ledwo się trzyma, jakby cały pokój miał zaraz runąć pod własnym
ciężarem — dosłowne echo Nekravora.

**Podłoga**:
> Seamless tileable top-down dungeon floor texture: heavy dark flagstones
> under crushing pressure, hairline stress-fractures glowing faint
> blue-violet (#6C63FF), scattered bone shard fragments pressed into the
> mortar between stones. [+ styl otoczenia]

**Ściana**:
> Seamless tileable dungeon wall texture: massive stone support columns bowed
> and bent inward like ribs under crushing weight, bone shards embedded in
> the cracked mortar, deep fissures seeping blue-violet (#6C63FF) light.
> [+ styl otoczenia]

### 4.5 Pokój Thal’Gora — Gardziel
Organiczny tunel, jakby gracz wchodził w żywy, pulsujący przełyk czegoś
ogromnego.
**POPRAWKA**: dostarczona grafika Thal'Gora wychodzi na czerwoną, nie zieloną
— zmienione w kodzie (`autoload/palette.gd`), poniższe prompty już zaktualizowane.

**Podłoga**:
> Seamless tileable top-down organic floor texture: fleshy, faintly pulsing
> membrane-like surface, thin veins of dark red (#E8524A) blood visible just
> beneath a translucent skin layer, damp and unsettling. [+ styl otoczenia]

**Ściana**:
> Seamless tileable organic wall texture: ribbed, muscular throat-like walls
> gently pulsing, thin taut membrane stretched between rib-like support
> beams, glowing dark red (#E8524A) veins of blood tracing along the ridges.
> [+ styl otoczenia]

### 4.6 Pokój Orryxa — Studnia Ciemności
Brak własnego oświetlenia — jedynym źródłem światła w tym starciu jest sam
Orryx.
**POPRAWKA**: dostarczona grafika Orryxa wychodzi na chłodny błękit, nie
ciepły beż — zmienione w kodzie (`autoload/palette.gd`), poniższy prompt
ściany już zaktualizowany.

**Podłoga**:
> Seamless tileable top-down floor texture: near-total matte black surface
> absorbing almost all light, only the faintest hint of uneven stone texture
> visible at extreme close range, otherwise pure oppressive darkness.
> [+ styl otoczenia]

**Ściana**:
> Seamless tileable wall texture: matte black stone that seems to swallow
> light entirely, edges and corners barely distinguishable from one another,
> an extremely faint cool blue-gray (#8C9AC2) outline hinting at the wall's
> shape. [+ styl otoczenia]

### 4.7 Ołtarz — Sala Sześciu Gniazd
Okrągła, wygładzona wiekami rytuału komnata — jedyny pokój bez wroga, tylko z
napięciem oczekiwania.

**Podłoga**:
> Seamless tileable top-down floor texture: smooth ancient ritual stone worn
> pale and glassy by centuries of use, thin carved channel-grooves radiating
> from the center outward toward six hexagonal sockets, faint multicolored
> residual glow (#F0447A #9B4DFF #C44FD6 #6C63FF #E8524A #8C9AC2) in the
> grooves. [+ styl otoczenia]

**Ściana**:
> Seamless tileable dungeon wall texture: solid carved ceremonial dark stone,
> smooth and deliberate compared to the other rooms, faint circular
> engravings echoing the altar's ring motif. [+ styl otoczenia]

### 4.8 Tło poza areną (`Palette.BACKGROUND`)
Wspólne dla wszystkich pokoi, poza samą areną — opcjonalne.
> A near-black void background texture, extremely subtle distant nebula-like
> wisps, almost solid dark purple-black, barely perceptible motion.
> [+ styl otoczenia]

---

## 5. UI

### 5.1 Pasek życia gracza
Rama z ciemnej, poszarpanej kości/obsydianu (nie gładki prostokąt) — wypełnienie
to cyjanowe płynne światło, lekko falujące jak ciecz.
> A horizontal fantasy game health bar frame made of dark jagged bone/obsidian
> shards, uneven organic edges, filled with rippling liquid-light cyan glow
> (#5BE0C8). [+ styl UI]

### 5.2 Pasek życia bossa
Szerszy, bardziej monumentalny — spękany czarny kamień z ostrymi, drapieżnymi
inkrustacjami, ciągnący się niemal przez całą szerokość ekranu.
> A wide, imposing horizontal boss health bar frame made of cracked black
> stone with sharp jagged inlaid edges, spans nearly the full screen width,
> fill glow color set dynamically per phase. [+ styl UI]

### 5.3 Pasek staminy
Cieńszy pasek ze splecionych rzemieni/ścięgien, wypełnienie jak żarzący się
bursztyn.
> A thin horizontal stat bar frame woven from dark leather straps and sinew,
> filled with glowing ember-amber (#E8A33D) light. [+ styl UI]

### 5.4 Pasek many
Cienka oprawa z pękniętego kryształu, wypełnienie jak drżące niebieskie
światło z delikatnym połyskiem.
> A thin horizontal stat bar frame encased in cracked crystal shards, filled
> with shimmering blue (#4FA8E8) liquid light. [+ styl UI]

### 5.5 Ikona dasha
Sześciokątny kafel runiczny z wygrawerowanym symbolem "smugi ruchu" (jak
zamazany ptak w locie) — cyjanowy, gdy gotowy; przygaszony szaro-niebieski w
trakcie odnowienia; z grubą, poszarpaną blizną-krzyżykiem, gdy zablokowany
przez Ząb Zera.
> A small hexagonal rune tile icon engraved with a stylized motion-blur
> streak symbol, glowing cyan (#5BE0C8) when ready, dimmed grayish-blue when
> on cooldown, with a crude scratched-out X overlay variant for when locked.
> [+ styl UI]

### 5.6 Ikona leczenia
Okrągła runa z cienką linią pulsu/tętna wyrytą wzdłuż obwodu — wypełnia się
zieloną poświatą zgodnie z ruchem wskazówek zegara, rozbłyskuje na biało-zielono
po naładowaniu.
> A small circular rune icon with a thin heartbeat-pulse line engraved around
> its rim, filling clockwise with green (#6FCF7A) glow as charge builds,
> flaring bright white-green when fully charged. [+ styl UI]

### 5.7 Typografia
Bez promptu graficznego — to wybór pliku fontu, nie generowanie obrazka.
Sugestia: jedna pogrubiona, lekko "postrzępiona"/mroczna czcionka fantasy
(np. z Google Fonts) używana wszędzie (UI, komunikaty, menu) dla spójności.

---

## 6. Menu / ekran startowy

### 6.1 Logo/tytuł NEMORAX
Litery nierówne, jakby wydrapane pazurem w kamieniu — różne wysokości,
asymetryczne, z cienkimi pęknięciami biegnącymi przez środek napisu. Gradient
koloru: cyjan gracza przechodzący w głęboką magentę/fiolet sześciu wcieleń.
> A dark fantasy game logo wordmark "NEMORAX", jagged uneven claw-scratched
> lettering of varying heights, thin cracks running through the letterforms,
> gradient glow from player-cyan (#5BE0C8) into deep incarnation magenta-
> violet, imposing and ominous, transparent background. [+ styl UI]

### 6.2 Tło menu
Ogromna, mroczna jaskinia/otchłań; w oddali ledwo widoczna, kolosalna sylwetka
Nemoraxa (sama czerń, prawie bez detalu); sześć maleńkich, kolorowych iskier
rozproszonych w ciemności reprezentujących sześć wcieleń; gęsta mgła na
pierwszym planie, żeby tekst UI został czytelny.
> A vast dark cavern/abyss background illustration, a barely-visible colossal
> silhouette of a hybrid monster looming far in the background (mostly pure
> shadow, low detail), six tiny distant colored glowing pinpricks scattered in
> the darkness, heavy foreground mist, composition leaves the center calm and
> uncluttered for UI text. [+ styl otoczenia]

---

## 7. Ekrany końcowe (śmierć / zwycięstwo)

Niski priorytet — obecny płaski przyciemniony overlay działa i jest czytelny.
Jeśli chcesz to podrasować, dwa warianty tej samej ramki dekoracyjnej:

**Śmierć** — pękająca, kruszejąca się kostna rama wpełzająca z rogów ekranu,
sącząca ciemnoczerwoną, prawie czarną maź.
> A decorative dark vignette frame for a game death screen, cracked crumbling
> bone creeping in from the screen corners, dripping near-black dark red
> essence, center left plain and dark for text, no text itself. [+ styl UI]

**Zwycięstwo** — ta sama forma ramy, ale z cyjanowo-złotym, spokojnym
światłem zamiast rozpadu.
> A decorative vignette frame for a game victory screen, the same ornate
> corner shapes but intact and calm, glowing cyan-gold (#5BE0C8 to warm gold)
> light instead of decay, triumphant, no text itself. [+ styl UI]

---

## 8. Czego NIE trzeba generować (zostaje w kodzie/shaderze)

- **Zaćmienie** (przyciemnienie ekranu wokół gracza w finałowej fazie
  Nemoraxa) — shader liczony w czasie rzeczywistym (`arena.gd`), zostaje jak jest.
- **Hitstop / trzęsienie ekranu / błysk trafienia na biało** — czysty kod
  (`juice.gd`), nie potrzebują grafiki.
- Drobne cząsteczki/detale poza powyższą listą — zostają proste, rysowane
  kodem, chyba że zechcesz inaczej.
