extends Node2D
class_name Boss
## Nemorax — sześć faz zastąpione mechaniką z CLAUDE_CODE_GAME_CONTENT_BIBLE.md
## sekcja 13: Motion/Force/Instinct/Dominion/Ruin/Sovereignty (na życzenie
## autora, zamiast Cisza/Zwłoka/Ciężar/Głód/Zaćmienie). Nazwa, ceremonia
## przywołania, arena i tor zwycięstwa/śmierci zostają BEZ ZMIAN — zmieniają
## się WYŁĄCZNIE ataki/wzorce każdej fazy. Specjalne reguły "łamania zasad"
## (sekcja 7 z wcześniejszej sesji: wyciszenie/podwójny cooldown dasha/stałe
## przyciąganie/zawężone pole widzenia) zostają PRZYPISANE DO TYCH SAMYCH
## INDEKSÓW faz co dawniej (arena.gd._on_boss_phase_changed przełącza po
## indeksie, nie po nazwie — zero zmian tam potrzebnych, testy bez zmian).
##
## Grafika: TYMCZASOWO reużywa 6 istniejących plików faz Nemoraksa pozycyjnie
## (phase_index 0..5) — tematy plików (Cisza/Zwłoka/...) już nie pasują do
## nowych nazw faz, ale wymiana grafiki idzie osobno przez GPT, nie blokuje
## mechaniki. Same ataki (pieczęcie/cień/strefa/pocisk/dodatki) są osobnymi
## scenami, które boss tylko spawnuje — jak dotychczas.

signal phase_changed(phase_index: int, color: Color, rule_name: String)
signal died(is_final: bool) ## false = duża forma padła (start fazy finałowej), true = koniec walki

const SealScene := preload("res://entities/seal.tscn")
const VoidZoneScene := preload("res://entities/void_zone.tscn")
const ShadowScene := preload("res://entities/shadow.tscn")
const DamageZoneScene := preload("res://entities/damage_zone.tscn")
const EnemyProjectileScene := preload("res://entities/enemy_projectile.tscn")
const ChaserScene := preload("res://entities/random_enemies/chaser.tscn") ## Dominion: dodatki, ten sam wzorzec co Summoner (entities/random_enemies/summoner.gd)

