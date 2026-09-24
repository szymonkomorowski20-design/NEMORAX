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

## HUD (krok 7, TERAZ_DLA_CLAUDE_ARENA_UI_I_FEELING.md): "pasek ma pokazywać
## zmianę utraconego HP przez chwilowy cień starej wartości" — sliver między
## nową krawędzią paska a tym, gdzie była PRZED ostatnim trafieniem, gasnący w
## PLAYER_HP_SHADOW_CATCH_UP_SPEED sekund. Czerwony — "czerwony TYLKO dla
## obrażeń" (paleta, sekcja UI) pasuje tu dosłownie: to WŁAŚNIE świeżo
## utracone HP. Sam pasek gracza jest niebieski (TEX_PLAYER_BAR), więc
## neutralny jasny odcień (kość/srebro) ledwie by się odróżniał od wypełnienia
## — czerwień daje kontrast niezależnie od koloru tekstury paska. Tylko dla
## obrażeń — leczenie NIE dostaje efektu cienia (patrz _update_bars: cień
## skacze w górę natychmiast przy wzroście HP, doganiam tylko spadek).
const PLAYER_HP_SHADOW_TINT := Color(0.85, 0.22, 0.22, 1.0)
const PLAYER_HP_SHADOW_CATCH_UP_SPEED := 1.0 ## ułamek paska/s

## Reliquary (krok 7): jeden wspólny, ciemny panel pod HP/staminą/maną/expem
## zamiast czterech osobnych pasków latających luzem nad podłogą — bez
## dedykowanej grafiki na tak duży, rzadko zmieniany kształt (jak tło
## stats_screen.gd), więc rysowany kodem jednym prostokątem z cienką ramką.
const RELIQUARY_BG_COLOR := Color(0.06, 0.05, 0.09, 0.72)
const RELIQUARY_BORDER_COLOR := Color(0.35, 0.30, 0.42, 0.55)
const RELIQUARY_PADDING := 12.0

## Minimapa (krok 7): "mapa pamięci, nie kolorowa siatka debugowa — odwiedzony
## pokój ciemny, bieżący turkusowy, boss/cel jednym akcentem". Wcześniej każdy
## rozdział duszy (SOUL) dostawał inny kolor z Palette.PHASE_COLORS (tęcza) —
## usunięte na rzecz jednego, spójnego schematu.
const MINIMAP_VISITED_COLOR := Color(0.29, 0.27, 0.35, 0.95) ## kamień — odwiedzony pokój
const MINIMAP_UNKNOWN_COLOR := Color(1.0, 1.0, 1.0, 0.08) ## odkryty sąsiad, jeszcze nieodwiedzony
const MINIMAP_VISIT_MARK_COLOR := Color(0.69, 0.83, 0.82, 0.90) ## czytelna kropka pamięci
const MINIMAP_GOAL_COLOR := Color("#E8C547") ## złoto — WYŁĄCZNIE Ołtarz, jedyny "cel/boss" na mapie

const BOSS_NAME := "Nemorax"
const CENTER_FONT_BANNER := preload("res://assets/fonts/Cinzel-SemiBold.woff")
const CENTER_FONT_LINE := preload("res://assets/fonts/EBGaramond-Medium.woff")
const CENTER_TEXT_COLOR := Color("#EDE3CF") ## pergamin — spójny z kartami, nie czysta biel

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

## Krok 4/8: karta relikwii — dolny środek, osobno od _center_message (górny
## środek, dzielony przez fazę bossa/nazwę pokoju/kwestie). Dokument: "ikona +
## nazwa + jedno zdanie efektu", 1,5-2,5s, zastępuje zwykły tekstowy toast
## "Zdobyto ulepszenie: X". room.gd woła show_relic_card() z _on_chest_opened().
const RELIC_CARD_DURATION := 2.0 ## s, środek okna 1,5-2,5s z dokumentu
const RELIC_ICONS := {
	"blood_edge": preload("res://assets/sprites/ui/relic_blood_edge.png"),
	"void_step": preload("res://assets/sprites/ui/relic_void_step.png"),
	"soul_echo": preload("res://assets/sprites/ui/relic_soul_echo.png"),
	"iron_heart": preload("res://assets/sprites/ui/relic_iron_heart.png"),
	"razor_wind": preload("res://assets/sprites/ui/relic_razor_wind.png"),
	"hunters_mark": preload("res://assets/sprites/ui/relic_hunters_mark.png"),
	"second_impact": preload("res://assets/sprites/ui/relic_second_impact.png"),
	"momentum": preload("res://assets/sprites/ui/relic_momentum.png"),
	"last_resolve": preload("res://assets/sprites/ui/relic_last_resolve.png"),
	"soul_bond": preload("res://assets/sprites/ui/relic_soul_bond.png"),
}
## Jedno zdanie na relikwię — te same efekty co w Player (dokładne liczby w
## entities/player.gd), tylko w krótkiej, czytelnej formie do karty.
const RELIC_DESCRIPTIONS := {
	"blood_edge": "Trafienie uzbraja kolejny zamach: +20% obrażeń.",
	"void_step": "Po dashu: chwilowy wzrost prędkości i zasięgu ataku.",
	"soul_echo": "Zabójstwo ma szansę dać +15% obrażeń na 4 sekundy.",
	"iron_heart": "+20% maksymalnego zdrowia, mniejsze odepchnięcie.",
	"razor_wind": "Trwale zwiększony zasięg ataku mieczem.",
	"hunters_mark": "Pierwsze trafienie znaczy cel — kolejne zadają więcej.",
	"second_impact": "Trafienie ma szansę na drugi, opóźniony cios.",
	"momentum": "Brak obrażeń zwiększa prędkość — trafienie zeruje bonus.",
	"last_resolve": "Przy niskim zdrowiu: więcej obrażeń i szybszy atak.",
	"soul_bond": "Podniesienie duszy daje chwilowy, tematyczny bonus.",
}
## A14: jedna lokalizacja — polskie nazwy relikwii we wszystkich widokach.
const RELIC_NAMES := {
	"blood_edge": "Krwawe Ostrze", "void_step": "Krok Otchłani", "soul_echo": "Echo Duszy",
	"iron_heart": "Żelazne Serce", "razor_wind": "Brzytwa Wiatru", "hunters_mark": "Znak Łowcy",
	"second_impact": "Drugie Uderzenie", "momentum": "Rozpęd", "last_resolve": "Ostatnia Wola",
	"soul_bond": "Więź Dusz",
}
const RELIC_CARD_BG := Color(0.06, 0.05, 0.09, 0.88)
const RELIC_CARD_BORDER := Color("#E8C547") ## złoto — "złoto wyłącznie dla nagród"
var _relic_card_id: String = ""
var _relic_card_timer: float = 0.0

