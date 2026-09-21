# NEMORAX — kierunek wizualny po analizie dwóch gier referencyjnych

## Jedno zdanie celu

Nemorax ma być mrocznym, stylizowanym roguelite'em z ciężkim klimatem pierwszej referencji oraz natychmiastową czytelnością walki drugiej: **świat jest ciemny i malowany, a akcja jasna, uporządkowana i łatwa do odczytania.**

Nie kopiujemy cudzych postaci, UI, lokacji ani konkretnych efektów. Przenosimy wyłącznie zasady kompozycji, skali, światła i czytelności.

## Co mówią referencje

### Referencja 1 — klimat i głębia

- Podłoga jest spokojna; detal buduje miejsce, nie walczy o uwagę z bohaterem.
- Obrzeża sceny toną w cieniu, a lokalne źródła światła prowadzą wzrok.
- Postacie, rekwizyty i wejścia mają wspólną perspektywę oraz osadzenie na podłożu.

### Referencja 2 — czytelność działania

- Sylwetka gracza i aktywnego przeciwnika odcina się od tła natychmiast.
- Kolor jest językiem rozgrywki: jasne barwy są zarezerwowane dla ataku, nagrody, zagrożenia i interakcji.
- Arena ma wyraźną ramę świata: krawędź, ścianę, otchłań lub niższy poziom — nigdy nie jest samym prostokątem tekstury.
- Efekty są krótkie, mają czytelny rdzeń i nie zasłaniają wszystkiego detalem.

## Kontrakt artystyczny NEMORAX

1. **Perspektywa:** stylizowane top-down 2D; żadna grafika nie może mieć innego kąta kamery niż podłoga i ściany.
2. **Skala:** gracz = 1.0. Małe zagrożenia 0.65–0.85, średnie 0.80–0.95, ciężkie 1.05–1.35, wcielenia 1.60–2.20, Nemorax 2.80+. Hitboxy nie zmieniają się z wyglądem.
3. **Światło:** chłodny, ciemny ambient świata; jeden dominujący kierunek oświetlenia; ciepły pomarańcz dla ognia/nagrody, cyjan dla gracza, kolor faz dla Nemoraxa, czerwony dla zagrożenia.
4. **Głębia:** każdy obiekt stojący na ziemi dostaje miękki cień kontaktowy; świat ma podłogę, krawędź/ścianę i otchłań poza areną.
5. **Hierarchia:** gracz i aktualne zagrożenie są zawsze mocniejsze wizualnie od podłogi. Dekoracje i tekstura nie mogą być jaśniejsze od istot w centrum walki.
6. **Warstwy:** podłoga → cienie → niskie dekoracje → postacie/drzwi/skrzynie → pociski i VFX → czytelne telegrafy → HUD/cutscenki.
7. **Łup:** po śmierci wróg nie pozostaje w pełnej stojącej pozie pod skrzynią. Najpierw znika/rozpada się, potem skrzynia pojawia się osobno przy jego dolnej krawędzi.

## Definicja pokoju wzorcowego

Jeden pokój testowy musi zawierać: gracza, małego przeciwnika, ciężkiego przeciwnika, drzwi, skrzynię, atak pociskowy, atak obszarowy i lokalne źródło światła.

Odbiór następuje dopiero, gdy:

- w pierwszej sekundzie widać, gdzie jest gracz, wróg, drzwi i bezpieczna przestrzeń;
- nic nie wygląda jak surowo wycięte PNG;
- podłoga nie konkuruje z walką;
- skrzynia nie nakłada się na ciało wroga;
- po włączeniu VFX widać gracza i telegraf;
- HUD jest czytelny i nie dostaje przyciemnienia świata.

Po zatwierdzeniu tego pokoju jego liczby, warstwy oraz sposób światła są obowiązujące dla wszystkich pokoi i assetów.
