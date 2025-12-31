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

# For caught pokemon deployed as towers
var caught_pokemon: CaughtPokemon = null

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
		if attack_timer >= 1.0 / get_effective_attack_speed():
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
	deal_damage(enemy, get_effective_damage())

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
			enemy.died.connect(_on_enemy_died)

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

	# XP gain for caught pokemon towers
	if caught_pokemon:
		var xp_gain = calculate_xp_gain(enemy)
		if caught_pokemon.add_xp(xp_gain):
			on_level_up()

func calculate_xp_gain(enemy: BaseEnemy) -> int:
	var base_xp = 10 + int(enemy.max_hp / 5)
	# Bonus for type effectiveness
	var multiplier = GameManager.get_type_multiplier(pokemon_type, enemy.pokemon_type)
	if multiplier > 1.0:
		base_xp = int(base_xp * 1.5)
	return base_xp

func on_level_up() -> void:
	# Visual feedback
	var label = DamageNumber.new()
	label.text = "LEVEL UP!"
	label.position = global_position + Vector2(-35, -50)
	label.add_theme_font_size_override("font_size", 16)
	label.add_theme_color_override("font_color", Color(0.3, 1.0, 0.5))
	get_viewport().add_child(label)

	# Check for evolution
	check_evolution()

func check_evolution() -> void:
	if not caught_pokemon:
		return

	var species = GameManager.get_species(caught_pokemon.species_id)
	if not species or species.evolves_to == "":
		return

	if caught_pokemon.level >= species.evolve_level:
		var old_id = caught_pokemon.species_id
		caught_pokemon.species_id = species.evolves_to
		GameManager.pokemon_evolved.emit(old_id, species.evolves_to)
		# TODO: swap tower scene for evolved form

func get_effective_damage() -> float:
	var mult = caught_pokemon.get_stat_multiplier() if caught_pokemon else 1.0
	return damage * mult

func get_effective_range() -> float:
	var mult = caught_pokemon.get_stat_multiplier() if caught_pokemon else 1.0
	return attack_range * mult

func get_effective_attack_speed() -> float:
	var mult = caught_pokemon.get_stat_multiplier() if caught_pokemon else 1.0
	return attack_speed * mult
