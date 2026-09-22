# NEMORAX — kompletny plan UI, nagród i komunikatów

## Problem do rozwiązania

Świat NEMORAXA ma być mroczny, materialny i niepokojący. Obecnie część UI
wygląda jak systemowy prototyp: białe napisy na środku ekranu, przypadkowe
kolory, prostokątne panele i zbyt techniczne instrukcje. To psuje immersję,
nawet gdy sama walka jest dobra.

**Zasada nadrzędna:** UI nie jest naklejką na grę. Jest rytuałem i częścią
tego samego świata. Każdy komunikat ma mieć cel, wagę, czas wejścia oraz
jedną hierarchię.

---

# Wspólny język UI — obowiązkowy dla każdego ekranu

## Materiały i kolory

- Tło paneli: niemal czarny granat/fiolet, lekka faktura kamienia, dymu lub
  starego metalu. Nigdy czysty, jednolity fioletowy prostokąt.
- Ramka: bardzo cienka, z ciemnego metalu/kości; dekoracja tylko na rogach,
  nie wokół każdego zdania.
- Tekst główny: przygaszona kość/srebro, nie czysta biel.
- Akcent gracza/energii: turkus przygaszony, nie neon.
- Akcent otchłani/bossa: fiolet/magenta używany oszczędnie.
- Akcent nagrody: stare złoto, ale tylko dla rzeczy wartościowych.
- Czerwony: wyłącznie obrażenia, zagrożenie, utrata życia.

## Typografia

- Jeden font display dla tytułów/wyborów i jeden czytelny font dla opisów.
- Bez domyślnego fontu systemowego.
- Tytuły: wersaliki lub małe kapitaliki, większy odstęp między literami.
- Opisy: krótkie, maksymalnie 2–3 wiersze.
- Żaden komunikat nie może zasłaniać środka walki, chyba że zatrzymuje grę
  i wymaga decyzji.

## Ruch wspólny

- Wejście: fade 0,18–0,35 s + przesunięcie 8–16 px albo minimalny scale.
- Wyjście: krótsze niż wejście.
- Żadnych nagłych `visible = true` dla ważnego UI.
- Żadnych stale pulsujących elementów poza jednym aktualnym priorytetem.
- Wszystkie Tweeny anulować/przestawiać przed uruchomieniem następnego;
  brak nakładających się animacji i „cięć”.

---

# 1. HUD podczas walki

## Cel

W sekundę gracz zna swoje życie, zasób ataku, stan leczenia i poziom, ale
HUD nie rywalizuje z pokojem ani nie wygląda jak nakładka z innej gry.

## Lewy dolny róg — stan gracza

- Zgrupować zdrowie, stamina/mana i level jako jeden zwarty „relikwiarz”.
- Każdy pasek ma własny materiał i cienką metalowo-kamienną oprawę, ale bez
  trzech wielkich ozdobnych ramek.
- HP: przygaszona czerwień tylko podczas utraty; normalnie kość/ciemna czerwień.
- Mana/energia: turkus; stamina: zgaszone złoto lub inny odrębny, ustalony kolor.
- Przy utracie zdrowia pasek krótko cofa się z cieniem starej wartości,
  zamiast skakać.
- Poziom ma być małym medalionem/liczbą przy HUD, nie luźnym napisem `Lv 0`.
- Liczniki skrzyń/ładunków mają czytelne ikonki i krótkie liczby, nie surowe `x1`.

## Prawy górny róg — mapa

Na nagraniu obecna mapa czyta się jak zestaw przypadkowych kolorowych kwadratów.

- Zamienić na „mapę pamięci”: ciemne, półprzezroczyste komnaty i połączenia.
- Odwiedzony pokój: ciemny kamień; obecny: dyskretny turkus; cel/boss: jeden
  przygaszony fiolet lub złoto.
- Bez losowej palety czerwieni, zieleni, różu i bieli naraz.
- Mapa jest ukrywana lub przygaszana w walce z bossem, jeśli rozprasza.
- Nie może wejść w obszar kamery lub menu.