## Krok 8: "błąd/brak zasobu — przy odpowiednim pasku HUD, mały, nie czerwony
## ekran". `kind` to "stamina"/"mana"/"heal" — dopasowane 1:1 do
## Player.resource_denied (entities/player.gd). Pulsuje krótko czerwienią na
## "under" danego paska/ikony zamiast dodawać osobny tekst.
const RESOURCE_FLASH_DURATION := 0.5
const RESOURCE_FLASH_COLOR := Color(1.0, 0.3, 0.3, 1.0)
var _resource_flash_kind: String = ""
var _resource_flash_timer: float = 0.0

var _overlay_text: String = ""
var _overlay_active: bool = false

var _heal_pos: Vector2 = Vector2.ZERO ## zapamiętane w _ready() do rysowania liczby stacków obok ikony leczenia
var _xp_bar_pos: Vector2 = Vector2.ZERO ## zapamiętane w _ready() do _draw_xp_bar()
var _player_bar_pos: Vector2 = Vector2.ZERO ## zapamiętane w _ready() do _draw_player_hp_text()
var _boss_bar_pos: Vector2 = Vector2.ZERO ## zapamiętane w _ready() do _draw_boss_hp_text()
var _player_hp_shadow_ratio: float = 1.0 ## dogania player.health/max_health tylko przy SPADKU (obrażenia), skacze w górę natychmiast przy leczeniu

@onready var player_bar_under: Sprite2D = $PlayerBarUnder
@onready var player_bar_shadow: Sprite2D = $PlayerBarShadow
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
	# Cień "utraconego HP" — trzeci sprite MIĘDZY under i fill w drzewie sceny
	# (ui.tscn), żeby rysował się nad tłem paska, ale pod aktualną wartością.
	player_bar_shadow.texture = TEX_PLAYER_BAR
	player_bar_shadow.centered = false
	player_bar_shadow.position = player_pos
	player_bar_shadow.scale = player_bar_size / PLAYER_BAR_CONTENT.size
	player_bar_shadow.region_enabled = true
	player_bar_shadow.region_rect = PLAYER_BAR_CONTENT
	player_bar_shadow.modulate = PLAYER_HP_SHADOW_TINT

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
	_tick_reward_reminder(delta)
	if _relic_card_timer > 0.0:
		_relic_card_timer -= delta
		if _relic_card_timer <= 0.0:
			_relic_card_id = ""
	if _resource_flash_timer > 0.0:
		_resource_flash_timer = max(0.0, _resource_flash_timer - delta)
	_update_bars(delta)
	queue_redraw()

func show_form_name(text: String) -> void:
	_center_message = text
	_center_message_timer = form_name_display_time
	_center_message_font_size = form_name_font_size

func show_taunt(text: String, duration: float) -> void:
	_center_message = text
	_center_message_timer = duration
	_center_message_font_size = taunt_font_size

## Krok 4/8: kanał "dolny środek" dla ulepszeń — patrz komentarz przy
## RELIC_CARD_DURATION. room.gd woła to zamiast show_taunt() z
## _on_chest_opened(). Nieznane ID (nie powinno się zdarzyć — 10 relikwii
## pokrywa RELIC_ICONS/RELIC_DESCRIPTIONS w komplecie) po prostu nic nie
## pokazuje zamiast crashować na brakującym kluczu.
const SND_RELIC_REVEAL := preload("res://assets/audio/sfx/p0/REWARD_RELIC_REVEAL.wav")

func show_relic_card(upgrade_id: String) -> void:
	if not RELIC_ICONS.has(upgrade_id):
		return
	_relic_card_id = upgrade_id
	_relic_card_timer = RELIC_CARD_DURATION
	Juice.play_ui_sfx(SND_RELIC_REVEAL)

## Krok 8: podpięte przez room.gd/arena.gd pod Player.resource_denied.
func flash_resource_denied(kind: String) -> void:
	_resource_flash_kind = kind
	_resource_flash_timer = RESOURCE_FLASH_DURATION