# Sześć baz wyglądu, jedna na fazę (kolejność = phase_index 0..5) — TYMCZASOWE
# przypisanie pozycyjne, patrz komentarz na górze pliku.
const PHASE_BASE_TEXTURES: Array[Dictionary] = [
	{
		"front": [preload("res://assets/sprites/nemorax/nemorax_phase-1_base.png"), preload("res://assets/sprites/nemorax/nemorax_phase-1_walk_front_stride.png")],
		"front_diagonal": [preload("res://assets/sprites/nemorax/nemorax_phase-1_walk_front_diagonal.png"), preload("res://assets/sprites/nemorax/nemorax_phase-1_walk_front_diagonal_stride.png")],
		"side": [preload("res://assets/sprites/nemorax/nemorax_phase-1_base_side.png"), preload("res://assets/sprites/nemorax/nemorax_phase-1_walk_side_stride.png")],
		"back_diagonal": [preload("res://assets/sprites/nemorax/nemorax_phase-1_walk_back_diagonal.png"), preload("res://assets/sprites/nemorax/nemorax_phase-1_walk_back_diagonal_stride.png")],
		"back": [preload("res://assets/sprites/nemorax/nemorax_phase-1_base_back.png"), preload("res://assets/sprites/nemorax/nemorax_phase-1_walk_back_stride.png")],
	},
	{
		"front": [preload("res://assets/sprites/nemorax/nemorax_phase-2_silence.png"), preload("res://assets/sprites/nemorax/nemorax_phase-2_silence_walk_front_stride.png")],
		"front_diagonal": [preload("res://assets/sprites/nemorax/nemorax_phase-2_silence_walk_front_diagonal.png"), preload("res://assets/sprites/nemorax/nemorax_phase-2_silence_walk_front_diagonal_stride.png")],
		"side": [preload("res://assets/sprites/nemorax/nemorax_phase-2_silence_side.png"), preload("res://assets/sprites/nemorax/nemorax_phase-2_silence_walk_side_stride.png")],
		"back_diagonal": [preload("res://assets/sprites/nemorax/nemorax_phase-2_silence_walk_back_diagonal.png"), preload("res://assets/sprites/nemorax/nemorax_phase-2_silence_walk_back_diagonal_stride.png")],
		"back": [preload("res://assets/sprites/nemorax/nemorax_phase-2_silence_back.png"), preload("res://assets/sprites/nemorax/nemorax_phase-2_silence_walk_back_stride.png")],
	},
	{
		"front": [preload("res://assets/sprites/nemorax/nemorax_phase-3_dash-cooldown.png"), preload("res://assets/sprites/nemorax/nemorax_phase-3_dash-cooldown_walk_front_stride.png")],
		"front_diagonal": [preload("res://assets/sprites/nemorax/nemorax_phase-3_dash-cooldown_walk_front_diagonal.png"), preload("res://assets/sprites/nemorax/nemorax_phase-3_dash-cooldown_walk_front_diagonal_stride.png")],
		"side": [preload("res://assets/sprites/nemorax/nemorax_phase-3_dash-cooldown_side.png"), preload("res://assets/sprites/nemorax/nemorax_phase-3_dash-cooldown_walk_side_stride.png")],
		"back_diagonal": [preload("res://assets/sprites/nemorax/nemorax_phase-3_dash-cooldown_walk_back_diagonal.png"), preload("res://assets/sprites/nemorax/nemorax_phase-3_dash-cooldown_walk_back_diagonal_stride.png")],
		"back": [preload("res://assets/sprites/nemorax/nemorax_phase-3_dash-cooldown_back.png"), preload("res://assets/sprites/nemorax/nemorax_phase-3_dash-cooldown_walk_back_stride.png")],
	},
	{
		"front": [preload("res://assets/sprites/nemorax/nemorax_phase-4_pull.png"), preload("res://assets/sprites/nemorax/nemorax_phase-4_pull_walk_front_stride.png")],
		"front_diagonal": [preload("res://assets/sprites/nemorax/nemorax_phase-4_pull_walk_front_diagonal.png"), preload("res://assets/sprites/nemorax/nemorax_phase-4_pull_walk_front_diagonal_stride.png")],
		"side": [preload("res://assets/sprites/nemorax/nemorax_phase-4_pull_side.png"), preload("res://assets/sprites/nemorax/nemorax_phase-4_pull_walk_side_stride.png")],
		"back_diagonal": [preload("res://assets/sprites/nemorax/nemorax_phase-4_pull_walk_back_diagonal.png"), preload("res://assets/sprites/nemorax/nemorax_phase-4_pull_walk_back_diagonal_stride.png")],
		"back": [preload("res://assets/sprites/nemorax/nemorax_phase-4_pull_back.png"), preload("res://assets/sprites/nemorax/nemorax_phase-4_pull_walk_back_stride.png")],
	},
	{
		"front": [preload("res://assets/sprites/nemorax/nemorax_phase-5_regeneration.png"), preload("res://assets/sprites/nemorax/nemorax_phase-5_regeneration_walk_front_stride.png")],
		"front_diagonal": [preload("res://assets/sprites/nemorax/nemorax_phase-5_regeneration_walk_front_diagonal.png"), preload("res://assets/sprites/nemorax/nemorax_phase-5_regeneration_walk_front_diagonal_stride.png")],
		"side": [preload("res://assets/sprites/nemorax/nemorax_phase-5_regeneration_side.png"), preload("res://assets/sprites/nemorax/nemorax_phase-5_regeneration_walk_side_stride.png")],
		"back_diagonal": [preload("res://assets/sprites/nemorax/nemorax_phase-5_regeneration_walk_back_diagonal.png"), preload("res://assets/sprites/nemorax/nemorax_phase-5_regeneration_walk_back_diagonal_stride.png")],
		"back": [preload("res://assets/sprites/nemorax/nemorax_phase-5_regeneration_back.png"), preload("res://assets/sprites/nemorax/nemorax_phase-5_regeneration_walk_back_stride.png")],
	},
	{
		"front": [preload("res://assets/sprites/nemorax/nemorax_phase-6_narrow-vision.png"), preload("res://assets/sprites/nemorax/nemorax_phase-6_narrow-vision_walk_front_stride.png")],
		"front_diagonal": [preload("res://assets/sprites/nemorax/nemorax_phase-6_narrow-vision_walk_front_diagonal.png"), preload("res://assets/sprites/nemorax/nemorax_phase-6_narrow-vision_walk_front_diagonal_stride.png")],
		"side": [preload("res://assets/sprites/nemorax/nemorax_phase-6_narrow-vision_side.png"), preload("res://assets/sprites/nemorax/nemorax_phase-6_narrow-vision_walk_side_stride.png")],
		"back_diagonal": [preload("res://assets/sprites/nemorax/nemorax_phase-6_narrow-vision_walk_back_diagonal.png"), preload("res://assets/sprites/nemorax/nemorax_phase-6_narrow-vision_walk_back_diagonal_stride.png")],
		"back": [preload("res://assets/sprites/nemorax/nemorax_phase-6_narrow-vision_back.png"), preload("res://assets/sprites/nemorax/nemorax_phase-6_narrow-vision_walk_back_stride.png")],
	},
]
const TEX_TELEGRAPH := preload("res://assets/sprites/nemorax/nemorax_telegraph.png")
const TEX_TELEGRAPH_FRONT_DIAGONAL := preload("res://assets/sprites/nemorax/nemorax_telegraph_front_diagonal.png")
const TEX_TELEGRAPH_SIDE := preload("res://assets/sprites/nemorax/nemorax_telegraph_side.png")
const TEX_TELEGRAPH_BACK_DIAGONAL := preload("res://assets/sprites/nemorax/nemorax_telegraph_back_diagonal.png")
const TEX_TELEGRAPH_BACK := preload("res://assets/sprites/nemorax/nemorax_telegraph_back.png")
const TEX_LUNGE := preload("res://assets/sprites/nemorax/nemorax_lunge.png")
const TEX_LUNGE_FRONT_DIAGONAL := preload("res://assets/sprites/nemorax/nemorax_lunge_front_diagonal.png")
const TEX_LUNGE_SIDE := preload("res://assets/sprites/nemorax/nemorax_lunge_side.png")
const TEX_LUNGE_BACK_DIAGONAL := preload("res://assets/sprites/nemorax/nemorax_lunge_back_diagonal.png")
const TEX_LUNGE_BACK := preload("res://assets/sprites/nemorax/nemorax_lunge_back.png")
const TEX_CAST_PULSE := preload("res://assets/sprites/nemorax/nemorax_cast-pulse.png")
const TEX_CAST_PULSE_FRONT_DIAGONAL := preload("res://assets/sprites/nemorax/nemorax_cast-pulse_front_diagonal.png")
const TEX_CAST_PULSE_SIDE := preload("res://assets/sprites/nemorax/nemorax_cast-pulse_side.png")
const TEX_CAST_PULSE_BACK_DIAGONAL := preload("res://assets/sprites/nemorax/nemorax_cast-pulse_back_diagonal.png")
const TEX_CAST_PULSE_BACK := preload("res://assets/sprites/nemorax/nemorax_cast-pulse_back.png")
const TEX_PULL := preload("res://assets/sprites/nemorax/nemorax_pull.png")
const TEX_PULL_FRONT_DIAGONAL := preload("res://assets/sprites/nemorax/nemorax_pull_front_diagonal.png")
const TEX_PULL_SIDE := preload("res://assets/sprites/nemorax/nemorax_pull_side.png")
const TEX_PULL_BACK_DIAGONAL := preload("res://assets/sprites/nemorax/nemorax_pull_back_diagonal.png")
const TEX_PULL_BACK := preload("res://assets/sprites/nemorax/nemorax_pull_back.png")
const TEX_HIT := preload("res://assets/sprites/nemorax/nemorax_hit.png")
const TEX_HIT_FRONT_DIAGONAL := preload("res://assets/sprites/nemorax/nemorax_hit_front_diagonal.png")
const TEX_HIT_SIDE := preload("res://assets/sprites/nemorax/nemorax_hit_side.png")
const TEX_HIT_BACK_DIAGONAL := preload("res://assets/sprites/nemorax/nemorax_hit_back_diagonal.png")
const TEX_HIT_BACK := preload("res://assets/sprites/nemorax/nemorax_hit_back.png")
const TEX_PHASE_TRANSFORM := preload("res://assets/sprites/nemorax/nemorax_phase-transform.png")
const TEX_PHASE_TRANSFORM_FRONT_DIAGONAL := preload("res://assets/sprites/nemorax/nemorax_phase-transform_front_diagonal.png")
const TEX_PHASE_TRANSFORM_SIDE := preload("res://assets/sprites/nemorax/nemorax_phase-transform_side.png")
const TEX_PHASE_TRANSFORM_BACK_DIAGONAL := preload("res://assets/sprites/nemorax/nemorax_phase-transform_back_diagonal.png")
const TEX_PHASE_TRANSFORM_BACK := preload("res://assets/sprites/nemorax/nemorax_phase-transform_back.png")
const TEX_LARGE_FORM_COLLAPSE := preload("res://assets/sprites/nemorax/nemorax_large-form-collapse.png")
const TEX_LARGE_FORM_COLLAPSE_FRONT_DIAGONAL := preload("res://assets/sprites/nemorax/nemorax_large-form-collapse_front_diagonal.png")
const TEX_LARGE_FORM_COLLAPSE_SIDE := preload("res://assets/sprites/nemorax/nemorax_large-form-collapse_side.png")
const TEX_LARGE_FORM_COLLAPSE_BACK_DIAGONAL := preload("res://assets/sprites/nemorax/nemorax_large-form-collapse_back_diagonal.png")
const TEX_LARGE_FORM_COLLAPSE_BACK := preload("res://assets/sprites/nemorax/nemorax_large-form-collapse_back.png")
const TEX_SMALL_FORM_REBIRTH := preload("res://assets/sprites/nemorax/nemorax_small-form-rebirth.png")
const TEX_SMALL_FORM_REBIRTH_FRONT_DIAGONAL := preload("res://assets/sprites/nemorax/nemorax_small-form-rebirth_front_diagonal.png")
const TEX_SMALL_FORM_REBIRTH_SIDE := preload("res://assets/sprites/nemorax/nemorax_small-form-rebirth_side.png")
const TEX_SMALL_FORM_REBIRTH_BACK_DIAGONAL := preload("res://assets/sprites/nemorax/nemorax_small-form-rebirth_back_diagonal.png")
const TEX_SMALL_FORM_REBIRTH_BACK := preload("res://assets/sprites/nemorax/nemorax_small-form-rebirth_back.png")
const TEX_SMALL_FORM_TAUNT := preload("res://assets/sprites/nemorax/nemorax_small-form-taunt.png")
const TEX_SMALL_FORM_TAUNT_FRONT_DIAGONAL := preload("res://assets/sprites/nemorax/nemorax_small-form-taunt_front_diagonal.png")
const TEX_SMALL_FORM_TAUNT_SIDE := preload("res://assets/sprites/nemorax/nemorax_small-form-taunt_side.png")
const TEX_SMALL_FORM_TAUNT_BACK_DIAGONAL := preload("res://assets/sprites/nemorax/nemorax_small-form-taunt_back_diagonal.png")
const TEX_SMALL_FORM_TAUNT_BACK := preload("res://assets/sprites/nemorax/nemorax_small-form-taunt_back.png")
const TEX_SMALL_FORM_TRUE_DEATH := preload("res://assets/sprites/nemorax/nemorax_small-form-true-death.png")
const TEX_SMALL_FORM_TRUE_DEATH_FRONT_DIAGONAL := preload("res://assets/sprites/nemorax/nemorax_small-form-true-death_front_diagonal.png")
const TEX_SMALL_FORM_TRUE_DEATH_SIDE := preload("res://assets/sprites/nemorax/nemorax_small-form-true-death_side.png")
const TEX_SMALL_FORM_TRUE_DEATH_BACK_DIAGONAL := preload("res://assets/sprites/nemorax/nemorax_small-form-true-death_back_diagonal.png")
const TEX_SMALL_FORM_TRUE_DEATH_BACK := preload("res://assets/sprites/nemorax/nemorax_small-form-true-death_back.png")
const TEX_LUNGE_WARNING := preload("res://assets/sprites/ataki_bossa/claw_dash_warning.png")
const LUNGE_WARNING_CONTENT_HEIGHT := 891.0
## Faza 2D (PLAN_PROFESSIONAL_GAME_FEEL_DLA_CLAUDE.md): "telegraf musi być
## odrobinę większy niż realna strefa obrażeń, nigdy mniejszy" — ta sama
## wartość co entities/damage_zone.gd, dla spójności między telegrafami.
const LUNGE_WARNING_SAFETY_MARGIN := 1.12

