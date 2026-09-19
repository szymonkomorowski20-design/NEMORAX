# NEMORAX — Sześć Wcieleń (dokument planistyczny, roboczy)

Ten plik to notatnik roboczy do zaprojektowania rozszerzenia gry: korytarz sześciu
pomieszczeń z sześcioma wcieleniami hybrydy, fragmenty duszy, ołtarz, i finałowy
Nemorax jako suma wszystkich sześciu. Wypełniamy go razem, wcielenie po wcieleniu.
Nie jest to jeszcze specyfikacja do implementacji — to szkic do rozmowy.

---

## 0. Ustalenia techniczne

- **Styl wizualny: prawdziwe sprite'y 2D** (zmiana z pierwotnego "wszystko rysowane
  kodem" — świadoma decyzja autora dla tego rozszerzenia).
- Ja nie generuję grafiki — przygotowuję specyfikacje (wymiary, klatki, nazwy plików,
  gdzie w projekcie mają trafić) i podpinam gotowe pliki, które dostarczysz.
- Format docelowy: prawdopodobnie PNG (spritesheet albo osobne klatki) +
  `AnimatedSprite2D`/`SpriteFrames` w Godocie. Doprecyzujemy przy pierwszym wcieleniu.
- Folder na assety: `assets/sprites/...` (do ustalenia dokładna struktura, gdy
  będzie wiadomo, ile stanów animacji potrzebuje każda istota).

## 1. Nemorax — obecne umiejętności (przypomnienie z dokumentu bazowego)

Sześć faz/reguł, które finałowa hybryda ma w sobie łączyć:

| # | Faza | Reguła / umiejętność | Kolor (obecny) |
|---|---|---|---|
| 1 | (bez formy) | brak modyfikatora, faza nauki | `#F0447A` |
| 2 | Cisza | cały dźwięk wyciszony do końca walki | `#FF8A3D` |
| 3 | Zwłoka | dash_cooldown gracza x2 | `#C44FD6` |
| 4 | Ciężar | stałe przyciąganie gracza w stronę bossa | `#6C63FF` |
| 5 | Głód | boss regeneruje HP, jeśli nie trafiony przez chwilę | `#7ED957` |
| 6 | Zaćmienie | zawężone pole widzenia wokół gracza | `#C9C2B4` |

Plus ataki uniwersalne (niezależne od fazy): Szósty Rytm (pieczęcie), Ząb Zera
(strefa blokująca dash), Kradzież Intencji (cień), Wypad (kontakt fizyczny).

**Pomysł roboczy**: każde z 6 wcieleń dostaje jako AKTYWNĄ, SYGNATURALNĄ
umiejętność to, co u Nemoraxa jest dziś pasywną regułą fazy — np. wcielenie
"Cisza" mogłoby aktywnie wyciszać/oślepiać gracza na chwilę, zamiast tylko
głuszyć dźwięk. Do ustalenia przy każdym wcieleniu osobno.

## 2. Sześć wcieleń — szablon (do wypełnienia jedno po drugim)

### Wcielenie 1 — [nazwa]
- **Nawiązanie do fazy Nemoraxa**: ?
- **Umiejętność sygnaturalna**: ?
- **Cechy szczególne / zachowanie**: ?
- **Motyw wizualny / sylwetka**: ?
- **Pokój**: wygląd otoczenia, klimat ?
- **Fragment duszy (item)**: wygląd, jak wypada ?

### Wcielenie 2 — [nazwa]
(jak wyżej)

### Wcielenie 3 — [nazwa]
(jak wyżej)

### Wcielenie 4 — [nazwa]
(jak wyżej)

### Wcielenie 5 — [nazwa]
(jak wyżej)

### Wcielenie 6 — [nazwa]
(jak wyżej)

## 3. Pokój 7 — Ołtarz

- Wygląd ołtarza, rytuał złożenia 6 fragmentów duszy?
- Co dokładnie widać/dzieje się przy przywołaniu Nemoraxa?

## 4. Nemorax — wygląd finałowy jako hybryda

- Jak sylwetka/wygląd ma łączyć cechy wszystkich sześciu wcieleń?

## 5. Gracz i ekwipunek

- Wygląd postaci gracza (dziś: kropka cyjanowa)
- Wygląd miecza w ręce / zamachu
- Wygląd różdżki / pocisku

---

*Status: pusty szkielet, czekamy na pierwsze wcielenie.*
