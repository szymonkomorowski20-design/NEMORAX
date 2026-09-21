extends Incarnation
class_name Zoner
## Archetyp 8/12: Zoner (dokument sekcja 6.1) — kontrola obszaru, rzuca strefę
## okresowych obrażeń (entities/damage_zone.gd) na pozycję gracza. Grafika:
## TYMCZASOWO Mordrath.

const TEX_WALK := preload("res://assets/sprites/wcielenia/mordrath/mordrath_walk.png")
const TEX_WALK_BACK := preload("res://assets/sprites/wcielenia/mordrath/mordrath_walk_back.png")
const TEX_WALK_SIDE := preload("res://assets/sprites/wcielenia/mordrath/mordrath_walk_side.png")
const TEX_TELEGRAPH := preload("res://assets/sprites/wcielenia/mordrath/mordrath_telegraph.png")
const TEX_PULSE := preload("res://assets/sprites/wcielenia/mordrath/mordrath_cast-pulse.png")
const TEX_HIT := preload("res://assets/sprites/wcielenia/mordrath/mordrath_hit.png")
const TEX_DEATH := preload("res://assets/sprites/wcielenia/mordrath/mordrath_death.png")

const DamageZoneScene := preload("res://entities/damage_zone.tscn")

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
	super._ready()
	current_color = Color("#9B4F8C")
	fragment_name = "Zoner"
	_skills = [_skill_place_zone]
	_sprite_textures = {
		"walk": {"front": TEX_WALK, "back": TEX_WALK_BACK, "side": TEX_WALK_SIDE},
		"telegraph": TEX_TELEGRAPH, "pulse": TEX_PULSE, "hit": TEX_HIT, "death": TEX_DEATH,
	}

## Rzuca na AKTUALNĄ pozycję gracza ("predicted space" z dokumentu uproszczone
## do pozycji w chwili rzutu — telegraf strefy 0.9s daje graczowi czas na
## reakcję i tak, bez potrzeby prawdziwego namierzania ruchu).
func _skill_place_zone() -> void:
	_set_skill_pose("pulse")
	var zone := DamageZoneScene.instantiate()
	zone.zone_radius = zone_radius
	zone.duration = zone_duration
	zone.tick_damage = zone_tick_damage
	zone.global_position = player.global_position
	get_parent().add_child(zone)
