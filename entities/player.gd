extends CharacterBody2D
class_name Player
## Gracz (sekcja 3). Ruch i dash trzymane są w prostym enumie stanu; atak (miecz
## lub różdżka) jest CELOWO niezależny od stanu ruchu — na życzenie autora da się
## machnąć/strzelić w dowolnym momencie dasha, więc trzyma się osobno przez
## _attack_phase i leci równolegle, niezależnie od tego, czy gracz właśnie dashuje.
## Broń (miecz/różdżka), blok i leczenie to dodatki na życzenie autora, poza dokumentem.

signal died
## Komunikaty w walce, krok 8 (TERAZ_DLA_CLAUDE_ARENA_UI_I_FEELING.md /
## PLAN_UI_UX_NAGRODY_DLA_CLAUDE.md): "błąd/brak zasobu — przy odpowiednim
## pasku HUD". Player nie zna ui.gd (osobna scena/warstwa) — arena.gd/room.gd
## łączą to z GameUI.flash_resource_denied(). `kind` to "stamina"/"mana"/"heal",
## dopasowane do tego, KTÓRY pasek/ikonę podświetlić. Dash pominięty — jego
## odmowa ma trzy różne przyczyny (cooldown/void-lock/stamina) zlane w jeden
## dźwięk, więc podświetlanie paska staminy byłoby czasem po prostu błędne.
signal resource_denied(kind: String)
signal skill_choice_ready
## Wynik zetknięcia ciosu z tarczą: "blocked" / "perfect" / "broken" /
## "direction" (cios z tyłu) / "unblockable" (strefa pod nogami).
signal block_feedback(kind: String)

enum State { NORMAL, DASHING, DEAD }

const ProjectileScene := preload("res://entities/projectile.tscn")
const SkillCatalog := preload("res://entities/skill_catalog.gd")
const SkillProcs := preload("res://entities/skill_procs.gd")
const VFX_FOLLOWUP := preload("res://assets/sprites/vfx/skills_preproduction/vfx_followup_slash.png")
const VFX_BLOOM := preload("res://assets/sprites/vfx/skills_preproduction/vfx_void_bloom.png")
const VFX_DASH_RING := preload("res://assets/sprites/vfx/skills_preproduction/vfx_dash_ring.png")
const VFX_SPLIT := preload("res://assets/sprites/vfx/skills_preproduction/vfx_split_shard.png")
const VFX_SECOND_BREATH := preload("res://assets/sprites/vfx/skills_preproduction/vfx_second_breath.png")

# --- Sprite'y (zamiast dawnego _draw()) ---
const TEX_BASE := preload("res://assets/sprites/gracz/player_base.png")
const TEX_WALK := preload("res://assets/sprites/gracz/player_walk.png")
const TEX_WALK_BACK := preload("res://assets/sprites/gracz/player_walk_back.png")
const TEX_WALK_SIDE := preload("res://assets/sprites/gracz/player_walk_side.png")
const TEX_WALK_FRONT_STRIDE := preload("res://assets/sprites/gracz/player_walk_front_stride.png")
const TEX_WALK_FRONT_DIAGONAL := preload("res://assets/sprites/gracz/player_walk_front_diagonal_neutral.png")
const TEX_WALK_FRONT_DIAGONAL_STRIDE := preload("res://assets/sprites/gracz/player_walk_front_diagonal_stride.png")
const TEX_WALK_SIDE_STRIDE := preload("res://assets/sprites/gracz/player_walk_side_stride.png")
const TEX_WALK_BACK_DIAGONAL := preload("res://assets/sprites/gracz/player_walk_back_diagonal_neutral.png")
const TEX_WALK_BACK_DIAGONAL_STRIDE := preload("res://assets/sprites/gracz/player_walk_back_diagonal_stride.png")
const TEX_WALK_BACK_STRIDE := preload("res://assets/sprites/gracz/player_walk_back_stride.png")
# Pilotaż 360° (PLAN_ANIMACJE_KIERUNKOWE.md) — na razie tylko chód ma warianty
# kierunkowe; "front" to dawny, jedyny plik. Facing.resolve() rozstrzyga
# front/back/side (+flip_h dla lewej strony) na podstawie kierunku ruchu.
const WALK_VARIANTS := {
	"front": [TEX_WALK, TEX_WALK_FRONT_STRIDE],
	"front_diagonal": [TEX_WALK_FRONT_DIAGONAL, TEX_WALK_FRONT_DIAGONAL_STRIDE],
	"side": [TEX_WALK_SIDE, TEX_WALK_SIDE_STRIDE],
	"back_diagonal": [TEX_WALK_BACK_DIAGONAL, TEX_WALK_BACK_DIAGONAL_STRIDE],
	"back": [TEX_WALK_BACK, TEX_WALK_BACK_STRIDE],
}
const TEX_DASH := preload("res://assets/sprites/gracz/player_dash.png")
const TEX_SWORD_WINDUP := preload("res://assets/sprites/gracz/player_sword_windup.png")
const TEX_SWORD_ACTIVE := preload("res://assets/sprites/gracz/player_sword_active.png")
const TEX_WAND_WINDUP := preload("res://assets/sprites/gracz/player_wand_windup.png")
const TEX_WAND_FIRE := preload("res://assets/sprites/gracz/player_wand_fire.png")
const TEX_BLOCK := preload("res://assets/sprites/gracz/player_block.png")
const TEX_HEAL := preload("res://assets/sprites/gracz/player_heal.png")
const TEX_HIT := preload("res://assets/sprites/gracz/player_hit.png")
const TEX_DEATH := preload("res://assets/sprites/gracz/player_death.png")
const TEX_BASE_FRONT_DIAGONAL := preload("res://assets/sprites/gracz/player_base_front_diagonal.png")
const TEX_BASE_SIDE := preload("res://assets/sprites/gracz/player_base_side.png")
const TEX_BASE_BACK_DIAGONAL := preload("res://assets/sprites/gracz/player_base_back_diagonal.png")
const TEX_BASE_BACK := preload("res://assets/sprites/gracz/player_base_back.png")
const TEX_DASH_FRONT_DIAGONAL := preload("res://assets/sprites/gracz/player_dash_front_diagonal.png")
const TEX_DASH_SIDE := preload("res://assets/sprites/gracz/player_dash_side.png")
const TEX_DASH_BACK_DIAGONAL := preload("res://assets/sprites/gracz/player_dash_back_diagonal.png")
const TEX_DASH_BACK := preload("res://assets/sprites/gracz/player_dash_back.png")
const TEX_SWORD_WINDUP_FRONT_DIAGONAL := preload("res://assets/sprites/gracz/player_sword_windup_front_diagonal.png")
const TEX_SWORD_WINDUP_SIDE := preload("res://assets/sprites/gracz/player_sword_windup_side.png")
const TEX_SWORD_WINDUP_BACK_DIAGONAL := preload("res://assets/sprites/gracz/player_sword_windup_back_diagonal.png")
const TEX_SWORD_WINDUP_BACK := preload("res://assets/sprites/gracz/player_sword_windup_back.png")
const TEX_SWORD_ACTIVE_FRONT_DIAGONAL := preload("res://assets/sprites/gracz/player_sword_active_front_diagonal.png")
const TEX_SWORD_ACTIVE_SIDE := preload("res://assets/sprites/gracz/player_sword_active_side.png")
const TEX_SWORD_ACTIVE_BACK_DIAGONAL := preload("res://assets/sprites/gracz/player_sword_active_back_diagonal.png")
const TEX_SWORD_ACTIVE_BACK := preload("res://assets/sprites/gracz/player_sword_active_back.png")
const TEX_WAND_WINDUP_FRONT_DIAGONAL := preload("res://assets/sprites/gracz/player_wand_windup_front_diagonal.png")
const TEX_WAND_WINDUP_SIDE := preload("res://assets/sprites/gracz/player_wand_windup_side.png")
const TEX_WAND_WINDUP_BACK_DIAGONAL := preload("res://assets/sprites/gracz/player_wand_windup_back_diagonal.png")
const TEX_WAND_WINDUP_BACK := preload("res://assets/sprites/gracz/player_wand_windup_back.png")
const TEX_WAND_FIRE_FRONT_DIAGONAL := preload("res://assets/sprites/gracz/player_wand_fire_front_diagonal.png")
const TEX_WAND_FIRE_SIDE := preload("res://assets/sprites/gracz/player_wand_fire_side.png")
const TEX_WAND_FIRE_BACK_DIAGONAL := preload("res://assets/sprites/gracz/player_wand_fire_back_diagonal.png")
const TEX_WAND_FIRE_BACK := preload("res://assets/sprites/gracz/player_wand_fire_back.png")
const TEX_BLOCK_FRONT_DIAGONAL := preload("res://assets/sprites/gracz/player_block_front_diagonal.png")
const TEX_BLOCK_SIDE := preload("res://assets/sprites/gracz/player_block_side.png")
const TEX_BLOCK_BACK_DIAGONAL := preload("res://assets/sprites/gracz/player_block_back_diagonal.png")
const TEX_BLOCK_BACK := preload("res://assets/sprites/gracz/player_block_back.png")
const TEX_HEAL_FRONT_DIAGONAL := preload("res://assets/sprites/gracz/player_heal_front_diagonal.png")
const TEX_HEAL_SIDE := preload("res://assets/sprites/gracz/player_heal_side.png")
const TEX_HEAL_BACK_DIAGONAL := preload("res://assets/sprites/gracz/player_heal_back_diagonal.png")
const TEX_HEAL_BACK := preload("res://assets/sprites/gracz/player_heal_back.png")
const TEX_HIT_FRONT_DIAGONAL := preload("res://assets/sprites/gracz/player_hit_front_diagonal.png")
const TEX_HIT_SIDE := preload("res://assets/sprites/gracz/player_hit_side.png")
const TEX_HIT_BACK_DIAGONAL := preload("res://assets/sprites/gracz/player_hit_back_diagonal.png")
const TEX_HIT_BACK := preload("res://assets/sprites/gracz/player_hit_back.png")
const TEX_DEATH_FRONT_DIAGONAL := preload("res://assets/sprites/gracz/player_death_front_diagonal.png")
const TEX_DEATH_SIDE := preload("res://assets/sprites/gracz/player_death_side.png")
const TEX_DEATH_BACK_DIAGONAL := preload("res://assets/sprites/gracz/player_death_back_diagonal.png")
const TEX_DEATH_BACK := preload("res://assets/sprites/gracz/player_death_back.png")

# Fazy 3-5 (PLAN_ANIMACJE_KIERUNKOWE.md) — pełne 5 kątów na każdą pozę bojową,
# przechodzą przez Facing.resolve() bez dalszych zmian w _update_visuals().
const TEX_BASE_VARIANTS := {
	"front": TEX_BASE,
	"front_diagonal": TEX_BASE_FRONT_DIAGONAL,
	"side": TEX_BASE_SIDE,
	"back_diagonal": TEX_BASE_BACK_DIAGONAL,
	"back": TEX_BASE_BACK,
}
const TEX_DASH_VARIANTS := {
	"front": TEX_DASH,
	"front_diagonal": TEX_DASH_FRONT_DIAGONAL,
	"side": TEX_DASH_SIDE,
	"back_diagonal": TEX_DASH_BACK_DIAGONAL,
	"back": TEX_DASH_BACK,
}
const TEX_SWORD_WINDUP_VARIANTS := {"front": TEX_SWORD_WINDUP, "front_diagonal": TEX_SWORD_WINDUP_FRONT_DIAGONAL, "side": TEX_SWORD_WINDUP_SIDE, "back_diagonal": TEX_SWORD_WINDUP_BACK_DIAGONAL, "back": TEX_SWORD_WINDUP_BACK}
const TEX_SWORD_ACTIVE_VARIANTS := {"front": TEX_SWORD_ACTIVE, "front_diagonal": TEX_SWORD_ACTIVE_FRONT_DIAGONAL, "side": TEX_SWORD_ACTIVE_SIDE, "back_diagonal": TEX_SWORD_ACTIVE_BACK_DIAGONAL, "back": TEX_SWORD_ACTIVE_BACK}
const TEX_WAND_WINDUP_VARIANTS := {"front": TEX_WAND_WINDUP, "front_diagonal": TEX_WAND_WINDUP_FRONT_DIAGONAL, "side": TEX_WAND_WINDUP_SIDE, "back_diagonal": TEX_WAND_WINDUP_BACK_DIAGONAL, "back": TEX_WAND_WINDUP_BACK}
const TEX_WAND_FIRE_VARIANTS := {"front": TEX_WAND_FIRE, "front_diagonal": TEX_WAND_FIRE_FRONT_DIAGONAL, "side": TEX_WAND_FIRE_SIDE, "back_diagonal": TEX_WAND_FIRE_BACK_DIAGONAL, "back": TEX_WAND_FIRE_BACK}
const TEX_BLOCK_VARIANTS := {"front": TEX_BLOCK, "front_diagonal": TEX_BLOCK_FRONT_DIAGONAL, "side": TEX_BLOCK_SIDE, "back_diagonal": TEX_BLOCK_BACK_DIAGONAL, "back": TEX_BLOCK_BACK}
const TEX_HEAL_VARIANTS := {"front": TEX_HEAL, "front_diagonal": TEX_HEAL_FRONT_DIAGONAL, "side": TEX_HEAL_SIDE, "back_diagonal": TEX_HEAL_BACK_DIAGONAL, "back": TEX_HEAL_BACK}
const TEX_HIT_VARIANTS := {"front": TEX_HIT, "front_diagonal": TEX_HIT_FRONT_DIAGONAL, "side": TEX_HIT_SIDE, "back_diagonal": TEX_HIT_BACK_DIAGONAL, "back": TEX_HIT_BACK}
const TEX_DEATH_VARIANTS := {"front": TEX_DEATH, "front_diagonal": TEX_DEATH_FRONT_DIAGONAL, "side": TEX_DEATH_SIDE, "back_diagonal": TEX_DEATH_BACK_DIAGONAL, "back": TEX_DEATH_BACK}
const TEX_SLASH_ARC := preload("res://assets/sprites/ekwipunek/sword_slash_arc.png")
const TEX_WAND_CHARGE := preload("res://assets/sprites/ekwipunek/wand_charge.png")

