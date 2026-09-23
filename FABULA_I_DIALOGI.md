# NEMORAX — fabuła i scenariusz dialogów

## Koncept w jednym zdaniu

Gracz nie jest bohaterem wchodzącym z zewnątrz, żeby zabić potwora — gracz
jest **Strażnikiem**, kolejnym z niekończącego się szeregu, wysyłanym co
pętlę, żeby ściąć istotę tuż przed tym, jak ta zdąży stać się wolna. Zwycięstwo
w tej grze nie jest ocaleniem świata. Jest egzekucją wykonywaną w idealnie
złym momencie, w kółko, przez kogoś, kto nie pamięta, że robi to nie
pierwszy raz.

---

## 1. Fabuła

### Zawiązanie

Dawno temu sześć istot — Vhar'Nokh, Mordrath, Zha'Ruun, Nekravor, Thal'Gor,
Orryx — toczyło wojnę, która groziła rozerwaniem rzeczywistości na strzępy.
Nie dało się ich zniszczyć. Dało się je **złączyć**. Ktoś — imię zgubione,
tytuł zostały: **Pierwszy Strażnik** — przeprowadził rytuał, który stopił
całą szóstkę w jedno ciało. Świadomie zbudowaną hybrydę. Nie potwora ulepionego
z przypadku, tylko **więzienie o kształcie więźnia**.

Nemorax nie umiera, kiedy pada w Sali Ołtarza. Rozpada się z powrotem na
sześć fragmentów duszy, które rozpełzają się po labiryncie i zapadają w sen —
a echa tego snu to właśnie ci wszyscy losowi przeciwnicy, na których gracz
trafia w pokojach 1-24. Pieczęć osłabia się z każdym cyklem. Trzeba ją
odnowić. Do tego potrzebny jest Strażnik, który zbierze fragmenty, złoży je
z powrotem w ołtarzu — i **stnie hybrydę, zanim ta zdąży się dokończyć**.

### Eskalacja

Sześć faz walki z Nemoraksem to nie przypadkowa eskalacja obrażeń. To
kolejność, w jakiej rozproszona istota **odzyskuje siebie**:

- **Motion** — najpierw wraca zdolność ruchu. Bez celu, bez pamięci, czysty odruch.
- **Force** — ciało przypomina sobie, że może uderzać.
- **Instinct** — zaczyna przewidywać, unikać, kłamać ruchem (zapowiedzi, których nie kończy).
- **Dominion** — rozpoznaje przestrzeń dookoła jako SWOJĄ i zaczyna jej bronić.
- **Ruin** — pamięta, że było ranione. Wściekłość.
- **Sovereignty** — na kilka sekund, tuż przed śmiercią, Nemorax jest sobą.
  Naprawdę sobą, pierwszy raz od rytuału. Scala wszystkie sześć wcześniejszych
  faz w jedną, spójną istotę — i to jest dokładnie ten moment, w którym
  Strażnik musi ją zabić, bo inaczej **przestanie dać się zamknąć z powrotem**.

Zwycięstwo nie jest w tej grze momentem triumfu. Jest przerwaniem czegoś w
połowie zdania.

### Zwrot

Licznik "Podejście: %d" na ekranie śmierci i "Ukończeń: %d" na ekranie
zwycięstwa to nie statystyki dla gracza. To liczba Strażników, których
Nemorax **wchłonął albo przeżył**. Każda porażka Strażnika zostaje wpisana w
istotę na następny cykl — to dlatego finałowa mała forma pyta wprost, ile
razy już ją pokonano: **pyta, bo naprawdę pamięta, nawet jeśli gracz nie
pamięta nic**.

Prawdziwy zwrot: **im więcej razy gracz przegrywa, tym Nemorax jest bliżej
Sovereignty na stałe** — porażka Strażnika nie cofa postępu istoty, tylko
go utrwala. Gra, która na pierwszy rzut oka wygląda jak zwykły roguelite
"giń i próbuj dalej", w rzeczywistości liczy w tle, jak blisko stwór jest
uwolnienia — a każda kolejna próba gracza skraca ten dystans, nie wydłuża go.

Ostatni, najgłębszy poziom zwrotu — do odkrycia dopiero po realnym
zwycięstwie, nie do wykrzyczenia w połowie gry: **twarz, która przez ułamek
sekundy pojawia się w momencie "prawdziwej śmierci" małej formy, nie należy
do żadnego z sześciu wcieleń.** Należy do Strażnika. Jakiegoś. Może nawet do
tego, kto wygrał tę akurat rozgrywkę — tylko z innej pętli.