## Górna krawędź — boss

- Pasek bossa ma być jednym ciężkim elementem: imię, faza i HP.
- Bez zbyt cienkiej neonowej linii przez cały ekran.
- Kolor fazy może zmieniać akcent, ale tło pozostaje ciemne.
- Przejście fazy: krótki podpis fazy + dźwięk + zmiana paska, nie ściana tekstu.

## Kryterium odbioru HUD

Na statycznym screenie z walki najpierw widać gracza i zagrożenie, potem HUD.
HUD jest rozpoznawalny, ale nie jest pierwszym najjaśniejszym elementem kadru.

---

# 2. Skrzynia i zdobycie ulepszenia

## Obecny problem

Napis typu `Zdobyto ulepszenie: Second Impact` pojawia się jak systemowa
notyfikacja. Nie ma ciężaru, nie mówi czym jest nagroda i wygląda obco wobec
świata.

## Docelowa sekwencja — 1,2 do 1,8 s

1. Ostatni wróg znika / opada na ziemię.
2. Krótka cisza (0,25–0,45 s).
3. Skrzynia pojawia się na podłodze z kontaktem, małym złotym blaskiem i
   krótkim dźwiękiem metalu.
4. Po otwarciu: mały pionowy promień/mgła nad skrzynią, bez zakrywania gracza.
5. Ulepszenie pojawia się jako **karta relikwii** przy dolnej/środkowej części
   ekranu: ikona, nazwa, jedno zdanie korzyści.
6. Karta znika sama po 1,5–2,5 s albo po potwierdzeniu, nie blokując gracza,
   jeśli nagroda jest automatyczna.

## Karta relikwii

```text
        [ mała ikona relikwii ]
           SECOND IMPACT
     Następny cios po trafieniu...
```

- Tło: ciemna półprzezroczysta mgła, cienki złoty ornament tylko w rogach.
- Nazwa: kość/złoto; opis: przygaszone srebro.
- Karta nie jest pełnoekranowym popupem i nie wyjeżdża z góry jak toast systemowy.
- W przyszłości karta może mieć krótki szept/efekt dźwiękowy unikalny dla
  rzadkości, ale teraz wystarczy jeden spójny dźwięk.

## Kryterium odbioru

Gracz po trzech sekundach pamięta nazwę i działanie ulepszenia, ale nie stracił
orientacji w pokoju.

---

# 3. Punkty statystyk / level up

## Obecny problem

Ekran punktów na nagraniu jest dużą fioletową planszą z tekstem. Mechanicznie
działa, ale nie wygląda jak część NEMORAXA i ma zbyt małą, słabą hierarchię.

## Docelowy ekran: „Ołtarz Rozwoju”

- Zatrzymuje lub wyraźnie spowalnia świat; nie może być otwierany nad aktywnym
  śmiertelnym atakiem.
- Tło gry pozostaje widoczne, ale zaciemnione i rozmyte/mglisto przygaszone.
- Panel centralny ma formę pionowego relikwiarza, nie pełnej planszy.
- Góra: `POZIOM 7` oraz mały, wypełniający się znak duszy.
- Pod spodem: `Punkty do wydania: 2` jako pojedynczy silny komunikat.
- Statystyki są sześcioma rzędami z ikoną, nazwą, aktualną wartością i
  jednym krótkim opisem po zaznaczeniu.

Przykład:

```text
           OŁTARZ ROZWOJU
                POZIOM 7
             ● ●  2 punkty

   ♥ Życie             1   [+10 zdrowia]
   ◈ Stamina           0
   ✦ Mana              0
   ⚔ Atak              3
   ≋ Szybkość           0
   ⟳ Regeneracja        1
```

## Interakcja

