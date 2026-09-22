extends Control
class_name GameUI
## Interfejs (sekcja 6 + paski staminy/many dodane na życzenie autora, poza
## dokumentem — bez nich zasoby z player.gd byłyby niewidoczne dla gracza).
## Minimalny: pasek gracza, pasek bossa, ikona dasha, nazwa formy na 2 s.
## W fazie finałowej znika w całości (sekcja 8).
## CanvasLayer-rodzic sprawia, że to nie drży razem z trzęsieniem ekranu.
##
## Paski są Sprite2D z region_rect przycinanym wg wartości, NIE
## TextureProgressBar — ten drugi liczy swój minimalny rozmiar z natywnych
## wymiarów przypisanej tekstury (u nas 1536x1024) i .size jest do tego
## dociskane w górę bez względu na to, co się mu każe, nawet po nadpisaniu
## _get_minimum_size() w skrypcie. Sprite2D nie ma tego problemu w ogóle.

const ARENA_LEFT := 90.0
const ARENA_WIDTH := 1100.0
# Okno gry jest na sztywno 1280x720, nierozciągalne (project.godot [display])
# — używane zamiast `size` (Control liczony z zakotwiczeń) w _ready(), bo
# to drugie może nie być jeszcze rozstrzygnięte w momencie, gdy _ready()
# liczy i NA STAŁE zapamiętuje pozycje pasków (dawny _draw() był bezpieczny,
# bo przeliczał size na nowo co klatkę zamiast tylko raz przy starcie).
const VIEWPORT_SIZE := Vector2(1280.0, 720.0)

const TEX_PLAYER_BAR := preload("res://assets/sprites/ui/player_health_bar.png")
const TEX_STAMINA_BAR := preload("res://assets/sprites/ui/stamina_bar.png")
const TEX_MANA_BAR := preload("res://assets/sprites/ui/mana_bar.png")
const TEX_BOSS_BAR := preload("res://assets/sprites/ui/boss_health_bar.png")
const TEX_DASH_ICON := preload("res://assets/sprites/ui/dash_icon.png")
const TEX_LOCK_CROSS := preload("res://assets/sprites/ui/lock_cross.png")
const TEX_HEAL_ICON := preload("res://assets/sprites/ui/heal_icon.png")
const TEX_DEATH_FRAME := preload("res://assets/sprites/end_screens/death_screen_frame.png")
const TEX_VICTORY_FRAME := preload("res://assets/sprites/end_screens/victory_screen_frame.png")

# Paski mają OGROMNE przezroczyste marginesy na płótnie 1536x1024 — sama
# rysowana grafika to ułamek tego (np. stamina: 138/1024 wysokości). Skalowanie
# całego płótna do docelowego bar_size ściskałoby też te marginesy, i sam
# widoczny pasek wychodziłby jako ledwie widoczny skrawek. Dlatego skala i
# region_rect liczone są względem tych zmierzonych (piksel po pikselu,
# +margines bezpieczeństwa) prostokątów treści, nie całego płótna.
const PLAYER_BAR_CONTENT := Rect2(64.0, 326.0, 1408.0, 354.0)
const STAMINA_BAR_CONTENT := Rect2(76.0, 438.0, 1382.0, 138.0)
const MANA_BAR_CONTENT := Rect2(106.0, 420.0, 1332.0, 172.0)
const BOSS_BAR_CONTENT := Rect2(0.0, 318.0, 1536.0, 394.0)
# Ta sama sztuczka co przy paskach — sama grafika ikonki leczenia to tylko
# ~67% płótna 1024x1024, więc dzielenie przez pełne płótno robiło ikonkę
# widocznie mniejszą (~13px) niż zamierzony heal_icon_size (20px).
const HEAL_ICON_CONTENT := Rect2(158.0, 150.0, 706.0, 698.0)

# Paski "under" (tło/tor) to ta sama grafika co "fill", tylko przyciemniona
# modulate — jeden wygenerowany obrazek na pasek, nie osobna para pusty/pełny
# (patrz PROMPTY_FINALNE_WSZYSTKO.md sekcja E).
const UNDER_MODULATE := Color(1.0, 1.0, 1.0, 0.25)
## Brak dedykowanej grafiki paska expa — rysowany kodem (_draw_xp_bar()), jak
## entities/enemy_health_bar.gd, zamiast rozciągać za ciężkie na to tekstury
## staminy/many (1536x1024) na coś, co nigdy nie miało własnej grafiki.
const XP_BAR_BG := Color(0.04, 0.03, 0.06, 0.85)
const XP_BAR_FILL := Color("#5BE0C8") # Palette.PLAYER_BODY — progresja postaci, spójne z tytułami menu