func show_overlay(text: String, kind: String = "death") -> void:
	_overlay_text = text
	_overlay_active = true
	overlay_frame.texture = TEX_VICTORY_FRAME if kind == "victory" else TEX_DEATH_FRAME
	overlay_frame.visible = true

## Krok 9 (polish ekranów): "panel: ZOSTAŁEŚ ODRZUCONY / inny wybrany tekst
## świata, przyczyna lub pokój, przyciski: spróbuj ponownie / menu". Wspólne
## dla arena.gd (walka z Nemoraksem — `reason` to numer próby) i room.gd
## (zwykły pokój — `reason` to nazwa pokoju z _room_display_name()), żeby oba
## nie duplikowały tego samego formatowania tekstu z małymi rozjazdami.
func show_death_overlay(reason: String = "") -> void:
	var lines := ["Zostałeś odrzucony"]
	if reason != "":
		lines.append("")
		lines.append(reason)
	lines.append("")
	lines.append("Enter — spróbuj ponownie      Escape — wyjdź do menu")
	show_overlay("\n".join(lines), "death")

## Paczka 9 (A17/E5): ekran końca z historią próby i radą na następny raz.
const END_SCREEN_DEATH_KEYS := "Enter — spróbuj ponownie      S — to samo ziarno      Escape — wyjdź do menu"
const END_SCREEN_VICTORY_KEYS := "Enter — nowa próba      S — to samo ziarno      Escape — wyjdź do menu"

func show_run_summary(entry: Dictionary) -> void:
	var lines := RunSummary.screen_lines(entry)
	lines.append(END_SCREEN_VICTORY_KEYS if entry["result"] == "victory" else END_SCREEN_DEATH_KEYS)
	show_overlay("\n".join(lines), "victory" if entry["result"] == "victory" else "death")

func hide_overlay() -> void:
	_overlay_active = false
	overlay_frame.visible = false

## Wołać PRZED get_tree().paused = true. Ten węzeł nie ma PROCESS_MODE_ALWAYS,
## a _process() to jedyne miejsce, które ponownie ocenia hide_all
## (_update_bars + queue_redraw) — samo ustawienie flagi tuż przed pauzą
## zostawiało zamrożoną ostatnią klatkę HUD-u pod dialogiem scenki.
func hide_for_cutscene() -> void:
	hide_all = true
	_update_bars(0.0)
	queue_redraw()

## Jedna reguła prezentacji HP dla gracza i bossa. max przez roundi (nie int):
## 100.0 * 1.15 to w double 114.999…, int() dawał 114, a ceili() tej samej
## wartości 115 — stąd "115/114" przy pełnym HP fazy. Bieżące HP w górę
## (0,3 HP żywego celu to "1", nie "0"), ale nigdy ponad wyświetlone maksimum.
static func hp_label(current: float, maximum: float) -> String:
	var max_display := roundi(maximum)
	var current_display := clampi(ceili(current), 0, max_display)
	return "%d / %d" % [current_display, max_display]

