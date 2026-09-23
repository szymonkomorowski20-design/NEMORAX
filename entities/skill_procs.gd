extends Node2D
## Wtórne efekty umiejętności. Żaden z nich nie woła on_hit_confirmed,
## więc nie tworzy kaskad proców ani dodatkowych ładunków leczenia.

const ProjectileScene := preload("res://entities/projectile.tscn")
const VFX_BLEED := preload("res://assets/sprites/vfx/skills_preproduction/vfx_bleed_mark.png")
const VFX_IMPACT := preload("res://assets/sprites/vfx/skills_preproduction/vfx_heavy_impact.png")
const VFX_WAVE := preload("res://assets/sprites/vfx/skills_preproduction/vfx_blade_wave.png")
const VFX_RUPTURE := preload("res://assets/sprites/vfx/skills_preproduction/vfx_rupture.png")
const VFX_SHARD := preload("res://assets/sprites/vfx/skills_preproduction/vfx_split_shard.png")
const VFX_GRAVITY := preload("res://assets/sprites/vfx/skills_preproduction/vfx_gravity_well.png")
const VFX_COUNTER := preload("res://assets/sprites/vfx/skills_preproduction/vfx_counterbrand.png")

var player
var _bleeds: Dictionary = {}
var _sunder: Dictionary = {}
var _rupture: Dictionary = {}
var _wave_swings: int = 0
var _rhythm_hits: int = 0
var _rhythm_timer: float = 0.0
var _counter_cooldown: float = 0.0
var _gravity_cooldown: float = 0.0
var _gravity_fields: Array[Dictionary] = []
var _gravity_baseline: Dictionary = {}
var _orbit_sprites: Array[Sprite2D] = []
var _orbit_phase: float = 0.0
var _orbit_next_hit: Dictionary = {}

func _physics_process(delta: float) -> void:
	_rhythm_timer = maxf(0.0, _rhythm_timer - delta)
	_counter_cooldown = maxf(0.0, _counter_cooldown - delta)
	_gravity_cooldown = maxf(0.0, _gravity_cooldown - delta)
	_tick_bleeds(delta)
	_tick_gravity(delta)
	_tick_orbit(delta)

func _exit_tree() -> void:
	for id in _gravity_baseline:
		var entry: Dictionary = _gravity_baseline[id]
		var target = entry["target"]
		if is_instance_valid(target):
			target.drift_speed = entry["speed"]

func attack_speed_bonus() -> float:
	if _rhythm_timer <= 0.0:
		return 0.0
	return 0.12 if player.skill_rank("guard_battle_rhythm") == 1 else 0.20

func on_damage_taken() -> void:
	_rhythm_hits = 0
	_rhythm_timer = 0.0

func on_sword_active(direction: Vector2, damage: float, attack_id: int) -> void:
	var rank: int = player.skill_rank("blade_wave")
	if rank == 0:
		return
	_wave_swings += 1
	if _wave_swings < (3 if rank == 1 else 2):
		return
	_wave_swings = 0
	var origin: Vector2 = player.global_position
	var center := origin + direction * 75.0
	AttackVfx.spawn(player.get_parent(), VFX_WAVE, center, 0.30, 150.0 / float(VFX_WAVE.get_width()), direction.angle())
	player.play_skill_sfx(player.SND_SKILL_TWIN, center, -14.0, 0.82)
	for target in get_tree().get_nodes_in_group("hittable"):
		if target.get("is_dead") == true:
			continue
		var to_target: Vector2 = target.global_position - origin
		var forward := to_target.dot(direction)
		var lateral := absf(direction.cross(to_target))
		var radius_value: float = target.get("radius") if target.get("radius") != null else 0.0
		if forward >= -radius_value and forward <= 140.0 + radius_value and lateral <= 34.0 + radius_value:
			player.apply_skill_bonus(target, damage * (0.50 if rank == 1 else 0.65), attack_id, damage)

