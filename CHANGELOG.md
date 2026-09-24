# Historia zmian — NEMORAX

## 1.0 — wersja finalna (24.09.2026)

Paczka `NEMORAX_Windows_2026-09-24.zip` (Windows 64-bit, eksport Godot 4.7.2).

### Oprawa dźwiękowa (ostatni etap przed wydaniem)
- Muzyka w każdej scenie, jeden wspólny odtwarzacz muzyki (bez nakładania
  utworów przy zmianie sceny):
  - menu — motyw przewodni;
  - prolog;
  - pokoje — 4 utwory eksploracji; walka, elita i wcielenie przełączane automatycznie;
  - rytuał przy ołtarzu;
  - 6 faz Nemoraksa, mała forma, zwrot akcji;
  - epilog zwycięstwa, porażka.
- Faza Siła wycisza teraz **tylko muzykę** — efekty i zapowiedzi ataków
  zostają słyszalne, więc faza jest uczciwa.
- Nowe efekty zamiast placeholderów:
  - tarcza: parowanie, przełamanie gardy, ześlizgnięcie;
  - wcielenia: zapowiedź ataku (dawny plik trwał 0,05 s), pojawienie się po teleporcie, przełamanie postawy;
  - pułapki: zapowiedź i uderzenie prasy;
  - strefy na podłodze: tyknięcie i wygasanie;
  - faza Władza: mrok (początek, pętla, koniec) i przestrzenny oddech bossa.
- Muzyka i część efektów: Pixabay (Pixabay Content License).

### Interfejs
- Karty run, relikwii, Paktu i intencji podświetlają się po najechaniu myszą.
- Poprawione zamykanie opcji w menu i zmiana sceny po wyborze próby.

## Drugi audyt nagrania (24.09.2026)
- Okno statystyk bez ucinania opisów i prześwitów: dwa panele, pełne opisy,
  przewijanie. Pod każdym oknem chowają się komunikaty gry.
- Faza Władza: boss ukryty w mroku zostawia uczciwy ślad (krąg kontaktu,
  oczy); granica sali widoczna nad ciemnością.
- Strefy, pieczęcie i telegraf bossa mają czytelne stany: zapowiedź,
  aktywne, wygasa.
- Arena finału w tym samym świecie co pokoje (mur, bramy, kamień).
- Każda faza bossa najpierw pokazuje każdy swój wzorzec raz.
- Oferty run nigdy nie są w całości martwe dla stylu gry (wcześniej 8 na 1000).
- Ekrany końca nie restartują próby przypadkiem (trzymany S, Enter z dialogu).
- Większa, czytelniejsza minimapa.

## Pierwszy audyt nagrania (24.09.2026)
- Obrys sylwetki gracza zamiast zasłaniającego dysku.
- Log każdego ciosu w gracza (F3).
- Zapowiedź wypadu po teleporcie wcieleń.
- Laboratorium tarczy.
- Postawa Nekravora z ostrzeżeniem i kręgiem odsłonięcia.
- Nowy wygląd pułapek, kryształów i wody.
- Przypomnienie o niewydanych nagrodach.
- Muzyka nie milknie pod prologiem.

## Paczki 0–11 (19–23.09.2026)
- Podstawy: siatka 32 pokoi, walka mieczem i różdżką, 11 archetypów wrogów,
  6 wcieleń, Nemorax w 6 fazach, zapis przebiegu.
- Trzymana tarcza z parowaniem, zasoby i leczenie (30% HP, 2 zapasy).
- Strojenie bossów według pomiarów.
- Przepisy spotkań, układy pokoi, cztery motywy z mechaniką, pokój pułapek, ziarno próby.
- 28 run z czytelnymi kartami, 10 relikwii, intencje startowe, odłożone
  wybory w HUD.
- Znaczniki ryzyka i nagrody na mapie i nad drzwiami, odpoczynki.
- Pakt fragmentu na Mordracie.
- Ekrany końca z historią próby, Kronika, Komnata Echa, Pętla Otchłani I.
- Polskie nazwy faz, typografia, runiczny krąg bossa, miks dźwięku.
- Integracja i regresja: 45/60/120 FPS, test obciążenia, status punktów audytu.