# --- Dźwięki ---
const SND_DASH_START := preload("res://assets/audio/sfx/gracz/P01_dash_start.wav")
const SND_DASH_DENIED := preload("res://assets/audio/sfx/gracz/P02_dash_denied.wav")
const SND_DASH_VOID_LOCKED := preload("res://assets/audio/sfx/gracz/P03_dash_void_locked.wav")
const SND_WEAPON_SWITCH := preload("res://assets/audio/sfx/gracz/P04_weapon_switch.wav")
const SND_ATTACK_DENIED := preload("res://assets/audio/sfx/gracz/P05_attack_denied.wav")
const SND_SWORD_SWING := preload("res://assets/audio/sfx/gracz/P07_sword_swing.wav")
const SND_SWORD_HIT := preload("res://assets/audio/sfx/gracz/P08_sword_hit.wav")
const SND_SWORD_MISS := preload("res://assets/audio/sfx/gracz/P09_sword_miss.wav")
const SND_WAND_CHARGE := preload("res://assets/audio/sfx/gracz/P10_wand_charge.wav")
const SND_WAND_FIRE := preload("res://assets/audio/sfx/gracz/P11_wand_fire.wav")
const SND_BLOCK_RAISE := preload("res://assets/audio/sfx/gracz/P13_block_raise.wav")
const SND_BLOCK_PUSH_HIT := preload("res://assets/audio/sfx/gracz/P14_block_push_hit.wav")
const GUARD_BREAK_PITCH := 0.55

## Audyt nagrania 24.09 (P0.1): czytelność sylwetki. Stały, subtelny obrys
## (ciemna postać na ciemnej podłodze) i mocniejszy obrys + rozjaśnienie przy
## nakładaniu na dużego wroga — zamiast dawnego pełnego turkusowego dysku,
## który zasłaniał samego gracza.
const OUTLINE_SHADER := preload("res://entities/player_outline.gdshader")
const OUTLINE_BASE := 0.35
const OUTLINE_OVERLAP := 0.9
const LIFT_OVERLAP := 0.35
const OVERLAP_BLEND_SPEED := 6.0 ## 1/s — wejście/wyjście z nakładania bez migotania
var _outline_material := ShaderMaterial.new()
var _overlap_blend: float = 0.0
const SND_HEAL_USE := preload("res://assets/audio/sfx/gracz/P16_heal_use.wav")
const SND_HEAL_CHARGE_TICK := preload("res://assets/audio/sfx/gracz/P18_heal_charge_tick.wav")
const SND_HEAL_READY := preload("res://assets/audio/sfx/gracz/P19_heal_ready.wav")
const SND_KNOCKBACK := preload("res://assets/audio/sfx/gracz/P22_player_knockback.wav")
# P20/P21 (ból/śmierć gracza) — dogenerowane w paczce P0 (wrzesień 2026).
const SND_HURT := [
	preload("res://assets/audio/sfx/p0/PLAYER_HURT_1.wav"),
	preload("res://assets/audio/sfx/p0/PLAYER_HURT_2.wav"),
	preload("res://assets/audio/sfx/p0/PLAYER_HURT_3.wav"),
]
const SND_DEATH := preload("res://assets/audio/sfx/p0/PLAYER_DEATH.wav")
const SND_SKILL_TWIN := preload("res://assets/audio/sfx/gracz/P08_sword_hit.wav")
const SND_SKILL_SPLIT := preload("res://assets/audio/sfx/gracz/P11_wand_fire.wav")
const SND_SKILL_VOID := preload("res://assets/audio/sfx/gracz/P12_wand_impact.wav")

@onready var sprite: Sprite2D = $Sprite
@onready var slash_arc: Sprite2D = $SlashArc
var _wide_slash_left: Sprite2D
var _wide_slash_right: Sprite2D
@onready var wand_charge_sprite: Sprite2D = $WandCharge
@onready var sfx: AudioStreamPlayer2D = $Sfx

# --- Ruch --- (max_speed to teraz WARTOŚĆ BAZOWA, patrz sekcja "Poziom i
# punkty statystyk" niżej — efektywny max_speed liczy _recompute_effective_stats())
@export var base_max_speed: float = 300.0 ## px/s, maksymalna prędkość biegu przed bonusem z punktów
var max_speed: float ## efektywna wartość — base_max_speed * (1 + punkty*speed_bonus_per_point)
@export var acceleration: float = 2600.0 ## px/s^2, jak szybko gracz rozpędza się do max_speed
@export var friction: float = 2500.0 ## px/s^2, jak szybko gracz hamuje bez wejścia
@export var radius: float = 14.0 ## px, promień koła gracza (też kolizji)

## Cykl chodu (PLAN_ANIMACJE_KIERUNKOWE.md, Faza 1b) — tempo stawiania kroków
## rośnie z prędkością, zamiast zawsze tej samej zamrożonej pozy "w rozkroku".
## Nieaktywne wizualnie, dopóki WALK_VARIANTS nie dostanie tablic [neutral,
## stride] zamiast pojedynczych tekstur (patrz Facing.resolve()) — bezpieczne
## do wdrożenia już teraz, bo nic się nie zmienia bez tej grafiki.
@export var walk_cycle_speed: float = 6.0 ## pełnych cykli/s przy pełnej max_speed
var _walk_cycle_phase: float = 0.0

# --- Wygląd (dostrojenie sprite'ów wobec oryginalnych plików 1024-1254px) ---
@export var sprite_scale: float = 0.10 ## postać gracza — powiększona z 0.08 (KIERUNEK_WIZUALNY_REFERENCJE.md: gracz musi być czytelniejszy/większy od tła i wrogów)
@export var slash_arc_scale: float = 0.09 ## wycinek ataku mieczem
@export var wand_charge_scale: float = 0.05 ## kula ładowania różdżki

# --- Dash ---
@export var input_buffer_window: float = 0.12 ## s, jak długo pamiętane jest wcześniejsze naciśnięcie dash/atak, żeby odpaliło się automatycznie w momencie, gdy znów będzie można (cooldown/zamach się kończy) — tylko dash i atak mają fazę/cooldown, którego wyścig z czasem naciśnięcia da się realnie wyczuć; blok/leczenie są ograniczone wyłącznie zasobem (stamina/stack), który nie zmienia się w tak krótkim oknie, więc bufor nic by im nie dał
@export var dash_speed: float = 900.0 ## px/s, prędkość w trakcie dasha
@export var dash_duration: float = 0.18 ## s, jak długo trwa dash
@export var dash_cooldown: float = 0.6 ## s, odnowienie dasha (mnożone x2 w fazie Zwłoka)
@export var dash_trail_count: int = 5 ## liczba zanikających kopii śladu na jeden dash
@export var dash_trail_lifetime: float = 0.25 ## s, jak długo blaknie pojedyncza kopia śladu

# --- Atak ---
@export var attack_windup: float = 0.08 ## s, zamach przed trafieniem (telegraf)
@export var attack_active: float = 0.10 ## s, okno, w którym atak faktycznie trafia
@export var attack_recovery: float = 0.22 ## s, bezwładność po ataku
@export var base_attack_range: float = 70.0 ## px, zasięg wycinka koła ataku przed bonusem z Razor Wind
var attack_range: float ## efektywna wartość — base_attack_range * (1 + Razor Wind), patrz _recompute_effective_stats()
@export var attack_angle_degrees: float = 100.0 ## stopnie, szerokość wycinka ataku
@export var base_attack_damage: float = 10.0 ## obrażenia zadawane trafionemu celowi, przed bonusem z punktów "atak"
var attack_damage: float ## efektywna wartość — base_attack_damage * (1 + punkty*damage_bonus_per_point)
@export var attack_move_speed_fraction: float = 0.75 ## ułamek max_speed w trakcie ataku — spowolnienie, nie zatrzymanie

# --- Różdżka (broń 2, atak na dystans) ---
@export var wand_windup: float = 0.10 ## s, zamach przed strzałem (telegraf)
@export var wand_active: float = 0.06 ## s, moment wystrzału pocisku
@export var wand_recovery: float = 0.30 ## s, bezwładność po strzale
@export var base_wand_damage: float = 8.0 ## obrażenia zadawane przez trafiony pocisk, przed bonusem z punktów "atak"
var wand_damage: float ## efektywna wartość — base_wand_damage * (1 + punkty*damage_bonus_per_point)
@export var wand_projectile_speed: float = 600.0 ## px/s, prędkość lotu pocisku
@export var wand_projectile_lifetime: float = 1.0 ## s, po tylu sekundach pocisk znika sam

# --- Życie ---
@export var base_max_health: float = 100.0 ## przed bonusem z punktów "życie"
var max_health: float ## efektywna wartość — base_max_health + punkty*health_per_point
@export var damage_invulnerability: float = 0.5 ## s nietykalności po otrzymaniu obrażeń

# --- Stamina (miecz + dash) i mana (różdżka) — dodane na życzenie autora, poza dokumentem ---
@export var base_max_stamina: float = 100.0 ## przed bonusem z punktów "stamina"
var max_stamina: float ## efektywna wartość — base_max_stamina + punkty*stamina_per_point
@export var base_stamina_regen_rate: float = 30.0 ## /s, przed bonusem z punktów "regeneracja staminy"
var stamina_regen_rate: float ## efektywna wartość — base_stamina_regen_rate * (1 + punkty*stamina_regen_bonus_per_point)
@export var sword_stamina_cost: float = 20.0
@export var dash_stamina_cost: float = 25.0
@export var base_max_mana: float = 100.0 ## przed bonusem z punktów "mana"
var max_mana: float ## efektywna wartość — base_max_mana + punkty*mana_per_point
@export var wand_mana_cost: float = 25.0
@export var mana_regen_per_hit: float = 15.0 ## w walce mana wraca wyłącznie za pierwotne trafienia wroga
@export var mana_out_of_combat_regen: float = 10.0 ## /s, TYLKO gdy w pokoju nie ma żywych wrogów (bez nieskończonego ostrzału w walce)
## Paczka 4: awaryjne dno many W WALCE — /s, i tylko dopóki mana < koszt
## jednego strzału. Czysty mag nie utyka na zawsze (AUDYT pkt 3 paczki 2),
## ale pełne tempo ognia nadal wymaga trafień (+15) lub przeplotu z mieczem.
@export var mana_combat_floor_regen: float = 5.0
var _combat_check_timer: float = 0.0
var _out_of_combat: bool = false

# --- Poziom postaci i punkty statystyk (na życzenie autora, poza dokumentem) ---
# 1 XP za KAŻDE pokonanie przeciwnika (patrz gain_xp(), wołane z room.gd/arena.gd),
# co xp_per_level XP daje +1 level, płasko (nie rosnąco), aż do max_level — 30
# pokoi ÷ 10 poziomów = dokładnie 3, więc level 10 wypada tuż przed ołtarzem
# przy normalnym tempie gry. Każdy level = 1 punkt do wydania w jedną z 6 statystyk
# (ui/stats_screen.gd, klawisz Tab).
@export var max_level: int = 10
@export var xp_per_level: float = 3.0 ## wartość zapasowa; wymagania poziomu liczy xp_required_for_next_level()
@export var health_per_point: float = 10.0
@export var stamina_per_point: float = 10.0
@export var mana_per_point: float = 10.0
@export var damage_bonus_per_point: float = 0.10 ## +10% do obrażeń miecza I różdżki za punkt
@export var speed_bonus_per_point: float = 0.05 ## +5% do max_speed za punkt
@export var stamina_regen_bonus_per_point: float = 0.10 ## +10% do regeneracji staminy za punkt

const STAT_KEYS: Array[String] = ["health", "stamina", "mana", "damage", "speed", "stamina_regen"]
const STAT_LABELS := {
	"health": "Życie",
	"stamina": "Stamina",
	"mana": "Mana",
	"damage": "Atak",
	"speed": "Szybkość poruszania się",
	"stamina_regen": "Regeneracja staminy",
}

var level: int = 0
var xp: float = 0.0
var unspent_stat_points: int = 0
var stat_points: Dictionary = {"health": 0, "stamina": 0, "mana": 0, "damage": 0, "speed": 0, "stamina_regen": 0}
var skill_ranks: Dictionary = {}
var pending_skill_choices: int = 0
var skill_offers: Array[String] = []
var _dash_ring_cooldown: float = 0.0
var _second_breath_used: bool = false
var _second_breath_scope: String = ""

func enter_breath_scope(scope: String) -> void:
	if _second_breath_scope != scope:
		_second_breath_used = false
		_second_breath_scope = scope
var _volley_serial: int = 0
var _volley_damage: Dictionary = {}
var _attack_serial: int = 0
var _bonus_damage: Dictionary = {}
var _confirmed_primary_hits: Dictionary = {}
var _skill_procs
var _weave_ready_weapon: String = ""
var _weave_timer: float = 0.0
var _shield_up: bool = false
var _shield_time: float = 0.0 ## s od podniesienia tarczy (okno idealnego bloku)
var _shield_dir: Vector2 = Vector2.DOWN
var _shield_down_time: float = 1.0 ## s od opuszczenia tarczy (blokada klepania parowania)
var _parry_ready: bool = true
var _stamina_regen_delay_timer: float = 0.0

# --- Blok (prawy przycisk myszy) — dodane na życzenie autora, poza dokumentem ---
# Trzymana tarcza (AUDYT, sekcja C) zamiast dawnego impulsu za 75% staminy
# z odepchnięciem 360°. Podniesienie nic nie kosztuje; płaci się za każdy
# przyjęty cios. Za mało staminy = przełamanie gardy (pełne obrażenia).
@export var shield_arc_degrees: float = 140.0 ## przedni łuk osłony; od tyłu brak obrony
@export var shield_move_multiplier: float = 0.7 ## prędkość ruchu z podniesioną tarczą
@export var shield_block_cost_base: float = 12.0
@export var shield_block_cost_per_damage: float = 0.9 ## koszt = clamp(base + x * surowe obrażenia, min, max)
@export var shield_block_cost_min: float = 20.0
@export var shield_block_cost_max: float = 45.0
@export var perfect_block_window: float = 0.15 ## s od podniesienia tarczy = okno parowania
@export var parry_cost_multiplier: float = 0.0 ## parowanie nie kosztuje staminy (decyzja autora)
@export var shield_reraise_lockout: float = 0.3 ## s z opuszczoną tarczą, zanim ponowne podniesienie znów daje okno parowania
@export var shield_block_invuln: float = 0.25 ## s po przyjętym ciosie — kontakt nie drenuje staminy co klatkę
@export var stamina_regen_delay: float = 0.5 ## s od ostatniego wydatku staminy do startu regeneracji
@export var block_visual_duration: float = 0.15 ## s błysku pozy po przyjętym ciosie
@export var counter_window: float = 1.0 ## s po udanym bloku na wzmocniony pierwotny cios (E1)
@export var counter_bonus: float = 0.25 ## +25% do JEDNEGO pierwotnego trafienia w oknie kontry
const SHIELD_ARC_COLOR := Color("#C9D6E3")
var _counter_timer: float = 0.0
var last_hit_source: String = "" ## kto zadał ostatnie obrażenia (Paczka 9: ekran śmierci, Kronika)
var slow_zones: Array[Rect2] = [] ## płycizna zalanej katakumby (room.gd, Paczka 5)
var _counter_hit_target: Node = null ## cel ciosu z okna kontry — do podwójnej postawy
var _guard_break_flash: float = 0.0 ## s czerwonego łuku po przełamaniu gardy