## Zastępuje dawne _draw_player_bar/_draw_resource_bars/_draw_boss_bar/
## _draw_dash_icon/_draw_heal_icon — teraz to prawdziwe sprite'y/TextureRect,
## więc tylko aktualizujemy region_rect/visible/modulate co klatkę.
func _update_bars(delta: float) -> void:
	var show_bars := not hide_all and not _overlay_active
	for node in [player_bar_under, player_bar_shadow, player_bar, stamina_bar_under, stamina_bar,
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
		var hp_ratio: float = player.health / player.max_health
		_update_bar_fill(player_bar, PLAYER_BAR_CONTENT, hp_ratio)
		# Leczenie skacze w górę natychmiast (bez cienia) — cień to WYŁĄCZNIE
		# ślad po obrażeniach, żeby cios "miał wagę" (dokument, krok 7).
		if hp_ratio > _player_hp_shadow_ratio:
			_player_hp_shadow_ratio = hp_ratio
		else:
			_player_hp_shadow_ratio = move_toward(_player_hp_shadow_ratio, hp_ratio, PLAYER_HP_SHADOW_CATCH_UP_SPEED * delta)
		_update_bar_fill(player_bar_shadow, PLAYER_BAR_CONTENT, _player_hp_shadow_ratio)
		_update_bar_fill(stamina_bar, STAMINA_BAR_CONTENT, player.stamina / player.max_stamina)
		_update_bar_fill(mana_bar, MANA_BAR_CONTENT, player.mana / player.max_mana)
		stamina_bar_under.modulate = _resource_flash_modulate(UNDER_MODULATE, "stamina")
		mana_bar_under.modulate = _resource_flash_modulate(UNDER_MODULATE, "mana")

		dash_icon.modulate = Color(1.0, 1.0, 1.0, 0.35 if player.is_dash_on_cooldown() else 1.0)
		dash_lock_cross.visible = player.is_dash_locked_by_void()

		var heal_base := Color(1.0, 1.0, 1.0, 1.0 if player.is_heal_ready() else 0.4 + 0.3 * player.heal_charge_ratio())
		heal_icon.modulate = _resource_flash_modulate(heal_base, "heal")

	if show_boss_bar:
		_update_bar_fill(boss_bar, BOSS_BAR_CONTENT, boss.health / boss.max_health)
		boss_bar.modulate = boss.current_color

## `base` to modulate danego elementu, gdyby NIE trwał flash — flash_resource_denied
## łagodnie odpływa od RESOURCE_FLASH_COLOR z powrotem do `base` w ciągu
## RESOURCE_FLASH_DURATION, zamiast twardo przełączać kolor na jedną klatkę.
func _resource_flash_modulate(base: Color, kind: String) -> Color:
	if _resource_flash_timer <= 0.0 or _resource_flash_kind != kind:
		return base
	var t: float = _resource_flash_timer / RESOURCE_FLASH_DURATION
	return base.lerp(RESOURCE_FLASH_COLOR, t)

func _draw() -> void:
	_draw_reliquary_panel() # PIERWSZE — rodzic rysuje się POD swoimi dziećmi (paski/ikony), więc to zawsze wyląduje w tle
	if _overlay_active:
		_draw_overlay()
	_draw_center_message()
	_draw_relic_card()
	_draw_heal_stack_count()
	_draw_xp_bar()
	_draw_reward_buttons()
	_draw_reward_reminder()
	_draw_player_hp_text()
	_draw_boss_name_and_phase()
	_draw_boss_hp_text()
	_draw_minimap()

## HUD krok 7: "lewy dół: jeden zwarty relikwiarz stanu gracza" zamiast czterech
## pasków latających osobno nad podłogą. Obejmuje HP/staminę/manę/exp — NIE
## ikony dash/heal (dokument wymienia tylko HP/stamina/mana/poziom, ikonki
## zdolności to osobny, mniejszy klaster obok, bez zmian).
func _draw_reliquary_panel() -> void:
	if hide_all or _overlay_active or player == null:
		return
	var top_left := _xp_bar_pos - Vector2(RELIQUARY_PADDING, RELIQUARY_PADDING)
	var bottom_right := _player_bar_pos + Vector2(player_bar_size.x, player_bar_size.y) + Vector2(RELIQUARY_PADDING, RELIQUARY_PADDING)
	var rect := Rect2(top_left, bottom_right - top_left)
	draw_rect(rect, RELIQUARY_BG_COLOR, true)
	draw_rect(rect, RELIQUARY_BORDER_COLOR, false, 1.5)

## Audyt UI (TERAZ_DLA_CLAUDE_ARENA_UI_I_FEELING.md): "ile ma życia i ile
## maksymalnie" musi być odpowiadalne bez zgadywania z samej długości
## wypełnienia paska — sam pasek to Sprite2D z przycinanym region_rect (patrz
## nagłówek pliku), bez żadnego tekstu. Wyśrodkowane NA pasku (nie obok niego)
## — po prawej stronie paska stoją już ikony dash/heal, tekst by na nie nachodził.
func _draw_player_hp_text() -> void:
	if player == null or hide_all or _overlay_active:
		return
	var font := ThemeDB.fallback_font
	var label := hp_label(player.health, player.max_health)
	var text_size := font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, 14)
	var pos := _player_bar_pos + Vector2((player_bar_size.x - text_size.x) * 0.5, player_bar_size.y * 0.5 + text_size.y * 0.3)
	draw_string(font, pos, label, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color.WHITE)

## HUD krok 7: "boss: jeden ciężki pasek z nazwą, fazą i HP; nie neonowa
## cienka linia" — dotąd pasek nie miał żadnego tekstu poza samym wypełnieniem.
## Nazwa jest na sztywno ("Nemorax") — jedyny boss w grze, nie ma potrzeby
## przekazywać jej z boss.gd. Faza czyta boss.phase_index NA BIEŻĄCO (nie z
## przelotnego sygnału phase_changed) — jedyne trwałe źródło aktualnej fazy.
func _draw_boss_name_and_phase() -> void:
	if boss == null or not (boss is Boss) or hide_all or _overlay_active:
		return
	var font: Font = CENTER_FONT_BANNER
	var phase_name := ""
	if boss.phase_index >= 0 and boss.phase_index < Palette.PHASE_NAMES.size():
		phase_name = Palette.PHASE_NAMES[boss.phase_index]
	# A14: nazwa fazy nie wisi dwa razy na górze — gdy baner fazy jest na
	# ekranie, pasek bossa pokazuje samo imię.
	if phase_name != "" and _center_message == phase_name:
		phase_name = ""
	var label := "%s — %s" % [BOSS_NAME, phase_name] if phase_name != "" else BOSS_NAME
	var text_size := font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, 18)
	var pos := _boss_bar_pos + Vector2(ARENA_WIDTH * 0.5 - text_size.x * 0.5, boss_bar_height + 22.0)
	draw_string_outline(font, pos, label, HORIZONTAL_ALIGNMENT_LEFT, -1, 18, 4, Color(0.03, 0.02, 0.05, 0.8))
	draw_string(font, pos, label, HORIZONTAL_ALIGNMENT_LEFT, -1, 18, CENTER_TEXT_COLOR)

## Audyt UI, punkt "ile HP ma boss" — pod nazwą/fazą, żeby razem czytały się
## jako jedna jednostka zamiast trzech niepowiązanych napisów.
func _draw_boss_hp_text() -> void:
	if boss == null or not (boss is Boss) or hide_all or _overlay_active:
		return
	var font := ThemeDB.fallback_font
	var label := hp_label(boss.health, boss.max_health)
	var text_size := font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, 14)
	var pos := _boss_bar_pos + Vector2(ARENA_WIDTH * 0.5 - text_size.x * 0.5, boss_bar_height + 42.0)
	draw_string(font, pos, label, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color.WHITE)

