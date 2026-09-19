# NEMORAX — Pozy do animacji: PEŁNY komplet (uniwersalne + unikalne umiejętności + poprawka)

Rozszerzenie poprzedniej wersji tego pliku. Poprzednio: tylko uniwersalny
zestaw 7 póz, wspólny dla wszystkich siedmiu postaci, bo tyle wystarczyło na
start. Teraz — **komplet**: te same 7 uniwersalnych + osobna, unikalna poza
dla KAŻDEGO z sześciu wcieleń (bo każde ma inną sygnaturalną sztuczkę w
kodzie, nie tylko przemalowany wspólny szablon) + pięć dodatkowych stanów
specyficznych dla Nemoraxa (transformacja, upadek dużej formy, odrodzenie
małej formy, kpina, prawdziwa śmierć) + jedna poprawka pliku, który już masz.

Masz już bazowe referencje: 7 czystych obrazków postaci (Vhar'Nokh, Mordrath,
Zha'Ruun, Nekravor, Thal'Gor, Orryx, Nemorax) w `01_characters`. Ten plik
mówi dokładnie, jakich POZ jeszcze brakuje, i jak o nie prosić, żeby żadna
postać nie "popłynęła" (nie zmieniła proporcji/kolorów/detali) między
osobnymi generacjami.

---

## 0. Zanim zaczniesz pozy — jedna poprawka do już dostarczonego pliku

`08_end_screens/death_screen_frame.png` ma dziś w pełni nieprzezroczyste tło
(sprawdzone technicznie: kanał alfa = 255, czyli pełna krycie, w całym
środku obrazka), podczas gdy bliźniaczy `victory_screen_frame.png` ma
poprawną przezroczystość na środku. Efekt: w silniku ramka zwycięstwa
nałoży się NA scenę gry, a ramka śmierci zamiast tego zamaluje wszystko pod
sobą na czarno. To NIE jest nowa poza — to regeneracja TEGO SAMEGO obrazka,
z tym samym pomysłem graficznym, tylko z realną przezroczystością:

> A decorative dark vignette frame for a game death screen, cracked
> crumbling bone creeping in from all four corners, dripping near-black dark
> red essence trailing toward the center, ornate border only. The entire
> center area must be fully transparent (alpha channel), not painted black —
> only the bone/blood border geometry should have any opacity, exactly like
> a PNG cutout frame. No solid background fill anywhere. No text itself, no
> watermark, transparent background.

---

## 1. Najważniejsza zasada: generuj z referencją, nie z opisu od zera

Jeśli poprosisz bota o "Vhar'Nokha w pozie ataku" bez podania obrazka, dostaniesz
PODOBNĄ, ale nie TĘ SAMĄ postać (inne proporcje rogów, inny odcień, inne
detale pancerza). To dokładnie sprawdzona, działająca metoda — tak właśnie
powstał cały komplet 11 póz gracza, bez żadnego "płynięcia" designu. Dla
KAŻDEJ nowej pozy poniżej, dla KAŻDEJ z siedmiu postaci:

1. **Wgraj/załącz już gotowy obrazek tej postaci** jako referencję do wiadomości
   (bazowy z `01_characters`, albo dowolna już wygenerowana poza tej samej postaci).
2. Użyj promptu w formie:

> Using the attached image as the exact reference for [NAZWA]'s design — same
> proportions, same colors, same materials, same markings, same accent glow
> color — regenerate this exact same creature in a new pose: [OPIS POZY
> PONIŻEJ]. Keep the identical art style, lighting, camera angle and framing
> as the reference. Transparent background, no text, single character, no
> other changes to the design.

3. Rób **jedną pozę na raz**, jedno zapytanie = jeden obrazek. Proszenie o cały
   arkusz póz naraz kończy się bałaganem (mieszanka wariantów, tekst,
   ignorowanie części instrukcji) — dokładnie to, co się już raz przydarzyło.

---

## 2. Priorytety — kolejność, w jakiej to robić

1. **Poprawka z sekcji 0** (jeden obrazek, 2 minuty roboty).
2. **Uniwersalne "konieczne 4"** (sekcja 3.1-3.2, 3.jeden atak wg wyboru, 3.7) ×
   7 postaci (6 wcieleń + Nemorax) = **28 obrazków** — z tym gra "żyje"
   wizualnie w każdym pokoju.
3. **Unikalne umiejętności** (sekcja 4) — po jednej na wcielenie = **6
   obrazków** — to jest właśnie "animacja skilli" per postać, nie tylko
   uniwersalny szablon.
4. **Pozostałe uniwersalne warianty** (sekcja 3.3-3.6 w całości) × 7 = **21
   obrazków**, dla kompletu wszystkich trzech typów ataku + trafiony.
5. **Stany finałowe Nemoraxa** (sekcja 5) — **5 obrazków**, bo Nemorax
   dodatkowo przechodzi transformację i ma dwie formy (dużą i finałową małą),
   czego reszta wcieleń nie ma.

Razem to **61 nowych obrazków + 1 poprawka** — patrz podsumowanie w sekcji 6.

