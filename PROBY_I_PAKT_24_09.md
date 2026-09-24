# Próby deterministyczne, Pakt i skrót (audyt nagrania 24.09, P1.9–P1.12)

Wszystkie liczby pochodzą z bota. Bot stoi przy celu i bije bez uników, więc daje **górną granicę przyjętych obrażeń i dolną granicę czasu**. Mnożnik „człowiek ≈ bot × 1,6” **nie jest zatwierdzonym balansem**: to hipoteza oparta na jednym niepełnym nagraniu. Tu porównuję warianty, a nie odtwarzam człowieka. Nagrania dwóch pełnych prób są po stronie autora.

„Dolewka” oznacza, że HP bota spadło poniżej 25% i zostało uzupełnione. To moment, w którym człowiek najpewniej by zginął.

## P1.9 — dwie pełne próby × wydawanie punktów

Polecenie: `Godot --headless --fixed-fps 60 --script res://debug/measure_run.gd -- <ziarno> <spend|skip>`
Trasa to minimalna droga do 6 dusz, potem finał. Intencja: Ostrze.

- **spend:** punkty idą od razu (obrażenia i zdrowie na zmianę), a bot bierze pierwszą ofertę runy.
- **skip:** bot nic nie wydaje, tak jak na nagraniu, gdzie „[R] Runa do wyboru” i punkty wisiały długo.

| Ziarno | Polityka | Pokoi | Walka na trasie | Przyjęte HP (trasa) | Dolewki (trasa) | Finał | Przyjęte HP (finał) | Dolewki (finał) | Niewydane na końcu |
|---|---|---|---|---|---|---|---|---|---|
| 5003 | spend | 18 | 286 s | 239–249 | 1 | 118–120 s | 280–362 | 1–3 | 0 pkt, 0 run |
| 5003 | skip | 18 | 709 s | 707 | 3 | 376 s | 1225 | **30** | 20 pkt, 10 run |
| 5011 | spend | 19 | 364–366 s | 176–219 | 0 | 148–151 s | 488–528 | 4–5 | 0 pkt, 0 run |
| 5011 | skip | 19 | 713 s | 449 | 0 | 375 s | 1249 | **27** | 20 pkt, 10 run |

Źródła obrażeń (5003, spend):

- Na trasie najwięcej zabierają kontakt Kolosa, kontakt Nekravora i kontakt Zha’Ruuna.
- W finale najwięcej zabierają pulsy, potem cienie i kontakt.

**Wniosek:** gdy gracz nie wydaje punktów i run, trasa trwa ~2,5× dłużej, a finał ~3× dłużej, z 27–30 momentami bliskimi śmierci zamiast 1–5. Śmierć z nagrania (poziom 4, niewydana runa i punkty) pasuje do tego obrazu. Dlatego zmieniam czytelność przypomnienia (P1.10), a HP bossów zostaje bez zmian.

**P1.10, co się zmieniło:**

- W walce przyciski nagród zwijają się do przygaszonej plakietki, która nie przykrywa paska HP.
- Po oczyszczeniu pokoju pojawia się jedno wyraźne przypomnienie („Pokój czysty — nagrody czekają”) na 2,5 s. To samo przypomnienie nie wraca częściej niż co 45 s.
- Nic nie otwiera się samo.

## P1.11 — Pakt Mordratha: Oczyść kontra Zwiąż

Polecenie: `measure_pact.gd -- <oczysc|zwiaz> medium`. Po 3 przebiegi na wariant, build średni (poziom 7).

| | Oczyść ciszę | Zwiąż ciszę |
|---|---|---|
| Cały finał | 159,0–159,4 s | 159,8–160,1 s |
| Faza Siła: czas / wzorce | 21,1 s / 20 | 21,2–21,3 s / 20 |
| Faza Siła: przyjęte HP | 130–148 | 194–218 (pieczęcie 60–100, pierścień F4 16) |
| Faza Siła: dolewki | 0 | 1 |
| Maks. stamina | 150 (+20) | 130 |

Wartość pola ciszy (`measure_run`): przy każdym blokowalnym ciosie w zasięgu 160 px stał **dokładnie 1 wróg** (n = 44, dwa ziarna). To ten sam wróg, którego samo parowanie już przerywa. Bot trzyma się jednego celu, więc to dolna granica. Człowiek w grupie może złapać więcej wrogów, ale nie mam na to dowodu.

**Wnioski i propozycje. Nie wdrożone — decyzja autora po próbie:**

1. „Zwiąż” ma dziś wyraźny koszt w finale (+60–90 HP w fazie Siła, 1 moment bliski śmierci) i mało widoczny zysk w pokojach. Istnieje ryzyko, że jest opcją „dla eksperta”. Zgodnie z audytem trzeba to poprawić, **zanim** system trafi na pozostałe 5 wcieleń.
2. Najmniejsza odwracalna zmiana do sprawdzenia: promień ciszy 160 → 220 px i czas 1,2 → 1,6 s. Alternatywa: cisza także na **zwykłym** bloku, słabsza (0,6 s). Drugi wariant pomaga średniemu graczowi, który rzadko paruje.
3. „Oczyść”: +20 staminy daje ~1–2% mniej odmów u bota, który bije bez przerwy. Realną wartość (dodatkowy blok lub dash) pokaże dopiero laboratorium tarczy i gra człowieka.
4. Obie karty są czytelne przed kliknięciem (nagranie: wybrano „Oczyść” świadomie). Brakuje próby „Zwiąż” i fazy Siła z człowiekiem.

## P1.12 — skrót na mapie (decyzja odłożona)

Dane z tras (200 ziaren, `measure_route.gd`):

- minimalna trasa ma 18–29 pokoi (mediana 23);
- najgłębszy cel leży 4–10 przejść od startu;
- pełna mapa ma 32 pokoje.

Na trasie ziarna 5003 do pierwszej duszy prowadzi 8 walk (~44 s bota). Dalsze dusze leżą blisko siebie: 1–3 walki między nimi.

**Rekomendacja:** skrótu nie wdrażać. Nuda ponownego dojścia dotyczy głównie odcinka do pierwszej duszy, a tę rolę częściowo pełni już Komnata Echa (trening wcielenia bez trasy). Jeśli po próbie z dwoma graczami odcinek do pierwszego wcielenia okaże się nużący, zrobić prototyp **jednej** odnogi: krótszej o 3–4 walki, bez skrzyni i z elitą na wejściu. Wymaga to decyzji autora.

## Co pozostaje hipotezą

- Przelicznik bot → człowiek.
- Realna częstość parowań u nowego i średniego gracza.
- Wartość pola ciszy w grupie, gdy gracz się rusza.
- Czy przypomnienie o nagrodach wystarczy, żeby gracz wydawał punkty przed wcieleniem.
