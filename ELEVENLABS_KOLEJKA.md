# NEMORAX — Kolejka generowania w ElevenLabs (Sound Effects)

Płaska, sekwencyjna checklista wyciągnięta z [AUDIO_KATALOG.md](AUDIO_KATALOG.md) —
jeden wiersz = jedna generacja w ElevenLabs. Rób od góry do dołu, odhaczaj,
zapisuj pod podaną nazwą pliku. Pominięte kody (P15, P17, U3, U5, U6) to
świadome duplikaty — patrz kolumna w katalogu, nie generuj ich osobno.

Sekcje muzyczne (na końcu, oznaczone 🎵) są bardziej "kompozycyjne" —
ElevenLabs może dać radę, ale jeśli wynik brzmi jak efekt dźwiękowy zamiast
utworu, to sygnał żeby ten JEDEN konkretny wiersz zrobić w Suno zamiast tu
(patrz `AUDIO_KATALOG.md` Krok 1).

**Ważne — twardy limit ElevenLabs: minimum 0.5 sekundy na generację**
(potwierdzone w dokumentacji API: `duration_seconds` musi być ≥0.5). Sporo
wierszy poniżej ma w opisie krótszy czas (0.05-0.4s) — to niemożliwe do
uzyskania wprost. Liczba sekund w tekście promptu to tylko sugestia
"jak krótki ma brzmieć charakter dźwięku", nie realny parametr. Rób tak:
1. Ustaw długość generacji na **0.5s** (minimum) dla każdego takiego wiersza.
2. W Audacity **przytnij** wynik do docelowej długości z opisu — model zwykle
   i tak daje "trzask"/transient na samym początku, resztę po prostu odetnij.

Jeśli w interfejsie widzisz przełącznik **"Loop"** przy generowaniu — włącz
go dla wszystkiego z sekcji 🎵 (muzyka/ambient), to model sam postara się o
bezszwową pętlę, bez ręcznego crossfade'u w Audacity.

---

## Priorytet 1 — Gracz (20 dźwięków)

- [ ] `P01_dash_start.ogg` — Quick whoosh dash sound, short air displacement, energetic, 0.3s
- [ ] `P02_dash_denied.ogg` — Short dull denial blip, low-pitched, no reverb, 0.15s
- [ ] `P03_dash_void_locked.ogg` — Short metallic locking/clamping sound, restrictive, slightly ominous, 0.2s
- [ ] `P04_weapon_switch.ogg` — Quick weapon-switch click, mechanical, subtle metallic shift, 0.15s
- [ ] `P05_attack_denied.ogg` — Soft empty-resource denial sound, hollow thud, 0.15s
- [ ] `P06_sword_windup.ogg` — Short sword wind-up swish, building tension, 0.2s
- [ ] `P07_sword_swing.ogg` — Sharp sword slash through air, fast metallic whoosh, aggressive, 0.25s
- [ ] `P08_sword_hit.ogg` — Heavy impactful sword hit, sharp crunch with a slight metallic ring, punchy, 0.2s
- [ ] `P09_sword_miss.ogg` — Sword swing whoosh with no impact, slightly disappointed tail, 0.2s
- [ ] `P10_wand_charge.ogg` — Rising magical charge-up hum, energy building, sparkly high-frequency tail, 0.4s
- [ ] `P11_wand_fire.ogg` — Magic projectile launch, short energetic zap, bright tonal quality, 0.25s
- [ ] `P12_wand_impact.ogg` — Magic projectile impact, sparkly burst hit, medium punch, 0.2s
- [ ] `P13_block_raise.ogg` — Shield-raise sound, brief metallic resonance, defensive, 0.2s
- [ ] `P14_block_push_hit.ogg` — Blunt shockwave push impact, deep thud with a knockback whoosh, 0.25s
- [ ] `P16_heal_use.ogg` — Warm healing chime, soft rising tone, gentle magical shimmer, 0.5s
- [ ] `P18_heal_charge_tick.ogg` — Tiny subtle tick, barely audible charge-up pip, 0.05s
- [ ] `P19_heal_ready.ogg` — Clear bright ready-notification ping, single bell-like tone, 0.3s
- [ ] `P20_player_hurt.ogg` — Player pain grunt combined with a dull impact hit, visceral but not graphic, 0.3s
- [ ] `P21_player_death.ogg` — Falling defeat sound, descending pitch groan, fading out, 1s
- [ ] `P22_player_knockback.ogg` — Quick forceful push-back whoosh, 0.2s

## Priorytet 2 — Nemorax, finałowy boss (19 dźwięków)

