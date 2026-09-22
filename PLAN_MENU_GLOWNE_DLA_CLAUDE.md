# NEMORAX — menu główne: plan jakości premium

> ## NOWY KIERUNEK WIZUALNY — PRIORYTET AUTORA
>
> Menu ma być **bezlitośnie mroczne, monumentalne i niepokojące**. Nie ma
> wyglądać jak neutralny ekran wyboru na ładnym tle. Ma być pierwszym wejściem
> do otchłani Nemoraxa: gracz powinien poczuć, że za przyciskiem „Graj” czeka
> nieznany, groźny świat. Mrok nie może jednak utrudniać wyboru opcji ani
> sprawiać, że UI znika.
>
> Inspiracja dotyczy wyłącznie nastroju: ogrom, cisza, głębia, ruch w cieniu,
> obca magia. Nie kopiować kompozycji, grafik ani logotypów innych gier.

## Diagnoza obecnego ekranu

Tło i logo mają już dobry, mroczny kierunek. Problem nie polega na braku
grafiki, tylko na hierarchii i ruchu:

- logo zajmuje zbyt dużo wysokości i spycha menu;
- zaznaczenie jest szerokim prostokątnym paskiem przez cały ekran — wygląda
  jak debugowy `ColorRect`, nie jak część świata;
- napisy używają zwykłego jasnego fontu bez własnego charakteru;
- instrukcja na dole jest techniczna i kradnie uwagę;
- tło, logo i menu są statycznymi warstwami, przez co ekran nie ma oddechu;
- przejścia nie mogą blokować wejścia ani doczytywać zasobów w chwili kliknięcia.

## Cel

Menu ma być bramą do otchłani: gęste, niemal czarne, monumentalne i
niepokojące. Użytkownik od razu widzi, co wybrać, ale ma wrażenie, że menu
obserwuje go z głębi jaskini. Ruch jest powolny i ciężki — nigdy wesoły,
kolorowy ani dekoracyjny.

---

# Docelowy układ

```text
┌──────────────────────────────────────────────────────────────┐
│  niemal czarna otchłań, daleki zarys Nemoraxa, powolna mgła   │
│                                                              │
│                    [ logo NEMORAX ]                          │
│             pojedynczy szczelinowy blask pod logo             │
│                                                              │
│                    ◈  GRAJ  ◈                                │
│                       OPCJE                                  │
│                       WYJDŹ                                  │
│                                                              │
│       [Enter — wybierz]   [Esc — wróć / wyjdź]               │
└──────────────────────────────────────────────────────────────┘
```

## Konkretne proporcje

- Logo: środek około 34–39% wysokości ekranu, szerokość maks. 34–42% ekranu.
  Nie może dotykać menu ani zasłaniać tła pod nim.
- Lista akcji: środek około 61–68% wysokości, odstęp między pozycjami
  16–24 px w rozdzielczości referencyjnej.
- Tekst pomocy: mały, przy dolnej krawędzi, niska przezroczystość; nie opisuje
  wszystkich klawiszy naraz, jeśli sterowanie myszą jest oczywiste.
- Zachować bezpieczny margines 5–8% z każdej strony dla różnych proporcji
  ekranu.

---

# Warstwy wizualne

## 1. Tło (najniżej) — otchłań, nie ilustracja tapety

- Istniejące tło użyć tylko jako podstawy. Górna połowa ma ginąć w czerni,
  mgle i ogromnej, ledwie czytelnej głębi.
- W tle może być zarys czegoś ogromnego: ściany, korzeni, żeber świata albo
  sylwetki Nemoraxa, lecz bez ostrego konturu i bez pokazywania całego bossa.
  Gracz ma **nie być pewien**, co widzi.
- Parallax: 6–16 pikseli w ciągu 10–18 s, z płynnym powrotem. Żadnych
  szybkich ruchów, odjazdów kamery ani efektu „żywej tapety”.
