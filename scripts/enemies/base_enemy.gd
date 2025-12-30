extends PathFollow2D
class_name BaseEnemy

signal died(enemy: BaseEnemy)

@export var max_hp: float = 30.0
@export var speed: float = 100.0
@export var reward: int = 15
@export var pokemon_type: GameManager.PokemonType = GameManager.PokemonType.NORMAL

var hp: float
var slow_timer: float = 0.0
var slow_amount: float = 1.0
var poison_damage: float = 0.0
var poison_timer: float = 0.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var hp_bar: ProgressBar = $HPBar

func _ready() -> void:
	hp = max_hp
	GameManager.register_enemy()
	update_hp_bar()

func _process(delta: float) -> void:
	# Movement
	var current_speed = speed * slow_amount
	progress += current_speed * delta

	# Slow effect decay
	if slow_timer > 0:
		slow_timer -= delta
		if slow_timer <= 0:
			slow_amount = 1.0

	# Poison damage
	if poison_timer > 0:
		poison_timer -= delta
		take_damage(poison_damage * delta, GameManager.PokemonType.GRASS)

	# Reached end of path
	if progress_ratio >= 1.0:
		reach_end()

func take_damage(amount: float, attacker_type: GameManager.PokemonType = GameManager.PokemonType.NORMAL) -> void:
	var multiplier = GameManager.get_type_multiplier(attacker_type, pokemon_type)
	var actual_damage = amount * multiplier
	hp -= actual_damage
	update_hp_bar()

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
