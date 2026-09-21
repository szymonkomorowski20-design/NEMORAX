# NEMORAX — plan wdrożenia cutscenek + jak mają wyglądać sceny

Bazuje na `FABULA_I_DIALOGI.md`. To jest PLAN, nic z tego nie jest jeszcze
wdrożone w kodzie — czeka na Twoje "tak, jedziemy".

---

## 0. Najważniejsza decyzja projektowa: nie wszystko jest "cutscenką"

Gra jest roguelite — gracz przechodzi rytuał ołtarza i walkę z Nemoraksem
**wielokrotnie, w każdym przebiegu**. Pełna, ciężka cutscenka za każdym razem
w tym samym miejscu (zwłaszcza przy każdej z 6 zmian fazy bossa — to
zdarza się w KAŻDEJ walce) zabiłaby tempo po 3. podejściu. Dzielę więc
scenariusz z `FABULA_I_DIALOGI.md` na dwie kategorie:

| Kategoria | Co to jest | Pauzuje grę? | Przykłady |
|---|---|---|---|
| **CUTSCENKA** | Pełna scena: portret, imię, tekst, głos, przyciemnione tło | TAK | Prolog, Rytuał Ołtarza, Upadek Wielkiej Formy (twist), Epilog Zwycięstwa |
| **OKRZYK (bark)** | To, co już dziś robi `ui.show_taunt()` — toast w rogu ekranu, + teraz opcjonalnie krótki głos | NIE | Podniesienie duszy (x6), zmiana fazy bossa (x6), ekran śmierci gracza |

Cutscenki grane są **rzadko i tylko raz na naprawdę ważny moment**. Okrzyki
lecą swobodnie, bo gracz i tak jest w ruchu/walce.

---

## 1. System cutscenek — plan techniczny

### 1.1 Dane: `DialogueBeat` (nowy `Resource`)

```gdscript
class_name DialogueBeat
extends Resource

@export var speaker_name: String = ""       # "" = brak etykiety (np. narrator/tekst bez twarzy)
@export var portrait: Texture2D = null      # opcjonalny, jeśli brak -> tylko tekst
@export var text: String = ""
@export var voice_clip: AudioStream = null  # opcjonalny — działa BEZ tego, patrz 1.3
@export var fallback_seconds: float = 3.0   # ile trzyma się na ekranie, jeśli NIE MA jeszcze nagranego głosu
@export var background_tint: Color = Color.BLACK # tło pod portretem/tekstem, np. kolor aktualnej fazy Nemoraksa
```

Każda scena to po prostu `Array[DialogueBeat]` — plik `.tres` albo tablica
budowana w kodzie. Nowa scena = nowa lista beatów, zero nowego kodu.

### 1.2 Odtwarzacz: `ui/cutscene_player.gd` (nowy, wzorem `ui/pause_menu.gd`)

- `CanvasLayer` + `Control`, `process_mode = PROCESS_MODE_ALWAYS`,
  `get_tree().paused = true` na czas trwania — **dokładnie ten sam
  mechanizm co już istniejące `PauseMenu`/`StatsScreen`/`KeybindScreen`**,
  żadnego nowego wzorca.
- Publiczne `play(beats: Array[DialogueBeat]) -> void` (async, `await`
  na końcu każdego beatu) + sygnał `finished`.
- Pełnoekranowe półprzezroczyste tło (`background_tint` beatu, alpha ~0.85) +
  portret wyśrodkowany/przesunięty w bok + pasek z `speaker_name` + `text`.
- **Skip**: dowolny klawisz akcji (np. `attack`/`ui_accept`) w trakcie
  odtwarzania beatu = natychmiast przechodzi do następnego; przytrzymanie
  przez >0.5s = pomija CAŁĄ resztę cutscenki. Bez tego drugie i kolejne
  podejście do gry będzie frustrujące.

### 1.3 Głos kontra brak głosu — działa od pierwszego dnia, bez nagrań

```gdscript
func _play_beat(beat: DialogueBeat) -> void:
    _show_text(beat)
    if beat.voice_clip:
        voice_player.stream = beat.voice_clip
        voice_player.play()
        await voice_player.finished
    else:
        await get_tree().create_timer(beat.fallback_seconds, true).timeout
```