func on_primary_hit(target: Node, damage: float, weapon: String, health_before: float, attack_id: int) -> void:
	var id := target.get_instance_id()
	var now := Time.get_ticks_msec()
	if weapon == "sword":
		_apply_bleed(target, damage)
		var sunder_rank: int = player.skill_rank("blade_sunder")
		if sunder_rank > 0:
			var info: Dictionary = _sunder.get(id, {"count": 0, "last": 0})
			info["count"] = 1 if now - int(info["last"]) > 5000 else int(info["count"]) + 1
			info["last"] = now
			if info["count"] >= (4 if sunder_rank == 1 else 3):
				info["count"] = 0
				player.apply_skill_bonus(target, damage * (0.75 if sunder_rank == 1 else 1.0), attack_id, damage)
				AttackVfx.spawn(player.get_parent(), VFX_IMPACT, target.global_position, 0.25, 90.0 / float(VFX_IMPACT.get_width()))
				player.play_skill_sfx(player.SND_SKILL_TWIN, target.global_position, -9.0, 0.72)
			_sunder[id] = info
	var rupture_rank: int = player.skill_rank("void_rupture")
	if rupture_rank > 0:
		var info: Dictionary = _rupture.get(id, {"count": 0, "last": 0})
		info["count"] = 1 if now - int(info["last"]) > 5000 else int(info["count"]) + 1
		info["last"] = now
		if info["count"] >= (4 if rupture_rank == 1 else 3):
			info["count"] = 0
			_burst_rupture(target, damage, attack_id, rupture_rank)
		_rupture[id] = info
	if player.skill_rank("guard_battle_rhythm") > 0:
		_rhythm_hits += 1
		if _rhythm_hits >= 3:
			_rhythm_timer = 4.0
	if player.skill_rank("guard_weapon_weave") > 0:
		player.arm_weapon_weave(weapon)
	if target.get("is_dead") == true:
		_on_primary_kill(target, damage, health_before)

func _apply_bleed(target: Node, damage: float) -> void:
	var rank: int = player.skill_rank("blade_bleed")
	if rank == 0 or target.get("is_dead") == true:
		return
	_bleeds[target.get_instance_id()] = {"target": target, "dps": damage * (0.12 if rank == 1 else 0.18), "time": 3.0}
	AttackVfx.spawn(player.get_parent(), VFX_BLEED, target.global_position, 0.25, 55.0 / float(VFX_BLEED.get_width()))

func _tick_bleeds(delta: float) -> void:
	for id in _bleeds.keys():
		var entry: Dictionary = _bleeds[id]
		var target = entry["target"]
		if not is_instance_valid(target) or target.get("is_dead") == true or float(entry["time"]) <= 0.0:
			_bleeds.erase(id)
			continue
		entry["time"] = float(entry["time"]) - delta
		# Bez hitstopu/flashu w każdej klatce; DoT nie uruchamia proców.
		target.take_damage(float(entry["dps"]) * delta)
		_bleeds[id] = entry

func _burst_rupture(target: Node, damage: float, attack_id: int, rank: int) -> void:
	var center: Vector2 = target.global_position
	var radius_value := 55.0 if rank == 1 else 70.0
	var burst_damage := damage * (0.80 if rank == 1 else 1.10)
	AttackVfx.spawn(player.get_parent(), VFX_RUPTURE, center, 0.30, radius_value * 2.0 / float(VFX_RUPTURE.get_width()))
	player.play_skill_sfx(player.SND_SKILL_VOID, center, -12.0, 0.65)
	for other in get_tree().get_nodes_in_group("hittable"):
		if other.get("is_dead") == true:
			continue
		var target_radius: float = other.get("radius") if other.get("radius") != null else 0.0
		if center.distance_to(other.global_position) > radius_value + target_radius:
			continue
		if other == target:
			player.apply_skill_bonus(other, burst_damage, attack_id, damage)
		else:
			Juice.apply_hit(other, burst_damage, 0.0, true)

func _on_primary_kill(target: Node, damage: float, health_before: float) -> void:
	var center: Vector2 = target.global_position
	var chain_rank: int = player.skill_rank("void_chain_burst")
	if chain_rank > 0:
		var candidates: Array = _nearby_targets(center, 220.0, target)
		for i in range(mini(2 if chain_rank == 1 else 3, candidates.size())):
			var other: Node2D = candidates[i]
			var shard = ProjectileScene.instantiate()
			shard.secondary = true
			shard.use_split_cap = false
			shard.texture_override = VFX_SHARD
			shard.direction = (other.global_position - center).normalized()
			shard.damage = damage * (0.30 if chain_rank == 1 else 0.40)
			shard.speed = 450.0
			shard.lifetime = 0.55
			shard.shooter = player
			shard.global_position = center
			player.get_parent().add_child(shard)
	if player.skill_rank("void_gravity_well") > 0 and _gravity_cooldown <= 0.0:
		_gravity_cooldown = 8.0
		_gravity_fields.append({"center": center, "time": 2.0})
		var visual := Sprite2D.new()
		visual.texture = VFX_GRAVITY
		visual.scale = Vector2.ONE * (200.0 / float(VFX_GRAVITY.get_width()))
		visual.global_position = center
		visual.modulate.a = 0.24
		visual.z_index = -1
		player.get_parent().add_child(visual)
		var tween := visual.create_tween()
		tween.tween_property(visual, "modulate:a", 0.0, 2.0)
		tween.tween_callback(visual.queue_free)
	var execution_rank: int = player.skill_rank("void_execution")
	if execution_rank > 0 and health_before >= 0.0:
		var spill := maxf(0.0, damage - health_before) * (0.35 if execution_rank == 1 else 0.50)
		var nearby := _nearby_targets(center, 85.0, target)
		if spill > 0.0 and not nearby.is_empty():
			for other in nearby:
				Juice.apply_hit(other, spill / float(nearby.size()), 0.0, true)

