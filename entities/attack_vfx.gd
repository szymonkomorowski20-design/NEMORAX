extends Node2D
class_name AttackVfx
## Krótkotrwały, czysto wizualny efekt ataku/umiejętności wroga losowego —
## TERAZ_DLA_CLAUDE.md krok 4. Nie uczestniczy w obrażeniach ani w żadnej
## mechanice (te już dzieją się przez _damage_pulse/_lunge_toward_player/
## EnemyProjectile niezależnie od tego węzła) — czysto kosmetyczny akcent nad
## postaciami (z_index dodatni), znika sam przez tween + queue_free().

const DEFAULT_DURATION := 0.35
const DEFAULT_VFX_SCALE := 0.3 ## dopasowane do źródeł 1024px -> ok. 300px, czytelne bez dominowania nad sylwetką

@onready var sprite: Sprite2D = $Sprite

func _ready() -> void:
	z_index = 5 # nad postaciami/drzwiami, pod HUD-em (konwencja PLAN_POLISH_WIZUALNY_DLA_CLAUDE.md sekcja C1)

## `rotation_rad` pozwala zorientować efekt w stronę gracza dla ataków
## kierunkowych (np. hammer_impact, double_stab) — 0.0 zostawia oryginalną
## orientację źródła (poprawne dla efektów promienistych/symetrycznych jak
## strefy czy auree).
## mirrored: łuk odbity w poprzek kierunku ciosu (np. powrotne cięcie
## Podwójnego ciosu czyta się jako osobny zamach, nie powtórka pierwszego).
static func spawn(parent: Node, texture: Texture2D, global_pos: Vector2, duration: float = DEFAULT_DURATION, vfx_scale: float = DEFAULT_VFX_SCALE, rotation_rad: float = 0.0, mirrored: bool = false) -> void:
	var vfx: AttackVfx = preload("res://entities/attack_vfx.tscn").instantiate()
	parent.add_child(vfx)
	vfx.global_position = global_pos
	vfx.sprite.texture = texture
	vfx.sprite.scale = Vector2(vfx_scale, vfx_scale)
	vfx.sprite.rotation = rotation_rad
	vfx.sprite.flip_v = mirrored
	var tween := vfx.create_tween()
	tween.tween_property(vfx.sprite, "modulate:a", 0.0, duration).from(1.0)
	tween.tween_callback(vfx.queue_free)