To jest kluczowe pod Twój warsztat: **piszę i podłączam WSZYSTKIE sceny już
teraz, testowalne i grywalne z samym tekstem** (fallback_seconds). Kiedy
nagrasz głos do konkretnej postaci, wrzucasz plik `.wav` do
`voice_clip` tego beatu — zero zmian w reszcie kodu, linijka po linijce, w
dowolnej kolejności, nie musisz nagrać wszystkiego naraz.

### 1.4 Rozszerzenie istniejących okrzyków (`ui.show_taunt`)

```gdscript
func show_taunt(text: String, duration: float = 2.0, voice: AudioStream = null) -> void:
    if voice:
        # AudioStreamPlayer na busie "Voice" (patrz sekcja 3), nie blokuje reszty UI
        _voice_player.stream = voice
        _voice_player.play()
    ...istniejąca logika toastu bez zmian...
```

Jedna nowa, opcjonalna linijka w istniejącej funkcji. Wszystkie 20+ miejsc,
które już dziś wołają `show_taunt(...)`, działają bez zmian (parametr
domyślny `null`).

---

## 2. Jak mają wyglądać konkretne sceny

### 2.1 PROLOG — "Nie pamiętasz, jak tu trafiłeś"

**Kiedy**: raz na zapis, przy pierwszym wejściu do pokoju startowego
(`GameFlow` dostaje nowe pole `seen_prolog: bool`, zapisywane na dysk jak
`fragments_collected`). Nigdy więcej się nie powtarza w tym zapisie.

**Wygląd**: ekran całkiem czarny (nie tło pokoju — czerń pod wszystkim).
Brak portretu — to głos bez twarzy, jakby coś mówiło zza kadru. Tekst
pojawia się linijka po linijce (3 beaty, każdy ~2s bez głosu):

1. *(bez etykiety)* "Nie pamiętasz, jak tu trafiłeś."
2. *(bez etykiety)* "To normalne. Nikt z nas nie pamięta."
3. *(bez etykiety)* "Zbierz sześć fragmentów. Idź do ołtarza. Zrób to, co robisz zawsze."