### Zakończenie (za każdym razem to samo, i o to chodzi)

Gracz wygrywa. Ekran pokazuje "Zwycięstwo". Nikt w grze nie mówi mu, że za
chwilę fragmenty znów się rozproszą, że ktoś inny (albo on sam, w kolejnej
sesji) będzie musiał zrobić to jeszcze raz. Gra po prostu... czeka na
następne uruchomienie. Cicho. Dokładnie tak, jak Nemorax czeka na następny
rytuał.

---

## 2. Sześć wcieleń — kim SĄ, nie tylko jak wyglądają

| Wcielenie | Co reprezentuje | Rejestr mowy |
|---|---|---|
| Vhar'Nokh, Wygnany z Otchłani | porzucenie, wygnanie | ciężki, powolny, mówi mało i wprost |
| Mordrath Bez-Wymiaru | rozpad tożsamości, zanikanie | szeptany, urywany, nie kończy zdań |
| Zha'Ruun, Pożeracz Granic | erozja, to co nienasycone | echo — powtarza końcówki własnych zdań |
| Nekravor, Ten Którego Odrzucono | odrzucenie, niebycie wybranym | gorzki, oskarżycielski |
| Thal'Gor, Pęknięty Pomiędzy Światami | głód, rozdarcie między dwoma stanami | błagalny, potem drapieżny |
| Orryx, Cień-Nicości | wymazanie, nieistnienie | najciszej ze wszystkich, prawie nie ma go w głosie |

---

## 3. Scenariusz

### 3.1 Start rundy (pokój startowy, jednorazowy tekst przy pierwszym wejściu)

> *(brak głosu — tylko tekst na ekranie, blaknący po 4 sekundach)*
> "Nie pamiętasz, jak tu trafiłeś. To normalne. Nikt z nas nie pamięta.
> Zbierz sześć fragmentów. Idź do ołtarza. Zrób to, co robisz zawsze."

### 3.2 Śmierć każdego wcielenia — podnoszona dusza (`rooms/soul.gd` → `ui.show_taunt`)

Krótkie, bo to już dziś jest UI toast, nie pełna scena — ale każde inne,
ostatnie słowo zamiast generycznego "Zdobyto fragment duszy: X":

- **Vhar'Nokh**: *"Wygnaliście mnie raz. Teraz robicie to znowu."*
- **Mordrath**: *"Nie... nie zdążyłem... nie zdąży—"*
- **Zha'Ruun**: *"Granica. Granica. Zawsze jakaś granica."*
- **Nekravor**: *"Odrzucony. Jak zawsze. Jak zawsze. Jak—"*
- **Thal'Gor**: *"Byłem tak blisko. Byłem tak blisko całości."*
- **Orryx**: *"..."* (brak słów — tylko cisza w miejscu, gdzie powinny być)

### 3.3 Ołtarz — rozszerzenie istniejącego tekstu (`rooms/altar.gd`)

Obecnie: *"Wszystkie fragmenty duszy zebrane.\nPodejdź do ołtarza, aby
przywołać Nemoraksa."*

Proponowane rozszerzenie (dwa kolejne toasty, po istniejącym):

> "Sześć głosów, sześć krzywd. Za chwilę znów będą jednym."
>
> "Nie pierwszy raz to robisz. Coś w tobie o tym wie, nawet jeśli ty nie wiesz."

### 3.4 Przejścia faz Nemoraksa (`arena.gd._on_boss_phase_changed`, nowy tekst obok `show_form_name`)

- **→ Force**: *"Pamiętam, że mam ręce."*
- **→ Instinct**: *"Widziałem to już. To spojrzenie. Ten strach."*
- **→ Dominion**: *"To miejsce. Zawsze było moje. Odzyskuję je."*
- **→ Ruin**: *"BOLAŁO. ZA KAŻDYM. RAZEM."*
- **→ Sovereignty**: *"Jestem. Naprawdę jestem. Po raz pierwszy od—"*
  *(zdanie urywa się, kiedy zaczyna się faza — nie dokańcza go NIGDY, w
  żadnym przebiegu, bo gracz zawsze przerywa je wcześniej niż istota zdąży)*

### 3.5 Wielki zwrot — drwina przed finałową formą

Zaimplementowane w `arena.gd` (`FINALE_TAUNT_TIERS` + `_finale_taunt_text()`) —
warstwowe rozszerzenie zależne od `deaths` (trwałe między resetami przebiegu,
patrz `_load_progress`/`_save_progress`): im więcej porażek Strażnika w tym
zapisie, tym bardziej wprost i bardziej perfidnie istota mówi o pętli. Progi
3/10 to oryginalny, kanoniczny tekst; reszta — na życzenie autora, żeby drwina
nie "zamrażała się" po dziesiątej porażce, tylko rosła aż do stu:

