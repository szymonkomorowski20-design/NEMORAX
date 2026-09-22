# NEMORAX — plan profesjonalnego feelingu, spójności i immersji

## Cel

NEMORAX ma pozostać mrocznym, malarskim roguelite'em z kamerą z góry, ale
ma **czuć się jak gotowa gra**, nie jak zestaw osobnych obrazków położonych na
jednej teksturze. Gracz musi skupić się na decyzji i walce, nigdy na tym, że
zauważył „wklejone PNG”, przypadkową skalę, krawędź kafla albo nieuczciwy
hitbox.

Nie kopiujemy grafiki ani rozwiązań konkretnych gier. Korzystamy z ich zasad:

1. natychmiastowa, uczciwa reakcja na wejście gracza;
2. czytelne zagrożenie przed obrażeniem;
3. wyraźny rezultat trafienia;
4. jedna fizyka obrazu dla świata, postaci, obiektów i efektów;
5. czytelność walki zawsze ważniejsza niż ozdobność tła.

## Definicja sukcesu

Po wejściu do pokoju gracz w mniej niż sekundę powinien rozpoznać:

- gdzie może chodzić;
- którędy wyjdzie;
- gdzie stoi on sam;
- który element jest wrogiem, nagrodą i zagrożeniem;
- co zaraz nastąpi w walce.

W zatrzymanym kadrze nie może być elementu, który wygląda jak wycięty PNG
leżący na podłodze bez ciężaru, cienia, wysokości i wspólnego światła.

---

# Zasady nienegocjowalne

## 1. Jedna perspektywa i jedna skala świata

- Wszystkie obiekty używają rzutu z góry, zgodnego z podłogą.
- Drzwi wchodzą w linię ściany; nie mogą być swobodnym obrazkiem postawionym
  na jej środku.
- Skrzynie, portale i potwory mają stać na tej samej płaszczyźnie podłogi.
- Skala referencyjna: gracz jest wzorcem. Mały wróg ~0,65–0,85 gracza,
  średni ~0,80–0,95, ciężki ~1,05–1,35. Nie zwiększaj potworów tylko dlatego,
  że ich grafika ma więcej detalu.
- Collider i hitbox nie mogą przekraczać wizualnej „stopy” postaci. Hitbox
  gracza powinien być odrobinę mniejszy niż sylwetka, aby uniki były uczciwe.

## 2. Zasada osadzenia w świecie

Każdy obiekt dotykający podłogi ma trzy składniki:

1. **kontakt** — mały, miękki cień dokładnie pod podstawą;
2. **wysokość** — właściwy `z_index`, aby nogi/stopa czytały się nad ziemią,
   a obiekt nie przechodził przez ścianę;
3. **światło** — jeśli obiekt świeci, daje małe lokalne światło i nie rozjaśnia
   bez powodu całej areny.

Dotyczy to: gracza, wszystkich wrogów, Nemoraxa, wcieleń, skrzyń, portali,
ołtarza, drzwi, pickupów i dużych efektów.

**Zakaz:** wróg po śmierci nie może zostać stojącym pełnym sprite'em ze
skrzynią wklejoną w środek. Kolejność: śmierć → krótka animacja zaniku/ciało
na ziemi → skrzynia w punkcie upadku z małym cieniem → subtelny błysk.

## 3. Czytelność ma pierwszeństwo przed detalem

- Środek areny: szeroki, ciemny i spokojny materiał.
- Detal: rogi, krawędzie, ściany, okolice drzwi i punktów fabularnych.
- Strefy zagrożenia, pociski, telegrafy i gracz muszą kontrastować z podłożem.
- Jednocześnie aktywne mogą być maksymalnie: główne zagrożenie, jeden efekt
  ataku, status i nagroda. Jeśli efekty się zlewają, zmniejszyć ich jasność,
  rozmiar lub czas, zamiast dodawać kolejne.

---

# Faza 0 — baza do oceny (najpierw)

## Zadanie Claude'a

1. Stworzyć jedną stałą scenę `reference_room` lub równoważny tryb debugowy:
   gracz, jeden mały wróg, Tank, skrzynia, portal/drzwi, aktywny telegraf,
   pocisk, nagroda i komplet UI.
2. Ustawić jeden stały rozmiar kamery i rozdzielczość referencyjną.
3. Dodać przełącznik debugowy pokazujący:
   - hitbox gracza;
   - hurtbox wroga;
   - obszar obrażeń ataku;
   - collider ścian i drzwi;
   - pozycję kontaktowego cienia.
4. Zrobić trzy referencyjne screenshoty: spokój, środek walki, pokój po
   oczyszczeniu. Każda późniejsza poprawka jest porównywana właśnie z nimi.

## Kryterium odbioru

W debugowym kadrze nie ma collidera widocznie wystającego poza „stopy”
postaci i nie ma obiektu bez ustalonego `z_index` oraz kontaktowego cienia.

---

# Faza 1 — składanie pokoju jak jednego miejsca, nie jak kolażu

## 1A. Podłoga, ściana i pustka poza pokojem