Po ostatnim beacie: zwykłe cięcie (bez fade'a) na pokój startowy, gra się
zaczyna. Głos: neutralny, zmęczony, jakby powtarzał tę kwestię tysiące razy
(bo powtarza).

### 2.2 RYTUAŁ OŁTARZA — rozszerzenie istniejącej sceny

**Kiedy**: zamiast dzisiejszego pojedynczego `ui.show_taunt("Wszystkie
fragmenty...")`, po dotarciu do stanu READY.

**Wygląd**: NIE pauzuje jeszcze gry na tym etapie (gracz wciąż może podejść
do ołtarza kiedy chce) — to zwykłe okrzyki, ale teraz DWA zamiast jednego,
z 1.5s odstępem:
1. "Wszystkie fragmenty duszy zebrane. Podejdź do ołtarza, aby przywołać Nemoraksa." *(bez zmian)*
2. "Sześć głosów, sześć krzywd. Za chwilę znów będą jednym."

Dopiero **ACTIVATING** (gniazda zapalają się po kolei, gra już pauzuje
sterowanie gracza — to już dziś tak działa) dostaje PRAWDZIWĄ cutscenkę:
kamera (a raczej cały ekran, bo kamera się nie rusza w tej grze) przyciemnia
się bardziej niż zwykle, każde zapalające się gniazdo dostaje SWÓJ
podpis-portret (sprite danego wcielenia, mały, w rogu, pojawia się i znika w
rytm zapalania gniazda) — 6 bardzo krótkich (~0.5s, prawie bez tekstu, tylko
imię) beatów, jeden na gniazdo, potem cięcie na "Nemorax powstaje..." jak dziś.

### 2.3 UPADEK WIELKIEJ FORMY → MAŁA FORMA — NAJWAŻNIEJSZA SCENA W GRZE

**Kiedy**: `arena.gd._play_big_form_death()`, zastępuje dzisiejsze samo
czekanie `body_fade_duration` sekund.

**Wygląd** (to jest scena, w której żyje cały twist — potraktuj ją poważnie):

1. Duża forma już leży (`nemorax_large-form-collapse.png`, jak dziś).
   Ekran ciemnieje do prawie czerni, zostaje tylko sylwetka.
2. **Beat 1** *(Nemorax, portret = collapse)*: "Pamiętam. Pamiętam WAS. Ilu was było?"
3. Krótka cisza (0.8s, celowo — to miejsce na oddech, nie na tekst).
4. **Beat 2** *(bez etykiety, głos "spoza" — Strażnik? Narrator? Celowo dwuznaczne)*:
   "Nie pierwszy raz to robisz. Coś w tobie o tym wie."
5. Mała forma się wyłania (`nemorax_small-form-rebirth.png`, jak dziś).
6. **Beat 3** *(Nemorax, portret = rebirth)*: "Czy pamiętasz, ile razy już mnie
   pokonałeś?" *(wariant zależny od `deaths` — patrz FABULA_I_DIALOGI.md 3.5)*
7. Cięcie na taunt-pytanie finałowe (`nemorax_small-form-taunt.png`) — jak
   dziś, ale teraz to naturalna kontynuacja sceny, nie osobny byt.

**Sygnał wizualny specyficzny dla tej sceny**: tło za portretem Nemoraksa w
tej JEDNEJ scenie mieni się KOLEJNO przez wszystkie 6 kolorów faz
(`Palette.PHASE_COLORS[0..5]`, po ~0.3s każdy, w tle za beatem 1) — wizualny
skrót "to wszystko, czym właśnie było, w jednej chwili", bez potrzeby
dodatkowego tekstu.

### 2.4 EPILOG ZWYCIĘSTWA

**Kiedy**: po `_finish_victory()` liczy `boss.take_damage` finałowe, PRZED
dzisiejszym ekranem "Zwycięstwo / Podejście / Ukończeń".

**Wygląd**: ekran całkiem czarny (jak prolog — spina klamrą całą rozgrywkę),
3 beaty, 2-2.5s każdy bez głosu:
1. *(bez etykiety)* "Rozpada się. Fragmenty już szukają, gdzie zasnąć."
2. *(bez etykiety, dłuższa pauza przed)* "Ktoś je znowu zbierze. Ty, albo ktoś bardzo do ciebie podobny."
3. *(bez etykiety)* "To nie było ocalenie. To było odłożenie na później."

Dopiero po tym pojawia się dzisiejszy ekran statystyk (bez zmian).

**Dodatkowo, TYLKO jeśli `wins == 0` przed tym zwycięstwem** (pierwsze
prawdziwe zwycięstwo w całym zapisie) — jeden dodatkowy, ukryty beat MIĘDZY
"prawdziwą śmiercią" a epilogiem: pełny czarny ekran, jedna klatka za długo
jak na wygodne przeczytanie, BEZ głosu, BEZ portretu:
> "...to twoja twarz."

Nie tłumaczyć, nie powtarzać nigdy więcej w tym zapisie. Ma zostać
niejasne — to jest haczyk fabularny do przemyślenia przez gracza, nie do
wyjaśnienia przez grę.

### 2.5 Okrzyki (bez pauzy) — wygląd bez zmian względem dzisiejszego UI

Podniesienie duszy i zmiana fazy Nemoraksa zostają DOKŁADNIE tym samym
toastem co dziś (`ui.show_taunt`, prawy górny róg czy gdzie już jest) — nowy
tekst z `FABULA_I_DIALOGI.md` sekcja 3.2/3.4, opcjonalny krótki głos (1-3
słowa, "Wygnaliście mnie raz" zamiast pełnego monologu — to bark, nie mowa).

---

## 3. Głosy — jak to nagrać i podłączyć

### 3.1 Konwencja plików

Nowy folder `assets/audio/voice/`, jedna podfolder na postać:
```
assets/audio/voice/narrator/    # prolog, epilog, beat "to twoja twarz"
assets/audio/voice/vhar_nokh/
assets/audio/voice/mordrath/
assets/audio/voice/zha_ruun/
assets/audio/voice/nekravor/
assets/audio/voice/thal_gor/
assets/audio/voice/orryx/
assets/audio/voice/nemorax/      # 6 podfaz w nazwie pliku: nemorax_motion_*, nemorax_force_* itd.
```
Nazwa pliku = skrót treści, np. `vhar_nokh_death_01.wav`,
`nemorax_sovereignty_transition.wav` — żeby dało się je łatwo dopasować do
`DialogueBeat.voice_clip` bez zgadywania.

### 3.2 Techniczne (żeby wszystko zaimportowało się tak samo jak reszta audio)

- Format WAV, mono, 44.1kHz — ten sam standard co reszta SFX w projekcie.
- Wytnij ciszę na początku/końcu (Audacity: Effect → Truncate Silence),
  inaczej `fallback_seconds`/synchronizacja tekstu będzie się rozjeżdżać.
- Nowy bus audio **"Voice"** w `assets/audio/default_bus_layout.tres`
  (dziecko "Master", osobny suwak głośności) — mała, jednorazowa zmiana,
  zrobię ją razem z systemem cutscenek, żebyś miał od razu gdzie
  wyregulować głośność swoich nagrań niezależnie od SFX/muzyki.

### 3.3 Wskazówki aktorskie per postać (z `FABULA_I_DIALOGI.md` sekcja 2)

| Postać | Jak grać | Ewentualna obróbka w Audacity |
|---|---|---|
| Vhar'Nokh | ciężko, wolno, mało słów, bez emocji w głosie — fakt, nie skarga | Pitch -3..-5 semitonów |
| Mordrath | szeptem, urywa słowa w połowie, jakby tracił wątek | lekki echo/delay, wysoki pitch |
| Zha'Ruun | powtarza końcówki własnych zdań, echo w SAMEJ grze aktorskiej | delay z 1 powtórzeniem |
| Nekravor | gorzko, oskarżycielsko, głośniej niż reszta | Pitch -2, lekki distortion |
| Thal'Gor | zaczyna błagalnie, kończy drapieżnie — jedna kwestia, dwa tony | brak, czysta gra aktorska |
| Orryx | prawie szept, momentami sama cisza/oddech zamiast słów | bardzo cicho w miksie, minimalny pogłos |
| Nemorax — Motion/Force/Ruin | głos przetworzony, nieludzki, warstwowy | Pitch -4..-6, lekki distortion/chorus |
| Nemorax — Instinct/Dominion | głos przetworzony, ale wyraźniejszy | Pitch -2..-3, delikatny pogłos |
| Nemorax — **Sovereignty** | **NAJCZYŚCIEJSZY, najbardziej ludzki głos w całej grze** — to jedyny moment, gdy brzmi jak ktoś, nie coś | brak/minimalna obróbka — kontrast to sedno tej fazy |
| Narrator (prolog/epilog) | płasko, zmęczony, jakby mówił to nie pierwszy raz (bo mówi) | brak obróbki |

Nagraj w DOWOLNEJ kolejności, wrzucaj pliki jeden po drugim — system działa
z tekstem od razu, więc żadna scena nie czeka na komplet nagrań.

---

## 4. Kolejność wdrożenia (dla mnie, jeśli dasz zielone światło)

1. `DialogueBeat` (Resource) + `ui/cutscene_player.gd` (odtwarzacz, skip,
   fallback bez głosu) — sam szkielet, przetestowany na scenie-atrapie.
2. Prolog + Epilog (najprostsze, bez portretów, czysto tekstowe) —
   pierwszy realny test systemu w grze.
3. Cutscenka "Upadek Wielkiej Formy" (najważniejsza, portrety + kolorowe tło).
4. Rozszerzenie Rytuału Ołtarza o sekwencję gniazd.
5. Rozszerzenie `ui.show_taunt()` o opcjonalny głos + podpięcie tekstów
   okrzyków z `FABULA_I_DIALOGI.md` (dusze, fazy bossa).
6. Nowy bus "Voice" w `default_bus_layout.tres`.

Każdy krok testowany headless + smoke-test jak cała reszta tej sesji, zanim
przejdę dalej.
