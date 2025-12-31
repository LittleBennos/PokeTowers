extends Area2D
class_name BaseProjectile

@export var speed: float = 400.0
@export var damage: float = 10.0
@export var pokemon_type: GameManager.PokemonType = GameManager.PokemonType.NORMAL

var target: Node2D = null
var direction: Vector2 = Vector2.RIGHT

func _ready() -> void:
	area_entered.connect(_on_area_entered)

func _process(delta: float) -> void:
	if target and is_instance_valid(target):
		# Home towards target
		direction = (target.global_position - global_position).normalized()
		rotation = direction.angle()

	position += direction * speed * delta

	# Remove if off screen
	if not get_viewport_rect().grow(100).has_point(global_position):
		queue_free()

func start(target_enemy: Node2D, dmg: float, type: GameManager.PokemonType) -> void:
	target = target_enemy
	damage = dmg
	pokemon_type = type
	if target:
		direction = (target.global_position - global_position).normalized()
		rotation = direction.angle()

func _on_area_entered(area: Area2D) -> void:
	var enemy = area.get_parent()
	if enemy is BaseEnemy:
		hit_enemy(enemy)
		queue_free()

func hit_enemy(enemy: BaseEnemy) -> void:
	enemy.take_damage(damage, pokemon_type)
	create_impact_effect(enemy.global_position)

func create_impact_effect(_pos: Vector2) -> void:
	# Override in subclasses
	pass