- [ ] `N01_transform_roar.ogg` — Powerful monstrous transformation roar, long sustained growl with rising pitch, earth-shaking, 1.5s
- [ ] `N02_attack_inhale.ogg` — Short menacing inhale/charge-up before an attack, ominous, 0.4s
- [ ] `N03_seal_telegraph.ogg` — Rising crackling energy build-up, warning tone, 0.6s
- [ ] `N04_seal_explosion.ogg` — Sharp rune explosion, bright crackling burst, energetic, 0.3s
- [ ] `N05_void_open.ogg` — Reality-tearing rip sound, deep void opening, unsettling low drone, 0.5s
- [ ] `N06_void_lock.ogg` — Metallic locking clamp, restrictive and final, 0.2s
- [ ] `N07_void_close.ogg` — Void closing shut, reversed tearing sound collapsing inward, 0.4s
- [ ] `N08_shadow_spawn.ogg` — Distorted echo of footsteps and a whisper, dark twisted mimicry, 0.4s
- [ ] `N09_shadow_hit.ogg` — Distorted version of a pain hit, warped and unnatural, 0.2s
- [ ] `N10_shadow_fade.ogg` — Shadow dissolving, whispery fade into nothing, 0.5s
- [ ] `N11_lunge_telegraph.ogg` — Deep menacing charge-up growl before a lunge, heavy and threatening, 0.5s
- [ ] `N12_lunge_charge.ogg` — Massive charging dash sound, heavy footfalls and rushing air, aggressive, 0.4s
- [ ] `N13_lunge_chain.ogg` — Second immediate lunge sound, same as a charging dash but slightly sharper/urgent, 0.4s
- [ ] `N14_body_contact.ogg` — Heavy dull body-contact thud, massive creature touch, 0.2s
- [ ] `N15_hunger_regen_loop.ogg` — Subtle ominous regenerating hum loop, low pulsing, unsettling, seamless loop
- [ ] `N16_nemorax_hurt.ogg` — Deep monstrous pain roar, short and guttural, 0.3s
- [ ] `N17_bigform_collapse.ogg` — Massive form collapsing, long descending groan that does not fully resolve, 1.2s
- [ ] `N18_smallform_resurrect.ogg` — Quiet unsettling resurrection sound, small but wrong, faint whisper-laugh undertone, 1s
- [ ] `N19_true_death.ogg` — Final massive death collapse, long dissonant descending tone, dissolves completely, 2s

## Priorytet 3 — Wspólny core sześciu wcieleń (8 dźwięków, pokrywa wszystkie 6 pokoi)

- [ ] `I01_telegraph.ogg` — Rising ominous warning drone, building tension, telegraphs an incoming attack, 0.5s
- [ ] `I02_damage_pulse.ogg` — Dark magical shockwave burst, radiating outward, deep low-end thump, 0.3s
- [ ] `I03_pull.ogg` — Reversed sucking whoosh, pulling inward, unsettling, 0.4s
- [ ] `I04_lunge_start.ogg` — Aggressive lunging dash sound, fast approach, guttural undertone, 0.3s
- [ ] `I05_contact_hit.ogg` — Dull creature-contact hit, organic thud, 0.15s
- [ ] `I06_knockback_received.ogg` — Creature knocked back, pained grunt with a whoosh, 0.25s
- [ ] `I07_incarnation_hurt.ogg` — Short creature pain shriek, sharp and dissonant, 0.2s
- [ ] `I08_incarnation_death.ogg` — Creature death dissolve, descending dissonant tone fading into silence, 0.8s

## Priorytet 4a — Unikalne warianty per wcielenie (7 dźwięków)

