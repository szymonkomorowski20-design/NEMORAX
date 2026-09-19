extends Incarnation
class_name GlodIncarnation
## Wcielenie fazy Głód — żeruje na wszystkim w zasięgu. Umiejętność: wypad-ugryzienie,
## które leczy istotę częścią zadanych obrażeń (LORE_I_ASSETY.md 2.5).

@export var bite_speed: float = 380.0
@export var bite_duration: float = 0.32
@export var lifesteal_fraction: float = 0.5 ## ułamek obrażeń z ugryzienia oddawany jako leczenie

func _ready() -> void:
	super._ready()
	current_color = Color("#7ED957")
	fragment_name = "Głód"

func _perform_signature_skill() -> void:
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