# Fazy 3-5 (PLAN_ANIMACJE_KIERUNKOWE.md) — pełne 5 kątów na każdą pozę, wspólne
# dla wszystkich 6 faz (w przeciwieństwie do PHASE_BASE_TEXTURES).
const TEX_TELEGRAPH_VARIANTS := {"front": TEX_TELEGRAPH, "front_diagonal": TEX_TELEGRAPH_FRONT_DIAGONAL, "side": TEX_TELEGRAPH_SIDE, "back_diagonal": TEX_TELEGRAPH_BACK_DIAGONAL, "back": TEX_TELEGRAPH_BACK}
const TEX_LUNGE_VARIANTS := {"front": TEX_LUNGE, "front_diagonal": TEX_LUNGE_FRONT_DIAGONAL, "side": TEX_LUNGE_SIDE, "back_diagonal": TEX_LUNGE_BACK_DIAGONAL, "back": TEX_LUNGE_BACK}
const TEX_CAST_PULSE_VARIANTS := {"front": TEX_CAST_PULSE, "front_diagonal": TEX_CAST_PULSE_FRONT_DIAGONAL, "side": TEX_CAST_PULSE_SIDE, "back_diagonal": TEX_CAST_PULSE_BACK_DIAGONAL, "back": TEX_CAST_PULSE_BACK}
const TEX_PULL_VARIANTS := {"front": TEX_PULL, "front_diagonal": TEX_PULL_FRONT_DIAGONAL, "side": TEX_PULL_SIDE, "back_diagonal": TEX_PULL_BACK_DIAGONAL, "back": TEX_PULL_BACK}
const TEX_HIT_VARIANTS := {"front": TEX_HIT, "front_diagonal": TEX_HIT_FRONT_DIAGONAL, "side": TEX_HIT_SIDE, "back_diagonal": TEX_HIT_BACK_DIAGONAL, "back": TEX_HIT_BACK}
const TEX_PHASE_TRANSFORM_VARIANTS := {"front": TEX_PHASE_TRANSFORM, "front_diagonal": TEX_PHASE_TRANSFORM_FRONT_DIAGONAL, "side": TEX_PHASE_TRANSFORM_SIDE, "back_diagonal": TEX_PHASE_TRANSFORM_BACK_DIAGONAL, "back": TEX_PHASE_TRANSFORM_BACK}
const TEX_LARGE_FORM_COLLAPSE_VARIANTS := {"front": TEX_LARGE_FORM_COLLAPSE, "front_diagonal": TEX_LARGE_FORM_COLLAPSE_FRONT_DIAGONAL, "side": TEX_LARGE_FORM_COLLAPSE_SIDE, "back_diagonal": TEX_LARGE_FORM_COLLAPSE_BACK_DIAGONAL, "back": TEX_LARGE_FORM_COLLAPSE_BACK}
const TEX_SMALL_FORM_REBIRTH_VARIANTS := {"front": TEX_SMALL_FORM_REBIRTH, "front_diagonal": TEX_SMALL_FORM_REBIRTH_FRONT_DIAGONAL, "side": TEX_SMALL_FORM_REBIRTH_SIDE, "back_diagonal": TEX_SMALL_FORM_REBIRTH_BACK_DIAGONAL, "back": TEX_SMALL_FORM_REBIRTH_BACK}
const TEX_SMALL_FORM_TAUNT_VARIANTS := {"front": TEX_SMALL_FORM_TAUNT, "front_diagonal": TEX_SMALL_FORM_TAUNT_FRONT_DIAGONAL, "side": TEX_SMALL_FORM_TAUNT_SIDE, "back_diagonal": TEX_SMALL_FORM_TAUNT_BACK_DIAGONAL, "back": TEX_SMALL_FORM_TAUNT_BACK}
const TEX_SMALL_FORM_TRUE_DEATH_VARIANTS := {"front": TEX_SMALL_FORM_TRUE_DEATH, "front_diagonal": TEX_SMALL_FORM_TRUE_DEATH_FRONT_DIAGONAL, "side": TEX_SMALL_FORM_TRUE_DEATH_SIDE, "back_diagonal": TEX_SMALL_FORM_TRUE_DEATH_BACK_DIAGONAL, "back": TEX_SMALL_FORM_TRUE_DEATH_BACK}

