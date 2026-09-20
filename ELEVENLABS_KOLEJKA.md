# NEMORAX — Kolejka generowania w ElevenLabs (Sound Effects)

Wersja 2: dużo bardziej szczegółowe prompty, napisane specjalnie pod to, jak
ElevenLabs faktycznie interpretuje opisy dźwięku. Różnice względem wersji 1:

- **Zero liczby sekund w treści promptu.** ElevenLabs i tak ma twardy limit
  minimum 0.5s (`duration_seconds` w API), a liczba w tekście to tylko
  sugestia, nie realny parametr — więc zamiast "0.2s" opisuję słowami KSZTAŁT
  dźwięku w czasie (natychmiastowy atak, brak ogona, szybkie wybrzmienie itd.),
  co model rozumie dużo lepiej. Docelową długość i przycinanie masz osobno w
  kolumnie **Cel**.
- **Konkretne materiały i fizyka** zamiast ogólników — "metallic clamp
  snapping shut" zamiast "metallic sound". Model radzi sobie wyraźnie lepiej,
  gdy wie, JAKI obiekt i JAKA czynność generuje dźwięk.
- **Jawne "dry recording, no reverb"** przy większości efektów — pogłos ma
  dokładać Godot (per pokój, przez busy audio), nie sam plik źródłowy. Bez
  tego zastrzeżenia modele często dodają pogłos hali/katedry, którego potem
  nie da się zdjąć.
- **"Seamlessly loopable" + opis stałej faktury** przy pętlach (muzyka/
  ambient) zamiast obiecywania konkretnej struktury utworu.

## Jak czytać kolumnę "Cel"
ElevenLabs nie zejdzie poniżej 0.5s. Dla wszystkiego, co docelowo ma być
krótsze: ustaw generację na **0.5s**, potem w Audacity przytnij do liczby
podanej w "Cel". Dla pętli (muzyka/ambient) generuj **blisko maksimum, 25-30s**
(twardy limit API to 30s) — Godot i tak zapętli ten kawałek w nieskończoność
przez `Loop = On`, więc nie trzeba (i nie da się) wygenerować całej
kilkuminutowej ścieżki na raz.

Jeśli w interfejsie jest przełącznik **"Loop"** — włącz go przy WSZYSTKICH
pozycjach 🎵, model sam postara się o zgodne zapętlenie.