## Wcześniej nigdzie niewidoczny — level/xp istniały tylko jako liczby w
## ekranie statystyk (Tab), bez własnego paska w HUD-zie.
func _draw_xp_bar() -> void:
	if player == null or hide_all or _overlay_active:
		return
	# Paczka 6 (A12): prawdziwy próg (2/3/4 XP, player.xp_ratio()), nie stałe
	# xp_per_level — dawny pasek pokazywał zły postęp. Na maksymalnym
	# poziomie pełny pasek i "MAX" zamiast pustki.
	var at_max := player.level >= player.max_level
	var ratio: float = 1.0 if at_max else clampf(player.xp_ratio(), 0.0, 1.0)
	draw_rect(Rect2(_xp_bar_pos, xp_bar_size), XP_BAR_BG, true)
	draw_rect(Rect2(_xp_bar_pos, Vector2(xp_bar_size.x * ratio, xp_bar_size.y)), XP_BAR_FILL, true)
	var font := ThemeDB.fallback_font
	var label := "Poz. %d · MAX" % player.level if at_max else "Poz. %d" % player.level
	draw_string(font, _xp_bar_pos + Vector2(xp_bar_size.x + 8.0, xp_bar_size.y + 2.0), label,
		HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color.WHITE)

## Decyzja autora (23.09): po awansie i po skrzyni wybór NIE otwiera się sam.
## Dwa przyciski nad relikwiarzem przypominają o nim do skutku (pulsujące
## złoto = nagroda), klikane albo z klawisza R / Q.
signal reward_button_pressed(kind: String) ## "level" albo "relic"
const REWARD_BUTTON_SIZE := Vector2(300.0, 28.0)
var _reward_button_rects: Dictionary = {}

## P1.10 (audyt nagrania 24.09): w walce przyciski nagród kurczą się do
## przygaszonej plakietki (nie konkurują z telegrafem ani paskiem HP), a po
## walce — jedno wyraźne, krótkie przypomnienie. Nic nie otwiera się samo.
## Próby deterministyczne: niewydane punkty i runy wydłużają finał ~3×.
const REWARD_REMINDER_TIME := 2.5
var _reward_reminder_timer: float = 0.0
var _was_in_combat: bool = false
const REWARD_REMINDER_REPEAT := 45.0 ## s — to samo przypomnienie najwyżej tak często
var _last_reminded: String = ""
var _last_reminded_at: float = -1000.0

func _tick_reward_reminder(delta: float) -> void:
	if player == null or not is_instance_valid(player):
		return
	var in_combat := not player.is_out_of_combat()
	if _was_in_combat and not in_combat and player.has_pending_rewards():
		var summary := _reward_summary()
		var now := Time.get_ticks_msec() / 1000.0
		if summary != _last_reminded or now - _last_reminded_at > REWARD_REMINDER_REPEAT:
			_reward_reminder_timer = REWARD_REMINDER_TIME
			_last_reminded = summary
			_last_reminded_at = now
	_was_in_combat = in_combat
	_reward_reminder_timer = maxf(0.0, _reward_reminder_timer - delta)

func _reward_summary() -> String:
	var parts: Array[String] = []
	if player.pending_skill_choices > 0:
		parts.append("runa ×%d [%s]" % [player.pending_skill_choices, Keybinds.display_for("open_runes")])
	if player.unspent_stat_points > 0:
		parts.append("punkty ×%d [%s]" % [player.unspent_stat_points, Keybinds.display_for("open_runes")])
	if not player.pending_relic_offers.is_empty():
		parts.append("relikwia [%s]" % Keybinds.display_for("open_relic"))
	return "  ·  ".join(parts)

func _draw_reward_reminder() -> void:
	if _reward_reminder_timer <= 0.0 or player == null or hide_all or _overlay_active or not player.has_pending_rewards():
		return
	var a := clampf(_reward_reminder_timer / 0.4, 0.0, 1.0) * clampf((REWARD_REMINDER_TIME - _reward_reminder_timer) / 0.25, 0.0, 1.0)
	var title := "Pokój czysty — nagrody czekają"
	var body := _reward_summary()
	var w := maxf(CENTER_FONT_LINE.get_string_size(body, HORIZONTAL_ALIGNMENT_LEFT, -1, 20).x, CENTER_FONT_BANNER.get_string_size(title, HORIZONTAL_ALIGNMENT_LEFT, -1, 22).x) + 60.0
	var rect := Rect2(Vector2((size.x - w) * 0.5, size.y * 0.70), Vector2(w, 74.0))
	draw_rect(rect, Color(0.08, 0.06, 0.03, 0.9 * a), true)
	draw_rect(rect, Color(RELIC_CARD_BORDER, a), false, 2.0)
	var tw := CENTER_FONT_BANNER.get_string_size(title, HORIZONTAL_ALIGNMENT_LEFT, -1, 22).x
	draw_string(CENTER_FONT_BANNER, rect.position + Vector2((w - tw) * 0.5, 30.0), title, HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color("#E8C547", a))
	var bw := CENTER_FONT_LINE.get_string_size(body, HORIZONTAL_ALIGNMENT_LEFT, -1, 20).x
	draw_string(CENTER_FONT_LINE, rect.position + Vector2((w - bw) * 0.5, 60.0), body, HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color(CENTER_TEXT_COLOR, a))