- Zaznaczenie przesuwa się miękko i rozjaśnia tylko jeden rząd.
- Dodanie punktu: liczba rośnie, krótki dźwięk, mała fala światła od ikony.
- Brak punktów: przycisk potwierdzenia zamyka panel; `Esc` ma jasną funkcję.
- Nie wyświetlać na dole długiego technicznego zdania o wszystkich klawiszach.
- Krótka podpowiedź: `↑↓ wybór · Enter inwestuj · Esc zamknij`.

## Kryterium odbioru

Gracz w 2 s widzi liczbę punktów, zaznaczoną statystykę i skutek inwestycji.

---

# 4. Komunikaty w walce

## Rodzaje i miejsce

| Rodzaj | Miejsce | Czas | Styl |
|---|---|---:|---|
| Obrażenia gracza | blisko trafionego celu | 0,5–0,8 s | małe, od kierunku uderzenia |
| Heal / odzyskanie | nad graczem | 0,7 s | turkus/kość, subtelne |
| Nazwa nowego pokoju | górny środek | 1,2 s | mała kapitelka, szybko znika |
| Faza bossa | górny środek | 1,0 s | ciężki tytuł + akcent fazy |
| Ulepszenie | dolny środek | 1,5–2,5 s | karta relikwii |
| Błąd / brak zasobu | przy odpowiednim pasku HUD | 0,4–0,7 s | mały, nie czerwony ekran |

## Zasady

- Nie używać jednego globalnego `Label` w środku ekranu do wszystkich zdarzeń.
- Powtarzalne komunikaty grupować; nie budować kolejki 10 toastów.
- Tekst nie może leżeć na hitboxie bossa ani na postaci gracza.
- Dla ważnych rzeczy: ikona + nazwa + jedno zdanie. Dla drobnych: tylko ikona
  lub krótki licznik.

---

# 5. Start, pauza, opcje, śmierć i zwycięstwo

## Start runu

- Krótki tytuł miejsca / wejście przez drzwi, nie zwykły napis „start”.
- HUD pojawia się przez 0,2–0,4 s, nie wyskakuje całością w jednej klatce.

## Pauza

- Gra zamrożona; tło przygaszone, ale widoczne.
- Trzy opcje: kontynuuj, opcje, wyjdź do menu.
- Ten sam materiał, font i animacja co menu główne.

## Opcje

- Podzielić na: dźwięk, grafika, sterowanie, dostępność.
- Każda zmiana daje natychmiastowy podgląd: głośność odtwarza cichy test,
  screen shake pokazuje próbkę, fullscreen przełącza bez rozsypania layoutu.

## Śmierć gracza

- Najpierw widoczny moment porażki: 0,15 s hit-stop, ciało/osłabienie,
  świat wygasa.
- Potem panel: `ZOSTAŁEŚ ODRZUCONY` / inny wybrany tekst świata, przyczyna
  lub pokój, przyciski: spróbuj ponownie / menu.
- Bez krzykliwej czerwieni i bez natychmiastowego resetu.

## Zwycięstwo i epilog

- Zachować już istniejący system cutscenek.
- UI zwycięstwa ma zniknąć na rzecz sceny i tekstu, nie zasypywać finału
  nagrodami, paskami i minimapą.

---

# 6. Faza „zawężonego widzenia” Nemoraxa

## Błąd widoczny na nagraniu

Krąg widzenia przyciemnia również gracza. Znika postać, a pod WASD porusza
się tylko widoczne koło. To łamie podstawową orientację i jest niedopuszczalne.

## Docelowe zachowanie

- Warstwa mroku przyciemnia świat, wrogów i tło, ale **nie sprite gracza**.
- Gracz zawsze zachowuje sylwetkę, kontaktowy cień i subtelny kontur.
- Krąg podąża za graczem; nie jest osobnym obiektem, który wygląda jak kursor.
- Krawędź jest miękka/mglista; poza kręgiem zostaje 5–10% widoczności ścian.
- Hitbox i telegraf nie mogą być całkiem niewidzialne, jeśli mogą zadać
  natychmiastowe obrażenia.

## Implementacja