const SND_TRANSFORM_ROAR := preload("res://assets/audio/sfx/nemorax/N01_transform_roar.wav")
const SND_ATTACK_INHALE := preload("res://assets/audio/sfx/nemorax/N02_attack_inhale.wav")
const SND_LUNGE_TELEGRAPH := preload("res://assets/audio/sfx/nemorax/N11_lunge_telegraph.wav")
const SND_LUNGE_CHARGE := preload("res://assets/audio/sfx/nemorax/N12_lunge_charge.wav")
const SND_BODY_CONTACT := preload("res://assets/audio/sfx/nemorax/N14_body_contact.wav")
const SND_HURT := preload("res://assets/audio/sfx/nemorax/N16_nemorax_hurt.wav")
const SND_BIGFORM_COLLAPSE := preload("res://assets/audio/sfx/nemorax/N17_bigform_collapse.wav")
const SND_SMALLFORM_RESURRECT := preload("res://assets/audio/sfx/nemorax/N18_smallform_resurrect.wav")

## Ile HP trzeba zdjąć, żeby przejść do kolejnej fazy — KAŻDA faza ma pełny pasek
## od nowa, mnożony przez PHASE_HP_MULTIPLIERS (dokument sekcja 13.1: "phase
## duration consistency, not six health sponges").
@export var phase_max_health: float = 100.0
const PHASE_HP_MULTIPLIERS: Array[float] = [1.00, 1.00, 1.05, 1.10, 1.10, 1.15]
@export var radius: float = 120.0
@export var boss_drift_speed: float = 100.0
@export var attack_interval: float = 0.9
@export var final_attack_interval: float = 0.6
@export var phase_transform_invuln: float = 1.5
@export var final_health: float = 150.0
@export var final_radius: float = 58.0

## Tempo przy niskim zdrowiu fazy (dokument: "below ~40-50% HP: neutral delay
## x0.85-0.9" — powtarzające się we wszystkich sześciu fazach dokumentu).
@export var low_health_threshold: float = 0.45
@export var low_health_tempo_multiplier: float = 0.85

# Reguły "łamania zasad" per faza (bez zmian co do treści/indeksu — patrz
# komentarz na górze pliku). Faza Dominion (index 3, dawniej Ciężar).
@export var gravity_pull_strength: float = 120.0
# Faza Ruin (index 4, dawniej Głód).
@export var hunger_regen_rate: float = 8.0
@export var hunger_regen_delay: float = 3.0

# --- Motion (faza 0): Directional Dash / Short Strike / Delayed Return ---
@export var motion_dash_telegraph: float = 0.60
@export var motion_dash_speed: float = 500.0
@export var motion_dash_duration: float = 0.35
@export var motion_dash_damage: float = 14.0
@export var motion_short_strike_range: float = 130.0
@export var motion_short_strike_damage: float = 12.0
@export var motion_delayed_return_damage: float = 15.0

# --- Force (faza 1): Wide Frontal Strike / Radial Warning / Advancing Pressure ---
@export var force_wide_strike_range: float = 160.0
@export var force_wide_strike_damage: float = 18.0
@export var force_advance_steps: int = 3
@export var force_advance_step_delay: float = 0.45
@export var force_advance_damage: float = 16.0
@export var seal_count: int = 6
@export var seal_min_distance: float = 150.0
@export var seal_interval: float = 0.25

# --- Instinct (faza 2): Reposition / Delayed Strike / Feint / Quick Strike ---
@export var instinct_reposition_margin: float = 150.0
@export var instinct_strike_telegraph: float = 0.75
@export var instinct_strike_damage: float = 17.0
@export var instinct_feint_duration: float = 0.5
@export var instinct_quick_strike_telegraph: float = 0.32
@export var instinct_quick_strike_damage: float = 12.0
@export var instinct_strike_range: float = 130.0

# --- Dominion (faza 3): Zone / Projectile Fan / Summon ---
@export var dominion_zone_radius: float = 80.0
@export var dominion_zone_duration: float = 3.5
@export var dominion_zone_tick_damage: float = 6.0
@export var dominion_fan_count: int = 5
@export var dominion_fan_spread_degrees: float = 50.0
@export var dominion_projectile_damage: float = 8.0
@export var dominion_projectile_speed: float = 260.0
@export var dominion_summon_count: int = 2

@export var shadow_delay: float = 8.0 ## dryf Ruin (dawniej Głód) używa cienia jako "pościgu" — patrz komentarz przy _launch_shadow_attack

# --- Ruin (faza 4): Short Dash / Melee Chain / Delayed Follow-up ---
@export var ruin_dash_speed: float = 450.0
@export var ruin_dash_duration: float = 0.28
@export var ruin_dash_damage: float = 13.0
@export var ruin_chain_hit_damage: float = 15.0
@export var ruin_chain_followup_damage: float = 16.0
@export var ruin_chain_gap: float = 0.35
@export var ruin_chain_range: float = 130.0

# Atak fizyczny wspólny (kontakt ciała + baza wypadu, reużywane przez kilka faz)
@export var body_contact_damage: float = 10.0
@export var lunge_telegraph: float = 0.3
@export var lunge_speed: float = 500.0
@export var lunge_duration: float = 0.35
@export var lunge_damage: float = 25.0
@export var lunge_double_chance: float = 0.5

@export var knockback_strength: float = 400.0
@export var knockback_friction: float = 2000.0

@export var sprite_scale: float = 0.28
@export var final_sprite_scale: float = 0.13
@export var cast_pose_duration: float = 0.4
@export var rebirth_pose_duration: float = 0.6

@onready var sprite: Sprite2D = $Sprite
@onready var lunge_warning: Sprite2D = $LungeWarning
@onready var sfx: AudioStreamPlayer2D = $Sfx

var _facing_direction: Vector2 = Vector2.ZERO
var _cast_pose_variants: Dictionary = {}
var _cast_pose_timer: float = 0.0
var _taunt_pose_active: bool = false
var _rebirth_pose_timer: float = 0.0

var health: float
var max_health: float
var phase_index: int = 0
var is_final_phase: bool = false
var is_dead: bool = false

var _invulnerable: bool = false
var _time_since_hit: float = 0.0
var _flash_frames: int = 0

var _attack_timer: float = 0.0
var current_color: Color