@export var player_bar_size: Vector2 = Vector2(200.0, 20.0)
@export var resource_bar_size: Vector2 = Vector2(200.0, 8.0)
@export var resource_bar_gap: float = 4.0 ## px, odstęp między paskami staminy/many/życia/expa
@export var xp_bar_size: Vector2 = Vector2(200.0, 6.0)
@export var boss_bar_height: float = 16.0
@export var dash_icon_size: float = 20.0
@export var heal_icon_size: float = 20.0
@export var form_name_display_time: float = 2.0 ## s
@export var form_name_font_size: int = 32
@export var taunt_font_size: int = 22
@export var overlay_font_size: int = 24

var player: Player = null
var boss = null ## Boss ALBO Incarnation — nietypowane celowo, oba mają health/max_health/current_color
var hide_all: bool = false ## faza finałowa: UI znika w całości
var show_minimap: bool = false ## ustawiane przez room.gd (nie arena.gd — po 30 pokojach minimapa nie ma już sensu)

var _center_message: String = ""
var _center_message_timer: float = 0.0
var _center_message_font_size: int = 32

var _overlay_text: String = ""
var _overlay_active: bool = false

var _heal_pos: Vector2 = Vector2.ZERO ## zapamiętane w _ready() do rysowania liczby stacków obok ikony leczenia
var _xp_bar_pos: Vector2 = Vector2.ZERO ## zapamiętane w _ready() do _draw_xp_bar()
var _player_bar_pos: Vector2 = Vector2.ZERO ## zapamiętane w _ready() do _draw_player_hp_text()
var _boss_bar_pos: Vector2 = Vector2.ZERO ## zapamiętane w _ready() do _draw_boss_hp_text()

@onready var player_bar_under: Sprite2D = $PlayerBarUnder
@onready var player_bar: Sprite2D = $PlayerBar
@onready var stamina_bar_under: Sprite2D = $StaminaBarUnder
@onready var stamina_bar: Sprite2D = $StaminaBar
@onready var mana_bar_under: Sprite2D = $ManaBarUnder
@onready var mana_bar: Sprite2D = $ManaBar
@onready var boss_bar_under: Sprite2D = $BossBarUnder
@onready var boss_bar: Sprite2D = $BossBar
@onready var dash_icon: TextureRect = $DashIcon
@onready var dash_lock_cross: TextureRect = $DashLockCross
@onready var heal_icon: Sprite2D = $HealIcon
@onready var overlay_frame: TextureRect = $OverlayFrame

func _ready() -> void:
	# Białe modulate na fill = kolor bierze się WYŁĄCZNIE z samej grafiki (już
	# wygenerowanej we właściwym kolorze) — poza paskiem bossa, który celowo
	# powstał neutralny biało-złoty, żeby dało się go zabarwiać dynamicznie
	# per faza (patrz PROMPTY_FINALNE_WSZYSTKO.md E2).
	var player_pos := Vector2(30.0, VIEWPORT_SIZE.y - 50.0)
	_player_bar_pos = player_pos
	_setup_bar(player_bar_under, player_bar, TEX_PLAYER_BAR, PLAYER_BAR_CONTENT, player_pos, player_bar_size, Color.WHITE)

	var stamina_pos := player_pos - Vector2(0.0, resource_bar_gap + resource_bar_size.y)
	_setup_bar(stamina_bar_under, stamina_bar, TEX_STAMINA_BAR, STAMINA_BAR_CONTENT, stamina_pos, resource_bar_size, Color.WHITE)

	var mana_pos := stamina_pos - Vector2(0.0, resource_bar_gap + resource_bar_size.y)
	_setup_bar(mana_bar_under, mana_bar, TEX_MANA_BAR, MANA_BAR_CONTENT, mana_pos, resource_bar_size, Color.WHITE)

	_xp_bar_pos = mana_pos - Vector2(0.0, resource_bar_gap + xp_bar_size.y)

	var boss_pos := Vector2(ARENA_LEFT, 20.0)
	_boss_bar_pos = boss_pos
	_setup_bar(boss_bar_under, boss_bar, TEX_BOSS_BAR, BOSS_BAR_CONTENT, boss_pos, Vector2(ARENA_WIDTH, boss_bar_height), Color.WHITE)

	var dash_pos := Vector2(30.0 + player_bar_size.x + 16.0, VIEWPORT_SIZE.y - 50.0)
	dash_icon.texture = TEX_DASH_ICON
	dash_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	dash_icon.stretch_mode = TextureRect.STRETCH_SCALE
	dash_icon.position = dash_pos
	dash_icon.size = Vector2(dash_icon_size, dash_icon_size)
	dash_lock_cross.texture = TEX_LOCK_CROSS
	dash_lock_cross.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	dash_lock_cross.stretch_mode = TextureRect.STRETCH_SCALE
	dash_lock_cross.position = dash_pos
	dash_lock_cross.size = Vector2(dash_icon_size, dash_icon_size)

	var heal_pos := dash_pos + Vector2(dash_icon_size + 10.0, 0.0)
	_heal_pos = heal_pos # zapamiętane do _draw_heal_stack_count() — ile stacków w banku
	heal_icon.texture = TEX_HEAL_ICON
	heal_icon.centered = false
	heal_icon.position = heal_pos
	heal_icon.scale = Vector2(heal_icon_size, heal_icon_size) / HEAL_ICON_CONTENT.size
	heal_icon.region_enabled = true
	heal_icon.region_rect = HEAL_ICON_CONTENT

	overlay_frame.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	overlay_frame.stretch_mode = TextureRect.STRETCH_SCALE
	overlay_frame.position = Vector2.ZERO
	overlay_frame.size = VIEWPORT_SIZE
	overlay_frame.visible = false

