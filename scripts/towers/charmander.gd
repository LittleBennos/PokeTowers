extends BaseTower
class_name CharmanderTower

@export var aoe_radius: float = 60.0

func _ready() -> void:
	tower_name = "Charmander"
	damage = 25.0
	attack_range = 120.0
	attack_speed = 0.8
	cost = 125
	pokemon_type = GameManager.PokemonType.FIRE
	super._ready()

func attack(enemy: BaseEnemy) -> void:
	# AoE damage at target location
	var hit_pos = enemy.global_position
	create_fire_effect(hit_pos)

	# Damage all enemies in radius
	for e in enemies_in_range:
		if is_instance_valid(e):
			var dist = e.global_position.distance_to(hit_pos)
			if dist <= aoe_radius:
				# Falloff damage based on distance
				var damage_mult = 1.0 - (dist / aoe_radius) * 0.5
				deal_damage(e, damage * damage_mult)

func create_fire_effect(pos: Vector2) -> void:
	# Explosion circle
	var circle = Polygon2D.new()
	var points: PackedVector2Array = []
	for i in 24:
		var angle = i * TAU / 24
		points.append(Vector2(cos(angle), sin(angle)) * aoe_radius)
	circle.polygon = points
	circle.color = Color(1.0, 0.5, 0.0, 0.6)
	circle.global_position = pos
	get_tree().root.add_child(circle)

	var tween = create_tween()
	tween.tween_property(circle, "scale", Vector2(1.2, 1.2), 0.1)
	tween.parallel().tween_property(circle, "modulate:a", 0.0, 0.3)
	tween.tween_callback(circle.queue_free)

	# Fire particles
	var particles = CPUParticles2D.new()
	particles.emitting = true
	particles.one_shot = true
	particles.explosiveness = 0.9
	particles.amount = 12
	particles.lifetime = 0.5
	particles.direction = Vector2(0, -1)
	particles.spread = 180.0
	particles.initial_velocity_min = 50.0
	particles.initial_velocity_max = 100.0
	particles.gravity = Vector2(0, -50)
	particles.color = Color(1.0, 0.4, 0.1)
	particles.global_position = pos
	get_tree().root.add_child(particles)

	var timer = get_tree().create_timer(1.0)
	timer.timeout.connect(particles.queue_free)
