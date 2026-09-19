# NEMORAX — Pozy do animacji dla już wygenerowanych postaci

Masz już 7 czystych obrazków referencyjnych (Vhar'Nokh, Mordrath, Zha'Ruun,
Nekravor, Thal'Gor, Orryx, Nemorax). Ten plik mówi dokładnie, jakich POZ
potrzeba do animacji w grze, i jak o nie prosić, żeby postać nie "pływała"
(nie zmieniała proporcji/kolorów/detali) między osobnymi generacjami.

---

## 0. Najważniejsza zasada: generuj z referencją, nie z opisu od zera

Jeśli poprosisz bota o "Vhar'Nokha w pozie ataku" bez podania obrazka, dostaniesz
PODOBNĄ, ale nie TĘ SAMĄ postać (inne proporcje rogów, inny odcień, inne
detale pancerza). Zamiast tego, dla KAŻDEJ nowej pozy:

1. **Wgraj/załącz już gotowy obrazek tej postaci** jako referencję do wiadomości.
2. Użyj promptu w formie:

> Using the attached image as the exact reference for [NAZWA]'s design — same
> proportions, same colors, same materials, same markings, same accent glow
> color — regenerate this exact same creature in a new pose: [OPIS POZY
> Z SEKCJI 2 PONIŻEJ]. Keep the identical art style, lighting, camera angle
> and framing as the reference. Transparent background, no text, single
> character, no other changes to the design.

3. Rób **jedną pozę na raz**, jedno zapytanie = jeden obrazek. Proszenie o cały
   arkusz póz naraz zwykle kończy się bałaganem (mieszanka wariantów, tekst,
   ignorowanie części instrukcji) — dokładnie to, co już Ci się przydarzyło.

---

## 1. Priorytety — nie musisz robić wszystkiego na raz

**Konieczne (4 nowe obrazki na postać)**: CHÓD, ZAPOWIEDŹ, jeden ATAK
(dowolny z trzech niżej), ŚMIERĆ. Z tym gra już "żyje".

**Dodatkowe, jeśli starczy cierpliwości**: pozostałe dwa warianty ataku,
TRAFIONY. Orryx dodatkowo ma unikalną pozę ZNIKANIA (sekcja 3).

---

## 2. Uniwersalny zestaw póz (te same opisy pasują do wszystkich 7 postaci —
opis referencji w promptcie i tak wymusi właściwy wygląd)

### 2.1 CHÓD / DRYFOWANIE (idle-walk)
Boss powoli sunie w stronę gracza cały czas między atakami — to najczęściej
widoczna poza w grze.
> ...regenerate this exact same creature in a mid-stride walking/advancing
> pose, leaning slightly forward as if slowly closing distance on a target,
> one side of the body advanced ahead of the other, calm but purposeful.

### 2.2 ZAPOWIEDŹ (telegraph) — KRYTYCZNE, gracz musi to rozpoznać
Krótka chwila przed każdym atakiem — MUSI wyraźnie różnić się od spoczynku,
bo to jedyne ostrzeżenie dla gracza (zasada z dokumentu: żaden atak nie trafia
bez zapowiedzi).
> ...regenerate this exact same creature in a tense wind-up/anticipation pose
> right before attacking — body coiled or drawn back, its glowing accent
> color visibly brighter and more intense than normal, unmistakably readable
> as "something is about to happen".

### 2.3 ATAK — SZARŻA / WYPAD (lunge)
Do umiejętności, gdzie stworzenie rzuca się/rusza gwałtownie w stronę gracza.
> ...regenerate this exact same creature in an aggressive forward-charging
> lunge pose, body thrust toward the viewer, claws/jaw/limbs extended
> aggressively, strong sense of fast forward motion.

### 2.4 ATAK — WYBUCH MOCY (cast/pulse)
Do umiejętności, gdzie stworzenie stoi w miejscu i wysyła falę obrażeń wokół
siebie.
> ...regenerate this exact same creature in a stationary casting pose, arms
> or limbs spread or raised, releasing a burst of its glowing accent-colored
> energy outward in all directions around itself.

### 2.5 ATAK — PRZYCIĄGANIE (pull)
Do umiejętności, gdzie stworzenie siłą przyciąga gracza bliżej.
> ...regenerate this exact same creature in a reaching/grasping pose, one or
> both limbs extended toward the viewer as if forcefully pulling something
> closer, glowing accent-colored energy trailing from the outstretched limb.

### 2.6 TRAFIONY (hit reaction) — opcjonalne
> ...regenerate this exact same creature in a recoiling, flinching pose as if
> just struck — body pulled back and off-balance, momentarily vulnerable.

### 2.7 ŚMIERĆ (death)
> ...regenerate this exact same creature in a collapsing, defeated death
> pose — the creature falling apart or dissolving into wisps of its glowing
> accent-colored essence, losing physical cohesion.

---

## 3. Uwagi specyficzne dla pojedynczych postaci

**Orryx** — dodatkowa, unikalna poza (jego sygnaturalna sztuczka to znikanie):
> ...regenerate this exact same creature turning semi-transparent mid-vanish,
> its shadow form dissipating into loose wisps of smoke, about to disappear.

**Nemorax** — na razie w grze ma te same 3 typy ataku co reszta (sekcja 2.3-2.5)
plus zwykły kontakt — NIE potrzebuje jeszcze 6 osobnych ataków "per część ciała"
z LORE_I_ASSETY.md (to pomysł na później, gdy dojdzie animacja per-atak w
kodzie). Na razie wystarczy mu ten sam uniwersalny zestaw co reszcie.

---

## 4. Ile to razem obrazków

7 postaci × 4 konieczne pozy = **28 obrazków** na start (plus 7 już masz =
5 póz na postać w sumie). Dodatkowe warianty ataku + trafiony to kolejne
3 × 7 = 21, jeśli zechcesz kompletu.