var player: Player = null
var arena_rect: Rect2

var _position_history: PackedVector2Array = PackedVector2Array()
var _history_write_index: int = 0

var _lunge_state: String = ""
var _lunge_timer: float = 0.0
var _lunge_direction: Vector2 = Vector2.ZERO
var _lunge_target: Vector2 = Vector2.ZERO
var _lunge_did_double: bool = false
var _lunge_damage_override: float = -1.0 ## -1 = użyj lunge_damage domyślnego; ustawiane przez fazy, które chcą inny obrażeń wypadu (Ruin/Motion)
var _pending_double_chance: float = -1.0 ## -1 = użyj lunge_double_chance; nadpisywane per-wywołanie przez wzorce, które chcą wymusić/wykluczyć podwójny wypad

var _knockback_velocity: Vector2 = Vector2.ZERO

@export var walk_cycle_speed: float = 6.0
var _walk_cycle_phase: float = 0.0

## Grupy wzorców per faza (dokument sekcja 11/13): każda faza ma WŁASNĄ listę
## {"name","weight","action"}, przypisywaną w _enter_phase()/_ready(). Losowanie
## ważone + anti-repeat na poziomie GRUPY (nie pojedynczego ataku wewnątrz niej).
var _pattern_groups: Array[Dictionary] = []
var _last_pattern_name: String = ""

func _ready() -> void:
	max_health = phase_max_health
	health = max_health
	current_color = Palette.PHASE_COLORS[0]
	add_to_group("hittable")
	player = get_tree().get_first_node_in_group("player") as Player
	_attack_timer = attack_interval
	_init_position_history()
	sprite.scale = Vector2(sprite_scale, sprite_scale)
	var contact_shadow := ContactShadow.new()
	contact_shadow.position = Vector2(0.0, 72.0)
	contact_shadow.configure(radius * 1.25, radius * 0.30, 0.52) # wyraźniejszy (KIERUNEK_WIZUALNY_REFERENCJE.md)
	add_child(contact_shadow)
	lunge_warning.texture = TEX_LUNGE_WARNING
	lunge_warning.centered = true
	lunge_warning.offset = Vector2(0.0, -lunge_warning.texture.get_height() * 0.5)
	var lunge_reach := lunge_speed * lunge_duration
	var lunge_warning_scale := (lunge_reach / LUNGE_WARNING_CONTENT_HEIGHT) * LUNGE_WARNING_SAFETY_MARGIN
	lunge_warning.scale = Vector2(lunge_warning_scale, lunge_warning_scale)
	_pattern_groups = _build_pattern_groups(0)
	_update_sprite_state()

func _init_position_history() -> void:
	var frame_count: int = max(1, int(shadow_delay * Engine.physics_ticks_per_second))
	_position_history.resize(frame_count)
	var start_pos: Vector2 = player.global_position if player else Vector2.ZERO
	for i in range(frame_count):
		_position_history[i] = start_pos

func _physics_process(delta: float) -> void:
	if player == null:
		return
	if is_dead:
		_update_sprite_state()
		queue_redraw()
		return

	_record_player_position()
	_time_since_hit += delta
	_check_body_contact()

	if _knockback_velocity.length() > 1.0:
		global_position = _clamp_to_arena(global_position + _knockback_velocity * delta)
		_knockback_velocity = _knockback_velocity.move_toward(Vector2.ZERO, knockback_friction * delta)
	elif _lunge_state != "":
		_process_lunge(delta)
	elif not _invulnerable:
		_drift_towards_player(delta)
		_walk_cycle_phase += delta * walk_cycle_speed
		_handle_hunger_regen(delta)
		_attack_timer -= delta
		if _attack_timer <= 0.0:
			_attack_timer = _effective_attack_interval()
			_perform_random_pattern()

	if _flash_frames > 0:
		_flash_frames -= 1
	if _cast_pose_timer > 0.0:
		_cast_pose_timer -= delta
	if _rebirth_pose_timer > 0.0:
		_rebirth_pose_timer -= delta

	lunge_warning.visible = _lunge_state == "telegraph"
	if _lunge_state == "telegraph":
		lunge_warning.rotation = (_lunge_target - global_position).angle() + PI * 0.5

	_update_sprite_state()
	queue_redraw()

func _is_low_health() -> bool:
	return max_health > 0.0 and (health / max_health) <= low_health_threshold

func _effective_attack_interval() -> float:
	var base := final_attack_interval if is_final_phase else attack_interval
	return base * low_health_tempo_multiplier if _is_low_health() else base

func _check_body_contact() -> void:
	if player == null or player.is_invulnerable():
		return
	var to_player: Vector2 = player.global_position - global_position
	if to_player.length() > radius + player.radius:
		return
	var damage := (_lunge_damage_override if _lunge_damage_override >= 0.0 else lunge_damage) if _lunge_state == "active" else body_contact_damage
	player.take_damage(damage)
	var dir := to_player.normalized() if to_player.length() > 0.01 else Vector2.RIGHT
	player.apply_knockback(dir * knockback_strength)
	_play_sfx(SND_BODY_CONTACT)

func apply_knockback(impulse: Vector2) -> void:
	_knockback_velocity = impulse

## Wspólny prymityw pulsu (wzorem Incarnation._damage_pulse) — kilka wzorców
## różnych faz to po prostu pulsy o innym zasięgu/obrażeniach.
func _damage_pulse(pulse_radius: float, damage: float) -> bool:
	if player.is_invulnerable():
		return false
	if global_position.distance_to(player.global_position) > pulse_radius:
		return false
	player.take_damage(damage)
	var dir: Vector2 = player.global_position - global_position
	player.apply_knockback((dir.normalized() if dir.length() > 0.01 else Vector2.RIGHT) * knockback_strength)
	return true

## Wspólny wypad (Motion/Ruin/Sovereignty korzystają z tego samego mechanizmu,
## tylko z innymi parametrami) — target ustalany RAZ w chwili startu (nie
## namierza na bieżąco), żeby dało się go uniknąć zejściem z linii ataku.
func _begin_lunge(target: Vector2, speed: float, duration: float, damage: float, telegraph: float, double_chance: float) -> void:
	_lunge_did_double = false
	_lunge_damage_override = damage
	_pending_double_chance = double_chance
	_lunge_state = "telegraph"
	_lunge_timer = telegraph
	_lunge_target = target
	_play_sfx(SND_LUNGE_TELEGRAPH)
	# _process_lunge musi znać prędkość/czas trwania TEGO konkretnego wypadu —
	# zapamiętane tu, odczytane w _process_lunge zamiast stałych domyślnych.
	_active_lunge_speed = speed
	_active_lunge_duration = duration

var _active_lunge_speed: float = 0.0
var _active_lunge_duration: float = 0.0

