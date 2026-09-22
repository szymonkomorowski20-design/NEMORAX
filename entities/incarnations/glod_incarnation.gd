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
const TEX_WALK_FRONT_STRIDE := preload("res://assets/sprites/wcielenia/thal_gor/thal-gor_walk_front_stride.png")
const TEX_WALK_FRONT_DIAGONAL := preload("res://assets/sprites/wcielenia/thal_gor/thal-gor_walk_front_diagonal.png")
const TEX_WALK_FRONT_DIAGONAL_STRIDE := preload("res://assets/sprites/wcielenia/thal_gor/thal-gor_walk_front_diagonal_stride.png")
const TEX_WALK_SIDE := preload("res://assets/sprites/wcielenia/thal_gor/thal-gor_walk_side.png")
const TEX_WALK_SIDE_STRIDE := preload("res://assets/sprites/wcielenia/thal_gor/thal-gor_walk_side_stride.png")
const TEX_WALK_BACK_DIAGONAL := preload("res://assets/sprites/wcielenia/thal_gor/thal-gor_walk_back_diagonal.png")
const TEX_WALK_BACK_DIAGONAL_STRIDE := preload("res://assets/sprites/wcielenia/thal_gor/thal-gor_walk_back_diagonal_stride.png")
const TEX_WALK_BACK := preload("res://assets/sprites/wcielenia/thal_gor/thal-gor_walk_back.png")
const TEX_WALK_BACK_STRIDE := preload("res://assets/sprites/wcielenia/thal_gor/thal-gor_walk_back_stride.png")
const TEX_TELEGRAPH := preload("res://assets/sprites/wcielenia/thal_gor/thal-gor_telegraph.png")
const TEX_TELEGRAPH_FRONT_DIAGONAL := preload("res://assets/sprites/wcielenia/thal_gor/thal-gor_telegraph_front_diagonal.png")
const TEX_TELEGRAPH_SIDE := preload("res://assets/sprites/wcielenia/thal_gor/thal-gor_telegraph_side.png")
const TEX_TELEGRAPH_BACK_DIAGONAL := preload("res://assets/sprites/wcielenia/thal_gor/thal-gor_telegraph_back_diagonal.png")
const TEX_TELEGRAPH_BACK := preload("res://assets/sprites/wcielenia/thal_gor/thal-gor_telegraph_back.png")
const TEX_LUNGE := preload("res://assets/sprites/wcielenia/thal_gor/thal-gor_lunge.png")
const TEX_LUNGE_FRONT_DIAGONAL := preload("res://assets/sprites/wcielenia/thal_gor/thal-gor_lunge_front_diagonal.png")
const TEX_LUNGE_SIDE := preload("res://assets/sprites/wcielenia/thal_gor/thal-gor_lunge_side.png")
const TEX_LUNGE_BACK_DIAGONAL := preload("res://assets/sprites/wcielenia/thal_gor/thal-gor_lunge_back_diagonal.png")
const TEX_LUNGE_BACK := preload("res://assets/sprites/wcielenia/thal_gor/thal-gor_lunge_back.png")
const TEX_PULSE := preload("res://assets/sprites/wcielenia/thal_gor/thal-gor_cast-pulse.png")
const TEX_PULSE_FRONT_DIAGONAL := preload("res://assets/sprites/wcielenia/thal_gor/thal-gor_cast-pulse_front_diagonal.png")
const TEX_PULSE_SIDE := preload("res://assets/sprites/wcielenia/thal_gor/thal-gor_cast-pulse_side.png")
const TEX_PULSE_BACK_DIAGONAL := preload("res://assets/sprites/wcielenia/thal_gor/thal-gor_cast-pulse_back_diagonal.png")
const TEX_PULSE_BACK := preload("res://assets/sprites/wcielenia/thal_gor/thal-gor_cast-pulse_back.png")
const TEX_PULL := preload("res://assets/sprites/wcielenia/thal_gor/thal-gor_pull.png")
const TEX_PULL_FRONT_DIAGONAL := preload("res://assets/sprites/wcielenia/thal_gor/thal-gor_pull_front_diagonal.png")
const TEX_PULL_SIDE := preload("res://assets/sprites/wcielenia/thal_gor/thal-gor_pull_side.png")
const TEX_PULL_BACK_DIAGONAL := preload("res://assets/sprites/wcielenia/thal_gor/thal-gor_pull_back_diagonal.png")
const TEX_PULL_BACK := preload("res://assets/sprites/wcielenia/thal_gor/thal-gor_pull_back.png")
const TEX_HIT := preload("res://assets/sprites/wcielenia/thal_gor/thal-gor_hit.png")
const TEX_HIT_FRONT_DIAGONAL := preload("res://assets/sprites/wcielenia/thal_gor/thal-gor_hit_front_diagonal.png")
const TEX_HIT_SIDE := preload("res://assets/sprites/wcielenia/thal_gor/thal-gor_hit_side.png")
const TEX_HIT_BACK_DIAGONAL := preload("res://assets/sprites/wcielenia/thal_gor/thal-gor_hit_back_diagonal.png")
const TEX_HIT_BACK := preload("res://assets/sprites/wcielenia/thal_gor/thal-gor_hit_back.png")
const TEX_DEATH := preload("res://assets/sprites/wcielenia/thal_gor/thal-gor_death.png")
const TEX_DEATH_FRONT_DIAGONAL := preload("res://assets/sprites/wcielenia/thal_gor/thal-gor_death_front_diagonal.png")
const TEX_DEATH_SIDE := preload("res://assets/sprites/wcielenia/thal_gor/thal-gor_death_side.png")
const TEX_DEATH_BACK_DIAGONAL := preload("res://assets/sprites/wcielenia/thal_gor/thal-gor_death_back_diagonal.png")
const TEX_DEATH_BACK := preload("res://assets/sprites/wcielenia/thal_gor/thal-gor_death_back.png")
const TEX_BITE := preload("res://assets/sprites/wcielenia/thal_gor/thal-gor_lifesteal-bite.png")
const TEX_BITE_FRONT_DIAGONAL := preload("res://assets/sprites/wcielenia/thal_gor/thal-gor_lifesteal-bite_front_diagonal.png")
const TEX_BITE_SIDE := preload("res://assets/sprites/wcielenia/thal_gor/thal-gor_lifesteal-bite_side.png")
const TEX_BITE_BACK_DIAGONAL := preload("res://assets/sprites/wcielenia/thal_gor/thal-gor_lifesteal-bite_back_diagonal.png")
const TEX_BITE_BACK := preload("res://assets/sprites/wcielenia/thal_gor/thal-gor_lifesteal-bite_back.png")

