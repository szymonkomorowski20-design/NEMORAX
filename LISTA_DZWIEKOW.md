# NEMORAX — lista dźwięków: czego brakuje i co już jest

Stan projektu z 24.09. Format: WAV 48 kHz / 24-bit (zgodnie z `BIBLIA_DZWIEKU_NEMORAX.md`). Pętle muszą mieć czysty szew — koniec przechodzi w początek bez kliknięcia. Zdarzenia powtarzalne dostają 3–5 wariantów, żeby ucho nie wyłapało powtórki. Czasy to cel, a nie sztywny wymóg: ±20% jest w porządku, ale zapowiedzi ataków muszą trwać tyle, ile zapowiedź w grze, bo tam dźwięk niesie informację.

## Najważniejsze spostrzeżenia

1. **Brak jakiejkolwiek muzyki poza zwykłymi pokojami.**
   - Menu, prolog, ołtarz, walka z Nemoraksem, mała forma, zwycięstwo, porażka i cutscenki grają w ciszy (albo z samymi efektami).
   - `MUS_defeat.wav` (3,2 s) istnieje, ale nie jest podpięty.
2. **Muzyka pokoi to 10 pętli po ~20 s.** Po minucie w pokoju słychać powtórkę.
3. **Katalog `assets/audio/ambient/` jest pusty.** Żaden pokój nie ma własnego tła dźwiękowego.
4. **47 plików leży nieużywanych**, m.in. cały pakiet P0: 4 warianty zamachu mieczem, trafień, różdżki, dasha oraz dźwięki bossa. Gra używa starszych pojedynczych plików z `sfx/gracz`. To może być tańsze niż szukanie nowych — wystarczy posłuchać, które lepsze, i podpiąć (zadanie kodowe, zrobię na prośbę).
5. **Podejrzane pliki:**
   - `I01_telegraph.wav` — zapowiedź ataku każdego wcielenia — trwa **0,05 s**, więc praktycznie jej nie słychać;
   - `I09_channel_interrupted.wav` jest w kodzie opisany jako pusty.
6. **Placeholdery** (jeden plik gra kilka ról): `P14_block_push_hit` gra blok, parowanie, przełamanie i ześlizgnięcie, różniąc się tylko wysokością. Prasa, regał i kryształ pożyczają dźwięki od bossa i wrogów.

---

## 1. Muzyka — ogólny motyw gry i utwory

| ID (propozycja) | Gdzie gra | Długość | Charakter |
|---|---|---|---|
| `MUS_theme_main` | menu główne, ekran tytułowy | **2:00–3:00, pętla** | Motyw przewodni NEMORAX-a: niski, kamienny, powolny; jedna rozpoznawalna fraza (4–6 nut), którą da się potem wpleść w inne utwory. Chór/szept, dzwon, niskie smyczki, bez perkusji „akcji”. |
| `MUS_prolog` | prolog (3 kwestie po ~2 s + przejście) | **0:30–0:45, pętla lub jednorazowy** | Motyw przewodni zredukowany do jednego instrumentu, dużo ciszy. |
| `MUS_explore_1…4` | pokoje bez walki / po oczyszczeniu | **1:30–2:30 każdy, pętla** | Zamiennik obecnych pętli 20 s. Ambientowy, rzadki, bez wyraźnego rytmu — gracz chodzi, wybiera nagrody. |
| `MUS_combat_1…3` | walka w zwykłym pokoju | **1:00–1:30, pętla** | Puls napięcia, perkusja kamienno-metalowa. Najlepiej jako **warstwa (stem)** nakładana na `MUS_explore` — płynne wejście przy walce i zejście po niej. |
| `MUS_elite` | pokój z elitą | **1:00–1:30, pętla** | Wersja combat z niższym basem i jednym „zimnym” elementem (jak aura elity). |
| `MUS_incarnation_1…6` | walki z 6 wcieleniami | **1:30–2:00 każdy, pętla** | Każde wcielenie ma swój akcent (Vhar’Nokh: nerwowy puls teleportu; Mordrath: cisza, oddech; Zha’Ruun: echo; Nekravor: ciężkie uderzenia; Thal’Gor: głód, zgrzyt; Orryx: cienie, pogłos). Wystarczy **jeden wspólny utwór + 6 krótkich motywów-nakładek** po 20–30 s, jeśli budżet mały. |
| `MUS_altar_ritual` | rytuał przy ołtarzu (cutscenka ~15–20 s) | **0:20–0:30, jednorazowy** | Narastanie, chór, kulminacja na „Nemorax powstaje”. Dziś jest nieużywany `W05_altar_summon` 17,8 s — **najpierw posłuchać, może wystarczy**. |
| `MUS_nemorax_phase_1…6` | 6 faz dużej formy (Ruch, Siła, Instynkt, Dominium, Ruina, Władza) | **0:45–1:00 każda, pętla** (średni build walczy 15–27 s na fazę, mocny 4–13 s) | Jeden utwór finałowy w 6 wariantach narastania — ta sama baza, kolejne warstwy. **Siła**: fazę wycisza gra (bez Paktu „Oczyść”) — muzyka tej fazy powinna wtedy mieć sens jako „głuchota”. **Władza**: mrok — mniej instrumentów, więcej przestrzeni i kierunkowych dźwięków. |
| `MUS_nemorax_small_form` | mała forma po twiście | **0:45–1:00, pętla** | Motyw przewodni w wersji rozbitej, nerwowej, wyższej. |
| `STINGER_twist` | przejście duża → mała forma | **3–5 s** | Pęknięcie świata, cisza, oddech. |
| `MUS_victory_epilog` | epilog (3–4 kwestie po ~2,5 s) + podsumowanie | **0:30–0:45** | Motyw przewodni spokojnie, niedomknięty („odłożenie na później”). |
| `MUS_defeat` | ekran śmierci | **5–8 s** (dziś jest 3,2 s, niepodpięty) | Krótki, niski, bez karania gracza. |