# --- Leczenie (E) — dodane na życzenie autora, poza dokumentem. System
# "stacków": trafienia ładują pasek co heal_hits_per_stack aż do max_heal_stacks
# ładunków w banku naraz — E zużywa JEDEN stack na naciśnięcie, więc gracz sam
# decyduje, czy leczy się od razu, czy odkłada zapas na później. ---
# Wariant C (AUDYT_I_PLAN_ROZBUDOWY_GRY_DLA_CLAUDE.md) zamiast dawnego
# 50% / 10 trafień / 3 zapasy natychmiast — to niwelowało całe ryzyko finału.
@export var heal_hits_per_stack: int = 12 ## ile pierwotnych trafień wroga ładuje jeden stack leczenia
@export var max_heal_stacks: int = 2 ## ile stacków leczenia można nabankować naraz
@export var heal_amount_fraction: float = 0.3 ## ułamek MAX zdrowia odzyskiwany JEDNYM stackiem
@export var heal_channel_time: float = 0.55 ## s użycia; trafienie przerywa, stack znika dopiero po udanym leczeniu
@export var heal_visual_duration: float = 0.4 ## s, jak długo pokazuje się poza leczenia

# --- Odepchnięcie (dodane na życzenie autora) ---
@export var knockback_recovery_duration: float = 0.15 ## s, jak długo po odepchnięciu nie steruje się ruchem

# --- Ulepszenia ze skrzyń (CLAUDE_CODE_GAME_CONTENT_BIBLE.md sekcja 8) ---
# Wszystkie 10 jest nie-stackowalnych (dokument) — każde zaczepione o JUŻ
# istniejący hak (register_hit_on_enemy, gain_xp, take_damage, _start_attack/
# _process_attack_phase, _process_dash, apply_knockback) zamiast osobnego
# systemu zdarzeń/rejestru, bo nic takiego nie istnieje gdzie indziej w tym
# projekcie — leveling/stacki leczenia też mieszkają wprost na Playerze.
const UPGRADE_IDS: Array[String] = [
	"blood_edge", "void_step", "soul_echo", "iron_heart", "razor_wind",
	"hunters_mark", "second_impact", "momentum", "last_resolve", "soul_bond",
]
const UPGRADE_LABELS := {
	"blood_edge": "Blood Edge",
	"void_step": "Void Step",
	"soul_echo": "Soul Echo",
	"iron_heart": "Iron Heart",
	"razor_wind": "Razor Wind",
	"hunters_mark": "Hunter's Mark",
	"second_impact": "Second Impact",
	"momentum": "Momentum",
	"last_resolve": "Last Resolve",
	"soul_bond": "Soul Bond",
}
var owned_upgrades: Array[String] = []

@export var blood_edge_bonus: float = 0.20 ## +20% obrażeń na zamach zbrojony przez poprzednie trafienie
@export var blood_edge_arm_duration: float = 4.0 ## s, jak długo uzbrojenie czeka na zużycie
var _blood_edge_armed: bool = false
var _blood_edge_timer: float = 0.0

@export var void_step_speed_bonus: float = 0.15 ## +15% prędkości biegu po dashu
@export var void_step_speed_duration: float = 1.25
@export var void_step_range_bonus: float = 0.20 ## +20% zasięgu na najbliższy zamach po dashu
@export var void_step_range_duration: float = 3.0
@export var void_step_cooldown: float = 2.0 ## s, od zakończenia dasha do kolejnego naładowania Void Step
var _void_step_speed_timer: float = 0.0
var _void_step_range_timer: float = 0.0
var _void_step_cooldown_timer: float = 0.0

@export var soul_echo_proc_chance: float = 0.25 ## szansa na +damage po zabójstwie
@export var soul_echo_bonus: float = 0.15
@export var soul_echo_duration: float = 4.0
var _soul_echo_timer: float = 0.0

@export var iron_heart_health_bonus: float = 0.20 ## +20% max zdrowia, trwałe po zdobyciu
@export var iron_heart_knockback_reduction: float = 0.25 ## -25% odepchnięcia OTRZYMYWANEGO

@export var razor_wind_range_bonus: float = 0.18 ## +18% zasięgu ataku, trwałe po zdobyciu

@export var hunters_mark_duration: float = 5.0 ## s, jak długo znak trzyma się na celu
@export var hunters_mark_bonus: float = 0.12 ## +12% obrażeń w kolejne trafienia OZNACZONEGO celu
var _marked_target: Node = null
var _marked_until_msec: int = 0 ## Time.get_ticks_msec(), niezależne od Engine.time_scale/hitstopu

@export var second_impact_chance: float = 0.30 ## szansa na opóźnione drugie trafienie
@export var second_impact_delay: float = 0.14 ## s, opóźnienie drugiego trafienia — w oknie 0,08-0,16s (audyt, TERAZ_DLA_CLAUDE_ARENA_UI_I_FEELING.md), było 0.22 (za wolno, żeby czytać się jako COMBO a nie osobny, przypadkowy proc)
@export var second_impact_damage_fraction: float = 0.45 ## ułamek obrażeń PIERWSZEGO trafienia
@export var second_impact_knockback_strength: float = 250.0 ## px/s, odepchnięcie celu drugim trafieniem
@export var second_impact_global_cooldown: float = 0.35 ## s, minimalny odstęp między kolejnymi procami
var _second_impact_cooldown_timer: float = 0.0

## Audyt Second Impact: dokument wymaga widocznego licznika aktywacji na karcie
## relikwii/w Księdze Runu ("Aktywacje w tym runie: 12") — generyczny słownik
## zamiast osobnej zmiennej per relikwia, bo Ołtarz/Księga Runu (kolejne kroki
## tego samego audytu) będą potrzebować tego dla KAŻDEJ relikwii, nie tylko tej.
var relic_activation_counts: Dictionary = {}

func _record_relic_activation(upgrade_id: String) -> void:
	relic_activation_counts[upgrade_id] = relic_activation_counts.get(upgrade_id, 0) + 1

@export var momentum_stack_interval: float = 2.0 ## s bez obrażeń na jeden stack
@export var momentum_speed_per_stack: float = 0.02 ## +2% prędkości za stack
@export var momentum_max_stacks: int = 5
var _momentum_stacks: int = 0
var _momentum_timer: float = 0.0

@export var last_resolve_threshold: float = 0.30 ## aktywacja przy HP <= 30% max
@export var last_resolve_hysteresis: float = 0.35 ## dezaktywacja dopiero powyżej 35% max
@export var last_resolve_damage_bonus: float = 0.20
@export var last_resolve_attack_speed_bonus: float = 0.10
var _last_resolve_active: bool = false

## Soul Bond (dokument): każda z 6 dusz daje inny, tematyczny bonus na
## soul_bond_duration sekund od chwili PODNIESIENIA (nie samego pokonania
## wcielenia) — indeksowane "chapter" tak jak GameFlow.INCARNATION_NAMES
## (0=Vhar'Nokh/Motion .. 5=Orryx/Sovereignty, przypisanie kolejności własne,
## poza dokumentem, bo zachowujemy istniejące wcielenia zamiast bossów z dokumentu).
const SOUL_BOND_EFFECTS: Array[Dictionary] = [
	{"move": 0.12},
	{"knockback_dealt": 0.15},
	{"attack_speed": 0.10},
	{"dash_cooldown": -0.20},
	{"damage": 0.15},
	{"move": 0.06, "damage": 0.06, "attack_speed": 0.06},
]
@export var soul_bond_duration: float = 8.0
var _soul_bond_timer: float = 0.0
var _soul_bond_effect: Dictionary = {}

## Ustalane raz na cały zamach w _start_attack() (Blood Edge/Last
## Resolve/Soul Echo/Soul Bond nie mogą się różnić trafienie-do-trafienia w
## OBRĘBIE jednego zamachu miecza, patrz dokument: "consume once per attack
## ID, not per target") — _check_attack_hits()/projectile.gd czytają je zamiast
## attack_damage/attack_range wprost.
var _current_attack_damage: float = 0.0
var _current_attack_range: float = 0.0

var stamina: float
var mana: float
var _heal_charge_hits: int = 0 ## postęp w stronę NASTĘPNEGO stacka (0..heal_hits_per_stack-1)
var _heal_stacks: int = 0 ## ile stacków jest już gotowych do zużycia (0..max_heal_stacks)
var _heal_channel_timer: float = 0.0
var _heal_visual_timer: float = 0.0
var _knockback_timer: float = 0.0

var health: float
var state: State = State.NORMAL

var _dash_cooldown_timer: float = 0.0
var _void_dash_lock_timer: float = 0.0 ## ustawiane z zewnątrz przez Ząb Zera
var _dash_timer: float = 0.0
var _buffered_dash_timer: float = 0.0
var _buffered_attack_timer: float = 0.0
var _dash_direction: Vector2 = Vector2.DOWN
var _last_move_direction: Vector2 = Vector2.DOWN

var current_weapon: String = "sword" ## "sword" albo "wand" — przełączane klawiszami 1/2
var _swing_weapon: String = "sword" ## broń "zamrożona" na czas trwającego zamachu

var _attack_phase: String = ""
var _attack_timer: float = 0.0
var _attack_direction: Vector2 = Vector2.RIGHT
var _attack_hit_targets: Array = []

var _invuln_timer: float = 0.0 ## nietykalność po obrażeniach (miganie)
var _flash_frames: int = 0 ## błysk trafienia — ile klatek jeszcze pokazywać poze trafienia
var _block_visual_timer: float = 0.0

var _trail_spawn_timer: float = 0.0

# Faza Ciężar: stałe przyciąganie w stronę bossa. Ustawiane z zewnątrz (arena/boss),
# gracz sam sobie dolicza to do prędkości, żeby zostać jedynym właścicielem `velocity`.
var pull_source: Node2D = null
var pull_strength: float = 0.0

# Faza finałowa, reguła siódma: wektor wejścia obrócony o 90 stopni.
var input_reversed: bool = false

func _ready() -> void:
	# A7 (AUDYT): gracz rysowany nad wrogami — duży sprite bossa nie może go
	# zasłonić. Telegrafy/VFX (z 5+) zostają nad graczem. Patrz Palette.
	z_index = 1
	_skill_procs = SkillProcs.new()
	_skill_procs.player = self
	add_child(_skill_procs)
	_recompute_effective_stats()
	health = max_health
	stamina = max_stamina
	mana = max_mana
	add_to_group("player")
	collision_layer = 2
	collision_mask = 1
	sprite.scale = Vector2(sprite_scale, sprite_scale)
	_outline_material.shader = OUTLINE_SHADER
	sprite.material = _outline_material
	var contact_shadow := ContactShadow.new()
	contact_shadow.position = Vector2(0.0, 32.0)
	contact_shadow.configure(68.0, 17.0, 0.44) # wyraźniejszy, dostrojony do powiększonego sprite_scale=0.10
	add_child(contact_shadow)
	slash_arc.scale = Vector2(slash_arc_scale, slash_arc_scale)
	slash_arc.texture = TEX_SLASH_ARC
	for side in [-1, 1]:
		var extra := Sprite2D.new()
		extra.texture = TEX_SLASH_ARC
		extra.scale = slash_arc.scale
		extra.modulate.a = 0.62
		extra.visible = false
		extra.z_index = slash_arc.z_index
		add_child(extra)
		if side < 0:
			_wide_slash_left = extra
		else:
			_wide_slash_right = extra
	wand_charge_sprite.texture = TEX_WAND_CHARGE
	_update_visuals()

func _physics_process(delta: float) -> void:
	if state == State.DEAD:
		_update_visuals()
		return

	_tick_timers(delta)
	_tick_upgrade_timers(delta)
	_dash_ring_cooldown = maxf(0.0, _dash_ring_cooldown - delta)
	_weave_timer = maxf(0.0, _weave_timer - delta)
	_stamina_regen_delay_timer = maxf(0.0, _stamina_regen_delay_timer - delta)
	_counter_timer = maxf(0.0, _counter_timer - delta)
	_guard_break_flash = maxf(0.0, _guard_break_flash - delta)
	if _shield_up:
		_shield_time += delta
	else:
		_shield_down_time += delta
	_handle_weapon_switch()
	_handle_dash_input(delta)
	if _heal_channel_timer <= 0.0:
		_handle_attack_input(delta) # niezależne od stanu ruchu — da się zacząć w trakcie dasha
	_handle_block_input()
	_handle_heal_input()
	_tick_heal_channel(delta)

	match state:
		State.DASHING:
			_process_dash(delta)
		_:
			_process_normal_movement(delta)

	if _attack_phase != "":
		_process_attack_phase(delta) # leci równolegle, niezależnie od ruchu/dasha

	_tick_stamina_regen(delta)
	_tick_out_of_combat_mana(delta)
	move_and_slide()
	_resolve_body_overlaps()
	_update_trail(delta)
	_update_walk_cycle(delta)
	_update_visuals()

## Tempo cyklu chodu rośnie z prędkością (Faza 1b) — stojąc w miejscu faza się
## nie rusza, więc _walk_cycle_frame() zamraża się na klatce, na której akurat
## gracz stanął, zamiast strzelać z powrotem do neutralnej pozy w 1 klatkę.
func _update_walk_cycle(delta: float) -> void:
	var ratio: float = clamp(velocity.length() / max_speed, 0.0, 1.0) if max_speed > 0.0 else 0.0
	if ratio > 0.05:
		_walk_cycle_phase += delta * walk_cycle_speed * ratio

func _walk_cycle_frame() -> int:
	return int(_walk_cycle_phase) % 2