Stan docelowy:

- Podłoga jest osobną powierzchnią od ściany.
- Ściana ma własny materiał, ciemniejszą wartość i czytelną wysokość.
- Pustka poza pokojem jest ciemna i spokojna; nie konkuruje z areną.
- Krawędź pokoju ma rytm: ściana → cień pod ścianą → podłoga, bez nagłego
  cięcia tej samej tekstury.

Implementacja:

- Zachować nowe pliki `*_floor_v2.png` i `*_wall_v2.png` jako aktualny
  zestaw tekstur losowych pokojów.
- Nie modulować ściany tak mocno, aby stała się tylko czarną kopią podłogi.
- Dodać delikatny pas cienia przy wewnętrznej krawędzi ściany (nie vignette
  na środku walki).
- Sprawdzić powtarzanie na co najmniej siatce 3×3. Jeśli widać szew albo
  centralnie powtarzający się ornament, tekstura nie przechodzi odbioru.

## 1B. Drzwi i portale

Stan docelowy:

- Cztery kierunki używają osobnych grafik (`top`, `bottom`, `left`, `right`),
  a nie jednego obróconego sprite'a.
- Grafika drzwi leży nad ścianą, ale pod postacią; próg wchodzi w podłogę.
- Cień progu pada do wnętrza pokoju.
- Punkt przejścia gracza jest na środku otworu, a nie za ozdobnym portalem.

Do sprawdzenia:

- wszystkie cztery strony pokoju;
- przejście pod skosem i dash przez próg;
- brak widocznej kolizji w miejscu, w którym obraz pokazuje otwarte drzwi.

## 1C. Dekoracje

- Nie umieszczać dekoracji losowo w centrum areny.
- Jeden motyw dekoracji ma wzmacniać typ pokoju, nie mieszać stylów.
- Dekoracje podłogowe mają niższy kontrast niż postacie i efekty.
- Jeśli dekoracja może wyglądać jak pickup lub strefa obrażeń, należy ją
  usunąć albo przyciemnić.

## Kryterium odbioru fazy 1

Screenshot bez postaci nadal czyta się jako prawdziwy, zamknięty pokój.
Screenshot z postaciami nie wygląda jak podłoga + losowe PNG.

---

# Faza 2 — profesjonalna warstwa walki

## 2A. Kolejność renderowania

Wprowadzić i konsekwentnie stosować jeden kontrakt `z_index` (wartości można
dostosować, ważna jest relacja):

| Warstwa | Przykład |
|---|---|
| -20 | pustka poza pokojem |
| -10 | podłoga |
| -8 | cień ściany / ambient |
| -5 | ściana |
| -3 | drzwi i portal osadzony w ścianie |
| -1 | dekoracje podłogowe, cień kontaktowy |
| 0 | postacie, skrzynie, pickupy |
| 1 | pociski, małe efekty ataku |
| 2 | telegrafy i strefy zagrożenia |
| 3 | błyski trafienia i krytyczne efekty |
| 10 | UI |

Nie stosować wyjątków bez komentarza wyjaśniającego, dlaczego obiekt łamie
kontrakt.

## 2B. Telegraf → uderzenie → rezultat

Każdy atak wroga i gracza musi mieć trzy osobne, czytelne etapy:

1. **Zapowiedź:** maksymalnie prosty znak, widoczny przed obrażeniem.
2. **Uderzenie:** właściwy hitbox i krótki efekt kierunkowy.
3. **Rezultat:** błysk, dźwięk, mikro-odrzut albo zanik — bez zasłaniania
   następnego zagrożenia.

Wszystkie 11 archetypów wrogów powinny być rozpoznawalne po zachowaniu:

- strzelec wymusza ruch;
- Tank wymusza obejście/unik;
- mag lub Summoner daje czas na przerwanie czaru;
- Ambusher zdradza pozycję przed wypadem;
- Support nie może mieć efektu mylonego ze strefą obrażeń.

## 2C. Trafienie i „waga” gry

Minimalny zestaw dla trafienia:

- 0,03–0,08 s hit-stop tylko dla obiektu trafionego lub całej sceny w bardzo
  ograniczonej formie;
- mikro-odrzut od kierunku ciosu;
- krótki flash materiału, nie biały ekran;
- odpowiedni dźwięk;
- opcjonalnie małe drżenie kamery wyłącznie przy ciężkich atakach.

Nie nakładać długiego shake'a, pełnoekranowego blasku i dużego VFX naraz.
„Ciężar” ma być odczuwalny, nie męczący.

## 2D. Uczciwe hitboxy

- Hitbox gracza: mały i stały względem stóp.
- Hitbox pocisku: zgodny z widocznym rdzeniem, nie z całym blaskiem.
- Telegraf musi być odrobinę większy niż realna strefa obrażeń, nigdy mniejszy.
- Duże potwory: obrażenia przy kontakcie liczone od dolnej części ciała, nie
  od całej szerokości grafiki.
- Dash: gracz widzi jasno, kiedy jest nietykalny i kiedy już nie jest.

## Kryterium odbioru fazy 2