func _nearby_targets(center: Vector2, max_distance: float, excluded: Node = null) -> Array:
	var found: Array = []
	for target in get_tree().get_nodes_in_group("hittable"):
		if target == excluded or target.get("is_dead") == true:
			continue
		if center.distance_to(target.global_position) <= max_distance:
			found.append(target)
	found.sort_custom(func(a, b): return center.distance_squared_to(a.global_position) < center.distance_squared_to(b.global_position))
	return found

func _tick_gravity(delta: float) -> void:
	for i in range(_gravity_fields.size() - 1, -1, -1):
		_gravity_fields[i]["time"] = float(_gravity_fields[i]["time"]) - delta
		if float(_gravity_fields[i]["time"]) <= 0.0:
			_gravity_fields.remove_at(i)
	for id in _gravity_baseline.keys():
		var entry: Dictionary = _gravity_baseline[id]
		if not is_instance_valid(entry["target"]):
			_gravity_baseline.erase(id)
	for target in get_tree().get_nodes_in_group("hittable"):
		if not target is Incarnation or target.get("is_dead") == true:
			continue
		var id := target.get_instance_id()
		var affected := false
		for field in _gravity_fields:
			if target.global_position.distance_to(field["center"]) <= 100.0:
				affected = true
				break
		if affected and id not in _gravity_baseline:
			_gravity_baseline[id] = {"target": target, "speed": target.drift_speed}
		if id in _gravity_baseline:
			target.drift_speed = float(_gravity_baseline[id]["speed"]) * (0.75 if affected else 1.0)
			if not affected:
				_gravity_baseline.erase(id)

func _tick_orbit(delta: float) -> void:
	var rank: int = player.skill_rank("void_shard_orbit")
	while _orbit_sprites.size() < rank:
		var sprite := Sprite2D.new()
		sprite.texture = VFX_SHARD
		sprite.scale = Vector2.ONE * 0.035
		sprite.modulate.a = 0.7
		add_child(sprite)
		_orbit_sprites.append(sprite)
	while _orbit_sprites.size() > rank:
		_orbit_sprites.pop_back().queue_free()
	if rank == 0:
		return
	_orbit_phase += delta * 3.0
	for i in range(rank):
		var shard := _orbit_sprites[i]
		shard.position = Vector2.RIGHT.rotated(_orbit_phase + TAU * float(i) / float(rank)) * 43.0
		for target in get_tree().get_nodes_in_group("hittable"):
			if target.get("is_dead") == true:
				continue
			var id := target.get_instance_id()
			if Time.get_ticks_msec() < int(_orbit_next_hit.get(id, 0)):
				continue
			var target_radius: float = target.get("radius") if target.get("radius") != null else 0.0
			if shard.global_position.distance_to(target.global_position) <= 12.0 + target_radius:
				_orbit_next_hit[id] = Time.get_ticks_msec() + 1000
				Juice.apply_hit(target, player.attack_damage * 0.25, 0.0, true)

func counterbrand() -> void:
	var rank: int = player.skill_rank("guard_counterbrand")
	if rank == 0 or _counter_cooldown > 0.0:
		return
	_counter_cooldown = 1.0
	var center: Vector2 = player.global_position
	AttackVfx.spawn(player.get_parent(), VFX_COUNTER, center, 0.27, 160.0 / float(VFX_COUNTER.get_width()))
	player.play_skill_sfx(player.SND_SKILL_TWIN, center, -8.0, 0.92)
	for target in get_tree().get_nodes_in_group("hittable"):
		if target.get("is_dead") == true:
			continue
		var target_radius: float = target.get("radius") if target.get("radius") != null else 0.0
		if center.distance_to(target.global_position) <= 80.0 + target_radius:
			Juice.apply_hit(target, player.attack_damage * (0.60 if rank == 1 else 0.90), 0.0, true)