---

## 3. Uniwersalny zestaw póz (pasuje do wszystkich 7 postaci — referencja w promptcie i tak wymusi właściwy wygląd)

### 3.1 CHÓD / DRYFOWANIE (idle-walk)
Boss powoli sunie w stronę gracza cały czas między atakami — to najczęściej
widoczna poza w grze.
> ...regenerate this exact same creature in a mid-stride walking/advancing
> pose, leaning slightly forward as if slowly closing distance on a target,
> one side of the body advanced ahead of the other, calm but purposeful.

### 3.2 ZAPOWIEDŹ (telegraph) — KRYTYCZNE, gracz musi to rozpoznać
Krótka chwila przed każdym atakiem — MUSI wyraźnie różnić się od spoczynku,
bo to jedyne ostrzeżenie dla gracza (zasada z dokumentu: żaden atak nie trafia
bez zapowiedzi).
> ...regenerate this exact same creature in a tense wind-up/anticipation pose
> right before attacking — body coiled or drawn back, its glowing accent
> color visibly brighter and more intense than normal, unmistakably readable
> as "something is about to happen".

### 3.3 ATAK — SZARŻA / WYPAD (lunge)
Do umiejętności, gdzie stworzenie rzuca się/rusza gwałtownie w stronę gracza.
> ...regenerate this exact same creature in an aggressive forward-charging
> lunge pose, body thrust toward the viewer, claws/jaw/limbs extended
> aggressively, strong sense of fast forward motion.

### 3.4 ATAK — WYBUCH MOCY (cast/pulse)
Do umiejętności, gdzie stworzenie stoi w miejscu i wysyła falę obrażeń wokół
siebie.
> ...regenerate this exact same creature in a stationary casting pose, arms
> or limbs spread or raised, releasing a burst of its glowing accent-colored
> energy outward in all directions around itself.

### 3.5 ATAK — PRZYCIĄGANIE (pull)
Do umiejętności, gdzie stworzenie siłą przyciąga gracza bliżej.
> ...regenerate this exact same creature in a reaching/grasping pose, one or
> both limbs extended toward the viewer as if forcefully pulling something
> closer, glowing accent-colored energy trailing from the outstretched limb.

### 3.6 TRAFIONY (hit reaction)
> ...regenerate this exact same creature in a recoiling, flinching pose as if
> just struck — body pulled back and off-balance, momentarily vulnerable.

### 3.7 ŚMIERĆ (death)
> ...regenerate this exact same creature in a collapsing, defeated death
> pose — the creature falling apart or dissolving into wisps of its glowing
> accent-colored essence, losing physical cohesion.

---

## 4. Unikalne pozy umiejętności — po jednej na wcielenie (to jest brakująca "animacja skilli", nie tylko uniwersalny szablon)

Każde wcielenie ma w kodzie 3 umiejętności zbudowane z tych samych trzech
klocków powyżej (szarża/wybuch/przyciąganie) — ALE każde ma też własną,
unikalną sztuczkę, której uniwersalny zestaw nie pokazuje. Bez tej pozy gra
wciąż "działa", ale najbardziej charakterystyczny moment każdego bossa
(ten, który go odróżnia od reszty) nie ma własnej grafiki.

### 4.1 Vhar'Nokh — TELEPORT / BLINK (`_teleport_near_player`, `zalazek.gd:36`)
Używane w "niestabilnym wybuchu" i "podwójnym mgnieniu" — jedyne wcielenie,
które fizycznie znika i pojawia się gdzie indziej.
> ...regenerate this exact same creature caught mid-teleport, its form
> dissolving into sharp glowing magenta-pink fragments and motes on one
> side while reforming solid on the other, as if blinking between two points
> in space.

### 4.2 Mordrath — TŁUMIONY WYBUCH (silence pulse, `cisza_incarnation.gd:19`)
Ten sam "wybuch mocy" co reszta, ale tematycznie MUSI wyglądać inaczej —
wygaszony, duszący, zamiast ostrego rozbłysku.
> ...regenerate this exact same creature releasing its silencing pulse — a
> slow-motion muffled shockwave, sound-deadening ripples visibly absorbing
> and smothering the air around it, its orange glow noticeably dampened and
> muted compared to a normal burst, oppressive quiet instead of violence.

### 4.3 Zha'Ruun — ECHO / STUTTER (`zwloka_incarnation.gd:21`, opóźniony drugi pulse)
Sygnaturalna sztuczka: powtórka tego samego ataku z opóźnieniem, jakby czas
się zaciął.
> ...regenerate this exact same creature mid-echo-pulse, a faint ghostly
> duplicate afterimage of itself slightly offset and delayed just behind its
> real body, both original and echo glowing purple-magenta, as if time is
> stuttering and repeating around it.

