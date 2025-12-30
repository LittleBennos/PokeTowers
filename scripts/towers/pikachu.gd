extends BaseTower
class_name PikachuTower

@export var chain_count: int = 2
@export var chain_range: float = 80.0

func _ready() -> void:
	tower_name = "Pikachu"
	damage = 15.0
	attack_range = 150.0
	attack_speed = 2.0
	cost = 100
	pokemon_type = GameManager.PokemonType.ELECTRIC
	super._ready()

func attack(enemy: BaseEnemy) -> void:
	# Chain lightning - hits target + nearby enemies
	var hit_enemies: Array[BaseEnemy] = [enemy]
	deal_damage(enemy, damage)
	create_lightning_effect(global_position, enemy.global_position)

	var current_target = enemy
	for i in chain_count:
		var next_target = find_chain_target(current_target, hit_enemies)
		if next_target:
			deal_damage(next_target, damage * 0.6)  # Reduced chain damage
			create_lightning_effect(current_target.global_position, next_target.global_position)
			hit_enemies.append(next_target)
			current_target = next_target
		else:
			break

func find_chain_target(from_enemy: BaseEnemy, exclude: Array[BaseEnemy]) -> BaseEnemy:
	var best_target: BaseEnemy = null
	var best_dist: float = chain_range

	for enemy in enemies_in_range:
		if enemy in exclude or not is_instance_valid(enemy):
			continue
		var dist = from_enemy.global_position.distance_to(enemy.global_position)
		if dist < best_dist:
			best_dist = dist
			best_target = enemy

	return best_target

func create_lightning_effect(from: Vector2, to: Vector2) -> void:
	var line = Line2D.new()
	line.width = 3.0
	line.default_color = Color.YELLOW
	line.add_point(from)
	line.add_point(to)
	get_tree().root.add_child(line)

	# Fade out
	var tween = create_tween()
	tween.tween_property(line, "modulate:a", 0.0, 0.15)
	tween.tween_callback(line.queue_free)