- Oddzielić `VisionOverlay` od warstwy renderowania gracza.
- Gracz musi rysować się nad warstwą ciemności lub mieć własny, zawsze
  widoczny pass renderowania.
- Maska widzenia wycina świat, a nie ukrywa protagonisty.
- Testować W/A/S/D oraz dash przy każdej krawędzi kręgu.

---

# 7. Wiedza o runie: statystyki, relikwie i zdrowie przeciwników

## Zasada

Gracz nie ma zgadywać, czy stał się silniejszy. Każda inwestycja i każde
ulepszenie muszą być widoczne w trzech momentach:

1. **w chwili zdobycia** — co dokładnie otrzymałem;
2. **podczas działania** — po czym widzę/mechanicznie czuję efekt;
3. **później na żądanie** — gdzie sprawdzam pełny stan runu.

Jeżeli `Second Impact` nie daje wyraźnie drugiego uderzenia, a punkt w życie
nie pokazuje zmiany `100 → 110`, dla gracza system wygląda jak niesprawny,
nawet gdy wartości istnieją w kodzie.

## 7A. Księga Runu — dostęp do wszystkiego

Wprowadzić jeden ekran dostępny z pauzy oraz skrótu `Tab` poza aktywną
decyzją/ekranem level-up. Nazwa w świecie: **KSIĘGA RUNU** albo
**ŚLADY DUSZY**.

Układ: dwa stałe zakładki.

```text
 [ STATYSTYKI ]   [ RELIKWIE ]

 Życie          110 / 110     baza 100  +10
 Stamina         100 / 100    baza 100  +0
 Mana            100 / 100    baza 100  +0
 Atak            13           baza 10   +30%
 Szybkość        315          baza 300  +5%
 Regen. staminy  33 / s       baza 30   +10%
```

Zasady:

- Każdy wiersz pokazuje **aktualną wartość**, bazę i źródło bonusu.
- Po zaznaczeniu wiersza krótki opis: co wartość realnie zmienia w walce.
- Nie chować liczb wyłącznie w kodzie lub tooltipie.
- Ekran nie może zatrzymywać walki przez przypadek: otwierany poza walką,
  z pauzy albo w trybie, który świadomie pauzuje grę.

## 7B. Zakładka Relikwie

Każde ulepszenie zdobyte w bieżącym runie ma małą kartę z:

- ikoną;
- nazwą;
- prostym opisem działania;
- statusem działania / liczbą aktywacji, jeśli ma to sens.

Przykład:

```text
  [ikona] SECOND IMPACT
  Po trafieniu mieczem następny cios zadaje dodatkowe 100% obrażeń.
  Aktywacje w tym runie: 12
```

Nie pisać ogólników typu „wzmacnia atak”. Tekst musi podawać konkretny
warunek oraz efekt.

## 7C. Natychmiastowy feedback po wydaniu punktu

Po inwestycji wyświetlić mały, czytelny rezultat przy wybranym rzędzie:

- `Życie: 100 → 110`;
- `Atak: 10 → 11` lub `Atak: +10%`;
- `Szybkość: 300 → 315`;
- `Regeneracja staminy: 30/s → 33/s`.

Następnie pasek HUD powinien od razu pokazać nowy maksymalny zasób. Gracz nie
może wyjść z ekranu punktów bez wiedzy, co konkretnie zmienił.

## 7D. Sprawdzenie każdego ulepszenia w walce

Każda relikwia potrzebuje widocznego dowodu działania. Przykłady:

| Ulepszenie | Dowód dla gracza |
|---|---|
| Second Impact | drugi, opóźniony cios/łuk w 0,08–0,16 s + osobna liczba obrażeń |
| Blood Edge | krótki czerwony znak na broni przed wzmocnionym ciosem |
| Void Step | ślad dasha i mała ikona aktywnego bonusu |
| Iron Heart | krótki metaliczny błysk przy pochłonięciu/obronie |
| Soul Echo | widoczna, krótka fala powtarzająca efekt |