func _tex_size(tex: Texture2D) -> Vector2:
	return Vector2(tex.get_width(), tex.get_height())

## Para under/fill: oba Sprite2D pokazują tę samą teksturę w tej samej skali
## (tak, żeby cała tekstura zmieściłaby się dokładnie w bar_size), ale "fill"
## dostaje region_rect przycinany co klatkę w _update_bars() do lewej części
## odpowiadającej wartości 0-1 — stąd pasek "pustoszeje" od prawej, z lewą
## krawędzią zawsze na miejscu, tak jak dawny FILL_LEFT_TO_RIGHT.
func _setup_bar(under: Sprite2D, fill: Sprite2D, tex: Texture2D, content: Rect2, pos: Vector2, bar_size: Vector2, tint: Color) -> void:
	var bar_scale := bar_size / content.size
	for bar in [under, fill]:
		bar.texture = tex
		bar.centered = false
		bar.position = pos
		bar.scale = bar_scale
		bar.region_enabled = true
	under.region_rect = content
	under.modulate = UNDER_MODULATE
	fill.region_rect = content
	fill.modulate = tint

## `content` to ten sam zmierzony prostokąt treści co przy _setup_bar (patrz
## PLAYER_BAR_CONTENT i inne) — przycinanie zaczyna się od jego lewej krawędzi,
## nie x=0 całego płótna, inaczej pasek "pustoszejąc" ujawniłby pusty margines.
func _update_bar_fill(fill: Sprite2D, content: Rect2, ratio: float) -> void:
	fill.region_rect = Rect2(content.position.x, content.position.y, content.size.x * clamp(ratio, 0.0, 1.0), content.size.y)

func _process(delta: float) -> void:
	if _center_message_timer > 0.0:
		_center_message_timer -= delta
		if _center_message_timer <= 0.0:
			_center_message = ""
	_update_bars()
	queue_redraw()

func show_form_name(text: String) -> void:
	_center_message = text
	_center_message_timer = form_name_display_time
	_center_message_font_size = form_name_font_size

func show_taunt(text: String, duration: float) -> void:
	_center_message = text
	_center_message_timer = duration
	_center_message_font_size = taunt_font_size

func show_overlay(text: String, kind: String = "death") -> void:
	_overlay_text = text
	_overlay_active = true
	overlay_frame.texture = TEX_VICTORY_FRAME if kind == "victory" else TEX_DEATH_FRAME
	overlay_frame.visible = true

func hide_overlay() -> void:
	_overlay_active = false
	overlay_frame.visible = false

