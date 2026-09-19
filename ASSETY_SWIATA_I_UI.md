# NEMORAX — Kompletny katalog tekstur (świat, efekty, UI, menu)

Uzupełnienie [LORE_I_ASSETY.md](LORE_I_ASSETY.md), które pokrywa TYLKO sześć
wcieleń, Nemoraxa, gracza, miecz i różdżkę. Ten plik to WSZYSTKO INNE, co dziś
jest rysowane kodem (koła/prostokąty) i docelowo powinno dostać teksturę —
przeszedłem cały projekt plik po pliku, więc to ma być kompletna lista, nic
więcej nie zostało pominięte.

Status: gotowe prompty, czekają na wygenerowanie.

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
> Dark fantasy game UI element, ornate worn dark metal or bone frame, glowing
> neon accent fill, flat clean icon/bar style readable at small size, no text,
> transparent background.

Paleta (przypomnienie): tło `#1A1026`, podłoga `#2A1B3D`, ściany `#3E2A57`,
gracz `#5BE0C8`, obrażenia/zagrożenie `#FFC857`, błysk `#FFFFFF`. Kolory faz/
wcieleń: `#F0447A` `#FF8A3D` `#C44FD6` `#6C63FF` `#7ED957` `#C9C2B4`.

---

## 1. Ataki bossów (obecnie rysowane w seal.gd / void_zone.gd / shadow.gd / boss.gd)

