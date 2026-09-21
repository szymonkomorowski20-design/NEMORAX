extends CharacterBody2D
class_name Player
## Gracz (sekcja 3). Ruch i dash trzymane są w prostym enumie stanu; atak (miecz
## lub różdżka) jest CELOWO niezależny od stanu ruchu — na życzenie autora da się
## machnąć/strzelić w dowolnym momencie dasha, więc trzyma się osobno przez
## _attack_phase i leci równolegle, niezależnie od tego, czy gracz właśnie dashuje.
## Broń (miecz/różdżka), blok i leczenie to dodatki na życzenie autora, poza dokumentem.

signal died

enum State { NORMAL, DASHING, DEAD }

const ProjectileScene := preload("res://entities/projectile.tscn")

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

# Fazy 3-5 (PLAN_ANIMACJE_KIERUNKOWE.md) — na razie każda ma tylko "front"
# (jedyny plik, jaki istnieje), ale już przechodzi przez Facing.resolve(), więc
# dowiezienie side/front_diagonal/back_diagonal/back kiedyś wystarczy dopisać
# jako nowe klucze tutaj, bez dalszych zmian w _update_visuals().
const TEX_BASE_VARIANTS := {"front": TEX_BASE}
const TEX_DASH_VARIANTS := {"front": TEX_DASH}
const TEX_SWORD_WINDUP_VARIANTS := {"front": TEX_SWORD_WINDUP}
const TEX_SWORD_ACTIVE_VARIANTS := {"front": TEX_SWORD_ACTIVE}
const TEX_WAND_WINDUP_VARIANTS := {"front": TEX_WAND_WINDUP}
const TEX_WAND_FIRE_VARIANTS := {"front": TEX_WAND_FIRE}
const TEX_BLOCK_VARIANTS := {"front": TEX_BLOCK}
const TEX_HEAL_VARIANTS := {"front": TEX_HEAL}
const TEX_HIT_VARIANTS := {"front": TEX_HIT}
const TEX_DEATH_VARIANTS := {"front": TEX_DEATH}
const TEX_SLASH_ARC := preload("res://assets/sprites/ekwipunek/sword_slash_arc.png")
const TEX_WAND_CHARGE := preload("res://assets/sprites/ekwipunek/wand_charge.png")
const TEX_DASH_TRAIL := preload("res://assets/sprites/ekwipunek/player_dash_trail.png")

# --- Dźwięki (P20/P21 — ból/śmierć gracza — jeszcze nie wygenerowane, brak na razie) ---
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
const SND_HEAL_USE := preload("res://assets/audio/sfx/gracz/P16_heal_use.wav")
const SND_HEAL_CHARGE_TICK := preload("res://assets/audio/sfx/gracz/P18_heal_charge_tick.wav")
const SND_HEAL_READY := preload("res://assets/audio/sfx/gracz/P19_heal_ready.wav")
const SND_KNOCKBACK := preload("res://assets/audio/sfx/gracz/P22_player_knockback.wav")

@onready var sprite: Sprite2D = $Sprite
@onready var slash_arc: Sprite2D = $SlashArc
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
@export var trail_ghost_scale: float = 0.08 ## kopie śladu dasha

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
@export var mana_regen_per_hit: float = 15.0 ## mana nie regeneruje się z czasem — wyłącznie za trafienia wroga

# --- Poziom postaci i punkty statystyk (na życzenie autora, poza dokumentem) ---
# 1 XP za KAŻDE pokonanie przeciwnika (patrz gain_xp(), wołane z room.gd/arena.gd),
# co xp_per_level XP daje +1 level, płasko (nie rosnąco), aż do max_level — 30
# pokoi ÷ 10 poziomów = dokładnie 3, więc level 10 wypada tuż przed ołtarzem
# przy normalnym tempie gry. Każdy level = 1 punkt do wydania w jedną z 6 statystyk
# (ui/stats_screen.gd, klawisz Tab).
@export var max_level: int = 10
@export var xp_per_level: float = 3.0
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