**Second Impact — obowiązkowy audyt:**

1. Test automatyczny: pierwsze trafienie uzbraja relikwię; kolejny cios
   wywołuje drugi efekt i drugie obrażenia dokładnie raz.
2. Test w grze: widać drugi łuk/uderzenie i osobną liczbę obrażeń.
3. Jeśli efekt jest tylko mnożnikiem obrażeń, zmienić opis lub dodać wyraźny
   efekt wizualny. Nie wolno nazywać go „drugim ciosem”, jeśli widać tylko
   zwykły pojedynczy zamach.
4. Licznik aktywacji w Księdze Runu ma rosnąć po zadziałaniu.

Jeżeli test nie przechodzi, traktować to jako bug mechaniki, nie problem UI.

## 7E. Zdrowie przeciwników

Gracz musi rozumieć postęp walki, ale ekran nie może być pełen pasków.

- Boss: zawsze widoczny pasek u góry z nazwą, fazą i dokładnym `HP / max HP`
  albo czytelnymi segmentami.
- Elita/miniboss: pasek nad głową po wejściu w walkę.
- Zwykły wróg: mały pasek nad głową pojawia się dopiero po pierwszym trafieniu
  albo po zaznaczeniu/przybliżeniu. Gaśnie po 1,5–2,5 s bez obrażeń.
- Pasek zdrowia wroga jest ciemny; utracone HP pozostawia na chwilę „cień”
  poprzedniej wartości, aby obrażenia miały wagę.
- Liczby obrażeń są opcjonalne, ale jeśli są włączone, mają jeden styl i nie
  mogą zakrywać gracza.

## 7F. Minimalny HUD liczb

Lewy dolny róg ma stale pokazywać przynajmniej:

- `HP 75 / 110`;
- stamina `62 / 100`, jeśli jest potrzebna do dasha/ataku;
- mana `40 / 100`, jeśli różdżka jej używa;
- poziom i punkty do wydania jako jedna mała, czytelna ikona.

To nie musi być wielki tekst. Ma być widoczne po spojrzeniu, zwłaszcza gdy
gracz pyta: „czy mam jeszcze życie?” oraz „czy inwestycja faktycznie działa?”.

## Kryterium odbioru fazy 7

Nowy gracz w jednym runie musi umieć odpowiedzieć bez zgadywania:

1. Ile ma teraz i maksymalnie życia?
2. Co dał mu ostatni punkt statystyki?
3. Jakie relikwie posiada oraz co robią?
4. Czy `Second Impact` właśnie zadziałał?
5. Ile zdrowia ma boss i czy zwykły wróg przyjmuje obrażenia?

Jeśli choć na jedno odpowiada „nie wiem”, UI/feedback nie jest ukończone.

---

# 8. Priorytet wdrożenia

1. Naprawić widoczność gracza w fazie zawężonego widzenia.
2. Usunąć systemowe, środkowe napisy ulepszeń i wdrożyć kartę relikwii.
3. Przebudować ekran punktów na ołtarz rozwoju.
4. Ujednolicić HUD i minimapę.
5. Uporządkować pasek bossa oraz komunikaty faz.
6. Dopiero potem: pauza, opcje, śmierć, zwycięstwo i kosmetyczne dźwięki.

---

# Test końcowy dla Claude'a

Claude ma nagrać jeden pełny ciąg:

1. start pokoju;
2. walka i otrzymanie obrażeń;
3. zabicie wroga i skrzynia;
4. zdobycie ulepszenia;
5. zdobycie poziomu i wydanie punktu;
6. przejście przez drzwi;
7. faza zawężonego widzenia Nemoraxa;
8. pauza i powrót;
9. śmierć lub zwycięstwo.

Odbiór przechodzi tylko wtedy, gdy w żadnym kroku UI nie wygląda jak obcy,
systemowy prostokąt lub nie zasłania informacji potrzebnej do uczciwej walki.
