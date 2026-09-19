# NEMORAX — Gracz i ekwipunek: kompletny katalog (baza + wszystkie pozy)

Uzupełnia lukę z [LORE_I_ASSETY.md](LORE_I_ASSETY.md) sekcja 5 — postać
gracza, miecz i różdżka miały tam tylko jednolinijkowe prompty i NIGDY nie
trafiły do żadnej checklisty generowania: siedem wcieleń + Nemorax mają swój
komplet w `01_characters` z `grafiki do gry/`, gracz — zero. Dorzucam tu też
pocisk różdżki, który nie był dotąd NIGDZIE opisany jako osobny obrazek, oraz
kompletny zestaw póz animacji gracza (dokładnie tym samym trybem, co
[POZY_ANIMACJI.md](POZY_ANIMACJI.md) dla siedmiu wcieleń).

Status: gotowe do wklejenia w bota. Kolejność ma znaczenie: najpierw sekcja 1
(baza, bez referencji), potem sekcja 4 (pozy, KAŻDA z załączoną referencją
z sekcji 1.1 — patrz zasada w sekcji 2).

---

## 0. Style guide (ten sam co reszta postaci — dokleić do KAŻDEGO promptu z sekcji 1)

> Dark fantasy 2D game creature concept art, painterly digital illustration,
> dramatic rim lighting, dark neutral materials (obsidian black, bone white,
> charcoal, dried blood), ONE glowing neon accent color applied only to a
> specific detail — not the whole body/object, clean bold readable silhouette
> designed to be recognizable even as a small top-down icon, plain near-black
> background (#1A1026), no text, no watermark, 3/4 view idle pose.

Paleta: gracz (cyjan) `#5BE0C8`, akcent różdżki/pocisku (żółty) `#FFC857`,
leczenie (zielony) `#6FCF7A`, błysk trafienia `#FFFFFF`.

---

## 1. Baza — te 4 obrazki generujesz PIERWSZE, bez żadnej referencji

### 1.1 Postać gracza (referencja bazowa — WSZYSTKO poniżej z niej korzysta)
**Koncept**: zwinny, drobny w porównaniu do bossów, JEDYNA cyjanowa postać w
grze (zasada z dokumentu bazowego) — musi się rzucać w oczy na tle
fioletowo-czarnych pokoi i kolorowych wcieleń. Ma nosić OBA uzbrojenia na
sobie widocznie, żeby ta jedna referencja wystarczyła do wszystkich póz
poniżej (miecz przy pasie, różdżka też), zamiast robić osobną referencję na
wariant "z mieczem" i osobną na "z różdżką".
> A small, agile hooded adventurer standing in a calm ready stance, dark
> tattered cloak and simple leather-and-cloth armor, hood casting the face
> mostly in shadow, glowing cyan (#5BE0C8) eyes visible under the hood, thin
> cyan energy veins faintly glowing under the skin/cloth at the wrists and
> collar, a simple short sword sheathed at the hip and a slender wand tucked
> through a belt strap — both weapons clearly visible and readable on the
> body — lean build suggesting speed and dodging rather than brute strength.
> [+ styl z sekcji 0]

### 1.2 Miecz (osobna ikona przedmiotu, nie na postaci)
> A simple, elegant short sword with a thin glowing cyan (#5BE0C8) edge
> running the length of the blade, minimalist dark hilt with a small
> cyan-wrapped grip, no ornate decoration, clean silhouette readable
> mid-swing, floating item icon presented on its own, angled diagonally.
> [+ styl z sekcji 0]

### 1.3 Różdżka (osobna ikona przedmiotu, nie na postaci)
> A slender dark wand, roughly forearm-length, with a small floating glowing
> yellow (#FFC857) crystal orb suspended just above its tip, faint crackling
> energy tendrils curling around the orb, minimalist otherwise, no ornate
> carving, floating item icon presented on its own, angled diagonally.
> [+ styl z sekcji 0]

### 1.4 Pocisk różdżki w locie (brakujący element — dotąd nigdzie nieopisany)
To NIE to samo co 1.3 — tamto jest ładowanie się orbu na czubku różdżki
(`_draw_wand_charge`, `player.gd:463`), to jest wersja PO wystrzeleniu, w
locie (`entities/projectile.gd`), osobny obrazek.
> A small fast-moving orb of crackling yellow (#FFC857) energy in flight, a
> short bright motion-streak tail trailing behind it, tight glowing core,
> compact and readable at small size. Dark fantasy 2D game VFX icon, glowing
> against near-black background (#1A1026), clean bold silhouette, single
> dominant neon accent color, no text, no watermark, no character,
> transparent or plain background.

---

## 2. Zasada dla sekcji 4: generuj z referencją, nie z opisu od zera

Dokładnie ta sama zasada co w `POZY_ANIMACJI.md` sekcja 0 — teraz obowiązuje
też dla gracza, i z tego samego powodu (inaczej każda poza to lekko INNA
postać: inne proporcje kaptura, inny odcień cyjanu). Dla KAŻDEJ poniższej
pozy:

1. Załącz do wiadomości gotowy obrazek **1.1 (postać gracza)**.
2. Użyj promptu w formie:

> Using the attached image as the exact reference for this adventurer's
> design — same proportions, same colors, same cloak/armor details, same
> cyan glow — regenerate this exact same character in a new pose: [OPIS Z
> SEKCJI 4 PONIŻEJ]. Keep the identical art style, lighting, camera angle and
> framing as the reference. Transparent background, no text, single
> character, no other changes to the design.

3. Jedna poza na raz, jedno zapytanie = jeden obrazek. Proszenie o cały
   arkusz póz naraz kończy się bałaganem — dokładnie to, co już się
   przydarzyło przy pierwszym podejściu do wcieleń.

---

## 3. Priorytety — nie musisz robić wszystkiego na raz

**Konieczne (7 póz)** — bez nich gra "nie żyje" wizualnie, bo brakuje
podstawowego stanu dla każdej głównej akcji: **CHÓD**, **ZAMACH MIECZEM
(active)**, **WYSTRZAŁ Z RÓŻDŻKI**, **BLOK**, **LECZENIE**, **TRAFIONY**,
**ŚMIERĆ**.

**Dodatkowe, jeśli starczy cierpliwości**: **ZAMACH MIECZEM — zapowiedź
(windup)**, **ŁADOWANIE RÓŻDŻKI (windup)**, **DASH**. Bez nich te trzy akcje
po prostu na razie użyją poz CHÓD/ZAMACH jako zamiennika w silniku — gra
działa, tylko mniej czytelnie w tym jednym momencie.

---

## 4. Kompletny zestaw póz (każda odpowiada dokładnie jednemu stanowi w `entities/player.gd`)

### 4.1 CHÓD (idle-walk) — najczęściej widoczna poza w grze
> ...regenerate this exact same character in a mid-stride walking pose,
> cloak trailing slightly with motion, alert and ready posture, sword still
> sheathed at the hip.

### 4.2 DASH (`_handle_dash_input`, `player.gd:165`)
> ...regenerate this exact same character in a low forward-leaning sprinting
> lunge, body compressed and streamlined, cloak whipping backward hard,
> faint cyan energy trail licking off the heels, strong sense of fast
> forward motion.

### 4.3 ZAMACH MIECZEM — zapowiedź/windup (`_start_attack`, `player.gd:292`, faza "windup")
> ...regenerate this exact same character gripping the drawn sword pulled
> back and raised in a tense wind-up before swinging, cyan edge glowing
> slightly brighter than at rest, coiled and ready — unmistakably readable as
> "about to strike".

### 4.4 ZAMACH MIECZEM — cięcie/active (`player.gd:316`, faza "active")
> ...regenerate this exact same character mid-swing with the drawn sword,
> arm fully extended through a wide slashing arc, cyan blade trailing a
> bright arc of light, dynamic and aggressive.

### 4.5 ŁADOWANIE RÓŻDŻKI — windup (`_draw_wand_charge`, `player.gd:463`)
> ...regenerate this exact same character holding the wand raised and
> extended forward, a small crackling yellow (#FFC857) orb building at its
> tip, character's own cyan glow undimmed, tense focused stance.

### 4.6 WYSTRZAŁ Z RÓŻDŻKI — active (`_fire_projectile`, `player.gd:328`)
> ...regenerate this exact same character with the wand thrust fully forward
> at the moment of firing, a bright yellow (#FFC857) burst just leaving the
> tip, slight recoil lean backward through the body.

### 4.7 BLOK (`_handle_block_input`, `player.gd:239`)
> ...regenerate this exact same character in a defensive guard stance,
> weapon raised crosswise in front of the body, a faint cyan energy ward
> shimmering just in front of the blade, braced stance with a low center of
> gravity.

### 4.8 LECZENIE (`_handle_heal_input`, `player.gd:263`)
> ...regenerate this exact same character with head tilted slightly down and
> one hand pressed to their own chest, enveloped in a soft warm green
> (#6FCF7A) healing glow, eyes closed, calm and momentarily vulnerable.

### 4.9 TRAFIONY / hit reaction (`take_damage`, `player.gd:395`)
> ...regenerate this exact same character in a recoiling, flinching pose as
> if just struck, body thrown off-balance and twisted slightly backward,
> momentarily vulnerable.

### 4.10 ŚMIERĆ (`player.gd:405`)
> ...regenerate this exact same character collapsing to their knees and
> falling forward, cyan glow visibly dimming and fading out of the veins and
> eyes, cloak crumpling loosely around the falling body.

---

## 5. Ile to razem obrazków

4 bazowe (postać + miecz + różdżka + pocisk) + 10 póz = **14 nowych
obrazków**. Docelowo lądują w `grafiki do gry/01_characters` obok siedmiu
wcieleń (postać gracza) i/lub w `03_player_vfx` (miecz/różdżka/pocisk, obok
istniejących efektów ślad-dasha/wycinek-cięcia/ładowanie-różdżki) — dopisz je
do `MANIFEST.md`, kiedy wszystkie będą gotowe.