# --- Blok (prawy przycisk myszy) — dodane na życzenie autora, poza dokumentem ---
@export var block_stamina_cost_fraction: float = 0.75 ## ułamek MAX staminy zużywany na blok
@export var block_range: float = 90.0 ## px, zasięg odepchnięcia wroga blokiem
@export var block_knockback_strength: float = 500.0 ## px/s, siła odepchnięcia wroga blokiem
@export var block_invuln_duration: float = 0.3 ## s nietykalności przy bloku
@export var block_visual_duration: float = 0.15 ## s, jak długo pokazuje się poza bloku

# --- Leczenie (E) — dodane na życzenie autora, poza dokumentem. System
# "stacków": trafienia ładują pasek co heal_hits_per_stack aż do max_heal_stacks
# ładunków w banku naraz — E zużywa JEDEN stack na naciśnięcie, więc gracz sam
# decyduje, czy leczy się od razu, czy odkłada zapas na później. ---
@export var heal_hits_per_stack: int = 10 ## ile celnych trafień wroga ładuje jeden stack leczenia
@export var max_heal_stacks: int = 3 ## ile stacków leczenia można nabankować naraz
@export var heal_amount_fraction: float = 0.5 ## ułamek MAX zdrowia odzyskiwany JEDNYM stackiem
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
@export var second_impact_delay: float = 0.22 ## s, opóźnienie drugiego trafienia
@export var second_impact_damage_fraction: float = 0.45 ## ułamek obrażeń PIERWSZEGO trafienia
@export var second_impact_knockback_strength: float = 250.0 ## px/s, odepchnięcie celu drugim trafieniem
@export var second_impact_global_cooldown: float = 0.35 ## s, minimalny odstęp między kolejnymi procami
var _second_impact_cooldown_timer: float = 0.0

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
	_recompute_effective_stats()
	health = max_health
	stamina = max_stamina
	mana = max_mana
	add_to_group("player")
	collision_layer = 2
	collision_mask = 1
	sprite.scale = Vector2(sprite_scale, sprite_scale)
	var contact_shadow := ContactShadow.new()
	contact_shadow.position = Vector2(0.0, 32.0)
	contact_shadow.configure(68.0, 17.0, 0.44) # wyraźniejszy, dostrojony do powiększonego sprite_scale=0.10
	add_child(contact_shadow)
	slash_arc.scale = Vector2(slash_arc_scale, slash_arc_scale)
	slash_arc.texture = TEX_SLASH_ARC
	wand_charge_sprite.texture = TEX_WAND_CHARGE
	_update_visuals()

func _physics_process(delta: float) -> void:
	if state == State.DEAD:
		_update_visuals()
		return

	_tick_timers(delta)
	_tick_upgrade_timers(delta)
	_handle_weapon_switch()
	_handle_dash_input(delta)
	_handle_attack_input(delta) # niezależne od stanu ruchu — da się zacząć w trakcie dasha
	_handle_block_input()
	_handle_heal_input()

	match state:
		State.DASHING:
			_process_dash(delta)
		_:
			_process_normal_movement(delta)

	if _attack_phase != "":
		_process_attack_phase(delta) # leci równolegle, niezależnie od ruchu/dasha

	_tick_stamina_regen(delta)
	move_and_slide()
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
func _tick_stamina_regen(delta: float) -> void:
	var is_spending_stamina := state == State.DASHING or (_attack_phase != "" and _swing_weapon == "sword")
	if not is_spending_stamina:
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
	return cd

func _process_dash(delta: float) -> void:
	_dash_timer -= delta
	velocity = _dash_direction.normalized() * dash_speed
	if _dash_timer <= 0.0:
		state = State.NORMAL
		velocity = Vector2.ZERO
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

	var target_speed := max_speed * _upgrade_speed_multiplier()
	if _attack_phase != "":
		target_speed *= attack_move_speed_fraction

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
	return mult

## Last Resolve (niskie HP) i Soul Bond/Instinct (+szybkość ataku) skracają
## czas trwania faz ataku (windup/active/recovery) — "szybszy atak" = krótsze
## fazy, stąd dzielenie, nie mnożenie, w miejscach, gdzie się to stosuje.
func _attack_speed_multiplier() -> float:
	var mult := 1.0
	if has_upgrade("last_resolve") and _last_resolve_active:
		mult *= (1.0 + last_resolve_attack_speed_bonus)
	if has_upgrade("soul_bond") and _soul_bond_timer > 0.0 and _soul_bond_effect.has("attack_speed"):
		mult *= (1.0 + _soul_bond_effect["attack_speed"])
	return mult

