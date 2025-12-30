extends Node2D
class_name BaseTower

@export var tower_name: String = "Tower"
@export var damage: float = 10.0
@export var attack_range: float = 150.0
@export var attack_speed: float = 1.0  # Attacks per second
@export var cost: int = 100
@export var pokemon_type: GameManager.PokemonType = GameManager.PokemonType.NORMAL

var target: BaseEnemy = null
var attack_timer: float = 0.0
var enemies_in_range: Array[BaseEnemy] = []

@onready var sprite: Sprite2D = $Sprite2D
@onready var range_area: Area2D = $RangeArea
@onready var range_shape: CollisionShape2D = $RangeArea/CollisionShape2D
@onready var range_indicator: Node2D = $RangeIndicator

func _ready() -> void:
	setup_range()
	hide_range_indicator()

func setup_range() -> void:
	if range_shape and range_shape.shape is CircleShape2D:
		(range_shape.shape as CircleShape2D).radius = attack_range
	if range_indicator:
		range_indicator.scale = Vector2(attack_range / 50.0, attack_range / 50.0)

func _process(delta: float) -> void:
	attack_timer += delta

	if target and is_instance_valid(target):
		look_at_target()
		if attack_timer >= 1.0 / attack_speed:
			attack_timer = 0.0
			attack(target)
	else:
		find_new_target()

func look_at_target() -> void:
	if target and sprite:
		var direction = (target.global_position - global_position).normalized()
		sprite.rotation = direction.angle()

func find_new_target() -> void:
	# Clean up dead enemies
	enemies_in_range = enemies_in_range.filter(func(e): return is_instance_valid(e))

	if enemies_in_range.size() > 0:
		# Target enemy closest to end (highest progress_ratio)
		var best_target: BaseEnemy = null
		var best_progress: float = -1.0
		for enemy in enemies_in_range:
			if enemy.progress_ratio > best_progress:
				best_progress = enemy.progress_ratio
				best_target = enemy
		target = best_target

func attack(enemy: BaseEnemy) -> void:
	# Override in subclasses for special attacks
	deal_damage(enemy, damage)

func deal_damage(enemy: BaseEnemy, amount: float) -> void:
	if enemy and is_instance_valid(enemy):
		enemy.take_damage(amount, pokemon_type)

func show_range_indicator() -> void:
	if range_indicator:
		range_indicator.visible = true

func hide_range_indicator() -> void:
	if range_indicator:
		range_indicator.visible = false

func _on_range_area_area_entered(area: Area2D) -> void:
	var enemy = area.get_parent()
	if enemy is BaseEnemy:
		enemies_in_range.append(enemy as BaseEnemy)
		if not enemy.died.is_connected(_on_enemy_died):
			enemy.died.connect(_on_enemy_died.bind(enemy))

func _on_range_area_area_exited(area: Area2D) -> void:
	var enemy = area.get_parent()
	if enemy is BaseEnemy:
		enemies_in_range.erase(enemy)
		if target == enemy:
			target = null

func _on_enemy_died(enemy: BaseEnemy) -> void:
	enemies_in_range.erase(enemy)
	if target == enemy:
		target = null
