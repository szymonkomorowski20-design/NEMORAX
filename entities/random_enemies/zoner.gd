extends Incarnation
class_name Zoner
## Archetyp 8/12: Zoner (dokument sekcja 6.1) — kontrola obszaru, rzuca strefę
## okresowych obrażeń (entities/damage_zone.gd) na pozycję gracza. Grafika:
## dedykowany base art z GPT (jeden statyczny obraz na wszystkie pozy na razie).

const TEX_BASE := preload("res://assets/sprites/random_enemies/zoner/zoner_base.png")

const DamageZoneScene := preload("res://entities/damage_zone.tscn")
const VFX_ATTACK := preload("res://assets/sprites/enemy_vfx/zoner_attack.png") # "skill" (silent_prayer_field) to sama DamageZone, patrz entities/damage_zone.gd

@export var zone_radius: float = 64.0
@export var zone_duration: float = 3.5
@export var zone_tick_damage: float = 5.0

func _ready() -> void:
	max_health = 48.0
	drift_speed = 70.0
	contact_damage = 6.0
	attack_interval = 4.2
	telegraph_duration = 0.90
	knockback_resistance = 0.15
	keep_distance_range = 250.0 ## dokument: "maintains midrange"
	sprite_scale = 0.0875 # KIERUNEK_WIZUALNY_REFERENCJE.md: średni wróg 0.80-0.95 gracza (player.sprite_scale=0.10)
	super._ready()
	current_color = Color("#9B4F8C")
	fragment_name = "Zoner"
	_skills = [_skill_place_zone]
	_sprite_textures = {
		"walk": TEX_BASE, "telegraph": TEX_BASE, "pulse": TEX_BASE, "hit": TEX_BASE, "death": TEX_BASE,
	}

## Rzuca na AKTUALNĄ pozycję gracza ("predicted space" z dokumentu uproszczone
## do pozycji w chwili rzutu — telegraf strefy 0.9s daje graczowi czas na
## reakcję i tak, bez potrzeby prawdziwego namierzania ruchu).
func _skill_place_zone() -> void:
	_set_skill_pose("pulse")
	AttackVfx.spawn(get_parent(), VFX_ATTACK, global_position, 0.35, 0.3)
	var zone := DamageZoneScene.instantiate()
	zone.zone_radius = zone_radius
	zone.duration = zone_duration
	zone.tick_damage = zone_tick_damage
	zone.global_position = player.global_position
	get_parent().add_child(zone)
