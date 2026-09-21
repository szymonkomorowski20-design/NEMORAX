extends Control
class_name CutscenePlayer
## Odtwarzacz cutscenek (PLAN_CUTSCENEK.md sekcja 1.2) — CanvasLayer+Control
## z process_mode ALWAYS i get_tree().paused=true na czas trwania, dokładnie
## ten sam mechanizm co ui/pause_menu.gd, żaden nowy wzorzec.
##
## Skip: "attack" albo "ui_accept" naciśnięte = koniec bieżącego beatu od razu;
## przytrzymane >SKIP_ALL_HOLD_SECONDS = pomija CAŁĄ resztę cutscenki. Bez tego
## drugie i kolejne podejście do gry byłoby frustrujące (KAŻDY przebieg
## roguelite'a przechodzi przez rytuał ołtarza / upadek wielkiej formy).

signal finished

const SKIP_ALL_HOLD_SECONDS := 0.5

@onready var voice_player: AudioStreamPlayer = $VoicePlayer

var _current_beat: DialogueBeat = null
var _skip_beat_requested: bool = false
var _skip_all_requested: bool = false
var _skip_hold_timer: float = 0.0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false

func _process(delta: float) -> void:
	if not visible:
		return
	queue_redraw()
	if Input.is_action_pressed("attack") or Input.is_action_pressed("ui_accept"):
		_skip_hold_timer += delta
		if _skip_hold_timer >= SKIP_ALL_HOLD_SECONDS:
			_skip_all_requested = true
	else:
		_skip_hold_timer = 0.0

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("attack") or event.is_action_pressed("ui_accept"):
		_skip_beat_requested = true

## Odtwarza sekwencję beatów, pauzując grę na czas trwania. `await` na końcu
## (coroutine) — wołający dostaje kontrolę z powrotem dopiero po ostatnim
## beacie albo po pominięciu całości.
func play(beats: Array[DialogueBeat]) -> void:
	if beats.is_empty():
		return
	visible = true
	get_tree().paused = true
	_skip_all_requested = false
	for beat in beats:
		if _skip_all_requested:
			break
		if beat.silence_before > 0.0:
			await _wait_seconds(beat.silence_before)
		if _skip_all_requested:
			break
		await _play_beat(beat)
	_current_beat = null
	visible = false
	get_tree().paused = false
	finished.emit()

func _play_beat(beat: DialogueBeat) -> void:
	_current_beat = beat
	_skip_beat_requested = false
	if beat.voice_clip:
		voice_player.stream = beat.voice_clip
		voice_player.play()
		while voice_player.playing and not _skip_beat_requested and not _skip_all_requested:
			await get_tree().process_frame
		voice_player.stop()
	else:
		await _wait_seconds(beat.fallback_seconds)

func _wait_seconds(seconds: float) -> void:
	var elapsed := 0.0
	while elapsed < seconds and not _skip_beat_requested and not _skip_all_requested:
		await get_tree().process_frame
		elapsed += get_process_delta_time()

func _draw() -> void:
	if not visible or _current_beat == null:
		return
	var viewport_size := get_viewport_rect().size
	draw_rect(Rect2(Vector2.ZERO, viewport_size), Color(_current_beat.background_tint, 0.85), true)

	var font := ThemeDB.fallback_font
	var center_x := viewport_size.x * 0.5
	var text_y := viewport_size.y * 0.62

	if _current_beat.portrait:
		var portrait_size := Vector2(220, 220)
		var portrait_pos := Vector2(center_x - portrait_size.x * 0.5, viewport_size.y * 0.22)
		draw_texture_rect(_current_beat.portrait, Rect2(portrait_pos, portrait_size), false)

	if _current_beat.speaker_name != "":
		var name_size := font.get_string_size(_current_beat.speaker_name, HORIZONTAL_ALIGNMENT_CENTER, -1, 22)
		draw_string(font, Vector2(center_x - name_size.x * 0.5, text_y - 34.0), _current_beat.speaker_name,
			HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Palette.HIT_FLASH)

	draw_multiline_string(font, Vector2(center_x - viewport_size.x * 0.4, text_y), _current_beat.text,
		HORIZONTAL_ALIGNMENT_CENTER, viewport_size.x * 0.8, 26)

	var hint := "trzymaj, aby pominąć"
	var hint_size := font.get_string_size(hint, HORIZONTAL_ALIGNMENT_CENTER, -1, 14)
	draw_string(font, Vector2(center_x - hint_size.x * 0.5, viewport_size.y - 24.0), hint,
		HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color(1.0, 1.0, 1.0, 0.4))