func _ready() -> void:
	super._ready()
	current_color = Color("#E8524A") # dopasowane do dostarczonej grafiki (czerwona, nie zielona)
	hit_material = Palette.HitMaterial.BONE
	is_miniboss = true
	fragment_name = "Thal’Gor, Pęknięty Pomiędzy Światami" # patrz LORE_I_ASSETY.md
	_skills = [_skill_bite, _skill_ravenous_pulse, _skill_pull_and_bite, _pattern_pulse_and_bite]
	_sprite_textures = {
		"walk": {
			"front": [TEX_WALK, TEX_WALK_FRONT_STRIDE],
			"front_diagonal": [TEX_WALK_FRONT_DIAGONAL, TEX_WALK_FRONT_DIAGONAL_STRIDE],
			"side": [TEX_WALK_SIDE, TEX_WALK_SIDE_STRIDE],
			"back_diagonal": [TEX_WALK_BACK_DIAGONAL, TEX_WALK_BACK_DIAGONAL_STRIDE],
			"back": [TEX_WALK_BACK, TEX_WALK_BACK_STRIDE],
		},
		"telegraph": {"front": TEX_TELEGRAPH, "front_diagonal": TEX_TELEGRAPH_FRONT_DIAGONAL, "side": TEX_TELEGRAPH_SIDE, "back_diagonal": TEX_TELEGRAPH_BACK_DIAGONAL, "back": TEX_TELEGRAPH_BACK},
		"lunge": {"front": TEX_LUNGE, "front_diagonal": TEX_LUNGE_FRONT_DIAGONAL, "side": TEX_LUNGE_SIDE, "back_diagonal": TEX_LUNGE_BACK_DIAGONAL, "back": TEX_LUNGE_BACK},
		"pulse": {"front": TEX_PULSE, "front_diagonal": TEX_PULSE_FRONT_DIAGONAL, "side": TEX_PULSE_SIDE, "back_diagonal": TEX_PULSE_BACK_DIAGONAL, "back": TEX_PULSE_BACK},
		"pull": {"front": TEX_PULL, "front_diagonal": TEX_PULL_FRONT_DIAGONAL, "side": TEX_PULL_SIDE, "back_diagonal": TEX_PULL_BACK_DIAGONAL, "back": TEX_PULL_BACK},
		"hit": {"front": TEX_HIT, "front_diagonal": TEX_HIT_FRONT_DIAGONAL, "side": TEX_HIT_SIDE, "back_diagonal": TEX_HIT_BACK_DIAGONAL, "back": TEX_HIT_BACK},
		"death": {"front": TEX_DEATH, "front_diagonal": TEX_DEATH_FRONT_DIAGONAL, "side": TEX_DEATH_SIDE, "back_diagonal": TEX_DEATH_BACK_DIAGONAL, "back": TEX_DEATH_BACK},
		"lifesteal_bite": {"front": TEX_BITE, "front_diagonal": TEX_BITE_FRONT_DIAGONAL, "side": TEX_BITE_SIDE, "back_diagonal": TEX_BITE_BACK_DIAGONAL, "back": TEX_BITE_BACK},
	}

## Wszystkie trzy umiejętności to warianty ugryzienia/wypadu — jedyne wcielenie,
## gdzie KAŻDY wypad (nie tylko jeden konkretny skill) pokazuje unikalną pozę
## zamiast generycznego "lunge", stąd nadpisanie _update_sprite_state().
func _update_sprite_state() -> void:
	super._update_sprite_state()
	if _lunge_active and _sprite_textures.has("lifesteal_bite"):
		var facing := Facing.resolve(_sprite_textures["lifesteal_bite"], _facing_direction)
		sprite.texture = facing["texture"]
		sprite.flip_h = facing["flip_h"]

func _skill_bite() -> void:
	_lunge_toward_player(bite_speed, bite_duration)

func _skill_ravenous_pulse() -> void:
	if _damage_pulse(ravenous_radius, ravenous_damage):
		health = min(max_health, health + ravenous_damage * lifesteal_fraction)

func _skill_pull_and_bite() -> void:
	_pull_player(pull_strength)
	_lunge_toward_player(bite_speed, bite_duration)

## "Grupa wzorców" (dokument sekcja 11) — osłabia impulsem, potem dobija ugryzieniem.
func _pattern_pulse_and_bite() -> void:
	_skill_ravenous_pulse()
	await get_tree().create_timer(0.3).timeout
	if not is_dead:
		_skill_bite()

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
