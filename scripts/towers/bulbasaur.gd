extends BaseTower
class_name BulbasaurTower

@export var poison_dps: float = 5.0
@export var poison_duration: float = 3.0

func _ready() -> void:
	tower_name = "Bulbasaur"
	damage = 8.0
	attack_range = 180.0
	attack_speed = 1.0
	cost = 80
	pokemon_type = GameManager.PokemonType.GRASS
	super._ready()

func attack(enemy: BaseEnemy) -> void:
	deal_damage(enemy, damage)
	enemy.apply_poison(poison_dps, poison_duration)
	create_poison_effect(enemy)

func create_poison_effect(enemy: BaseEnemy) -> void:
	# Tint enemy green briefly
	if enemy.sprite:
		var tween = create_tween()
		tween.tween_property(enemy.sprite, "modulate", Color(0.5, 1.0, 0.5), 0.1)
		tween.tween_interval(0.2)
		tween.tween_property(enemy.sprite, "modulate", Color.WHITE, 0.1)

	# Poison cloud particles
	var particles = CPUParticles2D.new()
	particles.emitting = true
	particles.one_shot = true
	particles.explosiveness = 0.5
	particles.amount = 6
	particles.lifetime = 0.6
	particles.direction = Vector2(0, -1)
	particles.spread = 60.0
	particles.initial_velocity_min = 20.0
	particles.initial_velocity_max = 40.0
	particles.gravity = Vector2(0, -20)
	particles.color = Color(0.3, 0.8, 0.2, 0.7)
	particles.global_position = enemy.global_position
	get_tree().root.add_child(particles)

	var timer = get_tree().create_timer(1.0)
	timer.timeout.connect(particles.queue_free)
