# NEMORAX — wzorce wcieleń i faz finału (AUDYT, Paczka 4 pkt 2)

Stan kodu na 23.09.2026, spisany z `entities/incarnations/*.gd` i `entities/boss.gd`.
Każde wcielenie przed umiejętnością pokazuje wspólny telegraf **0,5 s** (poniżej 45% HP: ×0,85). Odstęp między umiejętnościami 2,2 s. Wszystkie pulsy i wypady są blokowalne tarczą od frontu; strefy na podłożu i pieczęcie Nemoraksa — nie.

## Sześć wcieleń

| # | Wcielenie | Wzorce (liczby z kodu) | Lekcja | Okno na kontrę |
|---|---|---|---|---|
| 0 | **Vhar'Nokh** (Zalążek) | teleport + wypad (420 px/s, 0,3 s); niestabilny wybuch r 50–130, 12 obr.; podwójne mignięcie; teleport → wybuch 0,3 s później | Po teleporcie nie stój w miejscu — odskocz od punktu pojawienia się | Po wypadzie, zanim zacznie się następny telegraf |
| 1 | **Mordrath** (Cisza) | puls ciszy r 90, 14 obr.; przyciąganie → puls po 0,2 s; cichy szarż (360 px/s, 0,4 s) | Na telegrafie wyjdź poza 90 px albo trzymaj tarczę; przyciąganie przerywaj dashem | Po szarży |
| 2 | **Zha'Ruun** (Zwłoka) | puls-echo r 80 ×2 (drugi po 0,35 s); zacinający się wypad ×2 (przerwa 0,25 s); cofające przyciąganie | Nie wracaj po pierwszym pulsie — przyjdzie echo | Po drugim wypadzie |
| 3 | **Nekravor** (Ciężar) | przyciąganie grawitacji → puls r 70, 16 obr. po 0,2 s; miażdżący puls r 110, 20 obr.; wypad z przyciąganiem; wypad → miażdżenie | Duży promień miażdżenia — szanuj dystans; przyciąganie przerywaj bokiem/dashem | Po miażdżeniu; **pilotaż postawy** (niżej) |
| 4 | **Thal'Gor** (Głód) | ugryzienie-wypad (lifesteal 50%); żarłoczny puls r 85, 12 obr., leczy go; przyciąganie + ugryzienie | Każde przyjęte trafienie go leczy — blok/unik odbiera mu leczenie (zablokowane ugryzienie już nie leczy) | Po ugryzieniu |
| 5 | **Orryx** (Zaćmienie) | znikające uderzenie (0,4 s niewidzialny, pojawia się 150 px od gracza, wypad); migotliwy puls r 90; mroczne przyciąganie + puls r 75 w tej samej chwili | W czasie zniknięcia ruszaj się — nie czekaj w miejscu | Po wypadzie z pojawienia się |

### Pilotaż postawy (E1) — tylko Nekravor

- Postawę nabijają **wyłącznie trafienia pierwotne** (raz na atak i cel), cios z okna kontry po bloku liczy się podwójnie; efekty wtórne nic nie dają.
- Próg: 20% maks. HP. Przełamanie = **1,6 s odsłonięcia** (bez ruchu, ataków i obrażeń od dotyku), potem **6 s odporności** i próg ×1,3. Bez trafień przez 3 s postawa wraca do równowagi.
- Wskaźnik: cienka kremowa linia pod paskiem HP; w odporności przerywana.
- Pomiar (bot): długość walki **bez zmian** (bot nie musi unikać, więc nie zyskuje na odsłonięciu), 1–2 przełamania na walkę, wcielenie wykonuje o ~1 umiejętność mniej. **Ocena przyjemności wymaga gry człowieka** — dopiero potem decyzja, czy rozszerzać na pozostałe wcielenia.

### Znalezione problemy czytelności (świadomie NIE poprawione w tej paczce)

Audyt zabrania łączenia postawy, nowych wzorców i nowego HP w jednej zmianie. Do poprawy po ocenie pilotażu:
1. **Vhar'Nokh** — promień wybuchu jest losowy (50–130) i nigdzie nie pokazany przed wybuchem. Gracz nie ma jak ocenić bezpiecznej odległości.
2. **Mordrath, Nekravor** — przyciąganie → puls po 0,2 s, krócej niż czas reakcji. Realnym ostrzeżeniem jest wyłącznie wcześniejszy telegraf.
3. **Orryx** — mroczne przyciąganie i puls w tej samej klatce.

## Fazy finału (test A10)

Każda faza ma rozłączny zestaw wzorców i własną regułę łamania zasad (`arena.gd`, `_on_boss_phase_changed`). Sprawdza to test `test_finale_phases_have_distinct_threats`.

| Faza | Wzorce | Reguła | Zagrożenie mechaniczne |
|---|---|---|---|
| 0 Motion | M1 wypad; M2 wypad + krótki cios; M3 wypad z powrotem | — | czytanie toru wypadu |
| 1 Force | F1 szeroki cios; F2 pieczęcie (nieblokowalne); F3 napór krokami | wyciszony dźwięk | obszar, czytanie wyłącznie wzrokiem |
| 2 Instinct | I1 przestawienie + cios; I2 zmyłka; I3 szybki cios | cooldown dasha ×2 | timing bez częstego dasha, zmyłki |
| 3 Dominion | D1 strefa; D2 wachlarz pocisków; D3 przyzwanie; D4 strefa + wachlarz; D5 blokada Otchłani | stałe przyciąganie do bossa | kontrola przestrzeni pod prąd |
| 4 Ruin | R1 wypad z cięciem; R2 łańcuch ciosów; R3 pościg | — | presja i dłuższe sekwencje |
| 5 Sovereignty | S1–S3 kombinacje wcześniejszych faz; S4 sekwencja korony (częstsza < 50% HP) | mrok poza kręgiem | synteza pod ograniczoną widocznością |

Uwaga: „kombinacje stref zawsze pozostawiają drogę ucieczki” (D1/D4) nie ma jeszcze automatycznego testu geometrycznego — do sprawdzenia w nagraniu albo w Paczce 5 razem z testami bezpieczeństwa pułapek.

W mroku (faza 5) nakładka leży **pod** postaciami (`vision_overlay.gd`, z_index −1), więc gracz, wrogowie i telegrafy są zawsze w pełni widoczni, a krąg podąża za graczem.
