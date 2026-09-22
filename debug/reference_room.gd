extends Node2D
## Pokój wzorcowy do oceny wizualnej (KIERUNEK_WIZUALNY_REFERENCJE.md) — NIE
## jest częścią przepływu gry (GameFlow), to jednorazowa scena QA uruchamiana
## bezpośrednio (`godot res://debug/reference_room.tscn`) do zrobienia
## screenów przed/po bez przechodzenia całej gry. Składa w jednym kadrze:
## gracza, małego wroga, ciężkiego wroga, drzwi, skrzynię, pocisk w locie,
## aktywną strefę obszarową i lokalne światło, na tych samych komponentach
## co prawdziwy rooms/room.gd (RoomAtmosphere/ContactShadow/Walls),
## plus prawdziwy HUD (ui/ui.tscn) do oceny pasków/XP/paska bossa naraz z resztą.

## Faza 0 (PLAN_PROFESSIONAL_GAME_FEEL_DLA_CLAUDE.md) — nakładka debugowa
## pokazująca hitbox gracza, hurtbox wrogów, obszar obrażeń ataku, collider
## ścian/drzwi i pozycję cienia kontaktowego. Włącznik: F3 (Juice.debug_visible),
## ten sam co reszta gry — bez osobnego klawisza tylko dla tej sceny. Rysowanie
## dzieje się w osobnym węźle (debug/debug_overlay.gd), nie bezpośrednio tutaj —
## rodzic rysuje siebie PRZED dziećmi przy równym z_index, więc małe hitboxy
## (np. gracz, promień 14px) chowałyby się całkowicie pod sprite'em.
const DebugOverlayScene := preload("res://debug/debug_overlay.gd")

const ARENA_RECT := Rect2(90, 60, 1100, 600)
const WALL_THICKNESS := 20.0

const VOID_BACKGROUND := preload("res://assets/sprites/pokoje/tekstury/void_background.png")
const FLOOR_TEXTURE := preload("res://assets/sprites/pokoje/tekstury/random_rooms/crystal_cavern_floor_v2.png")
const WALL_TEXTURE := preload("res://assets/sprites/pokoje/tekstury/random_rooms/crystal_cavern_wall_v2.png")
# Ta sama para co rooms/room.gd — scena QA ma pokazywać AKTUALNY wygląd gry,
# nie starą wersję tekstur/modulacji sprzed Fazy 1 (PLAN_PROFESSIONAL_GAME_FEEL_DLA_CLAUDE.md).
const WALL_MODULATE := Color(0.45, 0.45, 0.52, 1.0)
const VOID_MODULATE := Color(0.22, 0.22, 0.28, 1.0)

const PlayerScene := preload("res://entities/player.tscn")
const ChaserScene := preload("res://entities/random_enemies/chaser.tscn")
const TankScene := preload("res://entities/random_enemies/tank.tscn")
const DoorScene := preload("res://rooms/door.tscn")
const ChestScene := preload("res://rooms/chest.tscn")
const EnemyProjectileScene := preload("res://entities/enemy_projectile.tscn")
const DamageZoneScene := preload("res://entities/damage_zone.tscn")
const RoomAtmosphereScene := preload("res://rooms/room_atmosphere.gd")
const UiScene := preload("res://ui/ui.tscn")

var _dbg_player: Player
var _dbg_chaser: Incarnation
var _dbg_tank: Incarnation
var _dbg_door: Door
var _debug_overlay: DebugOverlay

func _ready() -> void:
	Walls.build_void_background(self, get_viewport_rect().size, VOID_BACKGROUND, VOID_MODULATE)
	Walls.build_floor(self, ARENA_RECT, FLOOR_TEXTURE)
	Walls.build(self, ARENA_RECT, WALL_THICKNESS, WALL_TEXTURE, WALL_MODULATE)

	var atmosphere := RoomAtmosphereScene.new() as RoomAtmosphere
	atmosphere.configure(ARENA_RECT)
	add_child(atmosphere)

	# Faza 1 (PLAN_PROFESSIONAL_GAME_FEEL_DLA_CLAUDE.md): usunięty CanvasModulate
	# "ambient" — mimo nazwy w nagłówku pliku ("WorldAmbient") nic takiego nigdy
	# nie istniało w rooms/room.gd. Rozjaśniał tę scenę QA WZGLĘDEM prawdziwej
	# gry, więc scena wyglądała lepiej niż jest naprawdę — usunięte, żeby ta
	# scena była wiarygodnym odniesieniem, nie podkoloryzowaną wersją.

	var player: Player = PlayerScene.instantiate()
	add_child(player)
	player.global_position = Vector2(430, 420)
	_dbg_player = player

	var chaser := ChaserScene.instantiate()
	add_child(chaser)
	chaser.arena_rect = ARENA_RECT
	chaser.global_position = Vector2(560, 300)
	_dbg_chaser = chaser

	var tank := TankScene.instantiate()
	add_child(tank)
	tank.arena_rect = ARENA_RECT
	tank.global_position = Vector2(880, 420)
	_dbg_tank = tank
	tank._start_telegraph() # zamrożone w zapowiedzi ataku na potrzeby screena
	tank.health = tank.max_health * 0.4 # nie 100% — inaczej nie widać, że pasek nad głową w ogóle reaguje na obrażenia

	var ui_layer := UiScene.instantiate()
	add_child(ui_layer)
	var ui: GameUI = ui_layer.get_node("UI")
	ui.player = player
	ui.boss = tank # Incarnation, NIE Boss — pasek na górze MA zostać ukryty (patrz ui/ui.gd)
	player.gain_xp(2.0) # częściowo zapełniony pasek expa, nie 0% ani 100%

	var door := DoorScene.instantiate()
	add_child(door)
	door.global_position = Walls.wall_point(ARENA_RECT, "right") - Vector2(26.0, 0.0)
	_dbg_door = door

	var chest := ChestScene.instantiate()
	chest.player = player
	add_child(chest)
	chest.global_position = Vector2(700, 560)

	var projectile := EnemyProjectileScene.instantiate()
	projectile.direction = Vector2.LEFT
	projectile.lifetime = 999999.0 # scena QA statyczna — pocisk nie może zniknąć zanim zrobię screen
	add_child(projectile)
	projectile.global_position = Vector2(520, 460)

	var zone := DamageZoneScene.instantiate()
	zone.telegraph_duration = 0.0 # aktywna od razu, bez czekania na screen
	zone.duration = 999999.0 # jw. — strefa nie może zniknąć zanim zrobię screen
	add_child(zone)
	zone.global_position = Vector2(300, 550) # z dala od reszty, żeby ocenić samą strefę

	# Lokalne światło jest teraz stałą częścią rooms/chest.gd (mały złoty blask
	# przypisany do samej skrzyni) — scena QA nie musi już dokładać własnego.

	# Scena QA jest statyczną kompozycją do oceny wyglądu, nie symulacją walki —
	# bez tego gracz bez sterowania zginąłby wrogom w kilka sekund, zanim zdążę
	# zrobić i obejrzeć screen (żaden klawisz nigdy nie jest tu naciśnięty).
	# Kilka klatek odczekania NAJPIERW — _update_sprite_state() (tekstura/poza)
	# leci z _physics_process(), więc zamrożenie w klatce 0 zostawiłoby sprite'y
	# bez przypisanej tekstury wcale.
	await get_tree().create_timer(0.3).timeout
	player.set_physics_process(false)
	chaser.set_physics_process(false)
	tank.set_physics_process(false)

	_setup_debug_overlay()

