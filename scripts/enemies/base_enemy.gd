extends PathFollow2D
class_name BaseEnemy

signal died(enemy: BaseEnemy)

@export var species_id: String = ""

# Stats loaded from species
var max_hp: float = 30.0
var speed: float = 100.0
var reward: int = 15
var pokemon_type: GameManager.PokemonType = GameManager.PokemonType.NORMAL
var catch_rate: float = 0.5

var hp: float
var catch_attempted: bool = false
var slow_timer: float = 0.0
var slow_amount: float = 1.0
var poison_damage: float = 0.0
var poison_timer: float = 0.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var hp_bar: ProgressBar = $HPBar

func _ready() -> void:
	load_species_data()
	hp = max_hp
	GameManager.register_enemy()
	update_hp_bar()
	if species_id != "":
		GameManager.mark_seen(species_id)

func load_species_data() -> void:
	if species_id == "":
		return
	var species = GameManager.get_species(species_id)
	if not species:
		return
	max_hp = species.base_hp
	speed = species.base_speed
	reward = species.reward
	pokemon_type = species.pokemon_type
	catch_rate = species.catch_rate
	if species.icon and sprite:
		sprite.texture = species.icon

func _process(delta: float) -> void:
	# Movement
	var current_speed = speed * slow_amount
	progress += current_speed * delta

	# Slow effect decay
	if slow_timer > 0:
		slow_timer -= delta
		if slow_timer <= 0:
			slow_amount = 1.0

	# Poison damage (no number spam for DOT)
	if poison_timer > 0:
		poison_timer -= delta
		take_damage(poison_damage * delta, GameManager.PokemonType.GRASS, false)

	# Auto-catch when low HP
	if is_catchable() and not GameManager.is_caught(species_id):
		catch_attempted = true
		if GameManager.catch_pokemon(self):
			show_catch_effect(true)
		else:
			show_catch_effect(false)

	# Reached end of path
	if progress_ratio >= 1.0:
		reach_end()

func is_catchable() -> bool:
	return hp > 0 and hp < max_hp * 0.25 and not catch_attempted and species_id != ""

func show_catch_effect(success: bool) -> void:
	# Visual feedback for catch attempt
	if success:
		flash_color(Color(1, 0.3, 0.3))  # Red pokeball flash
		# Show "Caught!" text
		var label = DamageNumber.new()
		label.text = "CAUGHT!"
		label.position = global_position + Vector2(-30, -40)
		label.add_theme_font_size_override("font_size", 16)
		label.add_theme_color_override("font_color", Color(1, 0.8, 0.2))
		get_viewport().add_child(label)
	else:
		# Show "Failed!" text
		var label = DamageNumber.new()
		label.text = "FAILED"
		label.position = global_position + Vector2(-25, -40)
		label.add_theme_font_size_override("font_size", 14)
		label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
		get_viewport().add_child(label)

func take_damage(amount: float, attacker_type: GameManager.PokemonType = GameManager.PokemonType.NORMAL, show_number: bool = true) -> void:
	var multiplier = GameManager.get_type_multiplier(attacker_type, pokemon_type)
	var actual_damage = amount * multiplier
	hp -= actual_damage
	update_hp_bar()

	# Floating damage number (skip for small DOT ticks)
	if show_number and actual_damage >= 1.0:
		# Use viewport to stay in correct coordinate space
		DamageNumber.spawn(get_viewport(), global_position + Vector2(0, -20), actual_damage, multiplier)

	# Visual feedback for super effective
	if multiplier > 1.0:
		flash_color(Color.YELLOW)

	if hp <= 0:
		die()

func apply_slow(amount: float, duration: float) -> void:
	slow_amount = min(slow_amount, 1.0 - amount)
	slow_timer = max(slow_timer, duration)

func apply_poison(dps: float, duration: float) -> void:
	poison_damage = dps
	poison_timer = duration

func flash_color(color: Color) -> void:
	if sprite:
		var tween = create_tween()
		tween.tween_property(sprite, "modulate", color, 0.1)
		tween.tween_property(sprite, "modulate", Color.WHITE, 0.1)

func update_hp_bar() -> void:
	if hp_bar:
		hp_bar.value = (hp / max_hp) * 100

func die() -> void:
	died.emit(self)
	GameManager.unregister_enemy(true, reward)
	queue_free()

func reach_end() -> void:
	GameManager.lose_life()
	GameManager.unregister_enemy(false)
	queue_free()