**Minimum na start (jeśli budżet mały):** motyw przewodni, 3 pętle eksploracji po 2 min, jeden utwór wcieleń, jeden finałowy (może być w 2 wersjach: duża i mała forma), epilog i porażka. To 8–9 plików.

## 2. Ambient pokoi (tło, bez melodii)

Każdy ambient: **60–90 s pętla**, cichy (−20…−25 dB poniżej muzyki), najlepiej 2 warstwy o różnej długości (np. 60 s + 47 s), żeby nie było słychać szwu.

| ID | Pokój / motyw | Co ma być słychać |
|---|---|---|
| `AMB_flooded_catacombs` | zalana katakumba | kapanie, płynąca woda, wilgotny pogłos |
| `AMB_sunken_library` | biblioteka | skrzypienie regałów, szelest kartek, kurz |
| `AMB_frozen_crypt` | lodowa krypta | wiatr, trzask lodu, zimne dzwonienie |
| `AMB_blood_ritual_hall` | sala rytuału (też **arena finału**) | niski pomruk, odległe bicie serca, szept |
| `AMB_overgrown_ruins` | zarośnięte ruiny | liście, owady, osypujący się kamień |
| `AMB_ash_battlefield` | pobojowisko | wiatr z popiołem, tlący się żar, metal |
| `AMB_crystal_cavern` | kryształowa grota | dzwonienie kryształów, echo |
| `AMB_rusted_machine_hall` | zardzewiała hala (pułapki) | skrzypienie mechanizmów, syk pary, metal |
| `AMB_soul_room` (×6 lub 1 wspólny) | pokoje wcieleń | wspólny: ciężka cisza z pulsem; opcjonalnie akcent każdego wcielenia |
| `AMB_altar` | ołtarz | kamień, runy, prawie niesłyszalny szept |
| `AMB_menu_cavern` | menu | odległy wiatr, ogrom pustki, pojedyncze krople |
| `AMB_start_room` | pokój startowy | cisza, oddech, delikatny szmer portali |

## 3. Brakujące efekty — rozgrywka (od najważniejszych)

### P0 — bez tego gracz nie wie, co się dzieje