## Soul Bond/Force (+odepchnięcie ZADAWANE) — dotyczy bloku i Second Impact;
## odepchnięcie OTRZYMYWANE (Iron Heart) jest osobne, patrz apply_knockback().
func _knockback_dealt_multiplier() -> float:
	if has_upgrade("soul_bond") and _soul_bond_timer > 0.0 and _soul_bond_effect.has("knockback_dealt"):
		return 1.0 + _soul_bond_effect["knockback_dealt"]
	return 1.0

func _can_afford_attack() -> bool:
	if current_weapon == "wand":
		return mana >= wand_mana_cost
	return stamina >= sword_stamina_cost

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
	elif _buffered_attack_timer > 0.0:
		_buffered_attack_timer -= delta

	if _attack_phase != "" or _buffered_attack_timer <= 0.0:
		return
	if not _can_afford_attack():
		return
	_buffered_attack_timer = 0.0
	_start_attack()

## Blok (PPM) — dodane na życzenie autora: koszt 3/4 max staminy, odpycha
## wszystko dookoła w zasięgu i daje krótką nietykalność (stąd "blok").
func _handle_block_input() -> void:
	if state == State.DEAD:
		return
	if not Input.is_action_just_pressed("block"):
		return
	var cost := max_stamina * block_stamina_cost_fraction
	if stamina < cost:
		_play_sfx(SND_ATTACK_DENIED)
		return
	stamina -= cost
	_invuln_timer = max(_invuln_timer, block_invuln_duration)
	_block_visual_timer = block_visual_duration
	_play_sfx(SND_BLOCK_RAISE)
	_perform_block_push()

func _perform_block_push() -> void:
	var pushed_something := false
	var knockback_strength := block_knockback_strength * _knockback_dealt_multiplier()
	for target in get_tree().get_nodes_in_group("hittable"):
		var to_target: Vector2 = target.global_position - global_position
		var target_radius: float = target.get("radius") if target.get("radius") != null else 0.0
		if to_target.length() > block_range + target_radius:
			continue
		if target.has_method("apply_knockback"):
			var dir := to_target.normalized() if to_target.length() > 0.01 else Vector2.RIGHT
			target.apply_knockback(dir * knockback_strength)
			pushed_something = true
	if pushed_something:
		_play_sfx(SND_BLOCK_PUSH_HIT)

## Leczenie (E) — trafienia ładują stacki (patrz register_hit_on_enemy), E
## zużywa JEDEN stack na naciśnięcie (nie cały bank naraz) i oddaje połowę MAX
## zdrowia — można więc leczyć się od razu albo bankować do max_heal_stacks
## i rozłożyć leczenie na kilka późniejszych naciśnięć.
func _handle_heal_input() -> void:
	if state == State.DEAD:
		return
	if not Input.is_action_just_pressed("heal"):
		return
	if _heal_stacks <= 0:
		_play_sfx(SND_ATTACK_DENIED)
		return
	_heal_stacks -= 1
	_heal_visual_timer = heal_visual_duration
	health = min(max_health, health + max_health * heal_amount_fraction)
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
	while xp >= xp_per_level and level < max_level:
		xp -= xp_per_level
		level += 1
		unspent_stat_points += 1
	if level >= max_level:
		xp = 0.0

## Postęp do następnego levela (0-1) — do paska w ui/stats_screen.gd. 0 na max_level.
func xp_ratio() -> float:
	return 0.0 if level >= max_level else xp / xp_per_level