func _draw_reward_buttons() -> void:
	_reward_button_rects.clear()
	if player == null or hide_all or _overlay_active:
		return
	if not player.is_out_of_combat():
		# W walce: jedna przygaszona plakietka — nadal klikalna i widoczna.
		var compact := _reward_summary()
		if compact == "" and GameFlow.pending_pact >= 0:
			compact = "pakt [%s]" % Keybinds.display_for("open_pact")
		if compact != "":
			var cw := ThemeDB.fallback_font.get_string_size(compact, HORIZONTAL_ALIGNMENT_LEFT, -1, 13).x + 20.0
			var crect := Rect2(Vector2(_xp_bar_pos.x - RELIQUARY_PADDING, _xp_bar_pos.y - RELIQUARY_PADDING - 30.0), Vector2(cw, 22.0))
			_reward_button_rects["level" if player.has_pending_rewards() and player.pending_relic_offers.is_empty() else ("relic" if not player.pending_relic_offers.is_empty() else "pact")] = crect
			draw_rect(crect, Color(0.08, 0.06, 0.03, 0.6), true)
			draw_rect(crect, Color(RELIC_CARD_BORDER, 0.45), false, 1.0)
			draw_string(ThemeDB.fallback_font, crect.position + Vector2(10.0, 16.0), compact, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("#F1E4B8", 0.75))
		return
	var buttons: Array = []
	var level_text := RewardPrompt.level_label(player)
	if level_text != "":
		buttons.append(["level", "[%s] %s" % [Keybinds.display_for("open_runes"), level_text]])
	if not player.pending_relic_offers.is_empty():
		buttons.append(["relic", "[%s] Relikwia do wyboru" % Keybinds.display_for("open_relic")])
	if GameFlow.pending_pact >= 0:
		buttons.append(["pact", "[%s] Pakt fragmentu do wyboru" % Keybinds.display_for("open_pact")])
	var font := ThemeDB.fallback_font
	var pulse := 0.55 + 0.45 * absf(sin(Time.get_ticks_msec() / 400.0))
	var y := _xp_bar_pos.y - RELIQUARY_PADDING - 6.0
	for b in buttons:
		y -= REWARD_BUTTON_SIZE.y + 4.0
		var rect := Rect2(Vector2(_xp_bar_pos.x - RELIQUARY_PADDING, y), REWARD_BUTTON_SIZE)
		_reward_button_rects[b[0]] = rect
		draw_rect(rect, Color(0.08, 0.06, 0.03, 0.88), true)
		draw_rect(rect, Color(RELIC_CARD_BORDER, pulse), false, 2.0)
		draw_string(font, rect.position + Vector2(10.0, 19.0), b[1], HORIZONTAL_ALIGNMENT_LEFT, REWARD_BUTTON_SIZE.x - 16.0, 15, Color("#F1E4B8"))

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		for kind in _reward_button_rects:
			if (_reward_button_rects[kind] as Rect2).has_point(get_local_mouse_position()):
				reward_button_pressed.emit(kind)
				get_viewport().set_input_as_handled()
				return

## Minimapa w stylu "The Binding of Isaac" (na życzenie autora) — siatka 2D z
## game_flow.gd zamiast dawnej liniowej sekwencji. Bieżący pokój zawsze
## wyśrodkowany, mgła wojny: pokoje odwiedzone w pełnym kolorze, sąsiedzi
## odwiedzonych (znani, ale nieodwiedzeni) jako przygaszony zarys, reszta w
## ogóle nierysowana. Ołtarz i pokoje z duszą dostają dodatkową obwódkę, żeby
## wyróżniały się jako cel, nie przystanek.
## Paczka 7 (A13): duża mapa pod klawiszem "toggle_map" (M) — te same dane,
## większe pola, symbole typów i legenda. Nie pauzuje gry.
var big_map: bool = false

func _draw_minimap() -> void:
	if not show_minimap or hide_all or _overlay_active:
		return
	if big_map:
		_draw_big_map()
	var pip_size := 14.0
	var gap := 4.0
	var spacing := pip_size + gap
	var box_size := Vector2(6, 6) * spacing
	var anchor := Vector2(VIEWPORT_SIZE.x - box_size.x - 20.0, 20.0) + box_size * 0.5 - Vector2(pip_size, pip_size) * 0.5
	_draw_map_pips(anchor, pip_size, spacing, 3)
	var hint := "[%s] mapa" % Keybinds.display_for("toggle_map")
	draw_string(ThemeDB.fallback_font, Vector2(VIEWPORT_SIZE.x - 20.0 - box_size.x - 52.0, 32.0), hint, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(1, 1, 1, 0.5))

