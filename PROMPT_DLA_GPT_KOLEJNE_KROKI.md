# NEMORAX — prompt dla GPT/Codexa: co jest do zrobienia po stronie grafiki

Ten dokument zastępuje poprzednie listy zadań graficznych (PACZKA_DLA_GPT_NEMORAX_I_RESZTA.md,
PROMPTY_WROGOW_LOSOWYCH_I_SKRZYNI.md) w miejscach, gdzie się zdezaktualizowały —
opisuje TYLKO to, co faktycznie zostało, po stanie na dziś. Kod/mechanika/
cutscenki są w całości po mojej stronie i już zrobione; to poniżej jest
WYŁĄCZNIE grafika.

---

## 0. Status — co już wylądowało i działa

Żeby nie duplikować pracy: to wszystko jest już wygenerowane, podpięte w
kodzie i przetestowane.

- Pilotaż chodu gracza: 5 kątów × 2 klatki (front/front_diagonal/side/
  back_diagonal/back, neutralna+krok) — `assets/sprites/gracz/`.
- Base art (jeden statyczny obraz na wszystkie pozy) dla wszystkich 11
  archetypów wrogów losowych — `assets/sprites/random_enemies/<nazwa>/`.
- Aura Elite, skrzynia (zamknięta/otwarta), 8 motywów podłóg/ścian pokoi
  RANDOM, 5 nowych baz faz Nemoraxa.
- VFX ataku+umiejętności dla 7 z 11 archetypów (patrz sekcja 2 — reszta
  została do zrobienia).

## 1. Priorytet 1 — chód wcieleń i faz Nemoraxa (NIE pozy bojowe jeszcze)

Dokładnie ta sama konwencja co pilotaż gracza, którą już zaakceptowaliśmy:
**5 kątów × 2 klatki** (neutralna + krok w połowie kroku) na każdą postać.
Dziś sześć wcieleń i sześć faz Nemoraxa mają tylko front/back/side, po
JEDNYM obrazie każdy (bez cyklu chodu) — dokładnie stan gracza SPRZED
pilotażu.

### 1a. Sześć wcieleń (miniboss każdej z 6 gałęzi mapy)

Dla KAŻDEGO z sześciu: Vhar'Nokh, Mordrath, Zha'Ruun, Nekravor, Thal'Gor,
Orryx — potrzebne brakujące ujęcia chodu:
- front_diagonal (neutralna + krok) — NOWE, nie istnieje
- side — krok (neutralna już jest) — NOWE
- back_diagonal (neutralna + krok) — NOWE, nie istnieje
- back — krok (neutralna już jest) — NOWE

To 7 nowych obrazów na wcielenie (jak przy graczu) × 6 = 42 obrazy.
Zachowaj dokładnie ten sam projekt postaci, kolorystykę i proporcje co
istniejące pliki `*_walk.png`/`*_walk_back.png`/`*_walk_side.png` w
`assets/sprites/wcielenia/<nazwa>/` — to ma być spójny cykl chodu TEJ SAMEJ
postaci, nie redesign.

### 1b. Sześć faz Nemoraxa

Ta sama zasada, dla każdej z sześciu faz (Motion/Force/Instinct/Dominion/
Ruin/Sovereignty) — użyj już dostarczonych 5 nowych baz jako punktu
odniesienia dla front, dorysuj front_diagonal/side/back_diagonal/back +
klatki kroku w tym samym stylu. 6 faz × 7 obrazów = 42 obrazy.

**Nie zaczynaj punktu 3 (252 pozy bojowe) przed ukończeniem 1a/1b** — tak
ustaliliśmy wcześniej i to nadal obowiązuje.

## 2. Priorytet 2 — VFX ataku/umiejętności dla brakujących 4 archetypów

Mamy już VFX (atak + umiejętność, ten sam styl co dostarczone 14 plików w
`grafiki do gry/09_room_enemies/enemy_vfx/`) dla: Tank, Charger, Orbiter,
Shooter, Zoner, Dasher, Chaser. Brakuje jeszcze:

- **Striker** — burst wręcz, pojedyncze długie ostrze/pazur, szybki wypad
  (dokument: "lunge 85").
- **Ambusher** — czai się prawie niewidoczny, ujawnia i uderza (temat:
  zaskoczenie/wyłonienie się z cienia).
- **Summoner** — przywołuje słabsze dodatki (temat: rytuał/portal
  przywołania, nie atak bezpośredni).
- **Support** — wzmacnia własną prędkość (temat: aura/błysk na sobie, nie
  atak na gracza).

Format identyczny jak reszta: PNG 1024×1024, przezroczyste tło, jeden
atak + jedna umiejętność na archetyp.

**Uwaga do zweryfikowania**: nazwałeś/aś poprzednią paczkę 14 plików
nazwami klimatycznymi (chain_penitent, cracked_executioner, far_eye,
rib_bastion, rift_stalker, silence_bellringer, six_scar_archer) zamiast
nazw archetypów z kodu. Dopasowałem je sam po treści obrazka i nazwie
efektu: cracked_executioner→Tank, rib_bastion→Charger, far_eye→Orbiter,
six_scar_archer→Shooter, silence_bellringer→Zoner, rift_stalker→Dasher,
chain_penitent→Chaser. Jeśli miałeś/aś inne zamiary co do tego przypisania,
daj znać, a przepnę VFX pod właściwe archetypy — dziś działa na moim
odczytaniu obrazków, nie na jawnej liście od Ciebie.

## 3. Poprawki wynikające z oceny pokoju wzorcowego (KIERUNEK_WIZUALNY_REFERENCJE.md)

Zrobiłem, co dało się kodem (przyciemnienie/odszumienie podłogi, kontrast
ściana-vs-podłoga, większy gracz, mocniejsze cienie, mały blask skrzyni).
Trzy rzeczy zostały, bo wymagają NOWEJ grafiki, nie samego kodu:

1. **Osobna tekstura ściany**, wizualnie inny materiał niż podłoga (np.
   gładszy, ciemniejszy kamień/metal), nie ta sama tekstura z kryształami
   tylko przyciemniona kodem — dziś to jest właśnie tylko przyciemnienie,
   prowizorka. Dotyczy wszystkich 8 motywów pokoi RANDOM + motywu ołtarza/
   areny Nemoraxa.
2. **Mniej gęste dekoracje (kryształy itp.) na środku kafla podłogi** —
   zostaw je głównie przy brzegach kafla, środek ma być spokojniejszy
   wizualnie (walka toczy się głównie na środku pokoju).
3. **Mały cokół/podstawa pod portalem** (drzwi) — dziś to sam łuk,
   "unoszący się" nad podłogą mimo cienia w kodzie; ciemna kamienna
   podstawa osadzająca go fizycznie w scenie.

## 4. Priorytet 3 (później, dopiero po 1/2/3) — 252 pozy bojowe

Pełny zestaw kierunkowy dla ataków/umiejętności/castowania — gracz +
6 wcieleń + Nemorax, po tym jak chód (punkt 1) będzie oceniony w ruchu.
Nie zaczynaj tego teraz — to jawnie odłożone na potem.

---

Kolejność, jeśli chcesz jedną listę: **1a → 1b → 2 → 3 (poprawki) → 4**.
