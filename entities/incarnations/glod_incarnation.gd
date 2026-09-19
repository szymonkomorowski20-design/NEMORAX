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

func _ready() -> void:
	super._ready()
	current_color = Color("#7ED957")
	fragment_name = "Głód"
	_skills = [_skill_bite, _skill_ravenous_pulse, _skill_pull_and_bite]

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