func _tick_timers(delta: float) -> void:
	_dash_cooldown_timer = max(0.0, _dash_cooldown_timer - delta)
	_void_dash_lock_timer = max(0.0, _void_dash_lock_timer - delta)
	_invuln_timer = max(0.0, _invuln_timer - delta)
	_block_visual_timer = max(0.0, _block_visual_timer - delta)
	_heal_visual_timer = max(0.0, _heal_visual_timer - delta)
	if _flash_frames > 0:
		_flash_frames -= 1

## Timery/warunki wszystkich 10 ulepszeń ze skrzyń naraz — osobno od
## _tick_timers(), żeby nie mieszać "rdzenia" gracza (poza dokumentem) z tym,
## co dokument opisuje. Tanie nawet gdy żadne ulepszenie nie jest posiadane
## (same odejmowania/porównania, bez skanowania drzewa sceny).
func _tick_upgrade_timers(delta: float) -> void:
	if _blood_edge_timer > 0.0:
		_blood_edge_timer -= delta
		if _blood_edge_timer <= 0.0:
			_blood_edge_armed = false
	_void_step_speed_timer = max(0.0, _void_step_speed_timer - delta)
	_void_step_range_timer = max(0.0, _void_step_range_timer - delta)
	_void_step_cooldown_timer = max(0.0, _void_step_cooldown_timer - delta)
	_soul_echo_timer = max(0.0, _soul_echo_timer - delta)
	_second_impact_cooldown_timer = max(0.0, _second_impact_cooldown_timer - delta)
	_soul_bond_timer = max(0.0, _soul_bond_timer - delta)

	if has_upgrade("momentum") and state != State.DEAD:
		_momentum_timer += delta
		if _momentum_timer >= momentum_stack_interval:
			_momentum_timer = 0.0
			_momentum_stacks = mini(_momentum_stacks + 1, momentum_max_stacks)

	if has_upgrade("last_resolve") and max_health > 0.0:
		var ratio := health / max_health
		if _last_resolve_active and ratio > last_resolve_hysteresis:
			_last_resolve_active = false
		elif not _last_resolve_active and ratio <= last_resolve_threshold:
			_last_resolve_active = true

## Stamina regeneruje się, gdy nie dashuję i nie macham mieczem (mana NIE regeneruje
## się z czasem w ogóle — wyłącznie za trafienia, patrz register_hit_on_enemy()).
## Sprawdzane co 0,5 s, nie co klatkę — skan grupy "hittable".
func _tick_out_of_combat_mana(delta: float) -> void:
	_combat_check_timer -= delta
	if _combat_check_timer <= 0.0:
		_combat_check_timer = 0.5
		_out_of_combat = true
		for enemy in get_tree().get_nodes_in_group("hittable"):
			if enemy.get("is_dead") != true:
				_out_of_combat = false
				break
	if _out_of_combat:
		mana = minf(max_mana, mana + mana_out_of_combat_regen * delta)
	elif mana < _wand_mana_cost():
		mana = minf(_wand_mana_cost(), mana + mana_combat_floor_regen * delta)

## Trzymana tarcza i krótka przerwa po każdym wydatku (stamina_regen_delay)
## wstrzymują regenerację — blok ma kosztować, a nie zwracać się sam.
func _tick_stamina_regen(delta: float) -> void:
	var is_spending_stamina := state == State.DASHING or (_attack_phase != "" and _swing_weapon == "sword")
	if not is_spending_stamina and not _shield_up and _stamina_regen_delay_timer <= 0.0:
		stamina = min(max_stamina, stamina + stamina_regen_rate * delta)

func _is_dash_ready() -> bool:
	return _dash_cooldown_timer <= 0.0 and _void_dash_lock_timer <= 0.0 and stamina >= dash_stamina_cost

func _handle_weapon_switch() -> void:
	# Wolno przełączać w dowolnym momencie — trwający zamach i tak trzyma się
	# broni złapanej w _start_attack() przez _swing_weapon, więc się nie zepsuje.
	if Input.is_action_just_pressed("weapon_sword"):
		current_weapon = "sword"
		_play_sfx(SND_WEAPON_SWITCH)
	elif Input.is_action_just_pressed("weapon_wand"):
		current_weapon = "wand"
		_play_sfx(SND_WEAPON_SWITCH)

## Bufor wejścia (sekcja Responsywność): naciśnięcie dasha ZAWSZE od razu
## odpala "denied", jeśli w tym momencie nie jest gotowy — ale zostaje jeszcze
## przez input_buffer_window sekund "w pamięci", więc jeśli cooldown/blokada
## Zęba Zera skończy się w tym oknie, dash i tak odpali się automatycznie, bez
## potrzeby drugiego naciśnięcia w idealnym momencie.
func _handle_dash_input(delta: float) -> void:
	if Input.is_action_just_pressed("dash"):
		_buffered_dash_timer = input_buffer_window
		if state != State.DASHING and state != State.DEAD and not _is_dash_ready():
			_play_sfx(SND_DASH_VOID_LOCKED if _void_dash_lock_timer > 0.0 else SND_DASH_DENIED)
	elif _buffered_dash_timer > 0.0:
		_buffered_dash_timer -= delta

	if state == State.DASHING or state == State.DEAD or _buffered_dash_timer <= 0.0:
		return
	if not _is_dash_ready():
		return
	_buffered_dash_timer = 0.0
	# Atak NIE jest już przerywany dashem (na życzenie autora) — leci dalej
	# niezależnie, patrz _attack_phase i _process_attack_phase().
	var input_dir := _read_input_vector()
	_dash_direction = input_dir if input_dir.length() > 0.01 else _last_move_direction
	state = State.DASHING
	stamina -= dash_stamina_cost
	_stamina_regen_delay_timer = stamina_regen_delay
	_shield_up = false
	_dash_timer = dash_duration
	_dash_cooldown_timer = _effective_dash_cooldown()
	_trail_spawn_timer = 0.0
	_play_sfx(SND_DASH_START)

## Void Step (dokument): -20% cooldownu dasha, patrz Soul Bond/Dominion —
## SOUL_BOND_EFFECTS trzyma to jako wartość UJEMNĄ (mnożnik, nie procent do
## odjęcia ręcznie), więc zwykłe (1+x) działa tak samo jak przy bonusach dodatnich.
func _effective_dash_cooldown() -> float:
	var cd := dash_cooldown
	if has_upgrade("soul_bond") and _soul_bond_timer > 0.0 and _soul_bond_effect.has("dash_cooldown"):
		cd *= (1.0 + _soul_bond_effect["dash_cooldown"])
	return maxf(0.35, cd * (1.0 - 0.08 * skill_rank("guard_quickstep")))

func _process_dash(delta: float) -> void:
	_dash_timer -= delta
	velocity = _dash_direction.normalized() * dash_speed
	if _dash_timer <= 0.0:
		state = State.NORMAL
		velocity = Vector2.ZERO
		_fire_dash_ring()
		# Void Step (dokument): "on successful dash end" — dash zawsze faktycznie
		# się zaczął, żeby dotrzeć tutaj (stan DASHING wchodzi się tylko przez
		# udany start w _handle_dash_input), więc nie trzeba osobno tego sprawdzać.
		if has_upgrade("void_step") and _void_step_cooldown_timer <= 0.0:
			_void_step_speed_timer = void_step_speed_duration
			_void_step_range_timer = void_step_range_duration
			_void_step_cooldown_timer = void_step_cooldown

func _process_normal_movement(delta: float) -> void:
	if _knockback_timer > 0.0:
		# Odepchnięcie chwilowo odbiera sterowanie — prędkość tylko wytraca się
		# tarciem, żeby kopnięcie faktycznie było czuć, a nie znikało w 1 klatkę.
		_knockback_timer -= delta
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
		return

	var input_dir := _read_input_vector()
	if input_dir.length() > 0.01:
		_last_move_direction = input_dir

	var target_speed := minf(base_max_speed * 1.4, max_speed * _upgrade_speed_multiplier())
	if _attack_phase != "":
		target_speed *= attack_move_speed_fraction
	if _shield_up:
		target_speed *= shield_move_multiplier
	for z in slow_zones:
		if z.has_point(global_position):
			target_speed *= EncounterPlan.SLOW_LANE_MULTIPLIER
			break

	var target_velocity := input_dir * target_speed

	# Faza Ciężar (sekcja 7): stały "prąd" w stronę bossa. Dolicza się do docelowej
	# prędkości (nie do velocity wprost), żeby tarcie/przyspieszenie go ograniczały —
	# inaczej narastałby bez końca zamiast dawać stałe 120 px/s przyciągania.
	if pull_source != null and pull_strength > 0.0:
		var to_source: Vector2 = pull_source.global_position - global_position
		if to_source.length() > 1.0:
			target_velocity += to_source.normalized() * pull_strength

	var rate := acceleration if input_dir.length() > 0.01 else friction
	velocity = velocity.move_toward(target_velocity, rate * delta)

## Void Step (prędkość po dashu), Momentum (stacki za unikanie obrażeń) i
## Soul Bond/Motion (+ruch) mnożą się RAZEM, nie zastępują — gracz może mieć
## wszystkie trzy naraz.
func _upgrade_speed_multiplier() -> float:
	var mult := 1.0
	if has_upgrade("void_step") and _void_step_speed_timer > 0.0:
		mult *= (1.0 + void_step_speed_bonus)
	if has_upgrade("momentum"):
		mult *= (1.0 + _momentum_stacks * momentum_speed_per_stack)
	if has_upgrade("soul_bond") and _soul_bond_timer > 0.0 and _soul_bond_effect.has("move"):
		mult *= (1.0 + _soul_bond_effect["move"])
	return minf(1.4, mult * (1.0 + 0.05 * skill_rank("guard_fleetfoot")))

## Last Resolve (niskie HP) i Soul Bond/Instinct (+szybkość ataku) skracają
## czas trwania faz ataku (windup/active/recovery) — "szybszy atak" = krótsze
## fazy, stąd dzielenie, nie mnożenie, w miejscach, gdzie się to stosuje.
func _attack_speed_multiplier() -> float:
	var mult := 1.0
	if has_upgrade("last_resolve") and _last_resolve_active:
		mult *= (1.0 + last_resolve_attack_speed_bonus)
	if has_upgrade("soul_bond") and _soul_bond_timer > 0.0 and _soul_bond_effect.has("attack_speed"):
		mult *= (1.0 + _soul_bond_effect["attack_speed"])
	if _swing_weapon == "wand":
		mult *= (1.0 + 0.08 * skill_rank("wand_rapid_cast"))
	if _skill_procs != null:
		mult *= (1.0 + _skill_procs.attack_speed_bonus())
	return minf(1.8, mult)

## Soul Bond/Force (+odepchnięcie ZADAWANE) — dotyczy bloku i Second Impact;
## odepchnięcie OTRZYMYWANE (Iron Heart) jest osobne, patrz apply_knockback().
func _knockback_dealt_multiplier() -> float:
	if has_upgrade("soul_bond") and _soul_bond_timer > 0.0 and _soul_bond_effect.has("knockback_dealt"):
		return 1.0 + _soul_bond_effect["knockback_dealt"]
	return 1.0

func _can_afford_attack() -> bool:
	if current_weapon == "wand":
		return mana >= _wand_mana_cost()
	return stamina >= sword_stamina_cost

func _wand_mana_cost() -> float:
	return maxf(15.0, wand_mana_cost - 2.0 * skill_rank("wand_mana_weave"))

## Niezależne od stanu ruchu (sekcja o broni: da się atakować w dowolnym
## momencie dasha, mieczem albo różdżką) — jedyny warunek to brak trwającego
## już zamachu i śmierć. Bufor wejścia (jak w _handle_dash_input): naciśnięcie
## pod koniec recovery poprzedniego zamachu albo przy chwilowym niedoborze
## staminy/many zostaje w pamięci na input_buffer_window sekund i odpala się
## same, gdy tylko znów będzie można machnąć — bez wymogu drugiego, idealnie
## wymierzonego naciśnięcia.
func _handle_attack_input(delta: float) -> void:
	if state == State.DEAD:
		_buffered_attack_timer = 0.0
		return
	if Input.is_action_just_pressed("attack"):
		_buffered_attack_timer = input_buffer_window
		if _attack_phase == "" and not _can_afford_attack():
			_play_sfx(SND_ATTACK_DENIED)
			resource_denied.emit("mana" if current_weapon == "wand" else "stamina")
	elif _buffered_attack_timer > 0.0:
		_buffered_attack_timer -= delta

	# Przy podniesionej tarczy atak czeka w buforze — rusza po jej opuszczeniu.
	if _attack_phase != "" or _buffered_attack_timer <= 0.0 or _shield_up:
		return
	if not _can_afford_attack():
		return
	_buffered_attack_timer = 0.0
	_start_attack()

## Trzymana tarcza (PPM). Nie podnosi się w trakcie dasha, zamachu ani
## leczenia; atak wymaga jej opuszczenia (patrz _handle_attack_input), a dash
## ją zdejmuje (stan DASHING). Bez staminy na najtańszy blok tarcza nie
## wstaje — to czytelna odmowa zamiast gardy, która pęknie przy 1. ciosie.
func _handle_block_input() -> void:
	var can_hold := state == State.NORMAL and _attack_phase == "" and _heal_channel_timer <= 0.0
	if not Input.is_action_pressed("block") or not can_hold:
		_shield_up = false
		return
	if not _shield_up:
		if stamina < shield_block_cost_min:
			if Input.is_action_just_pressed("block"):
				_play_sfx(SND_ATTACK_DENIED)
				resource_denied.emit("stamina")
			return
		_shield_up = true
		_shield_time = 0.0
		# Parowanie tylko po uczciwym podniesieniu — klepanie PPM co klatkę
		# nie daje okna parowania na każdy cios.
		_parry_ready = _shield_down_time >= shield_reraise_lockout
		_shield_down_time = 0.0
		_play_sfx(SND_BLOCK_RAISE)
	var to_mouse := (debug_aim_point if debug_aim_point != Vector2.INF else get_global_mouse_position()) - global_position
	if to_mouse.length() > 1.0:
		_shield_dir = to_mouse.normalized()

func is_shield_up() -> bool:
	return _shield_up

func shield_block_cost(raw_damage: float) -> float:
	return clampf(shield_block_cost_base + shield_block_cost_per_damage * raw_damage, shield_block_cost_min, shield_block_cost_max)

func _in_shield_arc(source_position: Vector2) -> bool:
	var to_source := source_position - global_position
	if to_source.length() < 0.01:
		return true
	return rad_to_deg(absf(_shield_dir.angle_to(to_source))) <= shield_arc_degrees * 0.5