| ID | Zdarzenie | Długość | Warianty | Uwagi |
|---|---|---|---|---|
| `I01_telegraph` (**wymiana**) | zapowiedź ataku wcielenia | **0,5–0,8 s** | 2 | dziś 0,05 s; gra zapowiada atak przez 0,6–0,9 s |
| `I10_arrival_windup` | Vhar’Nokh/Orryx pojawia się i celuje (nowa zapowiedź po teleporcie) | **0,35 s** (dokładnie) | 2 | krótki świst + „zamek” celu |
| `P15_guard_break` | przełamanie gardy | **0,4–0,6 s** | 1–2 | pęknięcie tarczy, niski trzask |
| `P16_block_slip` | cios z boku/tyłu, poza tarczą | **0,2–0,3 s** | 2 | metaliczny zgrzyt |
| `P17_parry` | parowanie | **0,3–0,4 s** | 2 | jasny, czysty „dzwon” stali; dziś P14 wyżej |
| `P14_block_hit` (opcjonalna wymiana) | zwykły blok | **0,2–0,3 s** | 3 | głuche uderzenie w tarczę |
| `I11_stance_break` | przełamanie postawy Nekravora | **0,6–0,9 s** | 1 | pękający pancerz + „okno” (dźwięk okazji, nie bólu) |
| `W10_trap_press_warn` | zapowiedź prasy | **0,8 s** (dokładnie = zapowiedź) | 2 | narastający zgrzyt mechanizmu |
| `W11_trap_press_slam` | uderzenie prasy | **0,4–0,6 s** | 3 | ciężki metal o kamień |
| `N20_darkness_start` / `_loop` / `_end` | Władza: zapada mrok | **1,5–2 s / 30–60 s pętla / 1–1,5 s** | 1 | pętla ma pomagać słuchem odnaleźć kierunek bossa |
| `N21_boss_breath_loop` | oddech Nemoraksa w mroku (dźwięk przestrzenny = gdzie jest) | **2–4 s pętla** | 1 | cichy, kierunkowy |
| `W12_zone_tick` | tyknięcie strefy na podłodze | **0,15–0,25 s** | 3 | syk/przypalenie |
| `W13_zone_fade` | strefa wygasa | **0,3–0,5 s** | 1 | cichnący syk |

### P1 — czytelność i feeling

| ID | Zdarzenie | Długość | Warianty |
|---|---|---|---|
| `W14_water_step` | krok / wejście w wodę (spowolnienie) | **0,2 s** | 3 |
| `P20_footstep_stone` / `_wet` / `_crystal` / `_wood` / `_metal` | kroki na powierzchniach | **0,15–0,25 s** | 4 każdy |
| `W15_crystal_bounce` | pocisk odbija się od kryształu | **0,3–0,5 s** | 2 |
| `W16_shelf_fall` | przewraca się regał | **0,8–1,2 s** | 1 |
| `W17_rest_spring` | odpoczynek (+30% HP) | **1,2–1,8 s** | 1 |
| `W18_door_open` / `W19_door_close` | drzwi pokoju otwierają się / zamykają przy walce | **0,6–1,0 s** | 2 |
| `U08_reward_reminder` | „Pokój czysty — nagrody czekają” | **0,4–0,6 s** | 1 |
| `U09_pact_choose` | wybór Paktu | **1,0–1,5 s** | 2 (Oczyść / Zwiąż — różne barwy) |
| `N22_silence_wave` | fala ciszy po parowaniu (Zwiąż) | **0,5–0,8 s** | 1 |
| `I09_channel_interrupted` (**wymiana**) | przerwane przywoływanie | **0,3–0,5 s** | 1 |
| `C01_text_reveal` | pojawienie się linii dialogu/cutscenki | **0,1–0,2 s** | 3 |

### P2 — bogactwo świata (później)

- Warianty śmierci/trafienia każdego z 11 wrogów: `SPAWN`, `ATTACK`, `DEATH`, po 0,3–1,0 s.
- `UI_map_open` / `_close` (0,2–0,3 s), `UI_pause_open` / `_close` (0,2–0,3 s).
- Kroki wrogów dla Kolosa i dużych wcieleń (0,3–0,5 s, 4 warianty).

## 4. Co już jest w projekcie (130 plików)

Kolumna „Użycie” pokazuje, który plik gry go odtwarza. „Nieużywany” = leży w projekcie, nic go nie gra. Warto najpierw odsłuchać nieużywane — część może być lepsza od obecnych.