Gracz, oglądając nagranie bez HUD-u debugowego, potrafi poprawnie wskazać
źródło każdego otrzymanego obrażenia.

---

# Faza 3 — animacja i nowy pakiet 252 pozycji

## Stan assetów

Wygenerowano komplet **252/252** kierunkowych pozycji:

- gracz: 40;
- 6 wcieleń: 172;
- Nemorax: 40.

Pliki leżą bezpośrednio w folderach:

- `assets/sprites/gracz/`
- `assets/sprites/wcielenia/<postać>/`
- `assets/sprites/nemorax/`

Nazewnictwo: oryginalny plik pozy + `_front_diagonal`, `_side`,
`_back_diagonal`, `_back`.

## Zadanie Claude'a

1. Nie generować nowych wariantów i nie zastępować gotowych plików.
2. Użyć istniejącego `Facing.resolve()` / istniejącego systemu 5 kierunków.
3. Dla każdej pozy dodać słownik `front`, `front_diagonal`, `side`,
   `back_diagonal`, `back`.
4. Skierować akcje gracza według kursora, chód i śmierć według ruchu/
   ostatniego kierunku.
5. Skierować wcielenia oraz Nemoraxa według istniejącego kierunku do gracza.
6. Zachować fallback do `front` wyłącznie jako zabezpieczenie, nie normalny
   sposób renderowania ukończonych póz.

## Ważne

Najpierw podpiąć jeden pełny pakiet i go uruchomić (gracz), potem wcielenia
po jednej postaci, na końcu Nemorax. Nie robić masowego replace bez kontroli
nazw plików.

## Kryterium odbioru

Automatyczny skrypt weryfikuje, że każda z 252 grafik:

- istnieje;
- ma referencję w słowniku wariantów lub jest celowo oznaczona jako nieużyta;
- nie powoduje błędu ładowania zasobu.

---

# Faza 4 — nagrody, śmierć i mikro-pętla pokoju

Pętla pokoju ma dawać małą nagrodę emocjonalną:

1. wejście — krótki oddech, orientacja;
2. drzwi zamykają się czytelnie;
3. walka rośnie, ale środek pozostaje czytelny;
4. ostatni wróg ginie z wyraźnym końcem;
5. pół sekundy spokoju;
6. skrzynia lub nagroda pojawia się na podłodze, z małym złotym światłem;
7. drzwi otwierają się i gracz widzi dalszą drogę.

Nie dodawać wielkiej plamy światła pod skrzynią. Światło ma wskazywać nagrodę,
nie przyćmiewać pomieszczenie.

---

# Faza 5 — dźwięk, kamera i tempo

Te elementy mają ogromny wpływ na „feeling”, choć są małe wizualnie.

## Kamera

- Bez ciągłego kołysania.
- Mikro-shake tylko przy ciężkim trafieniu, dużym dashu lub fazie bossa.
- Nie przesuwać kamery podczas precyzyjnego uniku.
- Po wejściu do pokoju kamera powinna ustabilizować gracza przed startem walki.

## Dźwięk

- Atak ma czytelny start, kontakt i pudło.
- Różne materiały mają różne odpowiedzi: metal, kość, magia, kamień.
- Ostatni wróg i otwarcie drzwi potrzebują satysfakcjonującego, ale krótkiego
  sygnału.
- Muzyka nie może zagłuszać telegrafów i trafień.

## Tempo

- Normalny pokój: około 20–45 sekund decyzji i walki, nie ściana HP.
- Po walce: krótka cisza przed nagrodą.
- Boss ma zmieniać wzór, nie tylko zwiększać tempo i liczbę efektów.

---

# Kolejność wdrożenia

1. Faza 0: stała scena referencyjna + debug hitboxów.
2. Faza 1: kompletne osadzenie pokoju (ściana/podłoga/drzwi/cienie).
3. Faza 2D: hitboxy i czytelność telegrafów.
4. Faza 3: podpięcie 252 pozycji po pakietach.
5. Faza 4: sekwencja śmierć → nagroda → otwarcie drzwi.
6. Faza 5: kamera, dźwięk i micro-feedback.
7. Na końcu: nagranie pełnego runu od startu i korekty wyłącznie na podstawie
   rzeczy, które realnie rozpraszają albo psują czytelność.

## Czego nie robić teraz

- Nie przebudowywać całej gry na nowy silnik, Spine lub nowy pipeline.
- Nie dodawać kolejnych typów wrogów, zanim istniejący nie są czytelni.
- Nie maskować problemów z grafiką mocniejszym bloomem, vignette lub
  przyciemnieniem całego ekranu.
- Nie poprawiać pojedynczego assetu w izolacji bez oglądania go w pokoju
  razem z graczem, przeciwnikiem, światłem i UI.

## Raport Claude'a po każdej fazie

Po każdej fazie Claude ma podać:

1. co zmienił;
2. w jakich plikach;
3. co przetestował;
4. czego nie dało się potwierdzić bez playtestu użytkownika;
5. jeden screenshot „przed/po”, jeśli zmiana jest wizualna.

