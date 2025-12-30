extends BaseTower
class_name SquirtleTower

@export var slow_amount: float = 0.3
@export var slow_duration: float = 2.0

func _ready() -> void:
	tower_name = "Squirtle"
	damage = 10.0
	attack_range = 150.0
	attack_speed = 1.2
	cost = 75
	pokemon_type = GameManager.PokemonType.WATER
	super._ready()

func attack(enemy: BaseEnemy) -> void:
	deal_damage(enemy, damage)
	enemy.apply_slow(slow_amount, slow_duration)
	create_water_effect(enemy.global_position)

func create_water_effect(pos: Vector2) -> void:
	var particles = CPUParticles2D.new()
	particles.emitting = true
	particles.one_shot = true
	particles.explosiveness = 0.8
	particles.amount = 8
	particles.lifetime = 0.4
	particles.direction = Vector2(0, -1)
	particles.spread = 45.0
	particles.initial_velocity_min = 30.0
	particles.initial_velocity_max = 60.0
	particles.gravity = Vector2(0, 100)
	particles.color = Color(0.3, 0.6, 1.0)
	particles.global_position = pos
	get_tree().root.add_child(particles)

	var timer = get_tree().create_timer(1.0)
	timer.timeout.connect(particles.queue_free)