| Plik | Długość | Użycie | Uwagi |
|---|---|---|---|
| `music/MUS_defeat.wav` | 3,20 s | — | **nieużywany** |
| `music/MUS_room_chase_1.wav` | 19,88 s | rooms/room.gd | pętla ~20 s — szybko się powtarza |
| `music/MUS_room_chase_2.wav` | 19,88 s | rooms/room.gd | pętla ~20 s — szybko się powtarza |
| `music/MUS_room_melody_1.wav` | 19,88 s | rooms/room.gd | pętla ~20 s — szybko się powtarza |
| `music/MUS_room_melody_2.wav` | 19,88 s | rooms/room.gd | pętla ~20 s — szybko się powtarza |
| `music/MUS_room_melody_3.wav` | 19,88 s | rooms/room.gd | pętla ~20 s — szybko się powtarza |
| `music/MUS_room_melody_4.wav` | 19,88 s | rooms/room.gd | pętla ~20 s — szybko się powtarza |
| `music/MUS_room_synth_1.wav` | 19,88 s | rooms/room.gd | pętla ~20 s — szybko się powtarza |
| `music/MUS_room_synth_2.wav` | 19,88 s | rooms/room.gd | pętla ~20 s — szybko się powtarza |
| `music/MUS_room_synth_3.wav` | 19,88 s | rooms/room.gd | pętla ~20 s — szybko się powtarza |
| `music/MUS_room_synth_4.wav` | 19,88 s | rooms/room.gd | pętla ~20 s — szybko się powtarza |
| `sfx/gracz/P01_dash_start.wav` | 0,33 s | entities/player.gd |  |
| `sfx/gracz/P02_dash_denied.wav` | 1,49 s | entities/player.gd |  |
| `sfx/gracz/P03_dash_void_locked.wav` | 1,62 s | entities/player.gd |  |
| `sfx/gracz/P04_weapon_switch.wav` | 0,29 s | entities/player.gd |  |
| `sfx/gracz/P05_attack_denied.wav` | 0,48 s | entities/player.gd |  |
| `sfx/gracz/P07_sword_swing.wav` | 0,77 s | entities/player.gd |  |
| `sfx/gracz/P08_sword_hit.wav` | 1,08 s | entities/player.gd |  |
| `sfx/gracz/P09_sword_miss.wav` | 0,36 s | entities/player.gd |  |
| `sfx/gracz/P10_wand_charge.wav` | 1,01 s | entities/player.gd |  |
| `sfx/gracz/P11_wand_fire.wav` | 1,21 s | entities/player.gd |  |
| `sfx/gracz/P12_wand_impact.wav` | 0,43 s | entities/player.gd, entities/projectile.gd |  |
| `sfx/gracz/P13_block_raise.wav` | 0,80 s | entities/player.gd |  |
| `sfx/gracz/P14_block_push_hit.wav` | 0,18 s | entities/player.gd | gra też zastępczo: parowanie (×1,35), przełamanie (×0,55), ześlizgnięcie (×1,9) |
| `sfx/gracz/P16_heal_use.wav` | 1,37 s | entities/player.gd |  |
| `sfx/gracz/P18_heal_charge_tick.wav` | 0,22 s | entities/player.gd |  |
| `sfx/gracz/P19_heal_ready.wav` | 1,29 s | entities/player.gd |  |
| `sfx/gracz/P22_player_knockback.wav` | 0,77 s | entities/player.gd |  |
| `sfx/materials/bone_death.wav` | 0,40 s | autoload/palette.gd |  |
| `sfx/materials/bone_hurt.wav` | 0,15 s | autoload/palette.gd |  |
| `sfx/materials/magic_death.wav` | 0,40 s | autoload/palette.gd |  |
| `sfx/materials/magic_hurt.wav` | 0,15 s | autoload/palette.gd |  |
| `sfx/materials/metal_death.wav` | 0,40 s | autoload/palette.gd |  |
| `sfx/materials/metal_hurt.wav` | 0,15 s | autoload/palette.gd |  |
| `sfx/materials/stone_death.wav` | 0,40 s | autoload/palette.gd |  |
| `sfx/materials/stone_hurt.wav` | 0,15 s | autoload/palette.gd |  |
| `sfx/nemorax/N01_transform_roar.wav` | 8,11 s | entities/boss.gd |  |
| `sfx/nemorax/N02_attack_inhale.wav` | 0,79 s | entities/boss.gd |  |
| `sfx/nemorax/N04_seal_explosion.wav` | 1,21 s | entities/seal.gd, rooms/room_terrain.gd | gra też zastępczo jako uderzenie prasy |
| `sfx/nemorax/N06_void_lock.wav` | 0,59 s | entities/void_zone.gd |  |
| `sfx/nemorax/N11_lunge_telegraph.wav` | 1,42 s | entities/boss.gd |  |
| `sfx/nemorax/N12_lunge_charge.wav` | 2,11 s | entities/boss.gd |  |
| `sfx/nemorax/N14_body_contact.wav` | 0,51 s | entities/boss.gd, rooms/room_terrain.gd | gra też zastępczo jako upadek regału |
| `sfx/nemorax/N16_nemorax_hurt.wav` | 1,28 s | entities/boss.gd |  |
| `sfx/nemorax/N17_bigform_collapse.wav` | 7,38 s | entities/boss.gd |  |
| `sfx/nemorax/N18_smallform_resurrect.wav` | 3,01 s | entities/boss.gd |  |
| `sfx/nemorax/N19_true_death.ogg` | 1,54 s | — | **nieużywany** |
| `sfx/p0/AMB_ROOM_CLEAR.wav` | 0,90 s | rooms/room.gd |  |
| `sfx/p0/BOSS_DEATH.wav` | 4,70 s | — | **nieużywany** |
| `sfx/p0/BOSS_HIT_1.wav` | 0,80 s | — | **nieużywany** |
| `sfx/p0/BOSS_HIT_2.wav` | 0,70 s | — | **nieużywany** |
| `sfx/p0/BOSS_HIT_3.wav` | 0,60 s | — | **nieużywany** |
| `sfx/p0/BOSS_INTRO.wav` | 2,00 s | — | **nieużywany** |
| `sfx/p0/BOSS_PHASE.wav` | 3,70 s | — | **nieużywany** |
| `sfx/p0/BOSS_TELEGRAPH_1.wav` | 0,70 s | — | **nieużywany** |
| `sfx/p0/BOSS_TELEGRAPH_2.wav` | 0,60 s | — | **nieużywany** |
| `sfx/p0/BOSS_TELEGRAPH_3.wav` | 0,90 s | — | **nieużywany** |
| `sfx/p0/ENEMY_DEATH_1.wav` | 1,40 s | — | **nieużywany** |
| `sfx/p0/ENEMY_DEATH_2.wav` | 1,10 s | — | **nieużywany** |
| `sfx/p0/ENEMY_DEATH_3.wav` | 1,20 s | — | **nieużywany** |
| `sfx/p0/ENEMY_DEATH_4.wav` | 1,30 s | — | **nieużywany** |
| `sfx/p0/ENEMY_ELITE_AURA_1.wav` | 2,00 s | entities/incarnation.gd |  |
| `sfx/p0/ENEMY_ELITE_AURA_2.wav` | 2,00 s | entities/incarnation.gd |  |
| `sfx/p0/ENEMY_HIT_1.wav` | 0,50 s | rooms/room_terrain.gd |  |
| `sfx/p0/ENEMY_HIT_2.wav` | 0,60 s | rooms/room_terrain.gd | gra też zastępczo jako odbicie od kryształu |
| `sfx/p0/ENEMY_HIT_3.wav` | 0,60 s | rooms/room_terrain.gd |  |
| `sfx/p0/ENEMY_HIT_4.wav` | 0,70 s | rooms/room_terrain.gd |  |
| `sfx/p0/ENEMY_TELEGRAPH_1.wav` | 0,40 s | rooms/room_terrain.gd |  |
| `sfx/p0/ENEMY_TELEGRAPH_2.wav` | 0,70 s | rooms/room_terrain.gd | gra też zastępczo jako zapowiedź prasy |
| `sfx/p0/ENEMY_TELEGRAPH_3.wav` | 0,40 s | rooms/room_terrain.gd |  |
| `sfx/p0/ENEMY_TELEGRAPH_4.wav` | 0,30 s | rooms/room_terrain.gd |  |
| `sfx/p0/PLAYER_DASH_1.wav` | 0,60 s | — | **nieużywany** |
| `sfx/p0/PLAYER_DASH_2.wav` | 0,40 s | — | **nieużywany** |
| `sfx/p0/PLAYER_DEATH.wav` | 1,30 s | entities/player.gd |  |
| `sfx/p0/PLAYER_FOOTSTEP_STONE.wav` | 0,40 s | — | **nieużywany** |
| `sfx/p0/PLAYER_HURT_1.wav` | 0,60 s | entities/player.gd |  |
| `sfx/p0/PLAYER_HURT_2.wav` | 0,50 s | entities/player.gd |  |
| `sfx/p0/PLAYER_HURT_3.wav` | 0,60 s | entities/player.gd |  |
| `sfx/p0/PLAYER_SWORD_HIT_ARMOR_1.wav` | 0,40 s | — | **nieużywany** |
| `sfx/p0/PLAYER_SWORD_HIT_ARMOR_2.wav` | 0,60 s | — | **nieużywany** |
| `sfx/p0/PLAYER_SWORD_HIT_ARMOR_3.wav` | 0,60 s | — | **nieużywany** |
| `sfx/p0/PLAYER_SWORD_HIT_ARMOR_4.wav` | 0,40 s | — | **nieużywany** |
| `sfx/p0/PLAYER_SWORD_HIT_FLESH_1.wav` | 0,20 s | — | **nieużywany** |
| `sfx/p0/PLAYER_SWORD_HIT_FLESH_2.wav` | 0,70 s | — | **nieużywany** |
| `sfx/p0/PLAYER_SWORD_HIT_FLESH_3.wav` | 0,60 s | — | **nieużywany** |
| `sfx/p0/PLAYER_SWORD_HIT_FLESH_4.wav` | 0,30 s | — | **nieużywany** |
| `sfx/p0/PLAYER_SWORD_SWING_1.wav` | 0,40 s | — | **nieużywany** |
| `sfx/p0/PLAYER_SWORD_SWING_2.wav` | 0,50 s | — | **nieużywany** |
| `sfx/p0/PLAYER_SWORD_SWING_3.wav` | 0,40 s | — | **nieużywany** |
| `sfx/p0/PLAYER_SWORD_SWING_4.wav` | 0,40 s | — | **nieużywany** |
| `sfx/p0/PLAYER_WAND_CAST_1.wav` | 1,00 s | — | **nieużywany** |
| `sfx/p0/PLAYER_WAND_CAST_2.wav` | 0,90 s | — | **nieużywany** |
| `sfx/p0/PLAYER_WAND_CAST_3.wav` | 1,30 s | — | **nieużywany** |
| `sfx/p0/PLAYER_WAND_HIT_1.wav` | 1,20 s | — | **nieużywany** |
| `sfx/p0/PLAYER_WAND_HIT_2.wav` | 1,20 s | — | **nieużywany** |
| `sfx/p0/PLAYER_WAND_HIT_3.wav` | 1,10 s | — | **nieużywany** |
| `sfx/p0/REWARD_RELIC_CONFIRM.wav` | 1,00 s | — | **nieużywany** |
| `sfx/p0/REWARD_RELIC_REVEAL.wav` | 1,00 s | ui/ui.gd |  |
| `sfx/p0/UI_ALTAR_OPEN.wav` | 5,00 s | rooms/altar.gd |  |
| `sfx/p0/UI_ALTAR_POINT.wav` | 0,20 s | rooms/altar.gd |  |
| `sfx/p0/UI_BACK_1.wav` | 0,60 s | autoload/juice.gd, menu.gd, ui/keybind_screen.gd, ui/menu_list_panel.gd, ui/options_screen.gd, ui/pact_select.gd, ui/pause_menu.gd, ui/relic_draft.gd, ui/skill_draft.gd, ui/stats_screen.gd |  |
| `sfx/p0/UI_BACK_2.wav` | 0,60 s | autoload/juice.gd, menu.gd, ui/keybind_screen.gd, ui/menu_list_panel.gd, ui/options_screen.gd, ui/pact_select.gd, ui/pause_menu.gd, ui/relic_draft.gd, ui/skill_draft.gd, ui/stats_screen.gd |  |
| `sfx/p0/UI_CONFIRM_1.wav` | 0,20 s | autoload/juice.gd, menu.gd, ui/keybind_screen.gd, ui/menu_list_panel.gd, ui/options_screen.gd, ui/pause_menu.gd |  |
| `sfx/p0/UI_CONFIRM_2.wav` | 0,60 s | autoload/juice.gd, menu.gd, ui/keybind_screen.gd, ui/menu_list_panel.gd, ui/options_screen.gd, ui/pause_menu.gd |  |
| `sfx/p0/UI_ERROR.wav` | 0,30 s | autoload/juice.gd, menu.gd, rooms/room.gd, ui/reward_prompt.gd, ui/skill_draft.gd, ui/stats_screen.gd |  |
| `sfx/p0/UI_LEVEL_UP.wav` | 0,50 s | autoload/juice.gd, ui/intent_select.gd, ui/pact_select.gd, ui/relic_draft.gd, ui/skill_draft.gd, ui/stats_screen.gd |  |
| `sfx/p0/UI_NAVIGATE_2.wav` | 1,00 s | autoload/juice.gd, menu.gd, ui/intent_select.gd, ui/keybind_screen.gd, ui/menu_list_panel.gd, ui/options_screen.gd, ui/pause_menu.gd, ui/skill_draft.gd, ui/stats_screen.gd |  |
| `sfx/p0/UI_NAVIGATE_3.wav` | 1,00 s | autoload/juice.gd, menu.gd, ui/intent_select.gd, ui/keybind_screen.gd, ui/menu_list_panel.gd, ui/options_screen.gd, ui/pause_menu.gd, ui/skill_draft.gd, ui/stats_screen.gd |  |
| `sfx/p0/UI_NAVIGATE__1.wav` | 1,00 s | autoload/juice.gd |  |
| `sfx/p0/UI_STATS_OPEN.wav` | 0,30 s | ui/stats_screen.gd |  |
| `sfx/p0/WORLD_CHEST_OPEN_1.wav` | 1,00 s | rooms/chest.gd |  |
| `sfx/p0/WORLD_CHEST_OPEN_2.wav` | 1,00 s | rooms/chest.gd |  |
| `sfx/p0/WORLD_PORTAL_IDLE.wav` | 6,00 s | — | **nieużywany** |
| `sfx/p0/WORLD_PORTAL_USE_1.wav` | 1,00 s | — | **nieużywany** |
| `sfx/p0/nmx_enemy_ambusher_alert_01.wav` | 0,50 s | entities/random_enemies/ambusher.gd |  |
| `sfx/p0/nmx_enemy_zoner_skill_01.wav` | 0,50 s | entities/random_enemies/zoner.gd |  |
| `sfx/swiat/W01_door_pass.wav` | 3,97 s | — | **nieużywany** |
| `sfx/swiat/W03_soul_pickup.wav` | 1,68 s | rooms/chest.gd, rooms/soul.gd |  |
| `sfx/swiat/W05_altar_summon.wav` | 17,83 s | — | nieużywany, 17,8 s |
| `sfx/ui/U01_phase_banner.wav` | 2,88 s | — | **nieużywany** |
| `sfx/ui/U02_taunt_chime.wav` | 0,18 s | — | **nieużywany** |
| `sfx/ui/U04_death_overlay_sting.wav` | 0,88 s | — | **nieużywany** |
| `sfx/ui/U07_menu_confirm.wav` | 1,50 s | — | **nieużywany** |
| `sfx/wcielenia/I01_telegraph.wav` | 0,05 s | entities/incarnation.gd | **tylko 0,05 s — prawie niesłyszalny** |
| `sfx/wcielenia/I02_damage_pulse.wav` | 0,41 s | entities/incarnation.gd |  |
| `sfx/wcielenia/I04_lunge_start.wav` | 0,96 s | entities/incarnation.gd |  |
| `sfx/wcielenia/I05_contact_hit.wav` | 0,68 s | entities/enemy_projectile.gd, entities/incarnation.gd | gra też zastępczo jako przełamanie postawy i trafienie pociskiem |
| `sfx/wcielenia/I07_incarnation_hurt.wav` | 1,38 s | — | **nieużywany** |
| `sfx/wcielenia/I08_incarnation_death.wav` | 0,90 s | — | **nieużywany** |
| `sfx/wcielenia/I09_channel_interrupted.wav` | 0,15 s | entities/random_enemies/summoner.gd | w kodzie opisany jako „plik pusty do uzupełnienia” |

Pliki leżą w `assets/audio/`. Najszybciej odsłuchasz je w edytorze Godota (klik na plik → podgląd w inspektorze) albo w dowolnym odtwarzaczu.