## Wywoływane z ui/stats_screen.gd po naciśnięciu Enter na wybranej statystyce.
## Zwraca false (i nic nie robi), jeśli nie ma punktów do wydania.
func spend_stat_point(stat_key: String) -> bool:
	if unspent_stat_points <= 0 or not stat_points.has(stat_key):
		return false
	unspent_stat_points -= 1
	stat_points[stat_key] += 1
	_recompute_effective_stats()
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
	max_stamina = base_max_stamina + stat_points["stamina"] * stamina_per_point
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
	_swing_weapon = current_weapon # broń "zamrożona" na czas tego zamachu
	if _swing_weapon == "wand":
		mana -= wand_mana_cost
		_play_sfx(SND_WAND_CHARGE)
	else:
		stamina -= sword_stamina_cost
	_attack_phase = "windup"
	_attack_timer = (wand_windup if _swing_weapon == "wand" else attack_windup) / _attack_speed_multiplier()
	_attack_direction = (get_global_mouse_position() - global_position).normalized()
	_attack_hit_targets.clear()
	_current_attack_damage = _compute_attack_start_damage()
	_current_attack_range = attack_range
	if has_upgrade("void_step") and _void_step_range_timer > 0.0:
		_current_attack_range *= (1.0 + void_step_range_bonus)
		_void_step_range_timer = 0.0 # zużyte, jednorazowo (dokument: "one range charge")

## Wołane RAZ na cały zamach (nie per-cel) — Blood Edge/Last Resolve/Soul
## Echo/Soul Bond nie mogą się różnić trafienie-do-trafienia w obrębie
## JEDNEGO machnięcia mieczem (dokument: "one boosted attack snapshot").
## Hunter's Mark jest wyjątkiem: zależy od KONKRETNEGO celu, więc liczy się
## osobno w resolve_hit_damage() w chwili trafienia, nie tutaj.
func _compute_attack_start_damage() -> float:
	var base := wand_damage if _swing_weapon == "wand" else attack_damage
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
	var projectile = ProjectileScene.instantiate()
	projectile.direction = _attack_direction
	projectile.damage = _current_attack_damage
	projectile.speed = wand_projectile_speed
	projectile.lifetime = wand_projectile_lifetime
	projectile.shooter = self # żeby pocisk mógł oddać manę za trafienie
	projectile.global_position = global_position + _attack_direction * (radius + 6.0)
	get_parent().add_child(projectile)

## Wywoływane za KAŻDE celne trafienie wroga, niezależnie jaką bronią — jedyny
## sposób odzyskania many, a co heal_hits_per_stack-te takie trafienie dokłada
## jeden stack leczenia (do max_heal_stacks — powyżej banku trafienia nic już
## nie robią, żeby nie liczyć w nieskończoność stanu, który i tak przepadnie).
func register_hit_on_enemy() -> void:
	mana = min(max_mana, mana + mana_regen_per_hit)
	if _heal_stacks >= max_heal_stacks:
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
	if has_upgrade("hunters_mark"):
		return _apply_hunters_mark(target, base_damage)
	return base_damage

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
func on_hit_confirmed(target: Node, damage_dealt: float) -> void:
	register_hit_on_enemy()
	if has_upgrade("blood_edge"):
		_blood_edge_armed = true
		_blood_edge_timer = blood_edge_arm_duration
	if has_upgrade("second_impact"):
		_maybe_schedule_second_impact(target, damage_dealt)

## 30% szansy na kolejne, opóźnione trafienie za 45% obrażeń pierwszego —
## globalny cooldown (nie per-cel) pilnuje, żeby nie odpalało się bez końca
## przy szybkich wielotrafieniowych zamachach.
func _maybe_schedule_second_impact(target: Node, base_damage: float) -> void:
	if _second_impact_cooldown_timer > 0.0:
		return
	if randf() >= second_impact_chance:
		return
	_second_impact_cooldown_timer = second_impact_global_cooldown
	var impact_damage := base_damage * second_impact_damage_fraction
	get_tree().create_timer(second_impact_delay).timeout.connect(
		_fire_second_impact.bind(target, impact_damage, global_position)
	)

## Rewaliduje cel przy odpaleniu (dokument: "revalidate target/location at
## fire") — mógł umrzeć albo zniknąć (queue_free/reset pokoju) w tym
## opóźnieniu. Nie woła on_hit_confirmed() ponownie: drugie trafienie nie może
## samo siebie/Blood Edge/Second Impact ponownie uzbroić (dokument).
func _fire_second_impact(target: Node, damage: float, origin_pos: Vector2) -> void:
	if not is_instance_valid(target):
		return
	if target.get("is_dead") == true:
		return
	Juice.apply_hit(target, damage)
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
	var half_angle := deg_to_rad(attack_angle_degrees) * 0.5
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
		Juice.apply_hit(target, damage)
		on_hit_confirmed(target, damage)
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

