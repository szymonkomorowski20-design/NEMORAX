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

const TEX_PLAYER_BAR := preload("res://assets/sprites/ui/player_health_bar.png")
const TEX_STAMINA_BAR := preload("res://assets/sprites/ui/stamina_bar.png")
const TEX_MANA_BAR := preload("res://assets/sprites/ui/mana_bar.png")
const TEX_BOSS_BAR := preload("res://assets/sprites/ui/boss_health_bar.png")
const TEX_DASH_ICON := preload("res://assets/sprites/ui/dash_icon.png")
const TEX_LOCK_CROSS := preload("res://assets/sprites/ui/lock_cross.png")
const TEX_HEAL_ICON := preload("res://assets/sprites/ui/heal_icon.png")
const TEX_DEATH_FRAME := preload("res://assets/sprites/end_screens/death_screen_frame.png")
const TEX_VICTORY_FRAME := preload("res://assets/sprites/end_screens/victory_screen_frame.png")

# Paski "under" (tło/tor) to ta sama grafika co "fill", tylko przyciemniona
# modulate — jeden wygenerowany obrazek na pasek, nie osobna para pusty/pełny
# (patrz PROMPTY_FINALNE_WSZYSTKO.md sekcja E).
const UNDER_MODULATE := Color(1.0, 1.0, 1.0, 0.25)

@export var player_bar_size: Vector2 = Vector2(200.0, 20.0)
@export var resource_bar_size: Vector2 = Vector2(200.0, 8.0)
@export var resource_bar_gap: float = 4.0 ## px, odstęp między paskami staminy/many/życia
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

var _center_message: String = ""
var _center_message_timer: float = 0.0
var _center_message_font_size: int = 32

var _overlay_text: String = ""
var _overlay_active: bool = false

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
	var player_pos := Vector2(30.0, size.y - 50.0)
	_setup_bar(player_bar_under, player_bar, TEX_PLAYER_BAR, player_pos, player_bar_size, Color.WHITE)

	var stamina_pos := player_pos - Vector2(0.0, resource_bar_gap + resource_bar_size.y)
	_setup_bar(stamina_bar_under, stamina_bar, TEX_STAMINA_BAR, stamina_pos, resource_bar_size, Color.WHITE)

	var mana_pos := stamina_pos - Vector2(0.0, resource_bar_gap + resource_bar_size.y)
	_setup_bar(mana_bar_under, mana_bar, TEX_MANA_BAR, mana_pos, resource_bar_size, Color.WHITE)

	var boss_pos := Vector2(ARENA_LEFT, 20.0)
	_setup_bar(boss_bar_under, boss_bar, TEX_BOSS_BAR, boss_pos, Vector2(ARENA_WIDTH, boss_bar_height), Color.WHITE)

	var dash_pos := Vector2(30.0 + player_bar_size.x + 16.0, size.y - 50.0)
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
	heal_icon.texture = TEX_HEAL_ICON
	heal_icon.centered = false
	heal_icon.position = heal_pos
	heal_icon.scale = Vector2(heal_icon_size, heal_icon_size) / _tex_size(TEX_HEAL_ICON)

	overlay_frame.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	overlay_frame.stretch_mode = TextureRect.STRETCH_SCALE
	overlay_frame.position = Vector2.ZERO
	overlay_frame.size = size
	overlay_frame.visible = false

func _tex_size(tex: Texture2D) -> Vector2:
	return Vector2(tex.get_width(), tex.get_height())

## Para under/fill: oba Sprite2D pokazują tę samą teksturę w tej samej skali
## (tak, żeby cała tekstura zmieściłaby się dokładnie w bar_size), ale "fill"
## dostaje region_rect przycinany co klatkę w _update_bars() do lewej części
## odpowiadającej wartości 0-1 — stąd pasek "pustoszeje" od prawej, z lewą
## krawędzią zawsze na miejscu, tak jak dawny FILL_LEFT_TO_RIGHT.
func _setup_bar(under: Sprite2D, fill: Sprite2D, tex: Texture2D, pos: Vector2, bar_size: Vector2, tint: Color) -> void:
	var tex_size := _tex_size(tex)
	var bar_scale := bar_size / tex_size
	for bar in [under, fill]:
		bar.texture = tex
		bar.centered = false
		bar.position = pos
		bar.scale = bar_scale
		bar.region_enabled = true
	under.region_rect = Rect2(Vector2.ZERO, tex_size)
	under.modulate = UNDER_MODULATE
	fill.region_rect = Rect2(Vector2.ZERO, tex_size)
	fill.modulate = tint

func _update_bar_fill(fill: Sprite2D, ratio: float) -> void:
	var tex_size := _tex_size(fill.texture)
	fill.region_rect = Rect2(0.0, 0.0, tex_size.x * clamp(ratio, 0.0, 1.0), tex_size.y)

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
	boss_bar_under.visible = show_bars and boss != null
	boss_bar.visible = show_bars and boss != null

	if not show_bars:
		return

	if player != null:
		_update_bar_fill(player_bar, player.health / player.max_health)
		_update_bar_fill(stamina_bar, player.stamina / player.max_stamina)
		_update_bar_fill(mana_bar, player.mana / player.max_mana)

		dash_icon.modulate = Color(1.0, 1.0, 1.0, 0.35 if player.is_dash_on_cooldown() else 1.0)
		dash_lock_cross.visible = player.is_dash_locked_by_void()

		heal_icon.modulate = Color(1.0, 1.0, 1.0, 1.0 if player.is_heal_ready() else 0.4 + 0.3 * player.heal_charge_ratio())

	if boss != null:
		_update_bar_fill(boss_bar, boss.health / boss.max_health)
		boss_bar.modulate = boss.current_color

func _draw() -> void:
	if _overlay_active:
		_draw_overlay()
	_draw_center_message()

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