### 1.1 Pieczęć — Szósty Rytm (`seal.gd`)
Krąg-pułapka, zapowiedź (żółta, przezroczysta) → wybuch.
> A glowing magical rune-seal circle etched into the ground, radiating
> warning-yellow (#FFC857) light with a thin bright outline, ancient and
> ominous. [+ styl efektów]

### 1.2 Ząb Zera (`void_zone.gd`)
Nie zadaje obrażeń — celowo NIE żółta. Wnętrze niemal czarne (`#0B0810`),
kontur w kolorze aktualnej formy bossa.
> A perfectly circular void/rift in the ground, almost pure black interior
> (#0B0810), thin glowing rim in a shifting neon accent color, looks like a
> tear that swallows dashes/movement rather than deals damage. [+ styl efektów]

### 1.3 Cień — Kradzież Intencji (`shadow.gd`)
**Uwaga**: to dosłownie "gracz z przeszłości" — najprościej ODTWORZYĆ sprite
gracza (sekcja 5.1 w LORE_I_ASSETY.md) z 50% przezroczystością i żółtym
konturem, zamiast projektować osobną istotę. Nie trzeba osobnego promptu, jeśli
sprite gracza już istnieje — tylko wariant koloru/przezroczystości w silniku.

### 1.4 Wypad / kontakt fizyczny bossa (telegraf w `boss.gd`, `incarnation.gd`)
Kierunkowa zapowiedź przed rzutem/wypadem — dziś linia + pierścień.
> A sharp glowing warning streak/arrow on the ground showing an incoming charge
> direction, warning-yellow (#FFC857), aggressive and fast, fading trail.
> [+ styl efektów]

---

## 2. Gracz — dodatkowe efekty (poza samą postacią z LORE_I_ASSETY.md 5.1)

### 2.1 Ślad dasha (`player.gd`, `_trail`)
5 zanikających kopii sylwetki gracza.
> A fading translucent afterimage silhouette of a small hooded figure, cyan
> glow (#5BE0C8), motion-blur streak effect, dissolving trail. [+ styl efektów]

### 2.2 Wycinek ataku mieczem (`_draw_attack_sector`)
Żółty wycinek koła — zapowiedź/aktywne okno ciosu.
> A sharp glowing sword-slash arc effect, warning-yellow (#FFC857), clean wide
> swing shape, dynamic and fast. [+ styl efektów]

### 2.3 Ładowanie różdżki (`_draw_wand_charge`)
Mała iskra przy lufie różdżki przed strzałem.
> A small glowing charging spark/orb building up at a wand's tip, warning-
> yellow (#FFC857), crackling energy. [+ styl efektów]

---

## 3. Przedmioty i obiekty interaktywne pokoi

### 3.1 Drzwi (`rooms/door.gd`)
Wejście do bossa / wyjście dalej — ten sam obiekt w obu rolach.
> A tall ornate dark stone/bone archway doorway, glowing pale rim light
> (#C9C2B4), imposing and ancient, closed and open variants if possible.
> [+ styl efektów]

### 3.2 Dusza wcielenia (`rooms/soul.gd`)
Mały, pulsujący przedmiot do podniesienia (F) — już opisany per-wcielenie w
LORE_I_ASSETY.md (sekcja 2, "Fragment duszy" w każdym wpisie). Tu tylko
przypomnienie technicznej roli: mały, animowany (pulsowanie) sprite, 6
wariantów kolorystycznych (po jednym na wcielenie) LUB jeden generyczny sprite
tintowany kolorem w silniku.

### 3.3 Ołtarz (`rooms/altar.gd`)
Już opisany w LORE_I_ASSETY.md sekcja 3 (cała komnata). Dodatkowo osobno:
> A single ancient stone altar pedestal socket, empty and glowing faintly,
> ready to receive a soul fragment, dark carved stone. [+ styl efektów]

---

## 4. Otoczenie pokoi (podłoga/ściany, dziś płaskie kolory w `arena.gd`/`room.gd`)

Każdy z sześciu pokoi ma już opisany klimat w LORE_I_ASSETY.md (sekcja 2, pole
"Pokój" w każdym wpisie) — tu tylko techniczne przypomnienie, żeby dało się to
zrobić jako faktyczne tekstury podłogi/ściany zamiast płaskiego koloru:

| Pokój | Motyw ściany/podłogi |
|---|---|
| Vhar’Nokh | surowa, nieukończona architektura, wisząca geometria, mgła |
| Mordrath | wyściełana, tłumiąca komnata, grube fałdy materiału/kamienia |
| Zha’Ruun | ruiny z rozbitymi zegarami/klepsydrami wmurowanymi w ściany |
| Nekravor | przygniecione, zapadnięte sklepienie, wygięte kolumny |
| Thal’Gor | organiczne, mięsiste ściany jak wnętrze przełyku |
| Orryx | całkowicie czarna komnata, brak własnego oświetlenia |
| Ołtarz | okrągła kamienna komnata, sześć gniazd (LORE_I_ASSETY.md sekcja 3) |

Generyczny prompt na podłogę/ścianę (powtórzyć dla każdego motywu z tabeli,
podmieniając opis):
> Seamless tileable dark stone dungeon floor/wall texture, [motyw z tabeli],
> viewed from directly above, subtle accent glow in [kolor wcielenia].
> [+ styl otoczenia]

Tło poza areną (`Palette.BACKGROUND`, dziś płaski kolor `#1A1026`) — opcjonalnie:
> A near-black void background texture with very faint distant nebula-like
> texture, extremely subtle, almost solid dark purple-black. [+ styl otoczenia]

---

## 5. UI (`ui/ui.gd`) — dziś proste prostokąty/łuki rysowane kodem

### 5.1 Pasek życia gracza
> A horizontal fantasy game health bar frame, dark worn metal border, empty
> fill slot, cyan (#5BE0C8) glow along the frame edge. [+ styl UI]

### 5.2 Pasek życia bossa
> A wide horizontal fantasy boss health bar frame, ornate dark metal border,
> spans nearly the full screen width, neutral glow (color set dynamically per
> boss phase in-engine). [+ styl UI]

### 5.3 Pasek staminy
> A thin horizontal fantasy game stat bar frame, dark metal, amber-orange
> (#E8A33D) glow fill. [+ styl UI]

### 5.4 Pasek many
> A thin horizontal fantasy game stat bar frame, dark metal, blue (#4FA8E8)
> glow fill. [+ styl UI]

### 5.5 Ikona dasha
> A small square fantasy game icon representing a dash/blink ability, cyan
> (#5BE0C8) glowing motion-lines symbol, dark metal frame, plus a visually
> distinct "locked/crossed-out" variant for when it's disabled.
> [+ styl UI]

### 5.6 Ikona leczenia
> A small circular fantasy game icon representing a healing charge, ring-
> shaped progress border, green (#6FCF7A) glow, fills up as charge builds,
> bright pulse when fully charged. [+ styl UI]

### 5.7 Typografia (opcjonalnie)
Obecnie tekst UI/komunikatów/menu korzysta z domyślnej czcionki silnika. Jeśli
chcesz spójny styl, warto wybrać JEDNĄ pogrubioną, nieco "postrzępioną"/mroczną
czcionkę fantasy (np. z Google Fonts) zamiast promptu graficznego — to kwestia
wyboru pliku fontu, nie generowania obrazka.

---

## 6. Menu / ekran startowy (`menu.gd`)

### 6.1 Logo/tytuł NEMORAX
> A dark fantasy game logo wordmark "NEMORAX", jagged aggressive lettering,
> glowing cyan-to-magenta gradient, imposing and ominous, on a transparent
> background. [+ styl UI]

### 6.2 Tło menu
> A dark, moody full-screen background illustration: a distant silhouette of
> the Nemorax hybrid looming in darkness, six faint colored glows scattered
> around it representing the six incarnations, heavy atmosphere, low detail
> so UI text stays readable on top. [+ styl otoczenia]

---

## 7. Ekrany końcowe (śmierć / zwycięstwo, dziś płaski przyciemniony prostokąt)

Opcjonalnie, niski priorytet — obecny płaski ciemny overlay działa i czytelnie
pokazuje tekst. Jeśli chcesz to podrasować:
> A subtle dark decorative vignette/frame overlay for a game end screen,
> ornate corner details fading to plain darkness in the center where text sits,
> no text itself. [+ styl UI]

---

## 8. Czego NIE trzeba generować (zostaje w kodzie/shaderze)

- **Zaćmienie** (przyciemnienie ekranu wokół gracza w finałowej fazie
  Nemoraxa) — to shader liczony w czasie rzeczywistym (`arena.gd`), nie
  statyczna tekstura, zostaje jak jest.
- **Hitstop / trzęsienie ekranu / błysk trafienia na biało** — czyste efekty
  kodu (`juice.gd`), nie potrzebują żadnej grafiki.
- **Ślad cienia pod postacią** itp. drobne cząsteczki — zostają proste,
  rysowane kodem, chyba że zechcesz inaczej.