## Okno parowania: tarcza podniesiona przed chwilą (i nie wyklikana).
func is_parry_window() -> bool:
	return _shield_up and _parry_ready and _shield_time <= perfect_block_window

## true = cios zatrzymany tarczą (bez obrażeń HP). Przełamanie, zły kierunek
## i atak nieblokowalny zwracają false — obrażenia idą normalnie, ale gracz
## dostaje osobny sygnał, dlaczego blok nie zadziałał.
## Decyzja autora (23.09): zwykły blok BLOKUJE, blok w dobrym momencie PARUJE —
## nic nie kosztuje, odrzuca/przerywa napastnika (attacker.on_parried), a
## pocisk odbija z powrotem.
func _try_block(amount: float, source_position: Vector2, blockable: bool, attacker: Node = null) -> bool:
	if not _shield_up:
		return false
	if not blockable:
		_announce_block("unblockable")
		return false
	if source_position == Vector2.INF or not _in_shield_arc(source_position):
		if source_position != Vector2.INF and absf(_shield_dir.angle_to(source_position - global_position)) < deg_to_rad(115.0):
			_last_block_text = "direction_side"
			_last_block_side = true
		play_skill_sfx(SND_BLOCK_PUSH_HIT, global_position, -6.0, SLIP_PITCH)
		_announce_block("direction")
		return false
	var perfect := is_parry_window()
	var cost := shield_block_cost(amount) * (parry_cost_multiplier if perfect else 1.0)
	if stamina < cost:
		stamina = 0.0
		_stamina_regen_delay_timer = stamina_regen_delay
		_shield_up = false
		_guard_break_flash = 0.35
		# Paczka 10: przełamanie gardy ma własny, niski dźwięk (zastępczo P14 z
		# obniżoną wysokością — docelowy plik na liście brakujących assetów).
		# Osobny odtwarzacz — dźwięk bólu tuż po nim nie może go uciąć.
		play_skill_sfx(SND_BLOCK_PUSH_HIT, global_position, -2.0, GUARD_BREAK_PITCH)
		resource_denied.emit("stamina")
		_announce_block("broken")
		return false
	stamina -= cost
	_stamina_regen_delay_timer = stamina_regen_delay
	_invuln_timer = maxf(_invuln_timer, shield_block_invuln)
	_block_visual_timer = block_visual_duration
	_counter_timer = counter_window
	_play_sfx(SND_BLOCK_PUSH_HIT)
	sfx.pitch_scale = 1.35 if perfect else 1.0 # parowanie brzmi ostrzej niż zwykły blok
	if perfect and get_parent() != null:
		# Parowanie ma własny kształt: krótki, ciasny pierścień wokół gracza.
		AttackVfx.spawn(get_parent(), VFX_DASH_RING, global_position, 0.22, 150.0 / float(maxi(1, VFX_DASH_RING.get_width())))
	_announce_block("parry" if perfect else "blocked")
	if perfect:
		if is_instance_valid(attacker) and attacker.has_method("on_parried"):
			attacker.on_parried(self)
		if PactCatalog.is_bound():
			_silence_wave()
		if _skill_procs != null:
			_skill_procs.counterbrand()
	return true

## Pakt "Zwiąż ciszę" (Paczka 8): parowanie ucisza wrogów wokół gracza.
func _silence_wave() -> void:
	for target in get_tree().get_nodes_in_group("hittable"):
		if target.get("is_dead") == true or not (target is Node2D) or not target.has_method("silence"):
			continue
		if global_position.distance_to((target as Node2D).global_position) <= PactCatalog.ZWIAZ_SILENCE_RADIUS + float(target.get("radius") if target.get("radius") != null else 0.0):
			target.silence(PactCatalog.ZWIAZ_SILENCE_TIME)
	if get_parent() != null:
		AttackVfx.spawn(get_parent(), VFX_DASH_RING, global_position, 0.3, PactCatalog.ZWIAZ_SILENCE_RADIUS * 2.0 / float(maxi(1, VFX_DASH_RING.get_width())))

const BLOCK_FEEDBACK_TEXT := {
	"blocked": "Blok", "parry": "Parowanie!", "broken": "Garda przełamana",
	"direction": "Z tyłu — poza tarczą", "direction_side": "Z boku — poza tarczą", "unblockable": "Nie do zablokowania",
}
## P0.3 (audyt nagrania): ześlizgnięcie z krawędzi tarczy brzmi inaczej niż
## blok (zastępczo P14 wysoko i ciszej — docelowy plik na liście assetów).
const SLIP_PITCH := 1.9
## Punkt celowania tarczy dla botów i scen testowych (mysz w headless nie
## działa). Vector2.INF = zwykłe celowanie myszą.
var debug_aim_point: Vector2 = Vector2.INF
var _last_block_text: String = ""
var _last_block_side: bool = false

func _announce_block(kind: String) -> void:
	_last_block_kind = kind
	block_feedback.emit(kind)
	if kind in ["broken", "direction", "unblockable"]:
		Juice.duck_music(0.3) # A16: nieudany blok przebija muzykę
	if get_parent() != null:
		var color := Palette.PLAYER_BODY if kind in ["blocked", "parry"] else RECEIVED_DAMAGE_COLOR
		DamageNumber.spawn_text(get_parent(), global_position + Vector2(0.0, -95.0), BLOCK_FEEDBACK_TEXT[_last_block_text if _last_block_text != "" else kind], color)
	_last_block_text = ""

## Leczenie (E) — trafienia ładują stacki (patrz register_hit_on_enemy), E
## zużywa JEDEN stack na naciśnięcie (nie cały bank naraz) i oddaje połowę MAX
## zdrowia — można więc leczyć się od razu albo bankować do max_heal_stacks
## i rozłożyć leczenie na kilka późniejszych naciśnięć.
func _handle_heal_input() -> void:
	if state == State.DEAD:
		return
	if not Input.is_action_just_pressed("heal"):
		return
	if _heal_channel_timer > 0.0:
		return
	if _heal_stacks <= 0:
		_play_sfx(SND_ATTACK_DENIED)
		resource_denied.emit("heal")
		return
	_heal_channel_timer = heal_channel_time
	_play_sfx(SND_HEAL_CHARGE_TICK)

func is_heal_channeling() -> bool:
	return _heal_channel_timer > 0.0

func _tick_heal_channel(delta: float) -> void:
	if _heal_channel_timer <= 0.0:
		return
	_heal_channel_timer -= delta
	if _heal_channel_timer <= 0.0:
		_heal_channel_timer = 0.0
		_complete_heal()

func _interrupt_heal_channel() -> void:
	if _heal_channel_timer > 0.0:
		_heal_channel_timer = 0.0
		resource_denied.emit("heal")

func _complete_heal() -> void:
	if _heal_stacks <= 0 or state == State.DEAD:
		return
	_heal_stacks -= 1
	_heal_visual_timer = heal_visual_duration
	var health_before := health
	health = min(max_health, health + max_health * heal_amount_fraction)
	# Krok 8: "heal/odzyskanie — nad graczem, turkus/kość" — dotąd leczenie nie
	# miało ŻADNEGO wizualnego dowodu poza jaśniejącą ikonką (stan naładowania,
	# nie sam moment użycia). Reużywa DamageNumber (Second Impact, autoload/
	# juice.gd) z kolorem gracza zamiast Palette.DANGER — ten kolor jest
	# zarezerwowany dla obrażeń ZADAWANYCH, nie dla odzyskanego zdrowia.
	if get_parent() != null:
		DamageNumber.spawn(get_parent(), global_position + Vector2(0.0, -70.0), health - health_before, Palette.PLAYER_BODY)
	_play_sfx(SND_HEAL_USE)

func is_heal_ready() -> bool:
	return _heal_stacks > 0

## Postęp w stronę KOLEJNEGO stacka (0-1) — używane przez UI do przygaszania
## ikony leczenia, gdy bank jeszcze nie jest pełny (patrz ui.gd).
func heal_charge_ratio() -> float:
	return float(_heal_charge_hits) / float(heal_hits_per_stack)

## Do przenoszenia stanu gracza między pokojami (GameFlow) — patrz room.gd.
func get_heal_charge_hits() -> int:
	return _heal_charge_hits

func set_heal_charge_hits(value: int) -> void:
	_heal_charge_hits = clampi(value, 0, heal_hits_per_stack - 1)

func get_heal_stacks() -> int:
	return _heal_stacks

func set_heal_stacks(value: int) -> void:
	_heal_stacks = clampi(value, 0, max_heal_stacks)

## Wywoływane za KAŻDE pokonanie przeciwnika (room.gd/arena.gd) — 1 XP na
## zabójstwo domyślnie. Po max_level nic już nie robi (pasek levela to twardy
## sufit, nie licznik totalnych zabójstw w przebiegu).
func gain_xp(amount: float = 1.0) -> void:
	# Soul Echo (dokument): proc jest o SAMYM ZABÓJSTWIE, nie o ilości XP ani
	# o poziomie — rzucane przed twardym sufitem max_level, żeby dalej działało
	# nawet gdy XP samo w sobie już nic nie daje.
	if has_upgrade("soul_echo") and randf() < soul_echo_proc_chance:
		_soul_echo_timer = soul_echo_duration
	if level >= max_level:
		return
	xp += amount
	while level < max_level and xp >= xp_required_for_next_level():
		xp -= xp_required_for_next_level()
		level += 1
		unspent_stat_points += 2
		pending_skill_choices += 1
		skill_choice_ready.emit()
	if level >= max_level:
		xp = 0.0

## Postęp do następnego levela (0-1) — do paska w ui/stats_screen.gd. 0 na max_level.
func xp_ratio() -> float:
	return 0.0 if level >= max_level else xp / xp_required_for_next_level()

func xp_required_for_next_level() -> float:
	if level < 3:
		return 2.0
	if level < 7:
		return 3.0
	return 4.0

func skill_rank(id: String) -> int:
	return int(skill_ranks.get(id, 0))

## Paczka 6/7: oferta z ziarna próby (te same decyzje = te same karty),
## z gwarancją karty dla bieżącej broni i lekkim ukierunkowaniem intencji.
var skill_offer_count: int = 0 ## ile ofert już wylosowano w tej próbie (zapisywane)
var skill_rerolls: int = 1 ## jeden przerzut oferty na próbę (pilotaż E3)

func _offer_rng(salt: int = 0) -> RandomNumberGenerator:
	var r := RandomNumberGenerator.new()
	r.seed = hash([GameFlow.run_seed, "skill_offer", skill_offer_count, salt])
	return r

func ensure_skill_offer() -> Array[String]:
	if pending_skill_choices <= 0:
		return []
	if skill_offers.is_empty():
		skill_offers = SkillCatalog.roll_offer(skill_ranks, level, _offer_rng(), current_weapon, GameFlow.run_intent,
			skill_offer_count < SkillCatalog.INTENT_GUIDED_OFFERS)
		skill_offer_count += 1
	return skill_offers

## Odłożony wybór relikwii (decyzja autora 23.09): otwarta skrzynia oddaje
## ofertę graczowi; wybiera ją, kiedy chce (HUD pokazuje przycisk do skutku).
var pending_relic_offers: Array[String] = []

func has_pending_rewards() -> bool:
	return pending_skill_choices > 0 or unspent_stat_points > 0 or not pending_relic_offers.is_empty()

## W pokoju żyje wróg (skan co 0,5 s, ten sam co dla many poza walką).
func is_out_of_combat() -> bool:
	return _out_of_combat

func choose_relic(id: String) -> bool:
	if id not in pending_relic_offers or not acquire_upgrade(id):
		return false
	pending_relic_offers.clear()
	return true

## Jedna korekta na próbę: nowa trójka, w miarę możliwości bez obecnych kart.
func reroll_skill_offer() -> bool:
	if skill_rerolls <= 0 or pending_skill_choices <= 0:
		return false
	var previous := skill_offers.duplicate()
	skill_rerolls -= 1
	skill_offers = SkillCatalog.roll_offer(skill_ranks, level, _offer_rng(1), current_weapon, "", false, previous)
	return true

func choose_skill(id: String) -> bool:
	if pending_skill_choices <= 0 or id not in ensure_skill_offer():
		return false
	var old_max := max_health
	skill_ranks[id] = skill_rank(id) + 1
	pending_skill_choices -= 1
	skill_offers.clear()
	_recompute_effective_stats()
	if id == "guard_iron_skin":
		health = minf(max_health, health + max_health - old_max)
	return true

## Paczka 6 (A12): co da JEDEN punkt w statystyce — liczone tą samą funkcją
## (_recompute_effective_stats) co prawdziwy awans, więc ekran nie kłamie.
func stat_point_preview(stat_key: String) -> String:
	var before := _stat_snapshot()
	stat_points[stat_key] += 1
	_recompute_effective_stats()
	var after := _stat_snapshot()
	stat_points[stat_key] -= 1
	_recompute_effective_stats()
	match stat_key:
		"health": return "Maks. życie %.0f → %.0f" % [before["hp"], after["hp"]]
		"stamina": return "Maks. stamina %.0f → %.0f" % [before["st"], after["st"]]
		"mana": return "Maks. mana %.0f → %.0f  (strzał kosztuje %.0f)" % [before["mp"], after["mp"], _wand_mana_cost()]
		"damage": return "Miecz %.1f → %.1f  ·  Różdżka %.1f → %.1f" % [before["sw"], after["sw"], before["wd"], after["wd"]]
		"speed": return "Ruch %.0f → %.0f px/s" % [before["mv"], after["mv"]]
		"stamina_regen": return "Regeneracja staminy %.1f → %.1f /s" % [before["rg"], after["rg"]]
	return ""

func _stat_snapshot() -> Dictionary:
	return {"hp": max_health, "st": max_stamina, "mp": max_mana, "sw": attack_damage, "wd": wand_damage,
		"mv": minf(base_max_speed * 1.4, max_speed * _upgrade_speed_multiplier()), "rg": stamina_regen_rate}

## Wywoływane z ui/stats_screen.gd po naciśnięciu Enter na wybranej statystyce.
## Zwraca false (i nic nie robi), jeśli nie ma punktów do wydania.
func spend_stat_point(stat_key: String) -> bool:
	if unspent_stat_points <= 0 or not stat_points.has(stat_key):
		return false
	var old_max_health := max_health
	unspent_stat_points -= 1
	stat_points[stat_key] += 1
	_recompute_effective_stats()
	if stat_key == "health":
		health = minf(max_health, health + max_health - old_max_health)
	return true

