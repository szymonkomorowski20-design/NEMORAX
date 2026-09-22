# NEMORAX — teraz: arena Nemoraxa, widoczność, UI i progres

## Cel

Zamienić aktualny stan „działa, ale miejscami wygląda technicznie / obco” na
jedną spójną, mroczną grę. Priorytetem jest uczciwa czytelność walki i poczucie
progresu. Nie dokładać nowych systemów ani nowych typów wrogów, zanim te
elementy nie przejdą odbioru.

---

# Priorytet 1 — arena Nemoraxa

## Problem

Jasna szara podłoga z fioletowymi pęknięciami wygląda jak osobna arena sci-fi,
nie jak kulminacja świata NEMORAXA. Boss, strefy i żółte koło dodatkowo
wyglądają jak elementy techniczne położone na mapie.

## Zadania

1. **Osobny język areny, ale ten sam świat**
   - podłoga: mroczny kamień/obsydian, spokojniejszy środek, pęknięcia i
     detale odsunięte ku krawędziom;
   - ściana: własny, ciemniejszy materiał i czytelna wysokość, nie kopia
     podłogi;
   - zachować tylko przygaszony fiolet jako akcent otchłani, bez jasnej
     futurystycznej siatki pęknięć;
   - dodać głębię: cień przy ścianach, dyskretną mgłę i lokalne światło
     zagrożeń.

2. **Osadzić Nemoraxa w arenie**
   - mocniejszy, miękki kontaktowy cień dokładnie pod dolną częścią sylwetki;
   - dolna część bossa trochę ciemniejsza/obarwiona światłem areny;
   - nie zmniejszać grozy bossa, ale ograniczyć kontrast czerwieni/cyjanu
     tylko do aktywnych fragmentów/ataków;
   - sprite bossa musi czytać się jako stojący na podłodze, nie jako grafika
     przed ekranem.

3. **Usunąć techniczny żółty okrąg**
   - jeśli to zasięg lub hitbox, nie wyświetlać go jako idealnej żółtej linii;
   - zastąpić go runicznym kręgiem, cieniem, pęknięciami w podłodze lub
     przygaszoną magiczną aureolą zgodną z aktualną fazą;
   - realny hitbox pozostaje uczciwy, ale telegraph może być minimalnie
     większy i wizualnie miękki.

4. **Naprawić strefy czarno-zielono-fioletowe**
   - zachować czytelność;
   - dodać ciemniejszy środek/wnętrze, miękkie przejście w podłogę i cień;
   - zredukować neonową obwódkę;
   - strefa ma wyglądać jak energia psująca kamień, a nie płaski dysk UI.

5. **Wzmocnić gracza podczas bossa**
   - kontaktowy cień;
   - minimalnie wyższy kontrast sylwetki względem podłogi;
   - czytelne pociski/ataki gracza, ale bez rozjaśniania całej areny.

## Odbiór

Zatrzymany kadr z bossem ma najpierw pokazywać: gracza, zagrożenie, bossa,
drogę ruchu. Arena ma być kulminacją NEMORAXA, nie osobną planszą z innej gry.

---

# Priorytet 2 — faza zawężonego widzenia

## Bug do naprawy

Podczas fazy mroku znika sprite gracza, a pod WASD porusza się samo kółko
widzenia. To uniemożliwia uczciwą kontrolę.

## Docelowe zachowanie

- Gracz jest **zawsze w 100% widoczny**: pełna sylwetka, kontaktowy cień,
  delikatny cyjanowo-fioletowy kontur.
- Krąg widzenia **podąża za graczem**; nie może zastępować jego sylwetki.
- Tło i wrogowie poza kręgiem są przyciemnione niemal do czerni, ale zostawić
  5–10% widoczności ścian/orientacji.
- Krawędź kręgu jest miękka i mglista, nie twarda jak idealna czarna maska.
- Zagrożenie, które może natychmiast zranić gracza, nie może być całkowicie
  niewidzialne.

## Implementacja

- `VisionOverlay` ma być pod warstwą renderowania gracza.
- Maska ma przyciemniać świat, a nie sprite protagonisty.
- Sprawdzić ruch W/A/S/D oraz dash przy środku i krawędzi kręgu.

---

# Priorytet 3 — UI jako część świata, nie systemowe prostokąty

## Wspólne reguły

- Materiał: niemal czarny granat/fiolet, dyskretna faktura, cienka metalowo-
  kamienna/kościana oprawa.
- Tekst: kość/srebro; złoto wyłącznie dla nagród; turkus dla energii;
  magenta/fiolet dla otchłani; czerwony tylko dla obrażeń.
- Jeden font display dla tytułów i jeden czytelny dla opisów.
- Żaden popup nie zasłania środka walki, jeśli nie zatrzymuje gry i nie wymaga
  decyzji.
- Wejścia/wyjścia UI przez krótkie Tweeny; bez nagłych wyskoków i bez
  nakładających się animacji.

## HUD

