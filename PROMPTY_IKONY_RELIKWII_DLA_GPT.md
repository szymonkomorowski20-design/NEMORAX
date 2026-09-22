# NEMORAX — ikony relikwii (10 sztuk): specyfikacja i prompty dla GPT

## Po co to jest

Karta relikwii (pojawia się na dole ekranu po otwarciu skrzyni, ok. 1,5–2,5 s)
ma wyglądać tak:

```text
         [ ikona ]
       SECOND IMPACT
 Następny cios po trafieniu zadaje...
```

Dziś nie ma żadnej ikony — kod jest gotowy i czeka wyłącznie na te 10 plików.
(Te same ikony przydadzą się później też w "Księdze Runu", zakładka Relikwie —
jedna grafika, dwa miejsca użycia, nie trzeba nic dodatkowo generować.)

## Techniczne (dopasowane do już istniejących ikon w grze, dash_icon.png/
heal_icon.png)

- **Rozmiar płótna**: 1024×1024 px, PNG, przezroczyste tło.
- **Wypełnienie kadru**: art powinien zajmować **min. 85–90% płótna**, nie
  ~65% jak przy heal_icon.png/dash_icon.png — tamte dwie mają tak duży margines
  przezroczystości dookoła, że w kodzie trzeba było ręcznie mierzyć i wpisywać
  "prawdziwy" prostokąt treści (osobna stała w ui/ui.gd), żeby ikonka nie
  wychodziła 2× mniejsza niż zamierzona. Mniejszy margines = mniej ręcznej
  roboty przy podpinaniu.
- **Nazwy plików** (dokładnie te, kod czyta je 1:1 po ID relikwii):
  `relic_blood_edge.png`, `relic_void_step.png`, `relic_soul_echo.png`,
  `relic_iron_heart.png`, `relic_razor_wind.png`, `relic_hunters_mark.png`,
  `relic_second_impact.png`, `relic_momentum.png`, `relic_last_resolve.png`,
  `relic_soul_bond.png`
- Folder docelowy: `assets/sprites/ui/` (płaska struktura, bez podfolderów —
  tak samo jak dash_icon.png/heal_icon.png/bary HUD-u).
- Jeden statyczny obraz na relikwię — bez animacji, bez wariantów kierunkowych.

## Wspólny styl (dokleić do KAŻDEGO promptu poniżej)

> Dark fantasy game item icon, painterly digital illustration, centered
> composition filling nearly the entire square canvas, clean bold readable
> silhouette designed to be recognizable at small HUD size (40-60px), plain
> transparent background, no text, no watermark, no border/frame baked into
> the image (frame will be added separately in-engine). Dark neutral base
> materials (obsidian black, bone white, charcoal, aged bronze/gold) with ONE
> glowing accent color per icon (see each entry below) applied to the core
> symbol only — not a full-color illustration.

Paleta gry (dla kontekstu — akcent NA IKONIE ma być ciepły/złoty niezależnie
od tego neutralnego tła, bo złoto = kolor nagród w tej grze; drugi, tematyczny
akcent koloru z tabeli niżej podkreśla konkretny efekt):
- Tło poza areną: `#1A1026` · Podłoga: `#2A1B3D` · Ściany: `#3E2A57`
- Gracz (cyjan): `#5BE0C8` · Zagrożenie/obrażenia (żółty-pomarańcz): `#FFC857`
- Złoto nagród (użyj jako głównego akcentu ramki/blasku na WSZYSTKICH 10):
  `#E8C547`

## 10 relikwii — mechanika (żeby ikona pokazywała PRAWDZIWY efekt, nie zgadywała)

Każdy wpis: nazwa w grze, co faktycznie robi (dokładne liczby z kodu), sugerowany
motyw wizualny, dodatkowy akcent koloru (obok złota z sekcji wyżej).

### 1. `relic_blood_edge.png` — BLOOD EDGE
**Efekt**: trafienie uzbraja relikwię; NASTĘPNY zamach dostaje +20% obrażeń
(uzbrojenie wygasa po 4s, jeśli nie zużyte).
**Motyw**: ostrze miecza z cienką linią jarzącej się krwistoczerwonej energii
biegnącej wzdłuż krawędzi, jakby "naładowane" i gotowe do ciosu — napięcie,
nie sam akt cięcia.
**Akcent**: krwistoczerwony (`#B3283D`-ish).

### 2. `relic_void_step.png` — VOID STEP
**Efekt**: po zakończeniu dasha — 1,25s +15% prędkości biegu ORAZ jeden
najbliższy zamach z +20% zasięgu (do 3s).
**Motyw**: rozmyty ślad/poświata kroku rozpadająca się na fioletowo-fioletowe
drobiny, jakby ktoś przeszedł przez pęknięcie w przestrzeni — ruch i pustka
naraz.
**Akcent**: fioletowy otchłani (`#9B4DFF`-ish).

