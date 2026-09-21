extends Node2D
## Pokój wzorcowy do oceny wizualnej (KIERUNEK_WIZUALNY_REFERENCJE.md) — NIE
## jest częścią przepływu gry (GameFlow), to jednorazowa scena QA uruchamiana
## bezpośrednio (`godot res://debug/reference_room.tscn`) do zrobienia
## screenów przed/po bez przechodzenia całej gry. Składa w jednym kadrze:
## gracza, małego wroga, ciężkiego wroga, drzwi, skrzynię, pocisk w locie,
## aktywną strefę obszarową i lokalne światło, na tych samych komponentach
## co prawdziwy rooms/room.gd (RoomAtmosphere/ContactShadow/WorldAmbient/Walls).

const ARENA_RECT := Rect2(90, 60, 1100, 600)
const WALL_THICKNESS := 20.0

const VOID_BACKGROUND := preload("res://assets/sprites/pokoje/tekstury/void_background.png")
const FLOOR_TEXTURE := preload("res://assets/sprites/pokoje/tekstury/random_rooms/crystal_cavern_floor.png")
const WALL_TEXTURE := preload("res://assets/sprites/pokoje/tekstury/random_rooms/crystal_cavern_wall.png")

const PlayerScene := preload("res://entities/player.tscn")
const ChaserScene := preload("res://entities/random_enemies/chaser.tscn")
const TankScene := preload("res://entities/random_enemies/tank.tscn")
const DoorScene := preload("res://rooms/door.tscn")
const ChestScene := preload("res://rooms/chest.tscn")
const EnemyProjectileScene := preload("res://entities/enemy_projectile.tscn")
const DamageZoneScene := preload("res://entities/damage_zone.tscn")
const RoomAtmosphereScene := preload("res://rooms/room_atmosphere.gd")

func _ready() -> void:
	Walls.build_void_background(self, get_viewport_rect().size, VOID_BACKGROUND)
	Walls.build_floor(self, ARENA_RECT, FLOOR_TEXTURE)
	Walls.build(self, ARENA_RECT, WALL_THICKNESS, WALL_TEXTURE)

	var atmosphere := RoomAtmosphereScene.new() as RoomAtmosphere
	atmosphere.configure(ARENA_RECT)
	add_child(atmosphere)

	var ambient := CanvasModulate.new()
	ambient.color = Color(0.82, 0.88, 0.84, 1.0)
	add_child(ambient)

	var player: Player = PlayerScene.instantiate()
	add_child(player)
	player.global_position = Vector2(430, 420)

	var chaser := ChaserScene.instantiate()
	add_child(chaser)
	chaser.arena_rect = ARENA_RECT
	chaser.global_position = Vector2(560, 300)

	var tank := TankScene.instantiate()
	add_child(tank)
	tank.arena_rect = ARENA_RECT
	tank.global_position = Vector2(880, 420)
	tank._start_telegraph() # zamrożone w zapowiedzi ataku na potrzeby screena

	var door := DoorScene.instantiate()
	add_child(door)
	door.global_position = Walls.wall_point(ARENA_RECT, "right") - Vector2(26.0, 0.0)

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

	var local_light := PointLight2D.new()
	local_light.texture = _make_soft_light_texture()
	local_light.color = Color("#E8933D") # ciepły pomarańcz, kontrast wobec chłodnego ambientu (KIERUNEK_WIZUALNY_REFERENCJE.md)
	local_light.energy = 2.2
	local_light.texture_scale = 1.0 # tekstura 256px * 1.0 = ~256px lokalna poświata, nie cała arena
	local_light.global_position = Vector2(700, 500)
	add_child(local_light)

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

## Miękka radialna poświata generowana kodem (bez nowego pliku graficznego) —
## GradientTexture2D z wypełnieniem RADIAL, biały środek gasnący do przezroczystości.
func _make_soft_light_texture() -> GradientTexture2D:
	var gradient := Gradient.new()
	gradient.set_color(0, Color(1, 1, 1, 1))
	gradient.set_color(1, Color(1, 1, 1, 0))
	var tex := GradientTexture2D.new()
	tex.gradient = gradient
	tex.width = 256
	tex.height = 256
	tex.fill = GradientTexture2D.FILL_RADIAL
	tex.fill_from = Vector2(0.5, 0.5)
	tex.fill_to = Vector2(1.0, 0.5)
	return tex