## Zanikająca kopia śladu dasha — osobny top_level Sprite2D zamiast wpisu w
## tablicy do _draw(), żeby została w miejscu spawnu zamiast jechać z graczem.
func _spawn_trail_ghost() -> void:
	var ghost := Sprite2D.new()
	ghost.texture = TEX_DASH_TRAIL
	ghost.scale = Vector2(trail_ghost_scale, trail_ghost_scale)
	ghost.top_level = true
	ghost.global_position = global_position
	ghost.modulate = Color(1.0, 1.0, 1.0, 0.5)
	add_child(ghost)
	var tw := create_tween()
	tw.tween_property(ghost, "modulate:a", 0.0, dash_trail_lifetime)
	tw.tween_callback(ghost.queue_free)

## Wywoływane z zewnątrz (pieczęcie, cień, kontakt) — jedna, wspólna brama obrażeń,
## dzięki której nietykalność po trafieniu działa tak samo niezależnie od źródła.
func take_damage(amount: float) -> void:
	if state == State.DEAD:
		return
	if state == State.DASHING or _invuln_timer > 0.0:
		return
	health -= amount
	if has_upgrade("momentum"):
		_momentum_stacks = 0
		_momentum_timer = 0.0
	_invuln_timer = damage_invulnerability
	_flash_frames = 2
	Juice.hitstop(Juice.player_hit_hitstop)
	Juice.screen_shake()
	if health <= 0.0:
		health = 0.0
		state = State.DEAD
		died.emit()

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

func flash_white() -> void:
	_flash_frames = 2

func _play_sfx(stream: AudioStream) -> void:
	sfx.stream = stream
	sfx.play()

## Zastępuje dawny _draw() — wybiera właściwą teksturę wg priorytetu stanu i
## ustawia VFX ataku (wycinek miecza / kula różdżki) w miejsce dawnych rysowanych kształtów.
func _apply_facing(variants: Dictionary, direction: Vector2, frame: int = 0) -> void:
	var facing := Facing.resolve(variants, direction, frame)
	sprite.texture = facing["texture"]
	sprite.flip_h = facing["flip_h"]

## Każda poza przechodzi przez Facing.resolve() z WŁAŚCIWYM dla siebie
## źródłem kierunku (dokument, sekcja 2: mysz dla akcji bojowych, WASD dla
## chodu/dasha) — dziś każdy słownik ma tylko klucz "front", więc wizualnie
## nic się nie zmienia dopóki nie dowiezie się grafiki na resztę kątów
## (Facing.resolve() sam degraduje do "front" i NIE odbija fallbacku, patrz
## facing.gd), ale caly kod jest już gotowy na Fazy 3-5.
func _update_visuals() -> void:
	if state == State.DEAD:
		_apply_facing(TEX_DEATH_VARIANTS, _last_move_direction)
	elif _flash_frames > 0:
		_apply_facing(TEX_HIT_VARIANTS, _last_move_direction)
	elif _block_visual_timer > 0.0:
		_apply_facing(TEX_BLOCK_VARIANTS, _attack_direction)
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
	sprite.visible = not blinking_hidden

	var showing_slash := _attack_phase != "" and _swing_weapon == "sword"
	slash_arc.visible = showing_slash
	if showing_slash:
		slash_arc.rotation = _attack_direction.angle()
		slash_arc.position = _attack_direction * (_current_attack_range * 0.5)
		slash_arc.modulate.a = 0.5 if _attack_phase == "windup" else 1.0

	var showing_wand := _attack_phase != "" and _swing_weapon == "wand"
	wand_charge_sprite.visible = showing_wand
	if showing_wand:
		wand_charge_sprite.position = _attack_direction * (radius + 6.0)
		var charge_t: float = 0.6 if _attack_phase == "windup" else 1.0
		wand_charge_sprite.scale = Vector2(wand_charge_scale, wand_charge_scale) * charge_t
