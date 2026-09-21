# NEMORAX — pełna paczka dla GPT: co się zmieniło, co generować, w jakiej kolejności

Ten plik zastępuje potrzebę posiadania `CLAUDE_CODE_GAME_CONTENT_BIBLE.md` —
streszcza wszystko, co z niego faktycznie trafiło do gry, i mówi dokładnie,
co jest DZIŚ potrzebne graficznie, po tym jak cała mechanika (Nemorax,
ołtarz, respawn, 12 wrogów) jest już zaimplementowana i przetestowana
(126/126 testów). Zgodnie z Twoją radą: mechanika najpierw, duża paczka
grafiki dopiero teraz.

---

## 0. Status mechaniki (zrobione, przetestowane, zakomitowane)

1. ✅ **Bug respawnu** — powrót do wyczyszczonego pokoju już nie stawia
   wroga drugi raz.
2. ✅ **Ołtarz** — jawna maszyna stanów LOCKED→READY→ACTIVATING: gniazda
   zapalają się po kolei w kolejności Motion→Force→Instinct→Dominion→Ruin→
   Sovereignty, gracz traci sterowanie na czas ceremonii.
3. ✅ **12 archetypów wrogów losowych** — Chaser/Striker/Shooter/Charger/
   Orbiter/Dasher/Ambusher/Zoner/Summoner/Tank/Support + Elite jako
   modyfikator (nie 13. ciało) — pełna mechanika (koszt/HP/prędkość/obrażenia/
   telegrafy/cooldowny z dokumentu), na TYMCZASOWEJ, reużytej grafice.
4. ✅ **Nemorax przebudowany** — 6 faz zastąpione mechaniką Motion/Force/
   Instinct/Dominion/Ruin/Sovereignty z dokumentu (ważone grupy wzorców z
   anti-repeat, skalowanie HP per fazę, przyspieszenie tempa przy niskim
   zdrowiu, "Crown Sequence" w Sovereignty). Nazwa "Nemorax", ceremonia
   przywołania, arena i tor zwycięstwa/śmierci — BEZ ZMIAN.

**Teraz jest właściwy moment na grafikę** — mechanika się już nie zmieni pod
wygenerowanymi obrazkami.

---

## 1. Nemorax — co NAPRAWDĘ trzeba wygenerować (mniej, niż mogłoby się wydawać)

### 1.1 Ważne uproszczenie zanim zaczniesz

Sprite Nemoraksa dziś działa tak: **tylko poza "chód/dryfowanie" (baza) jest
inna dla każdej z 6 faz** (6 osobnych plików `nemorax_phase-N_*.png`).
Wszystkie pozostałe pozy — telegraf, wypad, rzucenie zaklęcia, pociągnięcie,
trafienie, śmierć/kolaps, transformacja fazy, odrodzenie małej formy, drwina,
prawdziwa śmierć — są DZIŚ JEDNYM, wspólnym obrazkiem używanym identycznie
we wszystkich 6 fazach (`nemorax_telegraph.png`, `nemorax_lunge.png` itd.).

**Wniosek: żeby nowe 6 faz (Motion/Force/Instinct/Dominion/Ruin/Sovereignty)
działało wizualnie, potrzeba WYŁĄCZNIE 5 nowych obrazków bazowych** (baza
frontu; back/side to osobna, późniejsza sprawa — sekcja 3). Reszta pozy
(telegraf/wypad/trafienie/śmierć/transformacja) zostaje BEZ ZMIAN — te same
pliki, które już są w projekcie, nie trzeba ich ruszać.

Dlaczego 5, nie 6: **Motion (faza 0) to dokładnie ta sama, "neutralna, bez
reguły" faza co dawna faza 1 (Zalążek)** — `nemorax_phase-1_base.png` (i jej
warianty `_back`/`_side`) zostaje bez zmian jako wygląd Motion. Zmieniają się
tylko fazy 2-6 (Force/Instinct/Dominion/Ruin/Sovereignty).

### 1.2 Bazowy model Nemoraksa (referencja — już istnieje, patrz LORE_I_ASSETY.md sekcja 4)

Nemorax to ŚWIADOMIE zbudowana hybryda sześciu wcieleń, NIE bezkształtna
sklejka: ciężki tors Vhar'Nokha na środku, długie ramię Mordratha po lewej,
opancerzone szponiaste ramię Nekravora po prawej, wydłużona szczękowa głowa
Zha'Ruuna z przodu, cztery różne skrzydła Thal'Gora z tyłu, osiem
mackowatych kończyn Orryxa pod spodem, całe ciało popękane energią. Zamiast
jednej twarzy — sześć małych twarzy obok siebie (oko/czaszka/paszcza/czarna
twarz/demoniczna twarz/kosmos).