## Przelicza max_health/max_stamina/max_mana/max_speed/attack_damage/wand_damage/
## stamina_regen_rate na nowo z base_* + punktów — IDEMPOTENTNE (bezpieczne
## wywołać wielokrotnie, zawsze liczy od zera z base_*, nigdy nie mnoży samo
## siebie). Musi być wołane po KAŻDEJ zmianie stat_points oraz w _ready() —
## każdy pokój tworzy NOWĄ instancję Playera (patrz room.gd), więc bez tego
## efektywne statystyki cofałyby się do bazowych przy każdym wejściu do pokoju.
func _recompute_effective_stats() -> void:
	max_health = base_max_health + stat_points["health"] * health_per_point
	if has_upgrade("iron_heart"):
		max_health *= (1.0 + iron_heart_health_bonus)
	max_health += 15.0 * skill_rank("guard_iron_skin")
	max_stamina = base_max_stamina + stat_points["stamina"] * stamina_per_point
	if PactCatalog.is_cleansed():
		max_stamina += PactCatalog.OCZYSC_STAMINA_BONUS # Pakt "Oczyść ciszę" (Paczka 8)
	max_mana = base_max_mana + stat_points["mana"] * mana_per_point
	max_speed = base_max_speed * (1.0 + stat_points["speed"] * speed_bonus_per_point)
	stamina_regen_rate = base_stamina_regen_rate * (1.0 + stat_points["stamina_regen"] * stamina_regen_bonus_per_point)
	attack_damage = base_attack_damage * (1.0 + stat_points["damage"] * damage_bonus_per_point)
	wand_damage = base_wand_damage * (1.0 + stat_points["damage"] * damage_bonus_per_point)
	attack_range = base_attack_range * (1.0 + (razor_wind_range_bonus if has_upgrade("razor_wind") else 0.0))

## Wywoływane z zewnątrz (bossa/void_zone itd.) — odpycha gracza i na chwilę
## odbiera mu sterowanie, żeby kopnięcie było wyczuwalne (patrz _process_normal_movement).
func apply_knockback(impulse: Vector2) -> void:
	var final_impulse := impulse
	if has_upgrade("iron_heart"):
		final_impulse *= (1.0 - iron_heart_knockback_reduction)
	velocity = final_impulse
	_knockback_timer = knockback_recovery_duration
	_play_sfx(SND_KNOCKBACK)

func _start_attack() -> void:
	_attack_serial += 1
	_swing_weapon = current_weapon # broń "zamrożona" na czas tego zamachu
	if _swing_weapon == "wand":
		mana -= _wand_mana_cost()
		_play_sfx(SND_WAND_CHARGE)
	else:
		stamina -= sword_stamina_cost
	_attack_phase = "windup"
	_attack_timer = (wand_windup if _swing_weapon == "wand" else attack_windup) / _attack_speed_multiplier()
	_attack_direction = (get_global_mouse_position() - global_position).normalized()
	_attack_hit_targets.clear()
	_current_attack_damage = _compute_attack_start_damage()
	_current_attack_range = attack_range
	if _swing_weapon == "sword":
		_current_attack_range *= (1.0 + 0.10 * skill_rank("blade_long_edge"))
	if has_upgrade("void_step") and _void_step_range_timer > 0.0:
		_current_attack_range *= (1.0 + void_step_range_bonus)
		_void_step_range_timer = 0.0 # zużyte, jednorazowo (dokument: "one range charge")
	_current_attack_range = minf(_current_attack_range, base_attack_range * 1.65)

## Wołane RAZ na cały zamach (nie per-cel) — Blood Edge/Last Resolve/Soul
## Echo/Soul Bond nie mogą się różnić trafienie-do-trafienia w obrębie
## JEDNEGO machnięcia mieczem (dokument: "one boosted attack snapshot").
## Hunter's Mark jest wyjątkiem: zależy od KONKRETNEGO celu, więc liczy się
## osobno w resolve_hit_damage() w chwili trafienia, nie tutaj.
func _compute_attack_start_damage() -> float:
	var base := wand_damage if _swing_weapon == "wand" else attack_damage
	if _weave_timer > 0.0 and _weave_ready_weapon == _swing_weapon and skill_rank("guard_weapon_weave") > 0:
		base *= (1.15 if skill_rank("guard_weapon_weave") == 1 else 1.25)
		_weave_timer = 0.0
		_weave_ready_weapon = ""
	if has_upgrade("last_resolve") and _last_resolve_active:
		base *= (1.0 + last_resolve_damage_bonus)
	if has_upgrade("soul_echo") and _soul_echo_timer > 0.0:
		base *= (1.0 + soul_echo_bonus)
	if has_upgrade("soul_bond") and _soul_bond_timer > 0.0 and _soul_bond_effect.has("damage"):
		base *= (1.0 + _soul_bond_effect["damage"])
	if has_upgrade("blood_edge") and _blood_edge_armed:
		base *= (1.0 + blood_edge_bonus)
		_blood_edge_armed = false # zamach, który konsumuje uzbrojenie, zużywa je JEDNORAZOWO
	return base

func arm_weapon_weave(weapon: String) -> void:
	_weave_ready_weapon = "wand" if weapon == "sword" else "sword"
	_weave_timer = 3.0

## Faza ataku (windup/active/recovery) — CELOWO osobno od ruchu/dasha, żeby dało
## się machnąć mieczem albo strzelić z różdżki w dowolnym momencie dasha.
func _process_attack_phase(delta: float) -> void:
	var is_sword := _swing_weapon == "sword"

	_attack_timer -= delta
	if _attack_timer > 0.0:
		if _attack_phase == "active" and is_sword:
			_check_attack_hits() # miecz sprawdza trafienie co klatkę, dopóki aktywny
		return

	match _attack_phase:
		"windup":
			_attack_phase = "active"
			_attack_timer = (attack_active if is_sword else wand_active) / _attack_speed_multiplier()
			if is_sword:
				_play_sfx(SND_SWORD_SWING)
				_check_attack_hits()
				_skill_procs.on_sword_active(_attack_direction, _current_attack_damage, _attack_serial)
			else:
				_fire_projectile() # różdżka strzela raz, w momencie wystrzału
				_play_sfx(SND_WAND_FIRE)
		"active":
			_attack_phase = "recovery"
			_attack_timer = (attack_recovery if is_sword else wand_recovery) / _attack_speed_multiplier()
			if is_sword and _attack_hit_targets.is_empty():
				_play_sfx(SND_SWORD_MISS)
		_:
			_attack_phase = ""

func _fire_projectile() -> void:
	_volley_serial += 1
	var volley_id := _volley_serial
	var projectile = ProjectileScene.instantiate()
	projectile.direction = _attack_direction
	projectile.damage = _current_attack_damage
	projectile.volley_id = volley_id
	projectile.volley_base_damage = _current_attack_damage
	projectile.pierce_remaining = skill_rank("wand_pierce")
	projectile.attack_id = _attack_serial
	projectile.homing_turn_rate = deg_to_rad(70.0 if skill_rank("wand_homing") == 1 else 120.0) if skill_rank("wand_homing") > 0 else 0.0
	projectile.ricochet_remaining = skill_rank("wand_ricochet")
	projectile.speed = wand_projectile_speed
	projectile.lifetime = wand_projectile_lifetime
	projectile.shooter = self # żeby pocisk mógł oddać manę za trafienie
	projectile.global_position = global_position + _attack_direction * (radius + 6.0)
	get_parent().add_child(projectile)
	var split_rank := skill_rank("wand_split_bolt")
	if split_rank > 0:
		for angle in [-18.0, 18.0]:
			var side = ProjectileScene.instantiate()
			side.direction = _attack_direction.rotated(deg_to_rad(angle))
			side.damage = _current_attack_damage * (0.50 if split_rank == 1 else 0.65)
			side.volley_id = volley_id
			side.volley_base_damage = _current_attack_damage
			side.attack_id = _attack_serial
			side.homing_turn_rate = projectile.homing_turn_rate
			side.secondary = true
			side.speed = wand_projectile_speed
			side.lifetime = wand_projectile_lifetime
			side.shooter = self
			side.global_position = global_position + side.direction * (radius + 6.0)
			get_parent().add_child(side)
		var vfx_scale := 56.0 / float(maxi(1, VFX_SPLIT.get_width()))
		AttackVfx.spawn(get_parent(), VFX_SPLIT, projectile.global_position, 0.22, vfx_scale, _attack_direction.angle())
		play_skill_sfx(SND_SKILL_SPLIT, projectile.global_position, -13.0, 0.88)
	if _volley_damage.size() > 48:
		_volley_damage.clear()
	var echo_rank := skill_rank("wand_echo_volley")
	if echo_rank > 0:
		get_tree().create_timer(0.14).timeout.connect(_fire_echo_projectile.bind(_attack_direction, _current_attack_damage * (0.55 if echo_rank == 1 else 0.70), _attack_serial))

func _fire_echo_projectile(direction: Vector2, damage: float, attack_id: int) -> void:
	if state == State.DEAD or get_parent() == null:
		return
	_volley_serial += 1
	var echo = ProjectileScene.instantiate()
	echo.secondary = true
	echo.use_split_cap = false
	echo.direction = direction
	echo.damage = damage
	echo.volley_id = _volley_serial
	echo.volley_base_damage = _current_attack_damage
	echo.attack_id = attack_id
	echo.speed = wand_projectile_speed
	echo.lifetime = wand_projectile_lifetime
	echo.shooter = self
	echo.global_position = global_position + direction * (radius + 6.0)
	get_parent().add_child(echo)
	AttackVfx.spawn(get_parent(), VFX_SPLIT, echo.global_position, 0.18, 45.0 / float(VFX_SPLIT.get_width()), direction.angle())

func cap_volley_damage(target: Node, volley_id: int, amount: float, base_damage: float) -> float:
	if skill_rank("wand_split_bolt") == 0:
		return amount
	var key := "%d:%d" % [volley_id, target.get_instance_id()]
	var dealt := float(_volley_damage.get(key, 0.0))
	var accepted := minf(amount, maxf(0.0, base_damage * 1.8 - dealt))
	_volley_damage[key] = dealt + accepted
	return accepted

## Wywoływane za KAŻDE celne trafienie wroga, niezależnie jaką bronią — jedyny
## sposób odzyskania many, a co heal_hits_per_stack-te takie trafienie dokłada
## jeden stack leczenia (do max_heal_stacks — powyżej banku trafienia nic już
## nie robią, żeby nie liczyć w nieskończoność stanu, który i tak przepadnie).
## heal_progress=false dla przyzwańców (meta "summoned", bez XP) — mana nadal
## wraca, żeby mag mógł walczyć z dodatkami, ale nie da się na nich farmić leczenia.
func register_hit_on_enemy(heal_progress: bool = true) -> void:
	mana = min(max_mana, mana + mana_regen_per_hit)
	if not heal_progress or _heal_stacks >= max_heal_stacks:
		return
	_heal_charge_hits += 1
	if _heal_charge_hits >= heal_hits_per_stack:
		_heal_charge_hits = 0
		_heal_stacks += 1
		_play_sfx(SND_HEAL_READY)
	else:
		_play_sfx(SND_HEAL_CHARGE_TICK)

# --- Ulepszenia ze skrzyń: haki trafienia (Sekcja 8) ---

func has_upgrade(id: String) -> bool:
	return id in owned_upgrades

## Wołane z rooms/chest.gd po wybraniu nagrody. Nieznane/już posiadane ID nic
## nie robi i zwraca false — wszystkie 10 jest nie-stackowalnych (dokument).
func acquire_upgrade(id: String) -> bool:
	if id not in UPGRADE_IDS or has_upgrade(id):
		return false
	owned_upgrades.append(id)
	if id == "iron_heart":
		# "add new max-health delta to current HP, not full heal" (dokument) —
		# _recompute_effective_stats() jest idempotentne, więc bezpiecznie
		# przeliczyć od razu i dolić RÓŻNICĘ, a nie leczyć do pełna.
		var old_max := max_health
		_recompute_effective_stats()
		health += (max_health - old_max)
	elif id == "razor_wind":
		_recompute_effective_stats()
	return true

## Publiczne — wołane też z projectile.gd (pocisk różdżki trafia z opóźnieniem
## po wystrzale, więc stan znaku celu do Hunter's Mark można sprawdzić dopiero
## TERAZ, nie w chwili strzału). Dolicza WYŁĄCZNIE bonus zależny od
## KONKRETNEGO celu — Blood Edge/Last Resolve/Soul Echo/Soul Bond są już
## wliczone w `base_damage` (ustalane raz na cały zamach, patrz
## _compute_attack_start_damage()).
func resolve_hit_damage(target: Node, base_damage: float) -> float:
	var damage := base_damage
	if _counter_timer > 0.0:
		# Okno kontry po udanym bloku — zużywa je jedno pierwotne trafienie.
		_counter_timer = 0.0
		_counter_hit_target = target
		damage *= 1.0 + counter_bonus
		if target is Node2D and get_parent() != null:
			DamageNumber.spawn_text(get_parent(), (target as Node2D).global_position + Vector2(0.0, -60.0), "Kontra", SHIELD_ARC_COLOR, true)
	if has_upgrade("hunters_mark"):
		return _apply_hunters_mark(target, damage)
	return damage

func has_counter_ready() -> bool:
	return _counter_timer > 0.0

## Pierwsze trafienie NIEOZNACZONEGO celu zakłada znak (bez własnego bonusu);
## kolejne trafienia w TEN SAM, wciąż oznaczony cel dostają +12%. Aktywny znak
## na INNYM celu nie przeskakuje na nowy cel, dopóki sam nie wygaśnie
## (dokument: "moves mark only if current mark expired").
func _apply_hunters_mark(target: Node, base_damage: float) -> float:
	var now := Time.get_ticks_msec()
	var mark_expired := _marked_target == null or not is_instance_valid(_marked_target) or now >= _marked_until_msec
	if not mark_expired and _marked_target == target:
		return base_damage * (1.0 + hunters_mark_bonus)
	if mark_expired:
		_marked_target = target
		_marked_until_msec = now + int(hunters_mark_duration * 1000.0)
	return base_damage