- Dodać maksymalnie 2–3 subtelne elementy: pełzająca mgła, rzadkie pyłki,
  pojedyncze odległe światło, które gaśnie zanim zwróci uwagę.
- Kolory: 85–90% prawie czarne granaty/szarości; akcenty wyłącznie głęboki
  fiolet, przygaszony cyjan i bardzo rzadko brudne złoto.

## 2. Winieta i czytelność — światło jako pułapka

- Winieta od brzegów ma być głęboka, ale organiczna — jak cień jaskini,
  nie czarna ramka nałożona na ekran.
- Menu istnieje w niewielkiej wyspie czytelności, jakby słabe światło z
  pęknięcia pod nim odkrywało tylko trzy słowa.
- Za tekstem użyć cienkiej mgły/gradientu, bez prostokątnego panelu.
- Światło zaznaczonej opcji ma delikatnie odsłaniać fakturę tła pod nią,
  a nie tworzyć żółty pasek przez cały ekran.

## 3. Logo — znak w ciemności

- Logo wyłania się z całkowitej czerni, a nie po prostu pojawia: najpierw
  cienkie turkusowo-fioletowe szczeliny, potem litery z mgły.
- Krótki `fade + scale` po wejściu: od 94% do 100% w ~0,9 s, `ease_out`.
  Bez podskoku i bez ciągłego pulsowania.
- Bardzo delikatny oddech jasności akcentu co 6–10 s, maks. ±5%, jak odległy
  puls czegoś pod kamieniem.
- Logo nie dostaje zwykłego drop-shadow; można dać subtelny ciemny cień i
  minimalną poświatę zgodną z jego turkusowo-fioletowym akcentem.

## 4. Pozycje menu

Stan zwykły:

- tekst jasnoszary, nie czysta biel;
- mały tracking / większy odstęp między literami;
- własny font gry, nie domyślny font systemowy;
- brak pełnoekranowego paska zaznaczenia.

Stan zaznaczony:

- tekst przechodzi w brudne kość/srebro, z małą nutą fioletu;
- po lewej pojawia się mały, cienki znak przypominający pęknięcie/oko,
  po prawej jego ledwie widoczne echo;
- tylko zaznaczony element przesuwa się o 6–10 px w prawo;
- cienkie podświetlenie pod tekstem albo dymna poświata o małym promieniu —
  nigdy prostokąt na całą szerokość.

Stan kliknięcia:

- 0,08–0,12 s lekkiego zmniejszenia, potem przejście;
- krótki dźwięk potwierdzenia;
- wejście blokowane tylko na czas jednej akcji, aby podwójne kliknięcie nie
  uruchamiało sceny dwukrotnie.

---

# Ruch i brak cięć

## Jedna maszyna stanów

Menu ma mieć jawne stany, np.:

`INTRO → IDLE → OPTIONS_OPEN → TRANSITIONING → EXITING`

Zasady:

- `INTRO`: pokazuje tło, potem logo, potem pozycje menu; wejście użytkownika
  jest akceptowane dopiero po krótkim `INTRO` albo natychmiast przeskakuje do
  końcowego stanu animacji.
- `IDLE`: działa klawiatura, mysz i gamepad; jedna pozycja jest zawsze
  zaznaczona.
- `OPTIONS_OPEN`: główne pozycje miękko znikają, panel opcji wchodzi z dołu
  lub z prawej; `Esc` wraca do listy, nie zamyka gry od razu.
- `TRANSITIONING`: ignoruje dodatkowe kliknięcia i klawisze potwierdzenia;
  najpierw krótki fade, potem zmiana sceny.
- `EXITING`: pojedyncze potwierdzenie wyjścia; żadnego przypadkowego zamknięcia
  gry przez `Esc` w menu opcji.

## Tweeny