### 4.4 Nekravor — ZGNIOT (crush pulse, `ciezar_incarnation.gd:28`)
Większy zasięg, cięższy niż zwykły wybuch — sam grawitacyjny ciężar zamiast
przyciągania.
> ...regenerate this exact same creature in a crushing downward stance,
> limbs pressed inward and hunched low as if bearing immense gravitational
> weight, loose debris being crushed toward it from all directions,
> blue-violet energy radiating outward in a heavier, slower burst than a
> normal pulse.

### 4.5 Thal'Gor — UGRYZIENIE / WYSYSANIE (lifesteal na kontakt, `glod_incarnation.gd:33-44`)
Jedyne wcielenie, które leczy się kosztem gracza — zasługuje na własny,
drapieżny moment.
> ...regenerate this exact same creature mid-bite, jaws or a feeding
> appendage clamped onto something, sickly green life-essence visibly
> draining away and flowing back into its own body, hungry and predatory.

### 4.6 Orryx — POWRÓT Z NICOŚCI (reappear, `zacmienie_incarnation.gd:34`)
Uzupełnienie do już opisanej niżej (sekcja 4.7 poniżej to ZNIKANIE) — ale
znikanie bez powrotu to tylko połowa sztuczki.
> ...regenerate this exact same creature caught in the instant of
> reappearing, materializing suddenly out of dark wisps of smoke right in
> front of the viewer, still slightly translucent at the edges, sudden and
> startling.

### 4.7 Orryx — ZNIKANIE (vanish, `zacmienie_incarnation.gd:27`)
> ...regenerate this exact same creature turning semi-transparent mid-vanish,
> its shadow form dissipating into loose wisps of smoke, about to disappear.

*(Orryx dostaje dwie unikalne pozy zamiast jednej — vanish i reappear to
dwie połówki tej samej sztuczki, obie warte osobnej grafiki.)*

---

## 5. Nemorax — dodatkowe stany specyficzne dla finałowego bossa

Nemorax przechodzi przez rzeczy, których żadne wcielenie nie robi: zmienia
fazę (transformacja), "umiera" w formie dużej tylko po to, żeby wrócić w
formie małej, i dopiero POTEM naprawdę ginie albo wygrywa. Uniwersalny
zestaw (sekcja 3) pokrywa jego zwykłe ataki i zwykłą śmierć/trafienie — te
pięć poniżej pokrywa wszystko, czego zwykły zestaw nie może pokazać.

### 5.1 Transformacja fazy (`_start_transform_invulnerability`, `boss.gd:313`)
Już dziś ma w kodzie towarzyszący screen shake — grafika powinna pasować do
tej gwałtowności.
> ...regenerate this exact same hybrid creature mid-transformation, its form
> violently shifting and warping, fragments of all six incarnation colors
> flickering across its body simultaneously, unstable and overwhelming, a
> brief moment of pure chaotic energy.

### 5.2 Upadek dużej formy — NIE finałowy (`boss.gd:294-303`, branch niefinałowy)
To nie jest sekcja 3.7 (prawdziwa śmierć) — to pozorna śmierć, po której
wraca mała forma. Musi się wizualnie różnić od 5.5 (prawdziwa śmierć).
> ...regenerate this exact same hybrid creature collapsing and losing
> physical cohesion, its massive form breaking apart into drifting embers of
> all six incarnation colors — but clearly NOT fully destroyed, a sense that
> something smaller survives within the collapse.

### 5.3 Odrodzenie małej formy (`start_final_phase`, `boss.gd:327`)
Kontrast z 5.2: mniejsza, słabsza, ale wciąż niepokojąca.
> ...regenerate this exact same creature but shrunk down to a small, frail,
> almost childlike remnant form, hunched and diminished compared to its
> earlier massive body, faint dying embers of color flickering weakly across
> it, unsettling despite its smaller size.

### 5.4 Kpina / pytanie finałowe (taunt, `arena.gd:137-140`, gracz ma odwrócone sterowanie)
Moment, w którym Nemorax pyta gracza "czy pamiętasz, ile razy już mnie
pokonałeś" — mała forma z 5.3, ale w konkretnej, prowokującej pozie.
> ...regenerate this exact same small final-phase creature tilting its head
> as if mocking the viewer, an unsettling knowing posture despite its
> frailty, quietly self-assured.

### 5.5 Prawdziwa śmierć (`died.emit(true)`, `boss.gd:299`)
Ostateczny koniec walki — musi wyglądać bardziej ostatecznie niż 5.2.
> ...regenerate this exact same small final-phase creature dissolving
> completely and finally, every last ember of colored light fading to
> nothing, a true and permanent end, no remaining form.

---

## 6. Ile to razem obrazków

- Poprawka (sekcja 0): **1**
- Uniwersalne, konieczne 4 × 7 postaci: **28**
- Unikalne umiejętności (sekcja 4, Orryx liczony podwójnie): **7**
- Pozostałe uniwersalne warianty (2 ataki + trafiony) × 7: **21**
- Nemorax, stany finałowe (sekcja 5): **5**

**Razem: 62 nowe/poprawione obrazki.** Rób w kolejności z sekcji 2 — po
"koniecznych 28" gra już wygląda kompletnie w każdym pokoju, reszta
dopełnia komplet.