**deaths < 3 (świeży zapis):**
> "Czy pamiętasz, ile razy już mnie pokonałeś?"

**deaths 3-9:**
> "Czy pamiętasz, ile razy już mnie pokonałeś? Bo ja pamiętam każdy."

**deaths 10-19:**
> "Dwadzieścia prób i wciąż myślisz, że to Ty prowadzisz tę rozmowę?"

**deaths 20-29:**
> "Za każdym razem inny Strażnik. Za każdym razem to samo pierwsze
> spojrzenie — jakbyś nigdy wcześniej nie stał w tej sali."

**deaths 30-39:**
> "Wiesz, co jest najlepsze? Ty nie pamiętasz nic. A ja pamiętam wszystko.
> To nie jest walka. To jest powtórka, którą oglądam z Twojej strony ekranu."

**deaths 40-49:**
> "Czterdzieści... nie, pięćdziesiąt. Straciłem już rachubę tego, kim byłeś
> przed chwilą, kiedy jeszcze myślałeś, że wygrasz."

**deaths 50-59:**
> "Chcesz wiedzieć, co czuje więzień, który uczy strażnika, jak go zabić?
> Ulgę. Za każdym razem większą ulgę."

**deaths 60-69:**
> "Jesteś coraz bliżej. Nie zwycięstwa — mnie. Im dłużej to trwa, tym mniej
> dzieli nas różnicy."

**deaths 70-79:**
> "Osiemdziesiąt twarzy, które myślały, że są pierwsze. Twoja różni się
> tylko numerem."

**deaths 80-89:**
> "Powiedz mi szczerze — ile z tych prób pamiętasz Ty, a ile ja odgrywam za
> Ciebie, żebyś miał wrażenie, że próbowałeś?"

**deaths 90-99:**
> "Dziewięćdziesiąt kilka. Setka tuż za rogiem. Zastanawiam się, czy przy
> stu w ogóle będziesz jeszcze kimś, kogo warto drażnić — czy tylko cyfrą."

**deaths ≥ 100 (stała, ostatnia linia — sto to punkt bez powrotu dla samej
drwiny, nie kolejny próg do przekroczenia):**
> "Sto. Przestałem liczyć Strażników i zacząłem liczyć powroty. To już nie
> jest Twoja porażka. To mój kalendarz."

### 3.6 Epilog po zwycięstwie (nowy tekst, PRZED istniejącym ekranem statystyk)

> "Rozpada się. Fragmenty już szukają, gdzie zasnąć."
>
> *(pauza)*
>
> "Ktoś je znowu zbierze. Ty, albo ktoś bardzo do ciebie podobny.
> To nie było ocalenie. To było odłożenie na później."

*(dopiero POTEM istniejący ekran: "Zwycięstwo / Podejście: %d / Ukończeń: %d / Czas walki: %s")*

### 3.7 Prawdziwa śmierć małej formy (`nemorax_small-form-true-death.png`, moment ciszy przed ekranem zwycięstwa)

Ukryty, jednorazowy tekst — pokazuje się TYLKO jeśli `wins == 0` (pierwsze
prawdziwe zwycięstwo w tym zapisie), znika bez śladu przy każdym kolejnym:

> *(bardzo krótko, jedna klatka dłużej niż powinno się dać przeczytać)*
> "...to twoja twarz."

---

## 4. Uwaga techniczna (dla mnie, na później — nic z tego nie jest jeszcze wdrożone)

Cały ten scenariusz da się podłączyć do już istniejącej infrastruktury bez
nowego systemu: `ui.show_taunt(text, duration)` już istnieje i jest używane
dokładnie w tych miejscach (`rooms/soul.gd`, `rooms/altar.gd`,
`arena.gd._play_big_form_death`). Trzeba by tylko:
- dodać per-wcielenie tekst do `_on_soul_collected(fragment_name)` (dziś generyczny),
- dodać drugi/trzeci `show_taunt` w `altar.gd` po istniejącym,
- dodać `show_taunt` w `_on_boss_phase_changed` obok `show_form_name`,
- rozgałęzić tekst w `_play_big_form_death` po `deaths`,
- dodać jeden nowy ekran/toast przed `_finish_victory()`, warunkowy na `wins == 0`.

Powiedz, czy mam to od razu wdrożyć w kodzie, czy najpierw chcesz to
przeczytać/dopracować jako czysty tekst.