## Zastępuje dawne _draw_player_bar/_draw_resource_bars/_draw_boss_bar/
## _draw_dash_icon/_draw_heal_icon — teraz to prawdziwe sprite'y/TextureRect,
## więc tylko aktualizujemy region_rect/visible/modulate co klatkę.
func _update_bars() -> void:
	var show_bars := not hide_all and not _overlay_active
	for node in [player_bar_under, player_bar, stamina_bar_under, stamina_bar,
			mana_bar_under, mana_bar, dash_icon, dash_lock_cross, heal_icon]:
		node.visible = show_bars
	# Pasek na górze ekranu TYLKO dla prawdziwego Bossa (Nemorax) — Incarnation
	# (6 wcieleń + 11 wrogów losowych) ma teraz własny pasek nad głową
	# (entities/enemy_health_bar.gd), na życzenie autora. room.gd wciąż
	# ustawia `ui.boss = incarnation` (nieszkodliwie, po prostu odfiltrowane
	# tutaj) — Boss to jedyna klasa w grze, dla której `boss is Boss` da true.
	var show_boss_bar := show_bars and boss != null and boss is Boss
	boss_bar_under.visible = show_boss_bar
	boss_bar.visible = show_boss_bar

	if not show_bars:
		return

	if player != null:
		_update_bar_fill(player_bar, PLAYER_BAR_CONTENT, player.health / player.max_health)
		_update_bar_fill(stamina_bar, STAMINA_BAR_CONTENT, player.stamina / player.max_stamina)
		_update_bar_fill(mana_bar, MANA_BAR_CONTENT, player.mana / player.max_mana)

		dash_icon.modulate = Color(1.0, 1.0, 1.0, 0.35 if player.is_dash_on_cooldown() else 1.0)
		dash_lock_cross.visible = player.is_dash_locked_by_void()

		heal_icon.modulate = Color(1.0, 1.0, 1.0, 1.0 if player.is_heal_ready() else 0.4 + 0.3 * player.heal_charge_ratio())

	if show_boss_bar:
		_update_bar_fill(boss_bar, BOSS_BAR_CONTENT, boss.health / boss.max_health)
		boss_bar.modulate = boss.current_color

func _draw() -> void:
	if _overlay_active:
		_draw_overlay()
	_draw_center_message()
	_draw_heal_stack_count()
	_draw_xp_bar()
	_draw_player_hp_text()
	_draw_boss_hp_text()
	_draw_minimap()

## Audyt UI (TERAZ_DLA_CLAUDE_ARENA_UI_I_FEELING.md): "ile ma życia i ile
## maksymalnie" musi być odpowiadalne bez zgadywania z samej długości
## wypełnienia paska — sam pasek to Sprite2D z przycinanym region_rect (patrz
## nagłówek pliku), bez żadnego tekstu.
func _draw_player_hp_text() -> void:
	if player == null or hide_all or _overlay_active:
		return
	var label := "%d / %d" % [ceili(player.health), int(player.max_health)]
	var pos := _player_bar_pos + Vector2(player_bar_size.x + 8.0, player_bar_size.y - 4.0)
	draw_string(ThemeDB.fallback_font, pos, label, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color.WHITE)

## j.w., punkt audytu "ile HP ma boss" — tymczasowe (do przebudowy paska bossa
## w jedną grubą jednostkę nazwa+faza+HP, krok 7 tego samego dokumentu).
## Wyśrodkowane pod paskiem (nie za jego prawym końcem — bar sięga niemal do
## krawędzi viewportu, więc tekst wyszedłby częściowo poza ekran).
func _draw_boss_hp_text() -> void:
	if boss == null or not (boss is Boss) or hide_all or _overlay_active:
		return
	var font := ThemeDB.fallback_font
	var label := "%d / %d" % [ceili(boss.health), int(boss.max_health)]
	var text_size := font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, 14)
	var pos := _boss_bar_pos + Vector2(ARENA_WIDTH * 0.5 - text_size.x * 0.5, boss_bar_height + 16.0)
	draw_string(font, pos, label, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color.WHITE)

## Wcześniej nigdzie niewidoczny — level/xp istniały tylko jako liczby w
## ekranie statystyk (Tab), bez własnego paska w HUD-zie.
func _draw_xp_bar() -> void:
	if player == null or hide_all or _overlay_active:
		return
	var ratio: float = clamp(player.xp / player.xp_per_level, 0.0, 1.0) if player.level < player.max_level else 1.0
	draw_rect(Rect2(_xp_bar_pos, xp_bar_size), XP_BAR_BG, true)
	draw_rect(Rect2(_xp_bar_pos, Vector2(xp_bar_size.x * ratio, xp_bar_size.y)), XP_BAR_FILL, true)
	var font := ThemeDB.fallback_font
	var label := "Lv %d" % player.level
	draw_string(font, _xp_bar_pos + Vector2(xp_bar_size.x + 8.0, xp_bar_size.y + 2.0), label,
		HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color.WHITE)