func _process_lunge(delta: float) -> void:
	_lunge_timer -= delta
	if _lunge_state == "telegraph":
		if _lunge_timer <= 0.0:
			_lunge_state = "active"
			_lunge_timer = _active_lunge_duration
			var to_target: Vector2 = _lunge_target - global_position
			_lunge_direction = to_target.normalized() if to_target.length() > 0.01 else Vector2.RIGHT
			_play_sfx(SND_LUNGE_CHARGE)
	else: # "active"
		global_position = _clamp_to_arena(global_position + _lunge_direction * _active_lunge_speed * delta)
		if _lunge_timer <= 0.0:
			var chance := lunge_double_chance if _pending_double_chance < 0.0 else _pending_double_chance
			if not _lunge_did_double and randf() < chance and player != null:
				_lunge_did_double = true
				_lunge_state = "telegraph"
				_lunge_timer = lunge_telegraph
				_lunge_target = player.global_position
				_play_sfx(SND_LUNGE_TELEGRAPH)
			else:
				_lunge_state = ""

func _clamp_to_arena(pos: Vector2) -> Vector2:
	var r := arena_rect
	return Vector2(
		clamp(pos.x, r.position.x + radius, r.position.x + r.size.x - radius),
		clamp(pos.y, r.position.y + radius, r.position.y + r.size.y - radius)
	)

func _record_player_position() -> void:
	_position_history[_history_write_index] = player.global_position
	_history_write_index = (_history_write_index + 1) % _position_history.size()

func _get_history_snapshot(delay_seconds: float) -> PackedVector2Array:
	var size := _position_history.size()
	var frames: int = clamp(int(delay_seconds * Engine.physics_ticks_per_second), 1, size)
	var start_idx: int = ((_history_write_index - frames) % size + size) % size
	var snapshot := PackedVector2Array()
	snapshot.resize(frames)
	for i in range(frames):
		snapshot[i] = _position_history[(start_idx + i) % size]
	return snapshot

func _drift_towards_player(delta: float) -> void:
	var to_player: Vector2 = player.global_position - global_position
	if to_player.length() > 1.0:
		_facing_direction = to_player
		global_position += to_player.normalized() * boss_drift_speed * delta

## Ruin (faza 4, dawniej Głód) — reguła bez zmian co do indeksu/treści.
func _handle_hunger_regen(delta: float) -> void:
	if phase_index < 4:
		return
	if _time_since_hit >= hunger_regen_delay and health < max_health:
		health = min(max_health, health + hunger_regen_rate * delta)

# === Grupy wzorców: wybór ważony + anti-repeat na poziomie grupy ===

## Wydzielone dla testowalności — czysta arytmetyka bez efektów ubocznych.
func _weighted_pick(groups: Array[Dictionary]) -> String:
	var total_weight := 0.0
	for g in groups:
		total_weight += float(g["weight"])
	var roll := randf() * total_weight
	var cumulative := 0.0
	for g in groups:
		cumulative += float(g["weight"])
		if roll <= cumulative:
			return g["name"]
	return groups[-1]["name"]

func _choose_pattern_name(groups: Array[Dictionary], previous: String) -> String:
	var choice := _weighted_pick(groups)
	var attempts := 0
	while choice == previous and groups.size() > 1 and attempts < 20:
		choice = _weighted_pick(groups)
		attempts += 1
	return choice

func _perform_random_pattern() -> void:
	if _pattern_groups.is_empty():
		return
	var name := _choose_pattern_name(_pattern_groups, _last_pattern_name)
	_last_pattern_name = name
	for g in _pattern_groups:
		if g["name"] == name:
			(g["action"] as Callable).call()
			return

## Buduje grupy wzorców danej fazy — wołane w _ready() (faza 0) i _enter_phase().
## Sovereignty (indeks 5) ma dodatkowo przeważanie zależne od zdrowia (dokument:
## "below 50% HP: S4 25%, others rebalanced") — obsłużone osobno w _perform_random_pattern
## nadpisaniu dla tej fazy, patrz _build_pattern_groups_sovereignty().
func _build_pattern_groups(index: int) -> Array[Dictionary]:
	match index:
		0: return _build_pattern_groups_motion()
		1: return _build_pattern_groups_force()
		2: return _build_pattern_groups_instinct()
		3: return _build_pattern_groups_dominion()
		4: return _build_pattern_groups_ruin()
		5: return _build_pattern_groups_sovereignty()
		_: return _build_pattern_groups_motion()

# --- Motion (faza 0) ---

func _build_pattern_groups_motion() -> Array[Dictionary]:
	return [
		{"name": "M1_dash_only", "weight": 0.35, "action": _attack_motion_dash_only},
		{"name": "M2_dash_and_strike", "weight": 0.40, "action": _attack_motion_dash_and_strike},
		{"name": "M3_dash_through_return", "weight": 0.25, "action": _attack_motion_dash_through_return},
	]

func _attack_motion_dash_only() -> void:
	_begin_lunge(player.global_position, motion_dash_speed, motion_dash_duration, motion_dash_damage, motion_dash_telegraph, 0.0)

func _attack_motion_dash_and_strike() -> void:
	_begin_lunge(player.global_position, motion_dash_speed, motion_dash_duration, motion_dash_damage, motion_dash_telegraph, 0.0)
	await get_tree().create_timer(motion_dash_telegraph + motion_dash_duration + 0.15).timeout
	if not is_dead:
		_set_cast_pose(TEX_CAST_PULSE_VARIANTS)
		_damage_pulse(motion_short_strike_range, motion_short_strike_damage)

func _attack_motion_dash_through_return() -> void:
	# Wymuszony podwójny wypad (Delayed Return, dokument) zamiast losowego —
	# ta grupa ISTNIEJE po to, żeby to zagwarantować.
	_begin_lunge(player.global_position, motion_dash_speed, motion_dash_duration, motion_delayed_return_damage, motion_dash_telegraph, 1.0)

# --- Force (faza 1) ---

func _build_pattern_groups_force() -> Array[Dictionary]:
	return [
		{"name": "F1_wide_strike", "weight": 0.40, "action": _attack_force_wide_strike},
		{"name": "F2_radial_warning", "weight": 0.30, "action": _attack_force_radial_warning},
		{"name": "F3_advance_pressure", "weight": 0.30, "action": _attack_force_advance_pressure},
	]

func _attack_force_wide_strike() -> void:
	_set_cast_pose(TEX_CAST_PULSE_VARIANTS)
	await get_tree().create_timer(0.85).timeout
	if not is_dead:
		_damage_pulse(force_wide_strike_range, force_wide_strike_damage)

func _attack_force_radial_warning() -> void:
	_launch_seal_attack()

func _attack_force_advance_pressure() -> void:
	_set_cast_pose(TEX_CAST_PULSE_VARIANTS)
	for i in range(force_advance_steps):
		await get_tree().create_timer(force_advance_step_delay).timeout
		if is_dead:
			return
	_damage_pulse(force_wide_strike_range, force_advance_damage)

# --- Instinct (faza 2) ---