func _draw_big_map() -> void:
	var panel := Rect2(Vector2(240.0, 70.0), Vector2(800.0, 560.0))
	draw_rect(panel, Color(0.03, 0.02, 0.05, 0.92), true)
	draw_rect(panel, RELIQUARY_BORDER_COLOR, false, 2.0)
	var pip := 26.0
	var spacing := pip + 7.0
	var center := panel.get_center() - Vector2(90.0, 0.0) - Vector2(pip, pip) * 0.5
	_draw_map_pips(center, pip, spacing, 8)
	var font := ThemeDB.fallback_font
	var y := panel.position.y + 40.0
	draw_string(font, Vector2(panel.end.x - 200.0, y), "Legenda", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, MINIMAP_GOAL_COLOR)
	for kind in ["soul", "altar", "chest", "trap", "elite", "rest"]:
		y += 30.0
		MapMarker.draw_marker(self, Vector2(panel.end.x - 188.0, y - 5.0), 16.0, kind)
		draw_string(font, Vector2(panel.end.x - 168.0, y), MapMarker.LABELS[kind], HORIZONTAL_ALIGNMENT_LEFT, 160.0, 13, Color.WHITE)
	y += 30.0
	draw_rect(Rect2(Vector2(panel.end.x - 196.0, y - 13.0), Vector2(16, 16)), Palette.PLAYER_BODY, true)
	draw_string(font, Vector2(panel.end.x - 168.0, y), "Tu jesteś", HORIZONTAL_ALIGNMENT_LEFT, 160.0, 13, Color.WHITE)
	y += 26.0
	draw_rect(Rect2(Vector2(panel.end.x - 196.0, y - 13.0), Vector2(16, 16)), MINIMAP_VISITED_COLOR, true)
	draw_rect(Rect2(Vector2(panel.end.x - 191.0, y - 8.0), Vector2(6, 6)), MINIMAP_VISIT_MARK_COLOR, true)
	draw_string(font, Vector2(panel.end.x - 168.0, y), "Odwiedzony", HORIZONTAL_ALIGNMENT_LEFT, 160.0, 13, Color.WHITE)
	y += 26.0
	draw_rect(Rect2(Vector2(panel.end.x - 196.0, y - 13.0), Vector2(16, 16)), Color(0.7, 0.7, 0.8, 0.5), false, 1.5)
	draw_string(font, Vector2(panel.end.x - 168.0, y), "Znany, nieodwiedzony", HORIZONTAL_ALIGNMENT_LEFT, 160.0, 13, Color.WHITE)

func _draw_map_pips(anchor: Vector2, pip_size: float, spacing: float, radius: int) -> void:

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
		if absi(pos.x - GameFlow.current_room_pos.x) > radius or absi(pos.y - GameFlow.current_room_pos.y) > radius:
			continue # tylko to, co mieści się w polu mapy
		var offset := Vector2(pos.x - GameFlow.current_room_pos.x, pos.y - GameFlow.current_room_pos.y) * spacing
		var draw_pos := anchor + offset
		var visited: bool = GameFlow.visited_rooms.has(pos)
		var is_current: bool = pos == GameFlow.current_room_pos
		draw_rect(Rect2(draw_pos, Vector2(pip_size, pip_size)), _minimap_pip_color(data, visited, is_current), true)
		if is_current:
			draw_rect(Rect2(draw_pos, Vector2(pip_size, pip_size)), Palette.HIT_FLASH, false, 2.0)
		elif visited:
			# Nie tylko ciemniejszy kolor: punkt w środku jednoznacznie znaczy "tu już byłem".
			draw_rect(Rect2(draw_pos + Vector2(pip_size, pip_size) * 0.36, Vector2(pip_size, pip_size) * 0.28), MINIMAP_VISIT_MARK_COLOR, true)
			if data.get("type") == GameFlow.RoomType.SOUL and not data.get("cleared", false):
				draw_rect(Rect2(draw_pos, Vector2(pip_size, pip_size)), Color(1.0, 1.0, 1.0, 0.6), false, 1.5)
		else:
			# Znany sąsiad to tylko pusty zarys — nie może udawać odwiedzonego.
			draw_rect(Rect2(draw_pos, Vector2(pip_size, pip_size)), Color(0.7, 0.7, 0.8, 0.5), false, 1.5)
		# Paczka 7: symbol typu (ryzyko/nagroda) — ten sam co nad drzwiami.
		MapMarker.draw_marker(self, draw_pos + Vector2(pip_size, pip_size) * 0.5, pip_size * 0.62, MapMarker.kind_for(data))

## "Mapa pamięci, nie kolorowa siatka debugowa — odwiedzony pokój ciemny,
## bieżący turkusowy, boss/cel jednym akcentem" (krok 7). SOUL dawniej dostawał
## inny kolor z Palette.PHASE_COLORS na każdy z 6 rozdziałów (tęcza) — teraz
## wygląda jak każdy inny odwiedzony pokój; jedyna pozostała wskazówka to
## cienka obwódka dla NIEODEBRANEJ duszy (rysowana wyżej), nie osobny kolor.
## ALTAR to JEDYNY "cel/boss" na mapie, więc jedyny z osobnym akcentem koloru.
func _minimap_pip_color(data: Dictionary, visited: bool, is_current: bool) -> Color:
	if not visited:
		return MINIMAP_UNKNOWN_COLOR # znany (sąsiad odwiedzonego), ale jeszcze nieodwiedzony
	if is_current:
		return Palette.PLAYER_BODY
	if data.get("type") == GameFlow.RoomType.ALTAR:
		return MINIMAP_GOAL_COLOR if GameFlow.fragments_collected.size() >= GameFlow.CHAPTER_COUNT else Color(MINIMAP_GOAL_COLOR, 0.4)
	return MINIMAP_VISITED_COLOR

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