## Status po przejrzeniu "400 Sounds Pack"
25 pozycji oznaczonych **✅ ZNALEZIONE** — skopiowane, przesłuchane,
zatwierdzone i przemianowane wg konwencji w
`C:\Users\gerwald\Desktop\dzwięki gra\NEMORAX_wybrane\`, gotowe do
wrzucenia do Godota bez generowania. Zostały jeszcze **P20_player_hurt** i
**P21_player_death** — w `_do_przesluchania` czeka 11 plików
`man_0.wav`...`man_10.wav`, trzeba wybrać jeden na ból i jeden (inny) na
śmierć, i przenieść do `02_player_sfx` pod właściwą nazwą. Ten pakiet jest
ogólny/casualowy (karty, retro 8-bit, match-3), więc NIE pokrywa niczego
związanego z magią/potworami/atmosferą — cała reszta (Nemorax, unikalne
umiejętności wcieleń, ambient, prawdziwa muzyka) i tak wymaga generowania.

---

## Priorytet 1 — Gracz (20 dźwięków)

- [x] **P01_dash_start.ogg** ✅ ZNALEZIONE (`Other/whoosh_1.wav` z 400 Sounds Pack) (cel: ~0.3s) — A very short, sharp whoosh of displaced air as a lightweight figure bursts forward at high speed, quick rising pitch sweep from low to high, crisp and energetic with almost no tail, dry recording with no reverb or room tone.
- [x] **P02_dash_denied.ogg** ✅ ZNALEZIONE (`UI/sci_fi_disallow.wav`, zatwierdzone) (cel: ~0.15s) — A very short, dull low-pitched electronic blip signaling a blocked action, flat and unresonant like a muted rubber tap, instant attack with no ring or sustain, dry and close, no reverb.
- [x] **P03_dash_void_locked.ogg** ✅ ZNALEZIONE (`UI/sci_fi_error.wav`, zatwierdzone) (cel: ~0.2s) — A short metallic clamp locking shut, a heavy latch or manacle snapping closed, cold and restrictive with a faint ominous low-end resonance underneath, dry recording, no reverb.
- [x] **P04_weapon_switch.ogg** ✅ ZNALEZIONE (`Weapons/weapon_equip_short.wav`) (cel: ~0.15s) — A quick, precise mechanical click of a weapon holster or clasp switching position, subtle metallic slide followed by a firm snap, small-scale and tactile, dry and close-up with no reverb.
- [x] **P05_attack_denied.ogg** ✅ ZNALEZIONE (`Retro/undesired_effect.wav`, zatwierdzone) (cel: ~0.15s) — A soft, hollow thud representing an empty or exhausted resource, low muted knock with no ring or brightness, slightly disappointing and flat in tone, dry recording, no reverb.
- [ ] **P06_sword_windup.ogg** (cel: ~0.2s) — A short rising swish of a blade being drawn back through the air in preparation to strike, thin and tense air-cutting sound with a quick upward pitch build, dry and close, no reverb.
- [x] **P07_sword_swing.ogg** ✅ ZNALEZIONE (`Weapons/sword_slice.wav`) (cel: ~0.25s) — A fast, sharp metallic sword slash cutting through the air, aggressive whoosh with a thin high-frequency edge and a quick low-to-high pitch sweep, dry recording, no reverb or room tone.
- [x] **P08_sword_hit.ogg** ✅ ZNALEZIONE (`Combat and Gore/crunch.wav`) (cel: ~0.2s) — A heavy, punchy sword impact striking flesh and bone, a sharp crunching hit layered with a brief metallic ring from the blade, immediate hard attack with a very short decay, dry and close-up.
- [x] **P09_sword_miss.ogg** ✅ ZNALEZIONE (`Weapons/sword_light.wav`) (cel: ~0.2s) — A fast sword swing whoosh through empty air with no impact at the end, thin metallic edge fading quickly into nothing, slightly anticlimactic tail, dry recording, no reverb.
- [ ] **P10_wand_charge.ogg** (cel: ~0.4s) — A rising magical energy charge-up, a smooth electric hum climbing steadily in pitch and intensity, glittering high-frequency sparkle woven through the buildup, tension increasing toward a peak, dry recording, no reverb.
- [ ] **P11_wand_fire.ogg** (cel: ~0.25s) — A short, bright magical zap as an energy projectile launches forward, a crisp electric crackle with a quick forward pitch sweep and a clean tonal center, energetic and precise, dry and close, no reverb.
- [ ] **P12_wand_impact.ogg** (cel: ~0.2s) — A magical projectile striking its target, a compact sparkly burst with a medium-weight punch at its core, bright crackling energy dissipating quickly outward, dry recording, no reverb.
- [x] **P13_block_raise.ogg** ✅ ZNALEZIONE (`Weapons/weapon_equip.wav`, zatwierdzone) (cel: ~0.2s) — A defensive shield or blade being raised into a guard position, a brief metallic resonance with a soft magical shimmer underneath, controlled and solid rather than aggressive, dry and close-up, no reverb.
- [x] **P14_block_push_hit.ogg** ✅ ZNALEZIONE (`Combat and Gore/punch_2.wav`) (cel: ~0.25s) — A blunt defensive shockwave pushing an attacker back, a deep low-end thud at the moment of contact immediately followed by a short forceful whoosh of displaced air, dry recording, no reverb.
- [x] **P16_heal_use.ogg** ✅ ZNALEZIONE (`Musical Effects/vibraphone_chime_positive.wav`) (cel: ~0.5s) — A warm, gentle healing chime, a soft tone rising smoothly in pitch with a light magical shimmer trailing behind it, comforting and soothing rather than bright or sharp, dry recording with a natural soft decay, no reverb.
- [x] **P18_heal_charge_tick.ogg** ✅ ZNALEZIONE (`UI/pop_1.wav`, zatwierdzone) (cel: ~0.05s) — An extremely small, subtle electronic tick, a barely-there pip marking one increment of progress, soft and unobtrusive with no ring or sustain at all, dry and close, no reverb.
- [x] **P19_heal_ready.ogg** ✅ ZNALEZIONE (`Musical Effects/vibraphone_chime_quick.wav`) (cel: ~0.3s) — A single clear, bright bell-like ping notifying that something is fully ready, clean pure tone with a short natural decay, pleasant and satisfying, dry recording, no reverb.
- [ ] **P20_player_hurt.ogg** 🔊 sprawdź 11 kandydatów `Human/man_0..10.wav` w `_do_przesluchania` — jeden z nich (cel: ~0.3s) — A short human pain grunt layered with a dull physical impact hit, visceral and immediate but restrained rather than graphic or gory, a single sharp exhale of effort and pain, dry recording, no reverb.
- [ ] **P21_player_death.ogg** 🔊 sprawdź te same kandydaty `Human/man_0..10.wav` — inny z nich (cel: ~1s) — A defeated human groan with a descending pitch, breath fading and weakening as the body collapses, a slow exhausted exhale trailing off into silence, dry recording with a natural soft fade, no reverb.
- [x] **P22_player_knockback.ogg** ✅ ZNALEZIONE (`Other/whoosh_2.wav`) (cel: ~0.2s) — A quick, forceful whoosh of a body being knocked backward through the air, a short burst of displaced air with a sudden onset and fast fade, dry recording, no reverb.

## Priorytet 2 — Nemorax, finałowy boss (19 dźwięków)

- [ ] **N01_transform_roar.ogg** (cel: ~1.5s) — A massive monstrous roar during a violent bodily transformation, a long sustained guttural growl that rises steadily in pitch and intensity, deep chest-shaking low frequencies mixed with a raw straining upper register, powerful and sustained throughout, dry recording, no reverb.
- [ ] **N02_attack_inhale.ogg** (cel: ~0.4s) — A short, menacing monstrous inhale as a creature draws breath before attacking, a deep rasping intake of air with an ominous low growl underneath, tension building toward the end, dry recording, no reverb.
- [ ] **N03_seal_telegraph.ogg** (cel: ~0.6s) — A rising crackling arcane energy build-up warning of an impending explosion, sharp electrical crackle intensifying steadily in pitch and density, a thin warning tone woven through it, dry recording, no reverb.
- [x] **N04_seal_explosion.ogg** ✅ ZNALEZIONE (`Retro/explosion_medium.wav`, zatwierdzone mimo retro-stylu) (cel: ~0.3s) — A sharp magical rune explosion, a bright energetic crackling burst with a hard percussive attack at its center, quickly dissipating into fading electrical sparks, dry recording, no reverb.
- [ ] **N05_void_open.ogg** (cel: ~0.5s) — A reality-tearing rip as a void portal forcefully opens, a deep unsettling low drone underpinning a harsh tearing texture, cold and vast rather than explosive, dry recording, minimal natural room tone only.
- [x] **N06_void_lock.ogg** ✅ ZNALEZIONE (`Materials/metal_clang.wav`) (cel: ~0.2s) — A heavy metallic clamp locking shut with finality, a solid mechanical snap with a short resonant metallic ring, restrictive and cold, dry recording, no reverb.
- [ ] **N07_void_close.ogg** (cel: ~0.4s) — A void portal collapsing shut, a tearing texture that seems to play in reverse and rush inward toward a single point, ending in an abrupt cold silence, dry recording, minimal room tone.
- [ ] **N08_shadow_spawn.ogg** (cel: ~0.4s) — A distorted, twisted echo of footsteps blended with a faint whispering voice, dark unnatural mimicry of something human, pitched slightly wrong and unsettling, subtle natural echo only, no heavy reverb.
- [ ] **N09_shadow_hit.ogg** (cel: ~0.2s) — A pain-impact sound that has been warped and pitch-distorted into something unnatural, a hit and a cry blended and twisted together, brief and jarring, dry recording, no reverb.
- [ ] **N10_shadow_fade.ogg** (cel: ~0.5s) — A shadowy figure dissolving into nothing, a soft whispery textured fade that thins out gradually until silence, airy and insubstantial, dry recording, no reverb.
- [ ] **N11_lunge_telegraph.ogg** (cel: ~0.5s) — A deep menacing growl building steadily as a massive creature prepares to lunge, heavy low-end weight with a threatening rising tension, guttural and powerful, dry recording, no reverb.
- [ ] **N12_lunge_charge.ogg** (cel: ~0.4s) — A massive creature charging forward at speed, heavy pounding footfalls layered with a rushing blast of displaced air, aggressive and forceful throughout, dry recording, no reverb.
- [ ] **N13_lunge_chain.ogg** (cel: ~0.4s) — A second immediate charging lunge coming right on the heels of the first, the same heavy rushing charge but slightly sharper and more urgent in attack, dry recording, no reverb.
- [x] **N14_body_contact.ogg** ✅ ZNALEZIONE (`Weapons/harsh_thud.wav`) (cel: ~0.2s) — A heavy, dull thud of a massive creature's body making contact, low-frequency weight with almost no brightness or ring, solid and blunt, dry recording, no reverb.
- [ ] **N15_hunger_regen_loop.ogg** (cel: 25-30s, loop) — A subtle, ominous regenerating hum, a low pulsing drone that breathes slowly in and out in volume, unsettling and organic like something quietly healing itself, consistent texture with no clear beginning or end, seamlessly loopable.
- [ ] **N16_nemorax_hurt.ogg** (cel: ~0.3s) — A deep, short monstrous roar of pain, a guttural burst of raw vocal power with a hard sudden attack and quick cutoff, powerful but brief, dry recording, no reverb.
- [ ] **N17_bigform_collapse.ogg** (cel: ~1.2s) — A massive creature's body collapsing without truly dying, a long descending groan that trails off before fully resolving, leaving a sense that something still lingers underneath, dry recording, minimal natural room tone.
- [ ] **N18_smallform_resurrect.ogg** (cel: ~1s) — A quiet, unsettling resurrection of something small but deeply wrong, a faint breathy movement with a barely-audible whispered laugh woven underneath, restrained rather than loud, dry recording, no reverb.
- [ ] **N19_true_death.ogg** (cel: ~2s) — A final, complete death collapse, a long dissonant tone descending steadily in pitch as the creature fully dissolves, gradually losing all body and texture until nothing remains, dry recording, minimal natural room tone.

## Priorytet 3 — Wspólny core sześciu wcieleń (8 dźwięków, pokrywa wszystkie 6 pokoi)

- [ ] **I01_telegraph.ogg** (cel: ~0.5s) — A rising ominous drone warning that an attack is about to happen, steadily increasing in pitch and intensity, tense and unmistakable, dry recording, no reverb.
- [ ] **I02_damage_pulse.ogg** (cel: ~0.3s) — A dark magical shockwave bursting outward from a single point, a deep low-end thump at the core with a quick radiating energy sizzle, contained and immediate, dry recording, no reverb.
- [ ] **I03_pull.ogg** (cel: ~0.4s) — An unsettling reversed whoosh that sounds like it is sucking everything inward toward a central point, air and energy rushing backward rather than outward, dry recording, no reverb.
- [ ] **I04_lunge_start.ogg** (cel: ~0.3s) — An aggressive creature lunging forward suddenly, a fast rushing approach sound with a low guttural growl underneath, quick onset and forward motion, dry recording, no reverb.
- [x] **I05_contact_hit.ogg** ✅ ZNALEZIONE (`Combat and Gore/slap.wav`) (cel: ~0.15s) — A dull, organic thud of a creature's body making brief contact, soft and fleshy rather than metallic, low-key and quick, dry recording, no reverb.
- [ ] **I06_knockback_received.ogg** (cel: ~0.25s) — A creature grunting in pain as it gets knocked backward, a short guttural cry blended with a quick whoosh of forced motion, dry recording, no reverb.
- [ ] **I07_incarnation_hurt.ogg** (cel: ~0.2s) — A short, sharp creature shriek of pain, dissonant and unnatural in pitch, a quick harsh cry with an abrupt cutoff, dry recording, no reverb.
- [ ] **I08_incarnation_death.ogg** (cel: ~0.8s) — A creature dissolving at the moment of death, a descending dissonant tone that thins out gradually as the body loses cohesion, fading completely into silence, dry recording, no reverb.

## Priorytet 4a — Unikalne warianty per wcielenie (7 dźwięków)

- [ ] **VN_teleport.ogg** (Vhar'Nokh, cel: ~0.2s) — A sharp instant teleport blink, a quick displacement pop as a body vanishes and reappears, a brief crackle of static energy accompanying the snap, dry recording, no reverb.
- [ ] **MD_muffled_burst.ogg** (Mordrath, cel: ~0.3s) — A magical energy burst that sounds heavily muffled, as if heard through thick padding or underwater, high frequencies almost completely dampened, distant and suppressed rather than sharp, dry recording, no natural room reverb — the muffling comes from filtering, not space.
- [ ] **ZR_echo_pulse.ogg** (Zha'Ruun, cel: ~0.3s) — A magical burst immediately followed by a faded, slightly detuned echo repeat of itself, as if a single moment in time is stuttering and repeating, the second hit noticeably weaker and off-pitch, dry recording, no natural reverb — the repeat is a distinct echo, not room ambience.
- [ ] **NK_crush_pulse.ogg** (Nekravor, cel: ~0.4s) — A heavy gravitational crushing impact, a deep sub-bass slam with an oppressive sense of enormous weight bearing down, slow and crushing rather than sharp, dry recording, no reverb.
- [ ] **TG_bite_drain.ogg** (Thal'Gor, cel: ~0.3s) — A wet, visceral creature bite clamping down, immediately followed by a draining slurping sound as life force is pulled away, predatory and hungry, dry recording, no reverb.
- [ ] **OR_vanish.ogg** (Orryx, cel: ~0.3s) — A ghostly vanishing whoosh as a creature turns intangible and disappears, airy and thin, dissolving smoothly into complete silence, dry recording, no reverb.
- [ ] **OR_reappear.ogg** (Orryx, cel: ~0.25s) — A creature suddenly reappearing out of nowhere, a sudden low thud marking the instant of return layered with a brief dark magical flourish, startling and abrupt, dry recording, no reverb.

## Priorytet 4b — Świat / pokoje (5 dźwięków)

- [x] **W01_door_pass.ogg** ✅ ZNALEZIONE (`Environment/creaky_door_long.wav`) (cel: ~0.4s) — A heavy ancient stone door creaking briefly as it shifts, a low grinding groan of old stone-on-stone friction ending in a solid thud, brief rather than prolonged, natural stone-room tone only, minimal reverb.
- [ ] **W02_soul_idle_hum.ogg** (cel: 25-30s, loop) — A soft, gentle magical hum that pulses slowly in volume, quiet and inviting rather than threatening, a warm steady tone with subtle shimmer, consistent texture with no clear beginning or end, seamlessly loopable.
- [x] **W03_soul_pickup.ogg** ✅ ZNALEZIONE (`Items/gem_collect.wav`) (cel: ~0.4s) — A warm, satisfying collection chime, a bright rising magical shimmer that resolves cleanly at the top, rewarding and pleasant, dry recording, no reverb.
- [ ] **W04_altar_tension.ogg** (cel: ~1s) — A rising ritualistic drone building steady anticipation, a slow deepening tone with a faint ceremonial undertone, deliberate and unhurried, dry recording, minimal natural room tone.
- [ ] **W05_altar_summon.ogg** (cel: ~2s) — A massive ceremonial thunderous boom marking a summoning ritual, a deep resonant low-end impact with a faint chanting choir undertone woven through the decay, powerful and dreadful, natural hall-like room tone appropriate to a large stone chamber.

## Priorytet 4c — UI (4 dźwięki)

- [x] **U01_phase_banner.ogg** ✅ ZNALEZIONE (`Musical Effects/grand_piano_level_start.wav`, zatwierdzone) (cel: ~0.3s) — A short, dramatic announcement sting, a single low gong strike with a clean immediate attack and a brief natural metallic decay, weighty and ceremonial, minimal natural room tone only.
- [x] **U02_taunt_chime.ogg** ✅ ZNALEZIONE (`UI/select_2.wav`) (cel: ~0.2s) — A gentle, brief notification chime, a soft clean tone with a quick natural decay, unobtrusive and pleasant, dry recording, no reverb.
- [x] **U04_death_overlay_sting.ogg** ✅ ZNALEZIONE (`Musical Effects/horror_sting.wav` — dosłownie tak się nazywa) (cel: ~0.5s) — A short, somber failure sting, a low tone descending smoothly in pitch, heavy and final without being harsh, dry recording, no reverb.
- [x] **U07_menu_confirm.ogg** ✅ ZNALEZIONE (`UI/sci_fi_confirm.wav`) (cel: ~0.15s) — A simple, satisfying UI confirmation sound, short and clean with a crisp immediate attack and a quick pleasant decay, neutral and modern, dry recording, no reverb.

## Priorytet 5 — 🎵 Muzyka (11 utworów/stingerów)

- [ ] **MUS_menu.ogg** (cel: 25-30s, loop) — A dark ambient dungeon-synth menu theme, slow and deeply ominous, built around a sustained low drone that never fully resolves, a distant faint choir whisper drifting in and out, sparse single piano notes played rarely and left to echo into silence, no percussion and no strong rhythm, restrained and unsettling rather than dramatic, consistent atmosphere throughout with no clear beginning or end, seamlessly loopable.
- [ ] **MUS_room_loop.ogg** (cel: 25-30s, loop) — Tense dungeon exploration music meant to loop in the background, a low pulsing bass drone that breathes slowly, sparse metallic percussion hits landing at irregular unpredictable intervals, building quiet unease without ever settling into a strong beat or clear melody, dark and atmospheric, consistent throughout with no clear beginning or end, seamlessly loopable.
- [ ] **MUS_altar.ogg** (cel: 25-30s, loop) — Ritualistic dark fantasy music for a summoning scene, a low chanting drone that steadily builds in intensity, deep resonant gong hits marking key moments, a dissonant choir growing louder and more unsettling as the piece progresses, climactic and dreadful by the end, with a steady, consistent middle section suitable for looping.
- [ ] **MUS_nemorax_battle.ogg** (cel: 25-30s, loop) — Intense dark fantasy boss battle music, driving low percussion carrying constant forward momentum, an aggressive distorted synth bass layered with hybrid orchestral elements, relentless energy that builds and releases in waves rather than staying flat, no vocals, consistent intensity throughout with no clear beginning or end, seamlessly loopable.
- [ ] **MUS_phase_zwloka.ogg** (cel: ~10s) — A short musical stinger built around a stuttering, glitchy repetition, a single musical phrase that stumbles and repeats like a skipping record, dark fantasy tone throughout, unsettling and mechanical rather than smooth.
- [ ] **MUS_phase_ciezar.ogg** (cel: ~10s) — A short, heavy musical stinger dominated by a descending pitch-down effect, deep sub-bass weight that feels like it is slowing and crushing everything beneath it, dark fantasy tone, oppressive and massive.
- [ ] **MUS_phase_glod.ogg** (cel: ~10s) — A short musical stinger with a low guttural growl texture woven through the instrumentation, a hungry, predatory feel throughout, dark fantasy tone, tense and stalking rather than explosive.
- [ ] **MUS_phase_zacmienie.ogg** (cel: ~10s) — A short musical stinger that gradually fades into near-total silence by its end, cold and isolating, dark fantasy tone, the sense of light and sound being slowly swallowed away.
- [ ] **MUS_phase_final.ogg** (cel: ~10s) — A short, unsettling music-box-like melody fragment, simple and childlike on the surface but subtly wrong in its tuning or rhythm, fading out gently by the end, dark fantasy undertone.
- [ ] **MUS_victory.ogg** (cel: 25-30s) — A somber victory theme for a dark fantasy game, bittersweet and exhausted rather than triumphant, slow swelling strings rising gently without ever becoming a fanfare, a single distant bell tolling once near the end, no percussion, resolving quietly and gently rather than ending abruptly.
- [x] **MUS_defeat.ogg** ✅ ZNALEZIONE (`Musical Effects/synth_bass_defeated.wav`, zatwierdzone) (cel: ~4s) — A short, dark defeat stinger, a single low dissonant chord struck once and left to descend in pitch, a hollow natural decay trailing off, no melody, heavy and final.

## Priorytet 6 — 🎵 Ambient per pokój (8 pętli)

- [ ] **AMB_room1_vharnokh.ogg** (cel: 25-30s, loop) — A deep, space-like void ambience, vast and cold with an oppressive sense of emptiness, distant echoing whispers drifting faintly in and out, no clear rhythm or melody, consistent throughout with no clear beginning or end, seamlessly loopable.
- [ ] **AMB_room2_mordrath.ogg** (cel: 25-30s, loop) — A near-silent, heavily muffled ambience, an extremely quiet distant murmur barely audible beneath the silence, oppressive in its quietness rather than its volume, consistent throughout with no clear beginning or end, seamlessly loopable.
- [ ] **AMB_room3_zharuun.ogg** (cel: 25-30s, loop) — A distorted, broken clock-ticking ambience, an irregular stuttering rhythm that never quite settles into a steady beat, as if time itself is malfunctioning, consistent unsettling texture throughout, seamlessly loopable.
- [ ] **AMB_room4_nekravor.ogg** (cel: 25-30s, loop) — A heavy, oppressive low rumble, a deep sub-bass drone that feels like enormous crushing weight pressing down on the air itself, slow and unrelenting, consistent throughout with no clear beginning or end, seamlessly loopable.
- [ ] **AMB_room5_thalgor.ogg** (cel: 25-30s, loop) — A distant, guttural growling ambience, a low organic undertone that sounds hungry and alive, unsettling and predatory without ever resolving into a clear creature sound, consistent throughout, seamlessly loopable.
- [ ] **AMB_room6_orryx.ogg** (cel: 25-30s, loop) — A dark, flickering ambience with a cold void-like quality, occasional whispery textures fading in and out unpredictably, sparse and unsettling rather than constant, consistent overall throughout, seamlessly loopable.
- [ ] **AMB_altar.ogg** (cel: 25-30s, loop) — A ceremonial waiting ambience, faint distant chanting drifting in and out just at the edge of hearing, anticipatory and still, consistent throughout with no clear beginning or end, seamlessly loopable.
- [ ] **AMB_arena_nemorax.ogg** (cel: 25-30s, loop) — A massive throne room ambience, a deep cavernous natural reverb tail suggesting an enormous stone space, a distant ominous rumble underlying everything, consistent throughout with no clear beginning or end, seamlessly loopable.

---

**Razem: 82 pozycje — 25 już znalezionych i zatwierdzonych, 2 czekają na
wybór spośród 11 kandydatów (P20/P21), 55 nadal do wygenerowania.** Po
ElevenLabs pamiętaj o Kroku 4 z `AUDIO_KATALOG.md` (przycięcie do "Cel",
pętla/crossfade jeśli trzeba, normalizacja głośności) zanim wrzucisz do
Godota — dotyczy też plików znalezionych w paczce, jeśli mają np. za dużo
ciszy na końcu.