func _build_pattern_groups_instinct() -> Array[Dictionary]:
	return [
		{"name": "I1_reposition_strike", "weight": 0.40, "action": _attack_instinct_reposition_strike},
		{"name": "I2_feint", "weight": 0.30, "action": _attack_instinct_feint},
		{"name": "I3_quick_strike", "weight": 0.30, "action": _attack_instinct_quick_strike},
	]

func _attack_instinct_reposition_strike() -> void:
	global_position = _random_arena_point(instinct_reposition_margin)
	_set_cast_pose(TEX_TELEGRAPH_VARIANTS)
	await get_tree().create_timer(instinct_strike_telegraph).timeout
	if not is_dead:
		_damage_pulse(instinct_strike_range, instinct_strike_damage)

## Zapowiedź BEZ obrażeń (dokument: "feint cannot itself damage") — czysty test
## reakcji gracza, odróżnia fałszywe zagrożenie od prawdziwego ataku.
func _attack_instinct_feint() -> void:
	_set_cast_pose(TEX_TELEGRAPH_VARIANTS)
	await get_tree().create_timer(instinct_feint_duration).timeout

func _attack_instinct_quick_strike() -> void:
	_set_cast_pose(TEX_CAST_PULSE_VARIANTS)
	await get_tree().create_timer(instinct_quick_strike_telegraph).timeout
	if not is_dead:
		_damage_pulse(instinct_strike_range, instinct_quick_strike_damage)

# --- Dominion (faza 3) ---

func _build_pattern_groups_dominion() -> Array[Dictionary]:
	return [
		{"name": "D1_zone", "weight": 0.25, "action": _attack_dominion_zone},
		{"name": "D2_projectile_fan", "weight": 0.25, "action": _attack_dominion_projectile_fan},
		{"name": "D3_summon", "weight": 0.20, "action": _attack_dominion_summon},
		{"name": "D4_zone_and_fan", "weight": 0.15, "action": _attack_dominion_zone_and_fan},
		{"name": "D5_void_lock", "weight": 0.15, "action": _attack_dominion_void_lock},
	]

## Ząb Zera (dawny atak "Zerowa Otchłań", zachowany jako część kontroli
## planszy Dominion — jedyny atak w grze, który nie rani, tylko blokuje dash,
## dokładnie jak wcześniej) — patrz entities/void_zone.gd.
func _attack_dominion_void_lock() -> void:
	_set_cast_pose(TEX_CAST_PULSE_VARIANTS)
	var zone = VoidZoneScene.instantiate()
	zone.player = player
	zone.boss = self
	zone.global_position = _random_arena_point(zone.void_radius)
	get_parent().add_child(zone)

func _attack_dominion_zone() -> void:
	_set_cast_pose(TEX_CAST_PULSE_VARIANTS)
	var zone := DamageZoneScene.instantiate()
	zone.zone_radius = dominion_zone_radius
	zone.duration = dominion_zone_duration
	zone.tick_damage = dominion_zone_tick_damage
	zone.global_position = _random_arena_point(dominion_zone_radius)
	get_parent().add_child(zone)

func _attack_dominion_projectile_fan() -> void:
	_set_cast_pose(TEX_CAST_PULSE_VARIANTS)
	var to_player: Vector2 = player.global_position - global_position
	var base_angle := to_player.angle() if to_player.length() > 0.01 else 0.0
	var spread := deg_to_rad(dominion_fan_spread_degrees)
	var count: int = max(1, dominion_fan_count)
	for i in range(count):
		var t: float = 0.0 if count == 1 else (float(i) / float(count - 1)) - 0.5
		var angle := base_angle + t * spread
		var direction := Vector2.RIGHT.rotated(angle)
		var projectile := EnemyProjectileScene.instantiate()
		projectile.direction = direction
		projectile.damage = dominion_projectile_damage
		projectile.speed = dominion_projectile_speed
		projectile.global_position = global_position + direction * (radius + 10.0)
		get_parent().add_child(projectile)

## Dodatki bez XP i bez wpływu na czyszczenie pokoju (dokument: "summoned units
## default to 0 XP") — ten sam wzorzec co entities/random_enemies/summoner.gd:
## `died` celowo nie podpięte pod nic.
func _attack_dominion_summon() -> void:
	_set_cast_pose(TEX_PULL_VARIANTS)
	for i in range(dominion_summon_count):
		var add: Incarnation = ChaserScene.instantiate()
		var offset := Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)).normalized() * 80.0
		get_parent().add_child(add)
		add.arena_rect = arena_rect
		add.global_position = _clamp_to_arena(global_position + offset)
		add.apply_difficulty_scale(0.6)

func _attack_dominion_zone_and_fan() -> void:
	_attack_dominion_zone()
	await get_tree().create_timer(0.8).timeout
	if not is_dead:
		_attack_dominion_projectile_fan()

# --- Ruin (faza 4) ---

func _build_pattern_groups_ruin() -> Array[Dictionary]:
	return [
		{"name": "R1_dash_cleave", "weight": 0.35, "action": _attack_ruin_dash_cleave},
		{"name": "R2_chain_followup", "weight": 0.35, "action": _attack_ruin_chain_followup},
		{"name": "R3_pursuit_strike", "weight": 0.30, "action": _attack_ruin_pursuit_strike},
	]

func _attack_ruin_dash_cleave() -> void:
	_begin_lunge(player.global_position, ruin_dash_speed, ruin_dash_duration, ruin_dash_damage, 0.42, 0.0)

func _attack_ruin_chain_followup() -> void:
	_set_cast_pose(TEX_CAST_PULSE_VARIANTS)
	_damage_pulse(ruin_chain_range, ruin_chain_hit_damage)
	await get_tree().create_timer(ruin_chain_gap).timeout
	if not is_dead:
		_damage_pulse(ruin_chain_range, ruin_chain_followup_damage)

func _attack_ruin_pursuit_strike() -> void:
	_spawn_shadow(shadow_delay * 0.5) ## echo bliższe teraźniejszości = czytelne jako "pościg"

# --- Sovereignty (faza 5) — synteza wcześniejszych faz, jedna grupa naraz ---

func _build_pattern_groups_sovereignty() -> Array[Dictionary]:
	var s4_weight := 0.25 if _is_low_health() else 0.15
	var remaining := 1.0 - s4_weight
	return [
		{"name": "S1_motion_force", "weight": remaining * (0.30 / 0.85), "action": _attack_sovereignty_s1},
		{"name": "S2_instinct_ruin", "weight": remaining * (0.30 / 0.85), "action": _attack_sovereignty_s2},
		{"name": "S3_dominion_motion", "weight": remaining * (0.25 / 0.85), "action": _attack_sovereignty_s3},
		{"name": "S4_crown_sequence", "weight": s4_weight, "action": _attack_sovereignty_crown_sequence},
	]

func _attack_sovereignty_s1() -> void:
	_attack_motion_dash_only()
	await get_tree().create_timer(motion_dash_telegraph + motion_dash_duration + 0.2).timeout
	if not is_dead:
		_attack_force_wide_strike()

