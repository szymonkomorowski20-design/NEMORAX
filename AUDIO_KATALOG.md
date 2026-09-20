# NEMORAX — Kompletny katalog dźwięku (muzyka, SFX, ambient)

Odpowiednik [LORE_I_ASSETY.md](LORE_I_ASSETY.md) / [ASSETY_SWIATA_I_UI.md](ASSETY_SWIATA_I_UI.md),
ale dla warstwy audio. Zero infrastruktury dźwiękowej istnieje dziś w kodzie
(sprawdzone: brak `AudioStreamPlayer`, brak plików `.ogg`/`.wav`, brak folderu
audio, brak busów poza domyślnym "Master") — więc to zarówno katalog TREŚCI
do wygenerowania/znalezienia, jak i lista miejsc w kodzie, gdzie trzeba będzie
dopiąć `AudioStreamPlayer`/`AudioStreamPlayer2D`.

Status: pełny katalog gotowy, czeka na wygenerowanie/znalezienie plików i
podpięcie w kodzie.

**Do faktycznego wklejania w ElevenLabs używaj [ELEVENLABS_KOLEJKA.md](ELEVENLABS_KOLEJKA.md)**
— ma dużo bardziej szczegółowe, dopracowane pod ten konkretny generator
opisy (fizyka dźwięku zamiast ogólników, "dry/no reverb" tam gdzie trzeba,
brak mylącej liczby sekund w tekście). Tabele poniżej to skrócony
przegląd + lokalizacja w kodzie, nie kopiuj z nich promptów bezpośrednio.

---

## 0. Jak to wszystko skompletować — konkretny plan działania

### Krok 1 — wybierz narzędzie per kategoria
Nie ma jednego bota na wszystko (inaczej niż przy grafice) — audio dzieli się
na dwa różne zadania z różnymi narzędziami:

- **SFX (krótkie efekty, ~80% tej listy)** → **ElevenLabs** (zakładka "Sound
  Effects" na elevenlabs.io) — wklejasz prompt z tabeli, dostajesz gotowy
  plik w kilka sekund. Ma darmowy limit generacji miesięcznie, wystarczy na
  tę listę rozłożoną w czasie. Alternatywa: **Stable Audio**
  (stableaudio.com) — też text-to-audio, też ma darmowy tier.
- **Muzyka/ambient w pętli (sekcja 1 i 7, ~15 pozycji)** → też ElevenLabs
  albo Stable Audio dają radę na krótkie pętle (10-30 s), ale do dłuższych,
  bardziej "kompozycyjnych" utworów (1.1-1.4) lepiej sprawdzi się **Suno**
  (suno.com) — w trybie instrumentalnym (wyłącz wokal/tekst), dłuższe i
  bardziej rozwinięte utwory.
- **Zamiast generować — szukaj gotowych paczek najpierw.** Realistycznie
  większość tego katalogu to rzeczy, które ktoś już nagrał (skrzypienie
  drzwi, magiczny błysk, uderzenie mieczem, dark ambient drone) — tylko
  najbardziej specyficzne dla fabuły rzeczy (unikalne umiejętności bossów,
  stingery faz Nemoraksa) realnie trzeba wygenerować od zera. Kolejność
  przeszukiwania, od najszybszej/najprostszej:
  1. **Kenney.nl** (Kenney Game Assets) — całe paczki dźwięków do gier za
     darmo, licencja **CC0** (zero atrybucji, zero pytań), gotowe zestawy
     typu "RPG Audio", "UI Audio", "Impact Sounds" — najszybszy strzał do
     generycznych rzeczy (kliki UI, uderzenia, kroki).
  2. **itch.io** (zakładka assets → sound effects, filtr "free") — mnóstwo
     paczek zrobionych stricte pod gry, często tematyczne ("dark fantasy
     SFX pack", "RPG monster sounds", "horror ambience pack") — najbliższe
     klimatowi NEMORAXA, część darmowa, część za kilka dolarów.
  3. **OpenGameArt.org** (sekcja Audio) — repozytorium assetów pod gry
     (CC0/CC-BY), starsze ale wciąż spore archiwum, dobre pod ambient/muzykę.
  4. **freesound.org** — pojedyncze dźwięki, świetne do uzupełniania
     konkretnych braków; załóż darmowe konto, filtruj po licencji **CC0**.
  5. **Sonniss GDC Audio Bundle** — ogromna (kilka-kilkanaście GB), darmowa,
     profesjonalna paczka wydawana co roku na GDC, wolna do użytku w grach;
     warto po nią sięgnąć, jeśli sporo pozycji wciąż brakuje po 1-4.

  W każdym z nich szukaj fraz z kolumny **"Szukaj też"** w tabelach poniżej —
  są napisane specjalnie pod wyszukiwanie w bibliotekach, nie pod generator.
  Co znajdziesz — odhacz i zapisz pod właściwą nazwą (Krok 3). Czego nie
  znajdziesz (zwłaszcza unikalne umiejętności bossów i muzyczne stingery faz)
  — dogeneruj w ElevenLabs z `ELEVENLABS_KOLEJKA.md`.

### Krok 2 — rób to w tej kolejności (żeby coś grało jak najszybciej)
1. **Sekcja 2 (gracz)** — najczęściej słyszane dźwięki w grze, rób pierwsze.
2. **Sekcja 4 (Nemorax)** — finałowa walka, drugi najważniejszy blok.
3. **Sekcja 3 (wcielenia, wspólny "core")** — 8 dźwięków pokrywa WSZYSTKIE 6 pokoi na raz.
4. **Sekcja 3.1 (unikalne warianty wcieleń) + sekcja 5 (świat) + sekcja 6 (UI)**.
5. **Sekcja 1 (muzyka) + sekcja 7 (ambient)** na koniec — najbardziej czasochłonne (pętle, miksowanie), a gra działa i bez nich (po prostu cicho w tle).

### Krok 3 — nazywaj pliki wg kodu z tabeli
Każdy wiersz w tabelach ma już krótki kod (P1, P2... I1... N1... W1... U1...) —
używaj go jako prefiksu pliku, np. `P07_sword_hit.ogg`,
`N04_seal_explosion.ogg`, `W03_soul_pickup.ogg`. Dla muzyki/ambientu użyj
`MUS_` / `AMB_` + skrót nazwy (`MUS_menu.ogg`, `AMB_room2_mordrath.ogg`).
Dzięki temu w kodzie/w Godocie od razu wiadomo, co jest czym, bez zgadywania.
Trzymaj wszystko w strukturze folderów równoległej do `grafiki do gry`, np.
`dzwieki do gry/01_music`, `02_player_sfx`, `03_incarnations_sfx`,
`04_nemorax_sfx`, `05_world_sfx`, `06_ui_sfx`, `07_ambient` — łatwo wtedy
zrobić `MANIFEST.md` tak jak przy grafice.

### Krok 4 — wykończenie PRZED wrzuceniem do Godota
Surowy plik z generatora prawie nigdy nie jest gotowy 1:1:
1. **Przytnij ciszę** na początku/końcu (Audacity — darmowy, `Effect →
   Truncate Silence` albo ręcznie zaznacz i wytnij).
2. **Pętle (muzyka/ambient)**: generator NIE gwarantuje bezszwowej pętli —
   w Audacji znajdź moment, gdzie fala pasuje rytmicznie do początku, przytnij
   tam, i zrób krótki (50-200 ms) crossfade końca z początkiem (`Effect →
   Crossfade Tracks` albo ręcznie dwie kopie na dwóch ścieżkach). Sprawdź,
   odtwarzając w pętli — jeśli słychać "kliknięcie" albo skok głośności w
   miejscu złączenia, popraw crossfade. Jeśli ElevenLabs pokazuje przełącznik
   "Loop" przy generowaniu — włącz go, to często załatwia sprawę bez ręcznej
   pracy w Audacity.
3. **Limit minimalnej długości w ElevenLabs: 0.5s** (twardy limit API,
   `duration_seconds` ≥0.5) — sporo krótkich SFX w katalogu (0.05-0.4s) trzeba
   wygenerować na 0.5s i DOPIERO przyciąć w Audacity do docelowej długości;
   liczba sekund w treści promptu to tylko sugestia charakteru, nie realny
   parametr czasu.
4. **Znormalizuj głośność** (`Effect → Normalize` w Audacity) do ok. -16 LUFS
   (SFX) / -20 LUFS (muzyka) — inaczej różne pliki będą różnie głośne.
5. **Eksportuj jako `.ogg` (Vorbis)** — Audacity robi to natywnie
   (`File → Export → Export as OGG`). Godot 4 równie dobrze importuje `.wav`
   i `.mp3`, więc jeśli coś już masz w tych formatach, nie musisz konwertować
   na siłę — `.ogg` jest tylko lżejszy na dłuższych pętlach muzyki.
6. W Godocie, po imporcie, w zakładce **Import** pliku audio ustaw **Loop =
   On** dla wszystkiego z sekcji 1 i 7 (muzyka/ambient) — bez tego Godot
   zagra plik raz i się zatrzyma, nawet jeśli plik sam w sobie już się ładnie
   zapętla.

### Format techniczny (podsumowanie)
- SFX: mono, 0.1–1.5 s (chyba że zaznaczono inaczej).
- Muzyka/ambient: stereo, zapętlone jak w Kroku 4.2, `Loop = On` w imporcie.
- Głośność: -16 LUFS (SFX) / -20 LUFS (muzyka).

### Proponowany układ busów audio (dziś nie istnieje, trzeba założyć)
Obecnie `arena.gd:35` i `arena.gd:98` wyciszają CAŁY bus "Master" na fazę
Cisza — to pasuje do motywu "totalna cisza", więc **zostaje bez zmian**, ale
oznacza, że wszystkie 3 busy poniżej i tak zamilkną razem w tej fazie. Warto
mimo to rozdzielić od razu:
- **Music** — muzyka walki/menu/ambientu pokoi.
- **SFX** — wszystkie efekty akcji (gracz, wcielenia, Nemorax).
- **UI** — dźwięki interfejsu (osobno, żeby dało się np. dociszyć tylko UI
  w opcjach w przyszłości, bez ruszania SFX walki).

---

## 1. Muzyka

### 1.1 Menu główne
Spokojna, złowieszcza zapowiedź tego, co czeka — nie epicka, raczej niepokojąca cisza przed burzą.
> Dark ambient dungeon-synth menu theme, slow and ominous, deep sustained
> drone, distant faint choir whisper, sparse single piano notes echoing into
> silence, no percussion, unsettling but restrained, loopable, 60-90 BPM feel.

**Szukaj też**: "dark ambient drone loop", "dungeon synth menu theme", "eerie choir pad".

### 1.2 Pokój wcielenia — pętla napięcia (współdzielona baza, 6 pokoi)
Bazowa pętla dla wszystkich sześciu pokoi wcieleń, żeby brzmiały spójnie jako
jeden gauntlet — indywidualny charakter dokłada osobna warstwa ambientu z
sekcji 8, nie osobna muzyka.
> Tense looping dungeon exploration music, low pulsing bass drone, sparse
> metallic percussion hits at irregular intervals, building unease without
> a strong beat, dark fantasy boss-room atmosphere, seamless loop, no melody
> hooks, stays in the background.

**Szukaj też**: "dark fantasy boss room loop", "tense dungeon ambient music".

### 1.3 Ołtarz — rytuał przywołania
Krótszy, bardziej ceremonialny niż pokoje — gra tylko w `altar.gd`.
> Ritualistic dark fantasy music, low chanting drone building in intensity,
> deep resonant gong hits, growing dissonant choir as the track progresses,
> climactic and dreadful, designed to build tension toward a summoning,
> loopable middle section.

**Szukaj też**: "ritual summoning music loop", "dark chant ambient".

### 1.4 Walka z Nemoraksem — warstwa bazowa
Główny motyw walki finałowej — intensywniejszy niż pokoje wcieleń, ale
zostawia miejsce na warstwy fazowe (1.5) nałożone na wierzch.
> Intense dark fantasy boss battle music, driving low percussion, aggressive
> distorted synth bass, orchestral hybrid, relentless but not chaotic, builds
> and releases in waves, seamless loop, no vocals.

**Szukaj też**: "epic dark boss battle loop", "dark fantasy boss theme instrumental".

### 1.5 Warstwy fazowe Nemoraksa (opcjonalne dodatki na 1.4, po jednej na fazę)
Zamiast 6 całkiem osobnych utworów — 6 krótkich (10-20 s) warstw/stingerów
grających RÓWNOLEGLE z 1.4 przy zmianie fazy (`_on_boss_phase_changed`,
`arena.gd:93`), żeby podkreślić charakter fazy bez zrywania ciągłości muzyki:

| Faza | Kolor | Charakter warstwy | Prompt |
|---|---|---|---|
| Cisza | `#FF8A3D` | i tak wyciszona przez mute — pomiń | — |
| Zwłoka | `#C44FD6` | stuttering, echo repeat | `Short stuttering musical stinger, notes repeating like a skipping record, glitchy echo, dark fantasy, 10 seconds` |
| Ciężar | `#6C63FF` | ciężki, zwalniający | `Short heavy descending musical stinger, slowing pitch-down effect, crushing weight sensation, deep sub-bass, dark fantasy, 10 seconds` |
| Głód | `#7ED957` | głodne, warczące | `Short musical stinger with a low guttural growl texture woven in, hungry and predatory feel, dark fantasy, 10 seconds` |
| Zaćmienie | `#C9C2B4` | wybrzmiewające w ciszę | `Short musical stinger that fades into near-total silence at the end, isolating and cold, dark fantasy, 10 seconds` |
| Finał (mała forma) | — | wybrzmienie do cichej, złowrogiej pointy | `Short unsettling music box-like melody fragment, childlike but wrong, fading out, dark fantasy, 10 seconds` |

**Szukaj też**: "glitch stinger", "descending bass stinger", "growl music transition", "eerie music box".

### 1.6 Zwycięstwo (ekran końcowy)
Gra raz przy `_finish_victory()` (`arena.gd:142`) — to prawdziwy koniec gry
(endgame), więc powinno brzmieć na wyczerpanie i gorzkie zwycięstwo, nie fanfary.
> Somber victory theme for a dark fantasy game, bittersweet and exhausted
> rather than triumphant, slow swelling strings, single distant bell,
> resolves into quiet, no percussion fanfare, 20-30 seconds, does not need to loop.

**Szukaj też**: "bittersweet victory theme", "somber triumphant ending music".

### 1.7 Porażka / reset (stinger, nie pętla)
Gra raz przy `_on_player_died()` (`arena.gd:154`) w walce z Nemoraksem —
krótki, bo zaraz po nim gracz wraca do pokoju 1.
> Short dark defeat stinger, low dissonant chord hit, descending pitch,
> hollow reverb tail, 3-5 seconds, no melody.

**Szukaj też**: "defeat stinger", "game over sting dark".

---

## 2. SFX gracza (`entities/player.gd`)

| # | Nazwa | Wyzwalacz | Opis | Prompt |
|---|---|---|---|---|
| P1 | Dash start | `player.gd:176-180` `_handle_dash_input()` | krótki podmuch/świst | `Quick whoosh dash sound, short air displacement, energetic, 0.3s` |
| P2 | Dash zablokowany (cooldown) | `player.gd:154-155`, `player.gd:170` | głuchy "odmowa" blip | `Short dull denial blip, low-pitched, no reverb, 0.15s` |
| P3 | Dash zablokowany przez Ząb Zera | `player.gd:410-415` `lock_dash()` | cięższa, "unieruchomiona" odmowa (inna barwa niż P2) | `Short metallic locking/clamping sound, restrictive, slightly ominous, 0.2s` |
| P4 | Zmiana broni (miecz/różdżka) | `player.gd:160-163` | mechaniczne kliknięcie/switch | `Quick weapon-switch click, mechanical, subtle metallic shift, 0.15s` |
| P5 | Atak zablokowany (brak staminy/many) | `player.gd:218-221`, `234` | miękka odmowa (odróżnij od P2) | `Soft empty-resource denial sound, hollow thud, 0.15s` |
| P6 | Zamach mieczem — telegraph/windup | `player.gd:292-301` "windup" | krótkie naciągnięcie/świst wstępny | `Short sword wind-up swish, building tension, 0.2s` |
| P7 | Zamach mieczem — cięcie | `player.gd:314-319` "windup"→"active" | ostre cięcie stali w powietrzu | `Sharp sword slash through air, fast metallic whoosh, aggressive, 0.25s` |
| P8 | Trafienie mieczem | `player.gd:367-374` `_check_attack_hits()` | uderzenie z impaktem (pasuje do hitstopu/screen shake już w kodzie) | `Heavy impactful sword hit, sharp crunch with a slight metallic ring, punchy, 0.2s` |
| P9 | Pudło mieczem (recovery bez trafienia) | `player.gd:322-324` | cichszy wariant P7 bez impaktu, opcjonalny | `Sword swing whoosh with no impact, slightly disappointed tail, 0.2s` |
| P10 | Ładowanie różdżki | `player.gd:298-299`, `463-466` | narastający magiczny hum | `Rising magical charge-up hum, energy building, sparkly high-frequency tail, 0.4s` |
| P11 | Wystrzał z różdżki | `player.gd:320-321`, `328-336` | wystrzał pocisku energii | `Magic projectile launch, short energetic zap, bright tonal quality, 0.25s` |
| P12 | Trafienie pociskiem różdżki | zob. `entities/projectile.gd` | uderzenie magicznego pocisku | `Magic projectile impact, sparkly burst hit, medium punch, 0.2s` |
| P13 | Blok — aktywacja | `player.gd:239-249` | metaliczny/energetyczny "podniesienie tarczy" | `Shield-raise sound, brief metallic resonance, defensive, 0.2s` |
| P14 | Blok — odepchnięcie trafia cel | `player.gd:251-259` `_perform_block_push()` | tępe uderzenie odpychające | `Blunt shockwave push impact, deep thud with a knockback whoosh, 0.25s` |
| P15 | Blok zablokowany (brak staminy) | `player.gd:244-246` | wariant P5 | (reużyj P5) |
| P16 | Leczenie — użycie | `player.gd:263-271` `_handle_heal_input()` | ciepły, kojący błysk dźwięku | `Warm healing chime, soft rising tone, gentle magical shimmer, 0.5s` |
| P17 | Leczenie zablokowane (nie naładowane) | `player.gd:268-269` | wariant P5 | (reużyj P5) |
| P18 | Tik ładowania leczenia (co trafienie) | `player.gd:340-342` `register_hit_on_enemy()` | bardzo krótki, subtelny tik | `Tiny subtle tick, barely audible charge-up pip, 0.05s` |
| P19 | Leczenie gotowe (ping) | stan czytany w `ui.gd:138-139` | wyraźny "ready" ping, odróżnialny od P18 | `Clear bright ready-notification ping, single bell-like tone, 0.3s` |
| P20 | Obrażenia gracza | `player.gd:395-409` `take_damage()` | ból/uderzenie, ludzkie warknięcie bólu | `Player pain grunt combined with a dull impact hit, visceral but not graphic, 0.3s` |
| P21 | Śmierć gracza | `player.gd:405-408` | dłuższy, opadający dźwięk porażki | `Falling defeat sound, descending pitch groan, fading out, 1s` |
| P22 | Otrzymany knockback (bez obrażeń) | `player.gd:288-290` `apply_knockback()` | krótki podmuch odrzutu | `Quick forceful push-back whoosh, 0.2s` |

**Szukaj też** (ogólnie do sekcji 2): "sword slash whoosh", "magic zap", "shield block impact", "heal chime", "player hurt grunt", "RPG UI denial sound".

---

## 3. SFX wspólne sześciu wcieleń (`entities/incarnation.gd`)

Każde z sześciu wcieleń używa tych samych bazowych umiejętności
(`_damage_pulse`, `_pull_player`, `_lunge_toward_player`) — jeden zestaw
"core" dźwięków wystarczy dla wszystkich, pomalowany opcjonalnie pitchem/EQ
per wcielenie zamiast nagrywać 6x to samo od zera.

| # | Nazwa | Wyzwalacz | Opis | Prompt |
|---|---|---|---|---|
| I1 | Telegraph (zapowiedź ataku) | `incarnation.gd:97-102` `_start_telegraph()` | narastający, ostrzegawczy hum (pasuje do pulsującego pierścienia w `_draw()`) | `Rising ominous warning drone, building tension, telegraphs an incoming attack, 0.5s` |
| I2 | Damage pulse — wybuch | `incarnation.gd:119-125` | fala uderzeniowa na zewnątrz | `Dark magical shockwave burst, radiating outward, deep low-end thump, 0.3s` |
| I3 | Pull — przyciąganie gracza | `incarnation.gd:127-130` | wciągający, odwrócony whoosh | `Reversed sucking whoosh, pulling inward, unsettling, 0.4s` |
| I4 | Lunge — start rzutu | `incarnation.gd:132-137` | gwałtowny rozbieg | `Aggressive lunging dash sound, fast approach, guttural undertone, 0.3s` |
| I5 | Kontakt/obrażenia od dotyku | `incarnation.gd:88-95` `_check_contact()` | tępe uderzenie cielesne | `Dull creature-contact hit, organic thud, 0.15s` |
| I6 | Knockback otrzymany (od bloku gracza) | `incarnation.gd:78-79` | reakcja na odepchnięcie, pasuje do P14 | `Creature knocked back, pained grunt with a whoosh, 0.25s` |
| I7 | Trafienie wcielenia | `incarnation.gd:152-159` `take_damage()`, pasuje z `flash_white()` | krótki skrzek bólu | `Short creature pain shriek, sharp and dissonant, 0.2s` |
| I8 | Śmierć wcielenia | `incarnation.gd:156-159` `died` sygnał | rozpad/zanikanie istoty | `Creature death dissolve, descending dissonant tone fading into silence, 0.8s` |

## 3.1 Unikalne warianty per wcielenie (dokładka do zestawu core powyżej)

### Vhar'Nokh (`zalazek.gd`, `#F0447A`, pokój 1)
- **Teleport/blink** (`_teleport_near_player`, `zalazek.gd:36-38`) — unikalne dla tej istoty.
  > Sharp teleport blink, quick displacement pop with a brief static crackle, 0.2s
  **Szukaj też**: "teleport blink sfx", "short static pop".

### Mordrath (`cisza_incarnation.gd`, `#FF8A3D`, pokój 2 — "cisza")
- **Wariant tłumiony wszystkich dźwięków I1-I5** — ta istota tematycznie
  powinna brzmieć "przez watę"/przytłumiona nawet PRZED fazą ciszy Nemoraksa.
  > Muffled, underwater-like version of a magical burst, dampened high
  > frequencies, distant and suppressed, 0.3s
  **Szukaj też**: "muffled underwater impact", "low-pass filtered whoosh".

### Zha'Ruun (`zwloka_incarnation.gd`, `#C44FD6`, pokój 3 — "zwłoka")
- **Echo pulse** — drugi, opóźniony pulse 0.35s po pierwszym (`zwloka_incarnation.gd:21-25`).
  > Delayed echo repeat of a magical burst, same hit but faded and slightly
  > detuned, like a stuck echo, 0.3s
  **Szukaj też**: "echo repeat impact", "delayed reverb hit".

### Nekravor (`ciezar_incarnation.gd`, `#6C63FF`, pokój 4 — "ciężar")
- **Crush pulse** (większy zasięg, cięższy niż I2, `ciezar_incarnation.gd:28-29`).
  > Heavy crushing gravitational impact, deep sub-bass slam, oppressive weight, 0.4s
  **Szukaj też**: "gravity slam bass hit", "heavy crush impact".

### Thal'Gor (`glod_incarnation.gd`, `#7ED957`, pokój 5 — "głód")
- **Ugryzienie/lifesteal** (`glod_incarnation.gd:33-44`, zysk zdrowia w linii 44) — jedyne wcielenie z leczeniem się kosztem gracza.
  > Wet visceral bite sound followed by a draining slurp, predatory, 0.3s
  **Szukaj też**: "creature bite sfx", "life drain sound".

### Orryx (`zacmienie_incarnation.gd`, `#C9C2B4`, pokój 6 — "zaćmienie")
- **Zanik (vanish)** (`zacmienie_incarnation.gd:27-28`, `40`).
  > Fading vanish whoosh, dissolving into silence, ghostly, 0.3s
- **Powrót (reappear)** (`zacmienie_incarnation.gd:34`, `42`).
  > Sudden reappearing thud with a dark magical flourish, 0.25s
  **Szukaj też**: "vanish whoosh sfx", "ghost reappear thud".

---

## 4. SFX Nemorax — finałowy boss (`entities/boss.gd` i pomocnicze)

| # | Nazwa | Wyzwalacz | Opis | Prompt |
|---|---|---|---|---|
| N1 | Zmiana fazy — transformacja | `boss.gd:313-317` `_start_transform_invulnerability()` (już ma screen shake) | potężny, przeciągnięty ryk transformacji | `Powerful monstrous transformation roar, long sustained growl with rising pitch, earth-shaking, 1.5s` |
| N2 | Wybór/zapowiedź ataku | `boss.gd:200-217` `_pick_and_launch_attack()` | krótki, groźny "inhale" przed atakiem | `Short menacing inhale/charge-up before an attack, ominous, 0.4s` |
| N3 | Pieczęć — telegraph pojedynczej pieczęci | `entities/seal.gd:15-16` | narastający trzask energii | `Rising crackling energy build-up, warning tone, 0.6s` |
| N4 | Pieczęć — eksplozja | `entities/seal.gd:25-28` `_explode()` | ostry wybuch pieczęci | `Sharp rune explosion, bright crackling burst, energetic, 0.3s` |
| N5 | Ząb Zera — otwarcie strefy | `entities/void_zone.gd:21-26` | rozdarcie przestrzeni, wciągające | `Reality-tearing rip sound, deep void opening, unsettling low drone, 0.5s` |
| N6 | Ząb Zera — zablokowanie dasha (wejście gracza) | `entities/void_zone.gd:29-30` | metaliczny "zatrzask" | `Metallic locking clamp, restrictive and final, 0.2s` |
| N7 | Ząb Zera — zanik strefy | `entities/void_zone.gd:31-33` | odwrotność N5, zasysające domknięcie | `Void closing shut, reversed tearing sound collapsing inward, 0.4s` |
| N8 | Cień — przywołanie | `boss.gd:270-276` `_spawn_shadow()` | mroczne, zniekształcone echo gracza (bo cień to "gracz z przeszłości") | `Distorted echo of footsteps and a whisper, dark twisted mimicry, 0.4s` |
| N9 | Cień — kontakt/obrażenia | `entities/shadow.gd:33-37` | podobne do P20, ale zniekształcone | `Distorted version of a pain hit, warped and unnatural, 0.2s` |
| N10 | Cień — zanik | `entities/shadow.gd:25-27` | rozpad cienia | `Shadow dissolving, whispery fade into nothing, 0.5s` |
| N11 | Wypad (lunge) — telegraph | `boss.gd:220-224` `_launch_lunge_attack()` | cięższy wariant I1, głębszy | `Deep menacing charge-up growl before a lunge, heavy and threatening, 0.5s` |
| N12 | Wypad — rozbieg | `boss.gd:146-151` `_process_lunge()` | masywny impet | `Massive charging dash sound, heavy footfalls and rushing air, aggressive, 0.4s` |
| N13 | Podwójny wypad — łańcuch (50% szansy) | `boss.gd:155-162` | wariant N12 z akcentem "znowu" | `Second immediate lunge sound, same as a charging dash but slightly sharper/urgent, 0.4s` |
| N14 | Kontakt cielesny (stały) | `boss.gd:129-138` `_check_body_contact()` | ciężkie, głuche uderzenie | `Heavy dull body-contact thud, massive creature touch, 0.2s` |
| N15 | Regeneracja głodu (pętla, faza ≥4) | `boss.gd:193-198` `_handle_hunger_regen()` | subtelna, złowieszcza pętla "leczenia się" | `Subtle ominous regenerating hum loop, low pulsing, unsettling, seamless loop` |
| N16 | Trafienie Nemoraksa | `boss.gd:285-303` `take_damage()`, `flash_white()` (`boss.gd:323-324`) | głęboki ryk bólu | `Deep monstrous pain roar, short and guttural, 0.3s` |
| N17 | "Śmierć" dużej formy (przejście fazy) | `boss.gd:294-303` branch (nie finałowa) | opadający, ale nie ostateczny — zapowiedź powrotu | `Massive form collapsing, long descending groan that does not fully resolve, 1.2s` |
| N18 | Odrodzenie małej formy (finał) | `boss.gd:327-334` `start_final_phase()` | cichy, złowieszczy powrót — kontrast z N17 | `Quiet unsettling resurrection sound, small but wrong, faint whisper-laugh undertone, 1s` |
| N19 | Prawdziwa śmierć (zwycięstwo) | `boss.gd:299` `died.emit(true)` | ostateczny, długi rozpad | `Final massive death collapse, long dissonant descending tone, dissolves completely, 2s` |

**Szukaj też** (ogólnie do sekcji 4): "monster roar", "boss transformation sfx", "rune explosion", "void portal sfx", "shadow whisper", "creature death groan".

---

## 5. SFX świata / pokoi

| # | Nazwa | Wyzwalacz | Opis | Prompt |
|---|---|---|---|---|
| W1 | Przejście przez drzwi | `rooms/door.gd:15-21` | lekkie skrzypnięcie/aktywacja progu | `Heavy stone door creak and thud, brief, ancient mechanism, 0.4s` |
| W2 | Dusza — idle hum (czeka na podniesienie) | `rooms/soul.gd:26-35`, pulsująca podpowiedź `[F]` | cichy, pulsujący hum w pętli | `Soft pulsing magical hum, gentle and inviting, seamless loop, quiet` |
| W3 | Dusza — podniesienie (F) | `rooms/soul.gd:18-22` `collected.emit()` | ciepły błysk zebrania | `Warm collection chime, rising magical shimmer, satisfying, 0.4s` |
| W4 | Ołtarz — wejście gracza do środka | `rooms/altar.gd:32-37` | narastające napięcie rytuału | `Rising ritualistic tension drone, building anticipation, 1s` |
| W5 | Ołtarz — przywołanie Nemoraksa | `rooms/altar.gd:39-42` `_summon_nemorax()` | potężny, ceremonialny grzmot | `Massive ceremonial summoning thunder, deep resonant boom with chanting undertone, 2s` |

**Szukaj też**: "stone door creak", "magic pickup chime", "ritual summon thunder".

---

## 6. SFX UI / menu

| # | Nazwa | Wyzwalacz | Opis | Prompt |
|---|---|---|---|---|
| U1 | Banner nazwy fazy | `ui.gd:47-50` `show_form_name()` | krótkie, dramatyczne ogłoszenie | `Short dramatic announcement sting, single low gong hit, 0.3s` |
| U2 | Dymek/taunt (podpowiedź, tekst finałowy itd.) | `ui.gd:52-55` `show_taunt()` | delikatny chime powiadomienia | `Gentle notification chime, soft and brief, 0.2s` |
| U3 | Ekran zwycięstwa (overlay) | `ui.gd:57-59`, wywołanie `arena.gd:148` | powiąż z muzyką 1.6, osobny krótki akcent nie jest konieczny | (opcjonalnie reużyj fragment 1.6) |
| U4 | Ekran śmierci (overlay) | `ui.gd:57-59`, wywołanie `arena.gd:158`/`room.gd:77` | powiąż z 1.7 (finał) lub własny krótszy dla pokoi | `Short somber failure sting, low descending tone, 0.5s` |
| U5 | Ikona dash — odmowa (cooldown/void-lock) | `ui.gd:111-124` `_draw_dash_icon()` | subtelny wizualny odpowiednik P2/P3, opcjonalny | (reużyj P2/P3 przy bardzo cichej głośności) |
| U6 | Ikona leczenia — gotowa | `ui.gd:128-139` `_draw_heal_icon()` | powiąż z P19 | (reużyj P19) |
| U7 | Menu — potwierdzenie startu (Spacja) | `menu.gd:7-9` | prosty, satysfakcjonujący "confirm" | `Simple satisfying UI confirm sound, short and clean, 0.15s` |

**Szukaj też**: "UI confirm click", "notification chime", "menu select sfx".

---

## 7. Ambient per pokój (7 lokacji + arena finałowa)

Osobna, cicha warstwa ambientu w pętli, GRAJĄCA POD muzyką z 1.2/1.3/1.4 —
to ona daje każdemu pokojowi indywidualny charakter (muzyka zostaje wspólna).

| Pokój | Wcielenie | Charakter ambientu | Prompt |
|---|---|---|---|
| 1 | Vhar'Nokh (Wygnany z Otchłani) | pustka, echo, coś nie z tego świata | `Deep space-like void ambience, distant echoing whispers, cold and empty, seamless loop` |
| 2 | Mordrath (Bez-Wymiaru) | niemal cisza, stłumione dźwięki | `Near-silent muffled ambience, extremely quiet distant murmur, oppressive quiet, seamless loop` |
| 3 | Zha'Ruun (Pożeracz Granic) | tykanie, powtórzenia, zaburzony czas | `Distorted clock ticking ambience, irregular stutter, time feels broken, seamless loop` |
| 4 | Nekravor (Ten Którego Odrzucono) | ciężki, gniotący rumor | `Heavy oppressive low rumble, crushing weight in the air, deep sub-bass drone, seamless loop` |
| 5 | Thal'Gor (Pęknięty Pomiędzy Światami) | głodne, organiczne warczenie w tle | `Distant guttural growling ambience, hungry organic undertone, unsettling, seamless loop` |
| 6 | Orryx (Cień-Nicości) | ciemność, migoczące zniknięcia | `Dark flickering ambience, occasional whispery fade in and out, cold void, seamless loop` |
| Ołtarz | — | ceremonialne, wyczekujące | `Ceremonial waiting ambience, faint distant chanting, anticipatory, seamless loop` |
| Arena Nemoraksa | — | masywna, groźna sala tronowa | `Massive throne room ambience, deep cavernous reverb, distant ominous rumble, seamless loop` |

**Szukaj też**: "dark ambient drone loop", "cavern ambience", "horror game room tone".

---

## 8. Podsumowanie i wdrożenie

**Liczba unikalnych pozycji audio**: 7 muzycznych (w tym 5 warstw fazowych
liczone razem w 1.5) + 22 SFX gracza + 8 core wcieleń + 7 unikalnych wariantów
wcieleń + 19 SFX Nemoraksa + 5 świata + 7 UI + 8 ambientów = **~78 plików
dźwiękowych** w sumie.

### Checklist wdrożenia w kodzie (po zebraniu plików)
- [ ] Założyć busy audio: Music / SFX / UI (patrz sekcja 0) w projekcie Godot.
- [ ] Dodać `AudioStreamPlayer` (muzyka/ambient, non-positional) do `arena.gd`,
      `rooms/room.gd`, `rooms/altar.gd`, `menu.gd`.
- [ ] Dodać `AudioStreamPlayer2D` (SFX pozycyjne) do `player.gd`,
      `incarnation.gd` (współdzielony przez wszystkie 6 podklas), `boss.gd`,
      `seal.gd`, `void_zone.gd`, `shadow.gd`, `door.gd`, `soul.gd`.
- [ ] Podpiąć każdy trigger z tabel powyżej (`file:line` już wskazuje dokładne
      miejsce w kodzie).
- [ ] Zweryfikować, że mute na fazę Cisza (`arena.gd:35`, `arena.gd:98`) nadal
      działa poprawnie z nowymi busami (dziś mutuje "Master", czyli wszystko —
      to zamierzone, zostaje).