## Minimapa w stylu "The Binding of Isaac" (na życzenie autora) — siatka 2D z
## game_flow.gd zamiast dawnej liniowej sekwencji. Bieżący pokój zawsze
## wyśrodkowany, mgła wojny: pokoje odwiedzone w pełnym kolorze, sąsiedzi
## odwiedzonych (znani, ale nieodwiedzeni) jako przygaszony zarys, reszta w
## ogóle nierysowana. Ołtarz i pokoje z duszą dostają dodatkową obwódkę, żeby
## wyróżniały się jako cel, nie przystanek.
func _draw_minimap() -> void:
	if not show_minimap or hide_all or _overlay_active:
		return
	var pip_size := 12.0
	var gap := 4.0
	var spacing := pip_size + gap
	var box_size := Vector2(6, 6) * spacing
	var anchor := Vector2(VIEWPORT_SIZE.x - box_size.x - 20.0, 20.0) + box_size * 0.5 - Vector2(pip_size, pip_size) * 0.5

	var revealed := {}
	for pos in GameFlow.visited_rooms.keys():
		revealed[pos] = true
		for d in GameFlow.DIRECTIONS:
			var n: Vector2i = pos + d
			if GameFlow.room_map.has(n):
				revealed[n] = true

	for pos in revealed.keys():
		var data: Dictionary = GameFlow.room_map.get(pos, {})
		if data.is_empty():
			continue
		var offset := Vector2(pos.x - GameFlow.current_room_pos.x, pos.y - GameFlow.current_room_pos.y) * spacing
		var draw_pos := anchor + offset
		var visited: bool = GameFlow.visited_rooms.has(pos)
		draw_rect(Rect2(draw_pos, Vector2(pip_size, pip_size)), _minimap_pip_color(data, visited), true)
		if pos == GameFlow.current_room_pos:
			draw_rect(Rect2(draw_pos, Vector2(pip_size, pip_size)), Palette.HIT_FLASH, false, 2.0)
		elif data.get("type") in [GameFlow.RoomType.SOUL, GameFlow.RoomType.ALTAR]:
			draw_rect(Rect2(draw_pos, Vector2(pip_size, pip_size)), Color(1.0, 1.0, 1.0, 0.6), false, 1.5)

func _minimap_pip_color(data: Dictionary, visited: bool) -> Color:
	if not visited:
		return Color(1.0, 1.0, 1.0, 0.12) # znany (sąsiad odwiedzonego), ale jeszcze nieodwiedzony
	match data.get("type"):
		GameFlow.RoomType.START:
			return Color(1.0, 1.0, 1.0, 0.5)
		GameFlow.RoomType.SOUL:
			var base_color: Color = Palette.PHASE_COLORS[data.get("chapter", 0)]
			return base_color if data.get("cleared", false) else Color(base_color, 0.4)
		GameFlow.RoomType.ALTAR:
			return Color(1.0, 0.9, 0.5, 1.0) if GameFlow.fragments_collected.size() >= GameFlow.CHAPTER_COUNT else Color(1.0, 0.9, 0.5, 0.3)
		_: # RANDOM
			return Color(Palette.PLAYER_BODY, 0.55) if data.get("cleared", false) else Color(Palette.PLAYER_BODY, 0.25)

## Liczba zbankowanych stacków leczenia (0-max_heal_stacks) obok ikony — bez
## tego gracz nie ma jak poznać, ile ma zapasu poza samą jasnością ikony
## (która i tak jest w pełni jasna już przy 1 stacku).
func _draw_heal_stack_count() -> void:
	if player == null or hide_all or _overlay_active:
		return
	var stacks := player.get_heal_stacks()
	if stacks <= 0:
		return
	var font := ThemeDB.fallback_font
	var text := "x%d" % stacks
	var pos := _heal_pos + Vector2(heal_icon_size + 2.0, heal_icon_size)
	draw_string(font, pos, text, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Palette.HIT_FLASH)

func _draw_center_message() -> void:
	if _center_message == "":
		return
	var font := ThemeDB.fallback_font
	var font_size := _center_message_font_size
	var text_size := font.get_string_size(_center_message, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size)
	var pos := Vector2((size.x - text_size.x) * 0.5, size.y * 0.5)
	draw_string(font, pos, _center_message, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Palette.HIT_FLASH)

func _draw_overlay() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color(Palette.BACKGROUND, 0.85), true)
	var font := ThemeDB.fallback_font
	var lines := _overlay_text.split("\n")
	var line_height := overlay_font_size * 1.4
	var start_y := size.y * 0.5 - (lines.size() - 1) * line_height * 0.5
	for i in range(lines.size()):
		var line: String = lines[i]
		var text_size := font.get_string_size(line, HORIZONTAL_ALIGNMENT_CENTER, -1, overlay_font_size)
		var pos := Vector2((size.x - text_size.x) * 0.5, start_y + i * line_height)
		draw_string(font, pos, line, HORIZONTAL_ALIGNMENT_LEFT, -1, overlay_font_size, Palette.PLAYER_BODY)