## Krok 8: "tekst nie może leżeć na hitboxie bossa ani na postaci gracza" —
## dawniej rysowane w PIONOWYM środku ekranu (size.y*0.5), dokładnie tam, gdzie
## stoi boss/gracz w trakcie walki. Faza bossa i nazwa pokoju mają być "górny
## środek" (dokument) — przesunięte pod stos nazwa+faza+HP bossa (kończy się
## ok. boss_bar_height+42 ≈ y=78 przy domyślnych wartościach), z zapasem.
func _draw_center_message() -> void:
	# hide_all brakowało tu (jedyne miejsce w _draw() bez tej straży) — dlatego
	# ostatni baner/kwestia (np. nazwa fazy "Sovereignty") wisiał na ekranie
	# przez całą sekwencję finałową i epilog zwycięstwa, pod dialogiem cutscenki.
	if _center_message == "" or hide_all or _overlay_active:
		return
	# A15 (Paczka 10): czcionki gry zamiast systemowej, pergamin zamiast czystej
	# bieli, ciemny obrys (czytelne nad walką, nie "naklejone"). Baner fazy —
	# Cinzel, kwestie/tytuły komnat — Garamond, mniejsze. Wieloliniowe OK.
	var is_banner := _center_message_font_size >= form_name_font_size
	var font: Font = CENTER_FONT_BANNER if is_banner else CENTER_FONT_LINE
	var font_size := _center_message_font_size if is_banner else _center_message_font_size - 2
	var lines := _center_message.split("\n")
	var alpha := clampf(_center_message_timer / 0.35, 0.0, 1.0) # łagodne zejście
	for i in lines.size():
		var text_size := font.get_string_size(lines[i], HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
		var pos := Vector2((size.x - text_size.x) * 0.5, size.y * 0.16 + i * font_size * 1.3)
		draw_string_outline(font, pos, lines[i], HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, 6, Color(0.03, 0.02, 0.05, 0.85 * alpha))
		draw_string(font, pos, lines[i], HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color(CENTER_TEXT_COLOR, alpha))

## Krok 4/8: "karta relikwii w dolnej/środkowej części ekranu — ikona, nazwa,
## jedno konkretne zdanie efektu", zastępuje dawny czysty tekst "Zdobyto
## ulepszenie: X". Panel w materiale reszty UI (ciemne tło, złota ramka —
## "złoto wyłącznie dla nagród"), stąd rysowany jako blok, nie goły tekst.
func _draw_relic_card() -> void:
	if _relic_card_id == "" or hide_all or _overlay_active:
		return
	var texture: Texture2D = RELIC_ICONS.get(_relic_card_id)
	if texture == null:
		return
	var title: String = String(RELIC_NAMES.get(_relic_card_id, _relic_card_id)).to_upper()
	var description: String = RELIC_DESCRIPTIONS.get(_relic_card_id, "")
	var font := ThemeDB.fallback_font
	var title_font_size := 20
	var desc_font_size := 15
	var icon_size := 56.0

	var title_size := font.get_string_size(title, HORIZONTAL_ALIGNMENT_CENTER, -1, title_font_size)
	var desc_size := font.get_string_size(description, HORIZONTAL_ALIGNMENT_CENTER, -1, desc_font_size)
	var content_width: float = max(icon_size, max(title_size.x, desc_size.x))
	var card_width: float = content_width + 48.0
	var card_height := 16.0 + icon_size + 10.0 + title_size.y + 8.0 + desc_size.y + 16.0

	var center_x := size.x * 0.5
	var card_top := size.y * 0.78
	var card_rect := Rect2(center_x - card_width * 0.5, card_top, card_width, card_height)
	draw_rect(card_rect, RELIC_CARD_BG, true)
	draw_rect(card_rect, RELIC_CARD_BORDER, false, 1.5)

	var icon_pos := Vector2(center_x - icon_size * 0.5, card_top + 16.0)
	draw_texture_rect(texture, Rect2(icon_pos, Vector2(icon_size, icon_size)), false)

	var title_pos := Vector2(center_x - title_size.x * 0.5, icon_pos.y + icon_size + 10.0 + title_size.y * 0.75)
	draw_string(font, title_pos, title, HORIZONTAL_ALIGNMENT_LEFT, -1, title_font_size, RELIC_CARD_BORDER)

	var desc_pos := Vector2(center_x - desc_size.x * 0.5, title_pos.y + 8.0 + desc_size.y * 0.75)
	draw_string(font, desc_pos, description, HORIZONTAL_ALIGNMENT_LEFT, -1, desc_font_size, Palette.HIT_FLASH)

func _draw_overlay() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color(Palette.BACKGROUND, 0.85), true)
	var font := ThemeDB.fallback_font
	var lines := _overlay_text.split("\n")
	# Długie podsumowanie próby (Paczka 9): tytuł duży, reszta mniejsza, żeby
	# kilkanaście linii mieściło się w oknie 720 px.
	var body_size := overlay_font_size if lines.size() <= 8 else 17
	var line_height := body_size * 1.45
	var start_y := size.y * 0.5 - (lines.size() - 1) * line_height * 0.5
	for i in range(lines.size()):
		var line: String = lines[i]
		var fs := overlay_font_size + 6 if i == 0 and lines.size() > 8 else body_size
		var text_size := font.get_string_size(line, HORIZONTAL_ALIGNMENT_CENTER, -1, fs)
		var pos := Vector2((size.x - text_size.x) * 0.5, start_y + i * line_height)
		var color := MINIMAP_GOAL_COLOR if line.begins_with("Następnym razem") else Palette.PLAYER_BODY
		draw_string(font, pos, line, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, color)