### 3. `relic_soul_echo.png` — SOUL ECHO
**Efekt**: 25% szansy po ZABICIU wroga na +15% obrażeń przez 4s.
**Motyw**: widmowy odprysk duszy (mała, przezroczysta sylwetka/wir światła)
odrywający się od ginącego wroga i wsiąkający w broń gracza.
**Akcent**: chłodny błękit-biel widma (`#C8E8FF`-ish).

### 4. `relic_iron_heart.png` — IRON HEART
**Efekt**: TRWAŁE (od zdobycia) +20% max zdrowia, -25% odpychania
OTRZYMYWANEGO.
**Motyw**: serce z żelaza/kamienia, nitowane płyty pancerza, wygląda ciężko i
niewzruszenie — coś, co stoi w miejscu, gdy inni są odpychani.
**Akcent**: przygaszony metaliczny szary/brąz (`#8A7A6A`-ish), NIE czerwony
(to nie jest o krwi, tylko o wytrzymałości).

### 5. `relic_razor_wind.png` — RAZOR WIND
**Efekt**: TRWAŁE (od zdobycia) +18% zasięgu ataku mieczem.
**Motyw**: sierp/łuk wiatru wycięty jak ostrze, wydłużony ponad typowy zasięg
cięcia — widoczne ciśnienie powietrza jako krawędź, nie sam miecz.
**Akcent**: chłodna biel-cyjan wiatru (`#D8F5F0`-ish).

### 6. `relic_hunters_mark.png` — HUNTER'S MARK
**Efekt**: pierwsze trafienie zakłada znak na celu (5s); kolejne trafienia W
TEN SAM cel, dopóki znak trwa, dostają +12% obrażeń.
**Motyw**: jarzący się runiczny znak/pieczęć w kształcie zawężającego się oka
lub celownika — coś, co "przykleja się" do ofiary, nie broń gracza.
**Akcent**: jadowita zieleń-żółć (`#C8D84D`-ish) — inny odcień niż złoto
nagród, żeby nie mylić się z resztą.

### 7. `relic_second_impact.png` — SECOND IMPACT
**Efekt**: 30% szansy na dodatkowe, opóźnione (ok. 0,14s) trafienie za 45%
obrażeń pierwszego ciosu.
**Motyw**: DWA nakładające się na siebie łuki cięcia, lekko przesunięte w
czasie/przestrzeni (jak podwójna ekspozycja) — czytelne jako "echo ciosu",
nie jeden zwykły zamach.
**Akcent**: złoto nagród + biały błysk na drugim, słabszym łuku.

### 8. `relic_momentum.png` — MOMENTUM
**Efekt**: co 2s BEZ obrażeń otrzymanych — +1 stack (+2% prędkości, max 5
stacków = +10%); JEDNO trafienie zeruje wszystkie stacki.
**Motyw**: narastający, przyspieszający spiralny ślad/strzałki ułożone w
rosnący stos (jak wskaźnik prędkościomierza) — coś, co WYRAŹNIE wygląda na
kruche/łatwe do przerwania, nie trwały bonus.
**Akcent**: elektryczny turkus przyspieszenia (`#5BE0C8`-ish, ten sam co
gracz — to bonus DO gracza).

### 9. `relic_last_resolve.png` — LAST RESOLVE
**Efekt**: aktywuje się przy HP ≤30% max (dezaktywuje dopiero >35%, żeby nie
migało): +20% obrażeń, +10% szybkości ataku.
**Motyw**: pękająca, prawie zgaszona żagiew/skorupa z JEDNYM uparcie płonącym
rdzeniem w środku — "ostatni opór", desperacka siła, nie triumfalny ogień.
**Akcent**: gasnąca pomarańcz-czerwień (`#FFC857`→`#B3283D` gradient), zgodnie
z kolorem zagrożenia w palecie gry.

### 10. `relic_soul_bond.png` — SOUL BOND
**Efekt**: aktywuje się w chwili PODNIESIENIA fragmentu duszy (nie pokonania
wcielenia); daje tematyczny bonus na 8s zależny od TEGO, którą z 6 dusz
podniesiono (nowa dusza NADPISUJE poprzedni bonus). Ikona reprezentuje sam
MECHANIZM WIĘZI, nie konkretny rozdział — nie ma jednego "prawidłowego"
koloru fragmentu do pokazania.
**Motyw**: dwie splecione, cienkie nici światła łączące fragment duszy
(mała, wielokątna bryła/kryształ) z symbolem gracza/serca — chwilowa,
widoczna więź, nie stały obiekt.
**Akcent**: neutralna biel-złoto (`#F0E8D8`-ish) — celowo stonowany, bo
faktyczny kolor bonusu zmienia się co dusza.

## Kolejność, jeśli wolisz dawkować

Jeśli 10 na raz to za dużo na jeden przebieg: **Second Impact, Blood Edge,
Iron Heart, Hunter's Mark** są używane/testowane najczęściej w tej chwili —
te cztery jako pierwsze dają najszybszy efekt w grze.