Dokument (LORE_I_ASSETY.md) już wcześniej zakładał, że **każda część ciała
"należy" do innego ataku** — dokładnie to teraz wykorzystujemy do zaprojektowania
6 nowych faz: każda faza to TA SAMA sylwetka hybrydy, ale z JEDNĄ częścią
ciała wizualnie wyeksponowaną/jaśniejszą (dominujący kolor przypisany danej
części), zamiast projektowania 6 zupełnie nowych, niepowiązanych potworów.

| Faza | Eksponowana część | Powód (jej atak w kodzie) | Kolor akcentu |
|---|---|---|---|
| Motion (0) | żadna — forma neutralna | brak specjalnej reguły, punkt wyjścia | `#4FC3E8` (już nieużywany, zostaje phase-1_base) |
| Force (1) | tors Vhar'Nokha | Wide Frontal Strike / Radial Warning — uderzenie ciężarem ciała | `#E8622E` |
| Instinct (2) | ramię/pęknięcia Mordratha | Reposition (teleport) / Feint | `#9B4DFF` |
| Dominion (3) | mackowate kończyny Orryxa | Zone / Projectile Fan / Summon — kontrola terenu | `#4FA65E` |
| Ruin (4) | opancerzone ramię Nekravora | Short Dash / Melee Chain — agresywne cięcie | `#D63B3B` |
| Sovereignty (5) | WSZYSTKIE sześć twarzy/części naraz, jaśniej niż gdziekolwiek indziej | synteza wszystkich wcześniejszych ataków | `#E8C547` |

### 1.3 Prompty — referencyjne regeneracje `nemorax_phase-1_base.png`

Ta sama zasada co w `PLAN_ANIMACJE_KIERUNKOWE.md` sekcja 6: jedna zmienna na
raz, zawsze bazując na TYM SAMYM pliku referencyjnym
(`nemorax_phase-1_base.png`), nie łańcuchowo jedna od drugiej.