- [ ] `VN_teleport.ogg` (Vhar'Nokh) — Sharp teleport blink, quick displacement pop with a brief static crackle, 0.2s
- [ ] `MD_muffled_burst.ogg` (Mordrath) — Muffled, underwater-like version of a magical burst, dampened high frequencies, distant and suppressed, 0.3s
- [ ] `ZR_echo_pulse.ogg` (Zha'Ruun) — Delayed echo repeat of a magical burst, same hit but faded and slightly detuned, like a stuck echo, 0.3s
- [ ] `NK_crush_pulse.ogg` (Nekravor) — Heavy crushing gravitational impact, deep sub-bass slam, oppressive weight, 0.4s
- [ ] `TG_bite_drain.ogg` (Thal'Gor) — Wet visceral bite sound followed by a draining slurp, predatory, 0.3s
- [ ] `OR_vanish.ogg` (Orryx) — Fading vanish whoosh, dissolving into silence, ghostly, 0.3s
- [ ] `OR_reappear.ogg` (Orryx) — Sudden reappearing thud with a dark magical flourish, 0.25s

## Priorytet 4b — Świat / pokoje (5 dźwięków)

- [ ] `W01_door_pass.ogg` — Heavy stone door creak and thud, brief, ancient mechanism, 0.4s
- [ ] `W02_soul_idle_hum.ogg` — Soft pulsing magical hum, gentle and inviting, seamless loop, quiet
- [ ] `W03_soul_pickup.ogg` — Warm collection chime, rising magical shimmer, satisfying, 0.4s
- [ ] `W04_altar_tension.ogg` — Rising ritualistic tension drone, building anticipation, 1s
- [ ] `W05_altar_summon.ogg` — Massive ceremonial summoning thunder, deep resonant boom with chanting undertone, 2s

## Priorytet 4c — UI (4 dźwięki)

- [ ] `U01_phase_banner.ogg` — Short dramatic announcement sting, single low gong hit, 0.3s
- [ ] `U02_taunt_chime.ogg` — Gentle notification chime, soft and brief, 0.2s
- [ ] `U04_death_overlay_sting.ogg` — Short somber failure sting, low descending tone, 0.5s
- [ ] `U07_menu_confirm.ogg` — Simple satisfying UI confirm sound, short and clean, 0.15s

## Priorytet 5 — 🎵 Muzyka (11 utworów/stingerów)

- [ ] `MUS_menu.ogg` — Dark ambient dungeon-synth menu theme, slow and ominous, deep sustained drone, distant faint choir whisper, sparse single piano notes echoing into silence, no percussion, unsettling but restrained, loopable, 60-90 BPM feel
- [ ] `MUS_room_loop.ogg` — Tense looping dungeon exploration music, low pulsing bass drone, sparse metallic percussion hits at irregular intervals, building unease without a strong beat, dark fantasy boss-room atmosphere, seamless loop, no melody hooks, stays in the background
- [ ] `MUS_altar.ogg` — Ritualistic dark fantasy music, low chanting drone building in intensity, deep resonant gong hits, growing dissonant choir as the track progresses, climactic and dreadful, designed to build tension toward a summoning, loopable middle section
- [ ] `MUS_nemorax_battle.ogg` — Intense dark fantasy boss battle music, driving low percussion, aggressive distorted synth bass, orchestral hybrid, relentless but not chaotic, builds and releases in waves, seamless loop, no vocals
- [ ] `MUS_phase_zwloka.ogg` — Short stuttering musical stinger, notes repeating like a skipping record, glitchy echo, dark fantasy, 10 seconds
- [ ] `MUS_phase_ciezar.ogg` — Short heavy descending musical stinger, slowing pitch-down effect, crushing weight sensation, deep sub-bass, dark fantasy, 10 seconds
- [ ] `MUS_phase_glod.ogg` — Short musical stinger with a low guttural growl texture woven in, hungry and predatory feel, dark fantasy, 10 seconds
- [ ] `MUS_phase_zacmienie.ogg` — Short musical stinger that fades into near-total silence at the end, isolating and cold, dark fantasy, 10 seconds
- [ ] `MUS_phase_final.ogg` — Short unsettling music box-like melody fragment, childlike but wrong, fading out, dark fantasy, 10 seconds
- [ ] `MUS_victory.ogg` — Somber victory theme for a dark fantasy game, bittersweet and exhausted rather than triumphant, slow swelling strings, single distant bell, resolves into quiet, no percussion fanfare, 20-30 seconds, does not need to loop
- [ ] `MUS_defeat.ogg` — Short dark defeat stinger, low dissonant chord hit, descending pitch, hollow reverb tail, 3-5 seconds, no melody

## Priorytet 6 — 🎵 Ambient per pokój (8 pętli)

- [ ] `AMB_room1_vharnokh.ogg` — Deep space-like void ambience, distant echoing whispers, cold and empty, seamless loop
- [ ] `AMB_room2_mordrath.ogg` — Near-silent muffled ambience, extremely quiet distant murmur, oppressive quiet, seamless loop
- [ ] `AMB_room3_zharuun.ogg` — Distorted clock ticking ambience, irregular stutter, time feels broken, seamless loop
- [ ] `AMB_room4_nekravor.ogg` — Heavy oppressive low rumble, crushing weight in the air, deep sub-bass drone, seamless loop
- [ ] `AMB_room5_thalgor.ogg` — Distant guttural growling ambience, hungry organic undertone, unsettling, seamless loop
- [ ] `AMB_room6_orryx.ogg` — Dark flickering ambience, occasional whispery fade in and out, cold void, seamless loop
- [ ] `AMB_altar.ogg` — Ceremonial waiting ambience, faint distant chanting, anticipatory, seamless loop
- [ ] `AMB_arena_nemorax.ogg` — Massive throne room ambience, deep cavernous reverb, distant ominous rumble, seamless loop

---

**Razem: 82 generacje.** Po ElevenLabs pamiętaj o Kroku 4 z `AUDIO_KATALOG.md`
(przycięcie, pętla/crossfade, normalizacja) zanim wrzucisz do Godota.