## Wspólny "po trafieniu" hak dla OBU broni — miecz woła to wprost z
## _check_attack_hits(), różdżka przez projectile.gd (bo tam faktycznie
## rejestruje się trafienie pocisku, z opóźnieniem od wystrzału). Zastępuje
## dawne bezpośrednie wywołanie register_hit_on_enemy() z obu miejsc, żeby
## Blood Edge/Second Impact też odpalały się identycznie dla obu broni.
func on_hit_confirmed(target: Node, damage_dealt: float, weapon: String = "", health_before: float = -1.0, attack_id: int = -1) -> void:
	if not is_instance_valid(target) or damage_dealt <= 0.0:
		return
	if attack_id < 0:
		attack_id = _attack_serial
	var primary_key := "%d:%d" % [attack_id, target.get_instance_id()]
	if _confirmed_primary_hits.has(primary_key):
		return # kilka pocisków tej samej salwy może zranić cel, ale nie farmi many/proców
	_confirmed_primary_hits[primary_key] = true
	if _confirmed_primary_hits.size() > 2048:
		_confirmed_primary_hits.clear()
		_confirmed_primary_hits[primary_key] = true
	register_hit_on_enemy(not target.has_meta("summoned"))
	# Postawa (prototyp E1): tylko trafienie PIERWOTNE, raz na atak i cel;
	# cios z okna kontry po bloku narusza ją podwójnie.
	if target.has_method("add_stance_damage"):
		target.add_stance_damage(damage_dealt * (2.0 if _counter_hit_target == target else 1.0))
	_counter_hit_target = null
	if _skill_procs != null and weapon != "":
		_skill_procs.on_primary_hit(target, damage_dealt, weapon, health_before, attack_id)
	if weapon == "sword" and skill_rank("blade_twin_cut") > 0:
		get_tree().create_timer(0.12).timeout.connect(_fire_twin_cut.bind(target, damage_dealt, global_position, attack_id))
	if skill_rank("void_bloom") > 0 and target.get("is_dead") == true:
		_fire_void_bloom(target.global_position, damage_dealt, target)
	if has_upgrade("blood_edge"):
		_blood_edge_armed = true
		_blood_edge_timer = blood_edge_arm_duration
	if has_upgrade("second_impact"):
		_maybe_schedule_second_impact(target, damage_dealt, attack_id)

const SECONDARY_CAP_OF_ATTACK := 2.0 ## cios + wszystkie jego bonusy <= 2x cios

func apply_skill_bonus(target: Node, requested: float, attack_id: int, base_damage: float, source: String = "skill_proc") -> void:
	if not is_instance_valid(target) or target.get("is_dead") == true or requested <= 0.0:
		return
	var amount := requested
	var key := ""
	var total := 0.0
	if attack_id >= 0:
		key = "%d:%d" % [attack_id, target.get_instance_id()]
		total = float(_bonus_damage.get(key, base_damage))
		# Paczka 4 (A2): wszystkie proce jednego zamachu na jednym celu razem
		# zadają najwyżej tyle, co sam cios (wcześniej 1,5x — połowa DPS
		# mocnego builda pochodziła z efektów wtórnych).
		amount = minf(requested, maxf(0.0, base_damage * SECONDARY_CAP_OF_ATTACK - total))
	if amount > 0.0:
		var dealt: float = Juice.apply_hit(target, amount, Juice.boss_hit_hitstop, true, source)
		if attack_id >= 0:
			_bonus_damage[key] = total + dealt
			if _bonus_damage.size() > 64:
				_bonus_damage.clear()

func _fire_twin_cut(target: Node, first_damage: float, origin: Vector2, attack_id: int = -1) -> void:
	if not is_instance_valid(target) or target.get("is_dead") == true:
		return
	var direction: Vector2 = (target.global_position - origin).normalized()
	var scale_value := 100.0 / float(maxi(1, VFX_FOLLOWUP.get_width()))
	# A6: powrotne cięcie — łuk odbity względem pierwszego, własny dźwięk i liczba bonusowa.
	AttackVfx.spawn(get_parent(), VFX_FOLLOWUP, target.global_position, 0.24, scale_value, direction.angle(), true)
	apply_skill_bonus(target, first_damage * (0.55 if skill_rank("blade_twin_cut") == 1 else 0.70), attack_id, first_damage, "twin_cut")
	play_skill_sfx(SND_SKILL_TWIN, target.global_position, -10.0, 1.10)
	if skill_rank("blade_third_cut") > 0 and target.get("is_dead") != true:
		get_tree().create_timer(0.12).timeout.connect(_fire_third_cut.bind(target, first_damage, origin, attack_id))

func _fire_third_cut(target: Node, first_damage: float, origin: Vector2, attack_id: int = -1) -> void:
	if not is_instance_valid(target) or target.get("is_dead") == true:
		return
	var direction: Vector2 = (target.global_position - origin).normalized()
	var scale_value := 85.0 / float(maxi(1, VFX_FOLLOWUP.get_width()))
	AttackVfx.spawn(get_parent(), VFX_FOLLOWUP, target.global_position, 0.20, scale_value, direction.angle())
	apply_skill_bonus(target, first_damage * 0.35, attack_id, first_damage, "third_cut")
	play_skill_sfx(SND_SKILL_TWIN, target.global_position, -14.0, 1.22)

func _fire_void_bloom(center: Vector2, primary_damage: float, killed_target: Node) -> void:
	var rank := skill_rank("void_bloom")
	var radius_value: float = [65.0, 85.0, 105.0][rank - 1]
	var damage: float = primary_damage * [0.35, 0.45, 0.55][rank - 1]
	var scale_value: float = radius_value * 2.0 / float(maxi(1, VFX_BLOOM.get_width()))
	AttackVfx.spawn(get_parent(), VFX_BLOOM, center, 0.32, scale_value)
	play_skill_sfx(SND_SKILL_VOID, center, -12.0, 0.72)
	for other in get_tree().get_nodes_in_group("hittable"):
		if other == killed_target or other.get("is_dead") == true:
			continue
		var target_radius: float = other.get("radius") if other.get("radius") != null else 0.0
		if center.distance_to(other.global_position) <= radius_value + target_radius:
			Juice.apply_hit(other, damage, 0.0, true, "void_bloom")

func _fire_dash_ring() -> void:
	var rank := skill_rank("void_dash_ring")
	if rank == 0 or _dash_ring_cooldown > 0.0:
		return
	_dash_ring_cooldown = 1.5
	var radius_value := 75.0 if rank == 1 else 95.0
	var damage := attack_damage * (0.35 if rank == 1 else 0.50)
	var scale_value := radius_value * 2.0 / float(maxi(1, VFX_DASH_RING.get_width()))
	AttackVfx.spawn(get_parent(), VFX_DASH_RING, global_position, 0.35, scale_value)
	play_skill_sfx(SND_SKILL_VOID, global_position, -14.0, 0.80)
	for target in get_tree().get_nodes_in_group("hittable"):
		if target.get("is_dead") == true:
			continue
		var target_radius: float = target.get("radius") if target.get("radius") != null else 0.0
		if global_position.distance_to(target.global_position) <= radius_value + target_radius:
			Juice.apply_hit(target, damage, 0.0, true, "dash_ring")

## 30% szansy na kolejne, opóźnione trafienie za 45% obrażeń pierwszego —
## globalny cooldown (nie per-cel) pilnuje, żeby nie odpalało się bez końca
## przy szybkich wielotrafieniowych zamachach.
func _maybe_schedule_second_impact(target: Node, base_damage: float, attack_id: int = -1) -> void:
	if _second_impact_cooldown_timer > 0.0:
		return
	if randf() >= second_impact_chance:
		return
	_second_impact_cooldown_timer = second_impact_global_cooldown
	var impact_damage := base_damage * second_impact_damage_fraction
	get_tree().create_timer(second_impact_delay).timeout.connect(
		_fire_second_impact.bind(target, impact_damage, global_position, attack_id, base_damage)
	)

## Rewaliduje cel przy odpaleniu (dokument: "revalidate target/location at
## fire") — mógł umrzeć albo zniknąć (queue_free/reset pokoju) w tym
## opóźnieniu. Nie woła on_hit_confirmed() ponownie: drugie trafienie nie może
## samo siebie/Blood Edge/Second Impact ponownie uzbroić (dokument).
##
## Audyt Second Impact (TERAZ_DLA_CLAUDE_ARENA_UI_I_FEELING.md): mechanika
## ZAWSZE działała (potwierdzone istniejącymi testami) — użytkownik nie widział
## "drugiego ciosu", bo w całej grze nie było ŻADNEGO wizualnego dowodu
## trafienia poza flash_white (identycznym dla pierwszego i drugiego ciosu,
## i dla każdego innego trafienia w grze). Naprawa NIE zmienia samej
## mechaniki (szansa/frakcja obrażeń zostają) — dodaje brakujący dowód:
## własny łuk cięcia w stronę celu (jak żywy zamach mieczem, ale
## odtworzony samodzielnie, bo gracz mógł już zdążyć się ruszyć/odwrócić)
## i osobną liczbę obrażeń (autoload/juice.gd, Juice.apply_hit is_bonus_hit).
func _fire_second_impact(target: Node, damage: float, origin_pos: Vector2, attack_id: int = -1, base_damage: float = 0.0) -> void:
	if not is_instance_valid(target):
		return
	if target.get("is_dead") == true:
		return
	_record_relic_activation("second_impact")
	var to_target: Vector2 = target.global_position - origin_pos
	if get_parent() != null:
		AttackVfx.spawn(get_parent(), TEX_SLASH_ARC, target.global_position, AttackVfx.DEFAULT_DURATION, slash_arc_scale, to_target.angle())
	apply_skill_bonus(target, damage, attack_id, base_damage, "second_impact")
	if target.has_method("apply_knockback"):
		var dir: Vector2 = target.global_position - origin_pos
		var strength := second_impact_knockback_strength * _knockback_dealt_multiplier()
		target.apply_knockback((dir.normalized() if dir.length() > 0.01 else Vector2.RIGHT) * strength)

## Soul Bond (dokument): wołane z room.gd w chwili PODNIESIENIA duszy (nie
## samego pokonania wcielenia) — nowa dusza NADPISUJE poprzedni bonus
## ("new soul replaces previous"), nie sumuje się z nim.
func activate_soul_bond(chapter: int) -> void:
	if not has_upgrade("soul_bond"):
		return
	if chapter < 0 or chapter >= SOUL_BOND_EFFECTS.size():
		return
	_soul_bond_effect = SOUL_BOND_EFFECTS[chapter]
	_soul_bond_timer = soul_bond_duration

func _check_attack_hits() -> void:
	var half_angle := deg_to_rad(attack_angle_degrees + 25.0 * skill_rank("blade_wide_sweep")) * 0.5
	for target in get_tree().get_nodes_in_group("hittable"):
		if target in _attack_hit_targets:
			continue
		var to_target: Vector2 = target.global_position - global_position
		var distance := to_target.length()
		# Cel liczymy jako koło, nie punkt — inaczej trafienie w sam brzeg dużego
		# kola (np. bossa) nie zaliczałoby się, bo tylko środek byłby "w zasięgu".
		var target_radius: float = target.get("radius") if target.get("radius") != null else 0.0

		if distance > _current_attack_range + target_radius:
			continue

		if distance > target_radius:
			# Gracz nie stoi wewnątrz koła celu — do stożka ataku doliczamy połowę
			# kąta, pod jakim widać krąg celu z pozycji gracza, żeby trafienie
			# w krawędź (środek poza wąskim stożkiem) też się liczyło.
			var angle: float = absf(_attack_direction.angle_to(to_target.normalized()))
			var angular_half_width := asin(clamp(target_radius / max(distance, 0.01), 0.0, 1.0))
			if angle > half_angle + angular_half_width:
				continue

		_attack_hit_targets.append(target)
		var damage := resolve_hit_damage(target, _current_attack_damage)
		var health_before: float = target.get("health") if target.get("health") != null else -1.0
		var dealt: float = Juice.apply_hit(target, damage, Juice.boss_hit_hitstop, false, "sword_primary")
		if dealt > 0.0:
			on_hit_confirmed(target, dealt, "sword", health_before, _attack_serial)
			_play_sfx(SND_SWORD_HIT)

func _read_input_vector() -> Vector2:
	var v := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if input_reversed:
		v = v.rotated(deg_to_rad(90.0)) # faza finałowa, reguła Odwrócenie
	return v

func _update_trail(delta: float) -> void:
	if state != State.DASHING:
		return
	_trail_spawn_timer -= delta
	if _trail_spawn_timer <= 0.0:
		_trail_spawn_timer = dash_duration / float(max(1, dash_trail_count))
		_spawn_trail_ghost()

## Powidok prawdziwej pozy postaci; top_level zatrzymuje go w miejscu dasha.
func _spawn_trail_ghost() -> void:
	var ghost := Sprite2D.new()
	var facing := Facing.resolve(TEX_DASH_VARIANTS, _dash_direction)
	ghost.texture = facing["texture"]
	ghost.flip_h = facing["flip_h"]
	ghost.scale = sprite.scale
	ghost.z_index = sprite.z_index - 1
	ghost.top_level = true
	add_child(ghost)
	ghost.global_transform = sprite.global_transform
	ghost.modulate = Color(0.38, 0.82, 0.88, 0.38)
	var tw := create_tween()
	tw.tween_property(ghost, "modulate:a", 0.0, dash_trail_lifetime)
	tw.tween_callback(ghost.queue_free)

## Wywoływane z zewnątrz (pieczęcie, cień, kontakt) — jedna, wspólna brama obrażeń,
## dzięki której nietykalność po trafieniu działa tak samo niezależnie od źródła.
## #D63B3B — sam kolor co entities/enemy_health_bar.gd FILL_COLOR ("osobny od
## Palette.DANGER, ten zarezerwowany dla obrażeń ZADAWANYCH") — jeden spójny
## odcień dla "obrażeń OTRZYMYWANYCH" w całej grze, nie import między plikami
## dla jednej stałej.
const RECEIVED_DAMAGE_COLOR := Color("#D63B3B")

## source_position: skąd przyszedł cios (Vector2.INF = nieznane, tarcza go
## nie złapie). blockable=false dla stref na podłożu, pieczęci itp.
## Zwraca true, gdy gracz faktycznie stracił HP (np. lifesteal wroga).
## attacker: kto zadał cios — sparowany dostaje on_parried(player).
## P0.2 (audyt nagrania): jak zakończył się cios, który doszedł do gracza.
const HIT_OUTCOME_BY_BLOCK := {
	"broken": "przełamanie gardy", "direction": "poza tarczą — tył", "direction_side": "poza tarczą — bok", "unblockable": "nieblokowalny",
}
var _last_block_kind: String = ""