**Force (nemorax_phase-2, PODMIENIA dawny `_silence`):**
> Using the attached image as the exact reference for this creature's design
> — same proportions, same six-faced head, same overall hybrid silhouette,
> same pose and camera angle — regenerate this EXACT same creature, but with
> the central horned torso visibly more massive and forward-leaning, faint
> cracks across the torso glowing bright orange (#E8622E) as the single
> dominant accent color instead of the reference's color, as if immense
> physical force is coiled and about to be unleashed. Keep the same
> materials, lighting style and all other body parts unchanged. Transparent
> background, no text, single character, no other changes to the design.

**Instinct (nemorax_phase-3, PODMIENIA dawny `_dash-cooldown`):**
> Using the attached image as the exact reference for this creature's design
> — same proportions, same six-faced head, same overall hybrid silhouette,
> same pose and camera angle — regenerate this EXACT same creature, but with
> the long unnatural left arm visibly cracked open with small dimensional
> rifts along its length, faint violet (#9B4DFF) light leaking from the
> rifts as the single dominant accent color instead of the reference's
> color, as if the arm exists slightly out of phase with reality. Keep the
> same materials, lighting style and all other body parts unchanged.
> Transparent background, no text, single character, no other changes to
> the design.

**Dominion (nemorax_phase-4, PODMIENIA dawny `_pull`):**
> Using the attached image as the exact reference for this creature's design
> — same proportions, same six-faced head, same overall hybrid silhouette,
> same pose and camera angle — regenerate this EXACT same creature, but with
> the eight shadow-root tentacle limbs beneath visibly longer, more numerous
> looking and spread wide as if claiming territory, glowing dull green
> (#4FA65E) as the single dominant accent color instead of the reference's
> color. Keep the same materials, lighting style and all other body parts
> unchanged. Transparent background, no text, single character, no other
> changes to the design.

**Ruin (nemorax_phase-5, PODMIENIA dawny `_regeneration`):**
> Using the attached image as the exact reference for this creature's design
> — same proportions, same six-faced head, same overall hybrid silhouette,
> same pose and camera angle — regenerate this EXACT same creature, but with
> the armored clawed right arm visibly larger and more aggressive, more
> blade-like bone protrusions along it, glowing deep red (#D63B3B) as the
> single dominant accent color instead of the reference's color, as if
> freshly torn and violent. Keep the same materials, lighting style and all
> other body parts unchanged. Transparent background, no text, single
> character, no other changes to the design.

**Sovereignty (nemorax_phase-6, PODMIENIA dawny `_narrow-vision`):**
> Using the attached image as the exact reference for this creature's design
> — same proportions, same six-faced head, same overall hybrid silhouette,
> same pose and camera angle — regenerate this EXACT same creature, but with
> ALL six body parts (torso, both arms, head, wings, tentacle limbs) equally
> and intensely glowing at once, brighter and more resplendent than any
> other phase, a unified golden light (#E8C547) as the single dominant
> accent color radiating from every part simultaneously, as if the creature
> has achieved its final, complete, crowned form. Keep the same materials,
> lighting style and all other body parts unchanged. Transparent background,
> no text, single character, no other changes to the design.

### 1.4 Co ZOSTAJE bez zmian (nie generować teraz)

- `nemorax_phase-1_base.png` (+ `_back`/`_side`) — Motion, bez zmian.
- `nemorax_telegraph.png`, `nemorax_lunge.png`, `nemorax_cast-pulse.png`,
  `nemorax_pull.png`, `nemorax_hit.png` — wspólne dla wszystkich faz, bez zmian.
- `nemorax_phase-transform.png`, `nemorax_large-form-collapse.png`,
  `nemorax_small-form-rebirth.png`, `nemorax_small-form-taunt.png`,
  `nemorax_small-form-true-death.png` — bez zmian, niezależne od fazy.
- Ołtarz (podłoga/ściana/gniazda/pedestał) — bez zmian, mechanika
  LOCKED/READY/ACTIVATING jest czysto kodowa (gniazda jaśnieją przez
  `modulate`, nie potrzebują nowej grafiki "zapełnione").

### 1.5 Opcjonalne, NIE blokujące (do rozważenia później)

Dominion strzela pociskami i stawia strefę obrażeń — dziś to jest
`entities/enemy_projectile.gd`/`entities/damage_zone.gd`, reużywające
istniejące tekstury (pocisk różdżki gracza, pieczęć Szóstego Rytmu). Jeśli
chcesz dedykowany wygląd pocisku/strefy specyficzny dla Nemoraksa (nie
reużyty), to osobna, mała, opcjonalna partia — nie jest wymagana do działania.

---

## 2. Reszta pakietu — już wysłana, wciąż aktualna

Poniższe dwa pliki są już w projekcie i **nic w nich się nie zmieniło** —
mechanika, którą opisują, jest zaimplementowana dokładnie tak, jak tam
napisano:

- **`PROMPTY_WROGOW_LOSOWYCH_I_SKRZYNI.md`** — 12 archetypów wrogów losowych
  (sekcja A), skrzynia (sekcja B), 8 motywów pokoi (sekcja C). Mechanika za
  tym stoi jest już wdrożona i przetestowana (`entities/random_enemies/*.gd`).
- **`PLAN_ANIMACJE_KIERUNKOWE.md`** — system 5 kątów + cykl chodu (Faza 1b,
  91 obrazków) i pełny zakres ruchu dla wszystkich pozostałych póz (Fazy 3-5,
  252 obrazki). Kod jest gotowy i czeka na te obrazki dla WSZYSTKICH postaci
  (gracz, 6 wcieleń, Nemorax) — łącznie z 5 nowymi bazami Nemoraksa z sekcji 1
  powyżej, kiedy już powstaną.

---

## 3. Zalecana kolejność generowania (zgodnie z Twoją radą — bez marnowania obrazków)

1. **Najpierw: 5 nowych baz Nemoraksa** (sekcja 1.3 powyżej) — to
   najważniejsza, najbardziej widoczna zmiana tożsamości bossa. Oceń, czy
   wygląd pasuje do nowych faz, zanim pójdziesz dalej.
2. **Potem: 12 wrogów + skrzynia + 8 motywów pokoi** (`PROMPTY_WROGOW_LOSOWYCH_I_SKRZYNI.md`)
   — mechanika tego już stoi, więc to bezpieczne do zamówienia od razu po (1).
3. **Na końcu: pełny system 5 kątów + cykl chodu** (`PLAN_ANIMACJE_KIERUNKOWE.md`)
   — dopiero gdy (1) i (2) są zatwierdzone wizualnie, żeby nie generować
   4-5 wariantów kąta dla wyglądu, który i tak jeszcze się zmieni.

Wszystko poza sekcją 1 tego pliku jest już gotowe do wklejenia bez zmian —
ten plik istnieje tylko po to, żeby dodać brakujący kawałek (nowe fazy
Nemoraksa) i ustawić kolejność.