func _process(_delta: float) -> void:
	# Juice.debug_visible to ten sam F3, co reszta gry (autoload/juice.gd).
	if is_instance_valid(_debug_overlay):
		_debug_overlay.visible = Juice.debug_visible

## Dodawany jako OSTATNIE dziecko, z wysokim z_index — musi rysować się NAD
## wszystkimi sprite'ami, inaczej mały hitbox gracza (14px) chowałby się pod
## jego własnym sprite'em (patrz komentarz przy DebugOverlayScene wyżej).
func _setup_debug_overlay() -> void:
	_debug_overlay = DebugOverlayScene.new()
	add_child(_debug_overlay)
	_debug_overlay.visible = Juice.debug_visible

	_debug_overlay.add_circle(_dbg_player.global_position, _dbg_player.radius, DebugOverlay.HITBOX_COLOR)
	_debug_overlay.add_contact_shadow_marker(_dbg_player)

	_debug_overlay.add_circle(_dbg_chaser.global_position, _dbg_chaser.radius, DebugOverlay.HURTBOX_COLOR)
	_debug_overlay.add_contact_shadow_marker(_dbg_chaser)
	_debug_overlay.add_circle(_dbg_chaser.global_position, _dbg_chaser.swipe_range, DebugOverlay.ATTACK_COLOR)

	_debug_overlay.add_circle(_dbg_tank.global_position, _dbg_tank.radius, DebugOverlay.HURTBOX_COLOR)
	_debug_overlay.add_contact_shadow_marker(_dbg_tank)
	_debug_overlay.add_circle(_dbg_tank.global_position, _dbg_tank.slam_range, DebugOverlay.ATTACK_COLOR)

	_debug_overlay.add_circle(_dbg_door.global_position, _dbg_door.trigger_range, DebugOverlay.COLLIDER_COLOR)

	# Te same 4 prostokąty, które Walls.build() stawia jako realne StaticBody2D —
	# pokazuje DOKŁADNIE tam, gdzie kolizja ściany faktycznie jest, nie gdzie
	# wygląda na oko na podstawie tekstury.
	var t := WALL_THICKNESS
	_debug_overlay.add_wall_rect(Rect2(ARENA_RECT.position.x - t, ARENA_RECT.position.y - t, ARENA_RECT.size.x + t * 2.0, t))
	_debug_overlay.add_wall_rect(Rect2(ARENA_RECT.position.x - t, ARENA_RECT.position.y + ARENA_RECT.size.y, ARENA_RECT.size.x + t * 2.0, t))
	_debug_overlay.add_wall_rect(Rect2(ARENA_RECT.position.x - t, ARENA_RECT.position.y, t, ARENA_RECT.size.y))
	_debug_overlay.add_wall_rect(Rect2(ARENA_RECT.position.x + ARENA_RECT.size.x, ARENA_RECT.position.y, t, ARENA_RECT.size.y))

	_debug_overlay.add_legend_line("F3 DEBUG — Faza 0 (PLAN_PROFESSIONAL_GAME_FEEL_DLA_CLAUDE.md)", Color.WHITE)
	_debug_overlay.add_legend_line("cyjan = hitbox gracza", DebugOverlay.HITBOX_COLOR)
	_debug_overlay.add_legend_line("czerwony = hurtbox wroga", DebugOverlay.HURTBOX_COLOR)
	_debug_overlay.add_legend_line("żółty = obszar obrażeń ataku", DebugOverlay.ATTACK_COLOR)
	_debug_overlay.add_legend_line("zielony = collider ściany/drzwi", DebugOverlay.COLLIDER_COLOR)
	_debug_overlay.add_legend_line("magenta = pozycja cienia kontaktowego", DebugOverlay.SHADOW_COLOR)
	_debug_overlay.refresh()