## Rodzaj ataku: jawny od wołającego (kontakt/puls/szarża) albo z typu źródła.
static func attack_kind_of(attacker: Node) -> String:
	if attacker is EnemyProjectile:
		return "pocisk"
	if attacker is RoomTerrain:
		return "pułapka"
	if attacker != null and is_instance_valid(attacker):
		var key := attacker.scene_file_path.get_file().get_basename()
		if key in ["damage_zone", "seal", "shadow"]:
			return {"damage_zone": "strefa", "seal": "pieczęć", "shadow": "cień"}[key]
	return "atak"

func _hit_log_entry(amount: float, blockable: bool, attacker: Node, kind: String) -> Dictionary:
	var skill := ""
	if attacker != null and is_instance_valid(attacker) and kind != "kontakt":
		var skills = attacker.get("_skills")
		var index = attacker.get("_last_skill_index")
		if skills is Array and index is int and index >= 0 and index < skills.size():
			skill = str((skills[index] as Callable).get_method()).trim_prefix("_")
		var pattern = attacker.get("_last_pattern_name")
		if pattern is String and pattern != "":
			skill = pattern
	return {
		"source": RunSummary.describe_attacker(attacker, blockable),
		"kind": kind if kind != "" else attack_kind_of(attacker),
		"skill": skill, "damage": amount, "blockable": blockable,
		"hp_before": health, "hp_after": health,
		"stamina_before": stamina, "stamina_after": stamina,
		"shield": _shield_up, "dashing": state == State.DASHING, "iframe": _invuln_timer,
		"pos": global_position, "outcome": "",
	}

func take_damage(amount: float, source_position := Vector2.INF, blockable := true, attacker: Node = null, kind: String = "") -> bool:
	if state == State.DEAD:
		return false
	var hit := _hit_log_entry(amount, blockable, attacker, kind)
	if state == State.DASHING or _invuln_timer > 0.0:
		hit["outcome"] = "dash" if state == State.DASHING else "nietykalność"
		Juice.log_player_hit(hit)
		return false
	_last_block_kind = ""
	_last_block_side = false
	if _try_block(amount, source_position, blockable, attacker):
		hit["outcome"] = "parowanie" if _last_block_kind == "parry" else "blok"
		hit["stamina_after"] = stamina
		Juice.log_player_hit(hit)
		return false
	hit["outcome"] = HIT_OUTCOME_BY_BLOCK.get("direction_side" if _last_block_side else _last_block_kind, "trafienie")
	hit["stamina_after"] = stamina
	hit["hp_after"] = maxf(0.0, health - amount)
	Juice.log_player_hit(hit)
	health -= amount
	last_hit_source = RunSummary.describe_attacker(attacker, blockable)
	_interrupt_heal_channel()
	if _skill_procs != null:
		_skill_procs.on_damage_taken()
	# Krok 8 komunikatów w walce: "obrażenia gracza" dotąd nie miały ŻADNEJ
	# liczby przy samym graczu (tylko flash_white+hitstop) — DamageNumber
	# (Second Impact) generalizuje się tu jeden do jednego.
	if get_parent() != null:
		DamageNumber.spawn(get_parent(), global_position + Vector2(0.0, -70.0), amount, RECEIVED_DAMAGE_COLOR)
	if has_upgrade("momentum"):
		_momentum_stacks = 0
		_momentum_timer = 0.0
	_invuln_timer = damage_invulnerability
	_flash_frames = 2
	Juice.hitstop(Juice.player_hit_hitstop)
	if health <= 0.0:
		if skill_rank("guard_second_breath") > 0 and not _second_breath_used:
			_second_breath_used = true
			health = 1.0
			_invuln_timer = 1.0
			_play_sfx(SND_HEAL_USE)
			var scale_value := 100.0 / float(maxi(1, VFX_SECOND_BREATH.get_width()))
			AttackVfx.spawn(get_parent(), VFX_SECOND_BREATH, global_position, 0.55, scale_value)
		else:
			health = 0.0
			state = State.DEAD
			_play_sfx(SND_DEATH)
			died.emit()
	else:
		_play_sfx(SND_HURT[randi() % SND_HURT.size()])
	return true

## Wywoływane przez Ząb Zera przy wejściu gracza w strefę.
func lock_dash(seconds: float) -> void:
	_void_dash_lock_timer = max(_void_dash_lock_timer, seconds)

func is_dash_locked_by_void() -> bool:
	return _void_dash_lock_timer > 0.0

func is_dash_on_cooldown() -> bool:
	return _dash_cooldown_timer > 0.0

## Publiczne, żeby boss mógł nie marnować odepchnięcia w chwili, gdy trafienie
## i tak zostanie zignorowane przez take_damage() (dash / miganie po obrażeniach).
func is_invulnerable() -> bool:
	return state == State.DASHING or _invuln_timer > 0.0

## Łuk tarczy: pokazuje DOKŁADNIE osłaniany sektor (shield_arc_degrees), pod
## sprite'em gracza (rodzic rysuje przed dziećmi), więc nie zasłania postaci.
## Jaśniejszy w oknie idealnego bloku, czerwony chwilę po przełamaniu.
## A7: gdy gracz nachodzi na dużego wroga (boss, wcielenie), za sylwetką
## pojawia się delikatna poświata — ciemny płaszcz nie zlewa się z ciałem bossa.
const FEET_RING_OFFSET := Vector2(0.0, 32.0) ## tam, gdzie cień kontaktowy
const FEET_RING_RADIUS := 34.0

func _update_outline() -> void:
	var target := 1.0 if state != State.DEAD and _overlaps_large_enemy() else 0.0
	_overlap_blend = move_toward(_overlap_blend, target, OVERLAP_BLEND_SPEED * get_physics_process_delta_time())
	_outline_material.set_shader_parameter("outline_strength", lerpf(OUTLINE_BASE, OUTLINE_OVERLAP, _overlap_blend) if state != State.DEAD else 0.0)
	_outline_material.set_shader_parameter("lift", LIFT_OVERLAP * _overlap_blend)

func _overlaps_large_enemy() -> bool:
	for e in get_tree().get_nodes_in_group("hittable"):
		if e is Node2D and e.get("is_dead") != true:
			var r: float = e.get("radius") if e.get("radius") != null else 0.0
			if r >= 60.0 and global_position.distance_to((e as Node2D).global_position) <= r + 40.0:
				return true
	return false

func _draw() -> void:
	if _overlap_blend > 0.01:
		# Cienki pierścień u stóp (elipsa na posadzce) — pokazuje, gdzie gracz
		# NAPRAWDĘ stoi, gdy sylwetka nachodzi na ciało dużego wroga.
		draw_set_transform(FEET_RING_OFFSET, 0.0, Vector2(1.0, 0.36))
		draw_arc(Vector2.ZERO, FEET_RING_RADIUS, 0.0, TAU, 40, Color(Palette.PLAYER_BODY, 0.75 * _overlap_blend), 2.5, true)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	var half := deg_to_rad(shield_arc_degrees * 0.5)
	var arc_radius := radius + 26.0
	if _shield_up:
		var angle := _shield_dir.angle()
		var perfect := is_parry_window()
		var color := SHIELD_ARC_COLOR
		color.a = 0.95 if perfect or _block_visual_timer > 0.0 else 0.55
		draw_arc(Vector2.ZERO, arc_radius, angle - half, angle + half, 24, color, 5.0 if perfect else 3.5, true)
	elif _guard_break_flash > 0.0:
		var angle := _shield_dir.angle()
		var broken := RECEIVED_DAMAGE_COLOR
		broken.a = clampf(_guard_break_flash / 0.35, 0.0, 1.0)
		# Przerwany łuk = pęknięta garda (kształt, nie tylko kolor).
		for i in 3:
			var a0 := angle - half + (2.0 * half) * float(i) / 3.0
			draw_arc(Vector2.ZERO, arc_radius, a0 + 0.08, a0 + (2.0 * half) / 3.0 - 0.08, 8, broken, 3.5, true)

func flash_white() -> void:
	if Palette.reduce_flashing:
		return
	_flash_frames = 2

func _play_sfx(stream: AudioStream) -> void:
	sfx.pitch_scale = 1.0
	sfx.stream = stream
	sfx.play()

func play_skill_sfx(stream: AudioStream, world_pos: Vector2, volume_db: float = -10.0, pitch: float = 1.0) -> void:
	if get_parent() == null:
		return
	var sound := AudioStreamPlayer2D.new()
	sound.stream = stream
	sound.volume_db = volume_db
	sound.pitch_scale = pitch
	sound.bus = &"SFX"
	get_parent().add_child(sound)
	sound.global_position = world_pos
	sound.finished.connect(sound.queue_free)
	sound.play()

## Zastępuje dawny _draw() — wybiera właściwą teksturę wg priorytetu stanu i
## ustawia VFX ataku (wycinek miecza / kula różdżki) w miejsce dawnych rysowanych kształtów.
func _apply_facing(variants: Dictionary, direction: Vector2, frame: int = 0) -> void:
	var facing := Facing.resolve(variants, direction, frame)
	sprite.texture = facing["texture"]
	sprite.flip_h = facing["flip_h"]

## Każda poza przechodzi przez Facing.resolve() z WŁAŚCIWYM dla siebie
## źródłem kierunku (dokument, sekcja 2: mysz dla akcji bojowych, WASD dla
## chodu/dasha) — od Fazy 3-5 każdy słownik ma pełne 5 kątów.
func _update_visuals() -> void:
	queue_redraw() # łuk tarczy (_draw)
	_update_outline()
	if state == State.DEAD:
		_apply_facing(TEX_DEATH_VARIANTS, _last_move_direction)
	elif _flash_frames > 0:
		_apply_facing(TEX_HIT_VARIANTS, _last_move_direction)
	elif _shield_up or _block_visual_timer > 0.0:
		_apply_facing(TEX_BLOCK_VARIANTS, _shield_dir)
	elif _heal_visual_timer > 0.0:
		_apply_facing(TEX_HEAL_VARIANTS, _attack_direction)
	elif state == State.DASHING:
		_apply_facing(TEX_DASH_VARIANTS, _dash_direction)
	elif _attack_phase == "windup":
		_apply_facing(TEX_SWORD_WINDUP_VARIANTS if _swing_weapon == "sword" else TEX_WAND_WINDUP_VARIANTS, _attack_direction)
	elif _attack_phase == "active" or _attack_phase == "recovery":
		_apply_facing(TEX_SWORD_ACTIVE_VARIANTS if _swing_weapon == "sword" else TEX_WAND_FIRE_VARIANTS, _attack_direction)
	elif velocity.length() > 5.0:
		_apply_facing(WALK_VARIANTS, velocity, _walk_cycle_frame())
	else:
		_apply_facing(TEX_BASE_VARIANTS, _last_move_direction)

	var blinking_hidden := _invuln_timer > 0.0 and int(_invuln_timer * 20.0) % 2 == 0
	# Nietykalność po trafieniu pulsuje przezroczystością, ale postać nigdy
	# nie znika całkiem — gracz zawsze widzi, gdzie stoi (AUDYT, Paczka 3).
	sprite.modulate.a = 0.4 if blinking_hidden else 1.0

	var showing_slash := _attack_phase != "" and _swing_weapon == "sword"
	slash_arc.visible = showing_slash
	if showing_slash:
		slash_arc.rotation = _attack_direction.angle()
		slash_arc.position = _attack_direction * (_current_attack_range * 0.5)
		slash_arc.scale = Vector2.ONE * slash_arc_scale * (_current_attack_range / base_attack_range)
		slash_arc.modulate.a = 0.5 if _attack_phase == "windup" else 1.0
	var wide_rank := skill_rank("blade_wide_sweep")
	for extra in [_wide_slash_left, _wide_slash_right]:
		extra.visible = showing_slash and wide_rank > 0
		if extra.visible:
			var sign_value := -1.0 if extra == _wide_slash_left else 1.0
			extra.position = slash_arc.position
			extra.scale = slash_arc.scale
			extra.rotation = slash_arc.rotation + deg_to_rad(sign_value * 12.5 * wide_rank)
			extra.modulate.a = 0.3 if _attack_phase == "windup" else 0.62

	var showing_wand := _attack_phase != "" and _swing_weapon == "wand"
	wand_charge_sprite.visible = showing_wand
	if showing_wand:
		wand_charge_sprite.position = _attack_direction * (radius + 6.0)
		var charge_t: float = 0.6 if _attack_phase == "windup" else 1.0
		wand_charge_sprite.scale = Vector2(wand_charge_scale, wand_charge_scale) * charge_t

# --- Ciała nie przenikają się (decyzja autora 23.09) ---
## Dotyk na krawędzi ciał nadal liczy się jak dotyk (obrażenia/odrzut wrogów).
const BODY_CONTACT_SLOP := 6.0
## Wróg o takim promieniu (i boss) nie ustępuje graczowi — ciężkie ciało.
const HEAVY_BODY_RADIUS := 60.0

## Po ruchu gracza rozsuwa nakładające się ciała na krawędź dotyku.
## Ciężki wróg stoi — odsuwa się gracz; lekki dzieli przesunięcie po połowie.
## Gracz przy ścianie (move_and_collide go zatrzyma) — resztę dostaje wróg.
## W dashu gracz przenika wrogów (ucieczka spod bossa przy ścianie), po
## dashu jest wypychany na krawędź.
func _resolve_body_overlaps() -> void:
	if state == State.DASHING or state == State.DEAD or not is_inside_tree():
		return
	for e in get_tree().get_nodes_in_group("hittable"):
		if not (e is Node2D) or e.get("is_dead") == true or e.get("_intangible") == true or not (e as Node2D).visible:
			continue
		var er = e.get("radius")
		if er == null:
			continue
		var min_d := radius + float(er)
		var delta: Vector2 = global_position - (e as Node2D).global_position
		var d := delta.length()
		if d >= min_d:
			continue
		var n: Vector2
		if d > 0.01:
			n = delta / d
		elif _last_move_direction.length() > 0.01:
			n = -_last_move_direction.normalized()
		else:
			n = Vector2.DOWN
		var overlap := min_d - d
		var heavy: bool = e is Boss or float(er) >= HEAVY_BODY_RADIUS
		var player_share := overlap if heavy else overlap * 0.5
		var collision := move_and_collide(n * player_share)
		var moved := player_share - (collision.get_remainder().length() if collision != null else 0.0)
		var rest := overlap - moved
		if rest > 0.01 and e.has_method("body_push"):
			e.body_push(-n * rest)
