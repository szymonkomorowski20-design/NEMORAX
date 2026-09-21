class_name DialogueBeat
extends Resource
## Jeden "beat" cutscenki (PLAN_CUTSCENEK.md sekcja 1.1) — portret+tekst+głos
## opcjonalny. Scena to po prostu Array[DialogueBeat], budowana w kodzie
## (patrz arena.gd/altar.gd/room.gd) — zero nowych plików .tres na start.

@export var speaker_name: String = "" ## "" = brak etykiety (narrator/głos bez twarzy)
@export var portrait: Texture2D = null ## opcjonalny, brak -> tylko tekst na czarnym/tintowanym tle
@export var text: String = ""
@export var voice_clip: AudioStream = null ## opcjonalny — działa BEZ tego (patrz fallback_seconds)
@export var fallback_seconds: float = 3.0 ## ile trzyma się na ekranie, jeśli NIE MA jeszcze nagranego głosu
@export var background_tint: Color = Color.BLACK ## tło pod portretem/tekstem
@export var silence_before: float = 0.0 ## opcjonalna cisza PRZED tym beatem (np. "oddech" przed twistem)