- Lewy dół: jeden zwarty relikwiarz stanu gracza.
- Stale pokazywać przynajmniej: `HP 75 / 110`, stamina i mana, gdy są używane,
  poziom i punkty do wydania.
- Pasek ma pokazywać zmianę utraconego HP przez chwilowy cień starej wartości.
- Prawy górny róg: mapa pamięci, nie kolorowa siatka debugowa.
  Odwiedzony pokój ciemny, bieżący turkusowy, boss/cel jednym akcentem.
- Boss: jeden ciężki pasek z nazwą, fazą i HP; nie neonowa cienka linia.

## Skrzynia i ulepszenie

Sekwencja po pokoju:

1. śmierć ostatniego wroga;
2. krótka cisza;
3. skrzynia na podłodze z cieniem i małym złotym blaskiem;
4. otwarcie: mały promień/mgła, bez zasłaniania gracza;
5. karta relikwii w dolnej/środkowej części ekranu — ikona, nazwa, jedno
   konkretne zdanie efektu.

Nie używać systemowego tekstu na środku ekranu typu:
`Zdobyto ulepszenie: Second Impact`.

Przykład karty:

```text
         [ ikona ]
       SECOND IMPACT
 Następny cios po trafieniu zadaje...
```

## Punkty statystyk

- Zastąpić zwykłą fioletową planszę panelem **Ołtarz Rozwoju**.
- Tło świata widoczne, ale przygaszone; centralny pionowy relikwiarz.
- Góra: poziom + liczba punktów do wydania.
- Rzędy: ikona, statystyka, wartość aktualna, baza i bonus.
- Po wydaniu punktu pokazać konkretną zmianę, np. `Życie: 100 → 110` albo
  `Szybkość: 300 → 315`.
- Krótka podpowiedź: `↑↓ wybór · Enter inwestuj · Esc zamknij`.

---

# Priorytet 4 — wiedza o progresie

## Księga Runu

Dostęp przez `Tab` poza aktywną decyzją lub przez pauzę. Dwie zakładki:

### Statystyki

```text
Życie          110 / 110     baza 100  +10
Stamina         100 / 100    baza 100  +0
Mana            100 / 100    baza 100  +0
Atak            13           baza 10   +30%
Szybkość        315          baza 300  +5%
Regeneracja     33 / s       baza 30   +10%
```

Każdy rząd po zaznaczeniu podaje krótki opis skutku w walce.

### Relikwie

Każda zdobyta relikwia: ikona, nazwa, konkretny opis, licznik aktywacji,
jeśli ma zastosowanie.

```text
SECOND IMPACT
Po trafieniu mieczem następny cios zadaje dodatkowe 100% obrażeń.
Aktywacje w tym runie: 12
```

## Second Impact — obowiązkowy audyt mechaniki

Użytkownik nie widział podwójnego ciosu. Sprawdzić, czy to bug.

1. Test: pierwsze trafienie uzbraja relikwię.
2. Następny cios wywołuje dokładnie raz dodatkowe obrażenia.
3. W grze widać drugi łuk/uderzenie po 0,08–0,16 s oraz osobną liczbę obrażeń.
4. Licznik aktywacji rośnie.
5. Jeśli mechanika to jedynie mnożnik, zmienić opis albo dodać dowód wizualny.

Nie uznawać tego za ukończone bez testu automatycznego i widocznego efektu
w grze.

## Zdrowie przeciwników

- Boss: stały pasek u góry.
- Elita/miniboss: pasek nad głową od startu walki.
- Zwykły wróg: mały pasek po pierwszym trafieniu albo zaznaczeniu; znika po
  1,5–2,5 s bez obrażeń.
- Paski mają ciemne tło i krótki „cień” poprzedniego HP, aby ciosy miały wagę.
- Nie zaśmiecać areny liczbami nad wszystkimi wrogami stale.

---

# Kolejność pracy

1. Naprawić widoczność gracza w fazie mroku.
2. Zrobić audyt i poprawkę Second Impact.
3. Wdrożyć numeryczne HP oraz podstawowy pasek zdrowia przeciwnika.
4. Wdrożyć kartę relikwii po skrzyni.
5. Wdrożyć Ołtarz Rozwoju z konkretnym rezultatem punktu.
6. Wdrożyć Księgę Runu: Statystyki + Relikwie.
7. Ujednolicić HUD/minimapę/pasek bossa.
8. Przebudować arenę Nemoraxa oraz VFX bossa.

# Warunek końcowy

Po jednym runie nowy gracz bez zgadywania odpowiada:

1. Ile ma życia i ile maksymalnie?
2. Co dał mu ostatni punkt?
3. Jakie relikwie ma i co robią?
4. Czy Second Impact zadziałał?
5. Ile HP ma boss i czy przeciwnik przyjmuje obrażenia?
6. Gdzie stoi w fazie mroku?

Jeśli na którekolwiek pytanie nie ma natychmiastowej odpowiedzi z gry, praca
nie jest ukończona.

