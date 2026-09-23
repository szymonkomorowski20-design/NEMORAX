# NEMORAX — pomiary walki (AUDYT, Paczki 2 i 4)

Narzędzie: `debug/measure_boss_fight.gd`

```
Godot_v4.7.2-stable_win64.exe --headless --fixed-fps 60 --script res://debug/measure_boss_fight.gd -- <naked|sword|wand|hybrid>
```

**Co mierzy:** bot jest nietykalny, zawsze stoi w zasięgu i atakuje bez przerwy.
To **górna granica ofensywy** (idealny gracz bez uników), nie nagranie rundy
człowieka. Prawdziwy gracz traci czas na uniki, podchodzenie i przerwy, więc
jego czasy będą dłuższe. Hitstop wyłączony (flaga redukcji migotania), bo
zamraża czas rzeczywisty; na obrażenia nie wpływa. Zapis izolowany.

## Buildy (poziom 10 = 20 punktów statystyk, 10 rang umiejętności)

| Build | Statystyki | Umiejętności | Relikwie |
|---|---|---|---|
| naked | poziom 1, awansuje w walce (bot wybiera 1. ofertę) | — | — |
| sword (mocny) | obrażenia 10, stamina 5, reg. staminy 5 | Podwójny cios 2, Trzeci rytm 1, Łamacz pancerza 2, Żywa rana 2, Ostrze echa 2, Długa krawędź 1 | Blood Edge, Second Impact, Hunter's Mark, Momentum, Razor Wind |
| wand (mocny) | obrażenia 10, mana 6, życie 4 | Rozszczepienie 2, Echo salwy 2, Szybkie runy 3, Splot many 3 | Blood Edge, Second Impact, Hunter's Mark, Momentum, Soul Echo |
| hybrid (średni) | obrażenia 6, życie 6, stamina 4, mana 4 | Podwójny cios 1, Rozszczepienie 1, Rytm walki 1, Przeplot 1, Pęknięcie 1, Kamienna skóra 2, Lekkie kroki 1, Długa krawędź 1, Szybkie runy 1 | Iron Heart, Second Impact, Momentum |

## Paczka 2 — stan przed strojeniem bossa (23.09.2026)

Nemorax: 6 faz × 100–115 HP + mała forma 150 HP = **790 HP łącznie**.
Cel z audytu (sekcja B): mocny build **90–150 s**, średni **150–240 s**.

| Build | Cały finał | DPS | Wzorce bossa na fazę | Obrażenia wtórne | Uwagi |
|---|---|---|---|---|---|
| naked | **92,4 s** | 8,4 | 4–14 | 2% | 1568 odmów staminy — stamina to jedyny limit |
| sword | **18,3 s** | 42,9 | **0–2** | **56%** (Podwójny cios 22%, Łamacz 11%, Fala 10%, Trzeci 6%, krwawienie 4%, Second Impact 3%) | 197 odmów staminy |
| wand | **nie kończy** (stoi na fazie 2) | 0,3 | — | — | mana wyczerpana po ~12 strzałach, 595 s bez many |
| hybrid | **23,9 s** | 32,8 | 1–3 | 45% | działa dzięki przełączaniu na miecz |

Wnioski:
1. Mocny build miecza przechodzi każdą fazę w ~3 s, a boss wykonuje w niej 0–2 wzorce. Mechaniki faz w ogóle nie zdążają wybrzmieć (A2, A10). Nawet goły build (92 s) jest tylko na dolnej granicy celu dla *mocnego*.
2. Połowa obrażeń mocnego builda pochodzi z efektów wtórnych. Nie ma już jednak kaskad: efekty wtórne nie nabijają proców, many ani leczenia (test `test_twin_and_third_cut_on_boss_are_secondary_without_cascade`).
3. **Czysta różdżka nie może skończyć walki.** Strzał kosztuje 19–25 many, pierwotne trafienie zwraca 15, a mana w walce nie regeneruje się z czasem. Zgodnie z audytem nie dodano regeneracji w walce, tylko powolną (10/s) *poza walką*. **Decyzja dla autora:** czy mag ma dobijać manę mieczem (tak jest teraz), czy dostać osobne źródło many w walce.
4. Przyczyną A2 (29 s w nagraniu) są przede wszystkim małe pule HP faz względem bazowego DPS, a dopiero w drugiej kolejności efekty wtórne. Strojenie w Paczce 4 musi objąć oba.

## Ekonomia leczenia — wariant C

Przed: 50% maks. HP co 10 trafień, 3 zapasy, natychmiast.
Po: **30% co 12 pierwotnych trafień, 2 zapasy, użycie 0,55 s przerywane trafieniem**, przyzwańcy bez XP nie ładują leczenia (manę nadal zwracają).

| Build | Zapasy naładowane w walce | Na minutę |
|---|---|---|
| naked | 2 | 1,3 |
| sword | 1 | 3,3 |
| hybrid | 2 | 5,0 |

Po wydłużeniu walk w Paczce 4 liczby bezwzględne wzrosną — tę tabelę trzeba wtedy zmierzyć ponownie.
