extends Incarnation
class_name GlodIncarnation
## Wcielenie fazy Głód — żeruje na wszystkim w zasięgu (LORE_I_ASSETY.md 2.5). Trzy
## umiejętności, każda leczy istotę częścią zadanych obrażeń: ugryzienie (wypad),
## żarłoczny impuls (leczy nawet bez kontaktu), przyciągnięcie i ugryzienie.

@export var bite_speed: float = 380.0
@export var bite_duration: float = 0.32
@export var lifesteal_fraction: float = 0.5 ## ułamek obrażeń oddawany jako leczenie
@export var ravenous_radius: float = 85.0
@export var ravenous_damage: float = 12.0
@export var pull_strength: float = 350.0

const TEX_WALK := preload("res://assets/sprites/wcielenia/thal_gor/thal-gor_walk.png")
const TEX_TELEGRAPH := preload("res://assets/sprites/wcielenia/thal_gor/thal-gor_telegraph.png")
const TEX_LUNGE := preload("res://assets/sprites/wcielenia/thal_gor/thal-gor_lunge.png")
const TEX_PULSE := preload("res://assets/sprites/wcielenia/thal_gor/thal-gor_cast-pulse.png")
const TEX_PULL := preload("res://assets/sprites/wcielenia/thal_gor/thal-gor_pull.png")
const TEX_HIT := preload("res://assets/sprites/wcielenia/thal_gor/thal-gor_hit.png")
const TEX_DEATH := preload("res://assets/sprites/wcielenia/thal_gor/thal-gor_death.png")
const TEX_BITE := preload("res://assets/sprites/wcielenia/thal_gor/thal-gor_lifesteal-bite.png")

func _ready() -> void:
	super._ready()
	current_color = Color("#E8524A") # dopasowane do dostarczonej grafiki (czerwona, nie zielona)
	fragment_name = "Thal’Gor, Pęknięty Pomiędzy Światami" # patrz LORE_I_ASSETY.md
	_skills = [_skill_bite, _skill_ravenous_pulse, _skill_pull_and_bite]
	_sprite_textures = {
		"walk": TEX_WALK, "telegraph": TEX_TELEGRAPH, "lunge": TEX_LUNGE,
		"pulse": TEX_PULSE, "pull": TEX_PULL, "hit": TEX_HIT, "death": TEX_DEATH,
		"lifesteal_bite": TEX_BITE,
	}

## Wszystkie trzy umiejętności to warianty ugryzienia/wypadu — jedyne wcielenie,
## gdzie KAŻDY wypad (nie tylko jeden konkretny skill) pokazuje unikalną pozę
## zamiast generycznego "lunge", stąd nadpisanie _update_sprite_state().
func _update_sprite_state() -> void:
	super._update_sprite_state()
	if _lunge_active and _sprite_textures.has("lifesteal_bite"):
		sprite.texture = _sprite_textures["lifesteal_bite"]

func _skill_bite() -> void:
	_lunge_toward_player(bite_speed, bite_duration)

func _skill_ravenous_pulse() -> void:
	if _damage_pulse(ravenous_radius, ravenous_damage):
		health = min(max_health, health + ravenous_damage * lifesteal_fraction)

func _skill_pull_and_bite() -> void:
	_pull_player(pull_strength)
	_lunge_toward_player(bite_speed, bite_duration)

## Nadpisane tylko na czas wypadu — zwykły dotyk (poza umiejętnością) nie leczy,
## żeby lifesteal był nagrodą za trafienie ugryzieniem, nie za samo dryfowanie obok.
func _check_contact() -> void:
	if not _lunge_active:
		super._check_contact()
		return
	if player.is_invulnerable():
		return
	if global_position.distance_to(player.global_position) > radius + player.radius:
		return
	player.take_damage(contact_damage)
	var dir: Vector2 = player.global_position - global_position
	player.apply_knockback((dir.normalized() if dir.length() > 0.01 else Vector2.RIGHT) * contact_knockback)
	health = min(max_health, health + contact_damage * lifesteal_fraction)