func _attack_sovereignty_s2() -> void:
	_attack_instinct_reposition_strike()
	await get_tree().create_timer(instinct_strike_telegraph + 0.3).timeout
	if not is_dead:
		_attack_ruin_dash_cleave()

func _attack_sovereignty_s3() -> void:
	_attack_dominion_zone()
	await get_tree().create_timer(0.6).timeout
	if not is_dead:
		_attack_dominion_projectile_fan()

## "Crown Sequence" (dokument sekcja 13.7) — łańcuch po jednym ruchu z KAŻDEJ
## wcześniejszej fazy, najdłuższa i najbardziej czytelna sekwencja w walce.
func _attack_sovereignty_crown_sequence() -> void:
	_attack_motion_dash_only()
	await get_tree().create_timer(motion_dash_telegraph + motion_dash_duration + 0.25).timeout
	if is_dead:
		return
	_attack_force_wide_strike()
	await get_tree().create_timer(1.1).timeout
	if is_dead:
		return
	_attack_instinct_reposition_strike()
	await get_tree().create_timer(instinct_strike_telegraph + 0.3).timeout
	if is_dead:
		return
	_attack_dominion_zone()
	await get_tree().create_timer(0.5).timeout
	if is_dead:
		return
	_attack_ruin_dash_cleave()

# === Ataki dzielone między fazy (pieczęcie/cień) ===

func _set_cast_pose(variants: Dictionary) -> void:
	_cast_pose_variants = variants
	_cast_pose_timer = cast_pose_duration
	_play_sfx(SND_ATTACK_INHALE)

func _launch_seal_attack() -> void:
	_set_cast_pose(TEX_CAST_PULSE_VARIANTS)
	var probe = SealScene.instantiate()
	var margin: float = probe.seal_radius
	probe.free()

	var points: Array = []
	var attempts := 0
	while points.size() < seal_count and attempts < 500:
		attempts += 1
		var p := _random_arena_point(margin)
		var ok := true
		for existing in points:
			if p.distance_to(existing) < seal_min_distance:
				ok = false
				break
		if ok:
			points.append(p)
	for i in range(points.size()):
		var seal = SealScene.instantiate()
		seal.player = player
		seal.stagger_delay = i * seal_interval
		seal.global_position = points[i]
		get_parent().add_child(seal)

func _spawn_shadow(delay_seconds: float) -> void:
	var shadow = ShadowScene.instantiate()
	shadow.player = player
	shadow.trace = _get_history_snapshot(delay_seconds)
	if shadow.trace.size() > 0:
		shadow.global_position = shadow.trace[0]
	get_parent().add_child(shadow)

func _random_arena_point(margin: float) -> Vector2:
	var r: Rect2 = arena_rect
	return Vector2(
		randf_range(r.position.x + margin, r.position.x + r.size.x - margin),
		randf_range(r.position.y + margin, r.position.y + r.size.y - margin)
	)

func take_damage(amount: float) -> void:
	if is_dead or _invulnerable:
		return
	health -= amount
	_time_since_hit = 0.0
	if health > 0.0:
		_play_sfx(SND_HURT)
		return

	health = 0.0
	var last_phase_index := Palette.PHASE_COLORS.size() - 1
	if is_final_phase or phase_index >= last_phase_index:
		is_dead = true
		_play_sfx(SND_TRANSFORM_ROAR if is_final_phase else SND_BIGFORM_COLLAPSE)
		died.emit(is_final_phase)
	else:
		_enter_phase(phase_index + 1)

func _enter_phase(new_index: int) -> void:
	phase_index = new_index
	var multiplier: float = PHASE_HP_MULTIPLIERS[new_index] if new_index < PHASE_HP_MULTIPLIERS.size() else 1.0
	health = phase_max_health * multiplier
	max_health = phase_max_health * multiplier
	current_color = Palette.PHASE_COLORS[phase_index]
	_pattern_groups = _build_pattern_groups(phase_index)
	_last_pattern_name = ""
	phase_changed.emit(phase_index, current_color, Palette.PHASE_NAMES[phase_index])
	_start_transform_invulnerability()

func _start_transform_invulnerability() -> void:
	_invulnerable = true
	Juice.screen_shake()
	_play_sfx(SND_TRANSFORM_ROAR)
	await get_tree().create_timer(phase_transform_invuln).timeout
	_invulnerable = false

func delay_next_attack(seconds: float) -> void:
	_attack_timer = max(_attack_timer, seconds)

func flash_white() -> void:
	_flash_frames = 2

func start_final_phase() -> void:
	is_dead = false
	is_final_phase = true
	radius = final_radius
	health = final_health
	max_health = final_health
	current_color = Palette.PHASE_COLORS[5]
	_attack_timer = final_attack_interval
	sprite.scale = Vector2(final_sprite_scale, final_sprite_scale)
	_rebirth_pose_timer = rebirth_pose_duration
	_play_sfx(SND_SMALLFORM_RESURRECT)

func show_taunt_pose(duration: float) -> void:
	_taunt_pose_active = true
	get_tree().create_timer(duration).timeout.connect(func(): _taunt_pose_active = false)

func _play_sfx(stream: AudioStream) -> void:
	sfx.stream = stream
	sfx.play()

func _update_sprite_state() -> void:
	var entry
	var is_walk_pose := false
	if is_dead:
		entry = TEX_SMALL_FORM_TRUE_DEATH_VARIANTS if is_final_phase else TEX_LARGE_FORM_COLLAPSE_VARIANTS
	elif _rebirth_pose_timer > 0.0:
		entry = TEX_SMALL_FORM_REBIRTH_VARIANTS
	elif _taunt_pose_active:
		entry = TEX_SMALL_FORM_TAUNT_VARIANTS
	elif _invulnerable:
		entry = TEX_PHASE_TRANSFORM_VARIANTS
	elif _flash_frames > 0:
		entry = TEX_HIT_VARIANTS
	elif _cast_pose_timer > 0.0:
		entry = _cast_pose_variants
	elif _lunge_state == "telegraph":
		entry = TEX_TELEGRAPH_VARIANTS
	elif _lunge_state == "active":
		entry = TEX_LUNGE_VARIANTS
	else:
		entry = PHASE_BASE_TEXTURES[phase_index]
		is_walk_pose = true
	if entry != null:
		var frame := _walk_cycle_frame() if is_walk_pose else 0
		var facing := Facing.resolve(entry, _facing_direction, frame)
		sprite.texture = facing["texture"]
		sprite.flip_h = facing["flip_h"]

func _walk_cycle_frame() -> int:
	return int(_walk_cycle_phase) % 2

func _draw() -> void:
	if not is_dead:
		var ring_width := 5.0 if _lunge_state == "telegraph" else 3.0
		draw_arc(Vector2.ZERO, radius + 4.0, 0.0, TAU, 32, Color(Palette.DANGER, 0.9), ring_width)