- Użyć `Tween`/`AnimationPlayer`, nie zmieniać pozycji UI w `_process()`.
- Każdy tween ma zostać zabity lub zastąpiony przed uruchomieniem kolejnego.
- Wspólne czasy: hover 0,12–0,18 s; wejście elementu 0,25–0,4 s;
  przejście sceny 0,35–0,6 s.
- Użyć `ease_out` przy wejściu, `ease_in` przy wyjściu. Unikać sprężyn,
  wielokrotnych odbić i błysków.

## Wydajność

- Wczytać scenę gry przed kliknięciem lub podczas spokojnego `IDLE`, bez
  blokowania renderu.
- Nie tworzyć i nie usuwać dziesiątek węzłów co klatkę.
- Cząsteczki menu ograniczyć do małej stałej puli.
- Zmierzyć pierwsze przejście „Graj”: brak wyraźnej klatki zawieszenia.
- Jeżeli zasób jest jeszcze wczytywany, dopuszczalny jest maks. jeden krótki
  ekran przejścia/fade, a nie zatrzymane menu.

---

# Sterowanie i dostępność

- Mysz: najechanie wybiera, klik potwierdza.
- Klawiatura: góra/dół zmienia wybór; Enter/Spacja potwierdzają; Esc wraca.
- Gamepad: d-pad/analog, przycisk potwierdzenia i cofnięcia.
- Po zmianie sterowania zaznaczenie nie może „zgubić” fokusu.
- Tekst pomocy pokaż jako dwie krótkie podpowiedzi, np.:
  `↑↓ wybór   Enter zatwierdź`, zamiast pełnego zdania z każdym klawiszem.
- W opcjach: pełny ekran, głośność muzyki, głośność efektów, screen shake,
  reduce flashing oraz klawisze. Nie projektować opcji jako osobnej gry —
  najpierw stabilny panel i powrót `Esc`.

---

# Dźwięk menu — cisza przed czymś złym

- Wejście: niski, prawie niesłyszalny oddech/mgła; żadnego heroicznego stingeru.
- Zmiana pozycji: krótki, suchy, głęboki tick — bardziej kamień/kość niż UI.
- Potwierdzenie „Graj”: głęboki sygnał + powolne, niepokojące narastanie,
  jak otwieranie szczeliny w ścianie.
- Cofnięcie: cichy, niższy odwrócony tick.
- Dźwięki UI powinny być słyszalne ponad muzyką, lecz znacznie cichsze niż
  dźwięki walki.

---

# Kolejność wdrożenia dla Claude'a

1. Zmierz i uporządkuj obecne węzły menu; nie przepisywać projektu od zera.
2. Ustawić responsywny layout przez `Control`/anchory, nie absolutne pozycje
   liczone na sztywno dla jednego ekranu.
3. Usunąć szeroki pasek zaznaczenia i wdrożyć nowy komponent jednej pozycji.
4. Ustawić focus dla klawiatury, myszy i gamepada.
5. Dodać stany oraz bezpieczne Tweeny.
6. Dodać bardzo oszczędny ruch tła, logo i akcentów.
7. Zbudować panel opcji z działającym powrotem.
8. Dopiero na końcu dźwięki i preload przejścia do gry.

## Test odbioru

Claude ma pokazać:

1. start menu po zimnym uruchomieniu;
2. mysz: najechanie + klik „Graj”;
3. klawiatura: góra/dół/Enter/Esc;
4. gamepad, jeśli jest obsługiwany;
5. wejście i wyjście z opcji;
6. pięć szybkich zmian zaznaczenia — bez pozostawionych tweenów, migania ani
   przesuniętego tekstu;
7. pierwsze przejście do gry — bez widocznego przycięcia.

## Warunek końcowy

Menu przechodzi odbiór, kiedy po pięciu sekundach patrzenia nie widzimy
„paska UI na tle”, tylko bramę do świata gry; po kliknięciu nie ma wahania,
cięcia ani wątpliwości, co się stało.
