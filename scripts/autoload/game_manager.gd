extends Node

signal currency_changed(new_amount: int)
signal lives_changed(new_amount: int)
signal wave_changed(wave_num: int)
signal game_over(won: bool)
signal enemy_killed(enemy: Node2D, reward: int)

# Game state
var currency: int = 200:
	set(value):
		currency = value
		currency_changed.emit(currency)

var lives: int = 20:
	set(value):
		lives = max(0, value)
		lives_changed.emit(lives)
		if lives <= 0:
			game_over.emit(false)

var current_wave: int = 0
var waves_total: int = 10
var is_wave_active: bool = false
var enemies_alive: int = 0

# Type effectiveness chart
enum PokemonType { NORMAL, FIRE, WATER, GRASS, ELECTRIC, GROUND, ROCK, FLYING, BUG }

var type_chart: Dictionary = {
	PokemonType.FIRE: { PokemonType.GRASS: 2.0, PokemonType.WATER: 0.5, PokemonType.ROCK: 0.5, PokemonType.BUG: 2.0 },
	PokemonType.WATER: { PokemonType.FIRE: 2.0, PokemonType.GRASS: 0.5, PokemonType.GROUND: 2.0 },
	PokemonType.GRASS: { PokemonType.WATER: 2.0, PokemonType.FIRE: 0.5, PokemonType.GROUND: 2.0, PokemonType.BUG: 0.5 },
	PokemonType.ELECTRIC: { PokemonType.WATER: 2.0, PokemonType.GROUND: 0.0 },
	PokemonType.GROUND: { PokemonType.ELECTRIC: 2.0, PokemonType.FIRE: 2.0, PokemonType.ROCK: 2.0 },
	PokemonType.ROCK: { PokemonType.FIRE: 2.0, PokemonType.FLYING: 2.0, PokemonType.BUG: 2.0 },
	PokemonType.FLYING: { PokemonType.BUG: 2.0, PokemonType.GRASS: 2.0 },
}

# Tower placement
var selected_tower_type: String = ""
var is_placing_tower: bool = false

# Map editor
var selected_map_name: String = ""
var selected_map_bg: String = ""

func _ready() -> void:
	pass

func get_type_multiplier(attacker_type: PokemonType, defender_type: PokemonType) -> float:
	if attacker_type in type_chart:
		if defender_type in type_chart[attacker_type]:
			return type_chart[attacker_type][defender_type]
	return 1.0

func add_currency(amount: int) -> void:
	currency += amount

func spend_currency(amount: int) -> bool:
	if currency >= amount:
		currency -= amount
		return true
	return false

func lose_life(amount: int = 1) -> void:
	lives -= amount

func register_enemy() -> void:
	enemies_alive += 1

func unregister_enemy(was_killed: bool, reward: int = 0) -> void:
	enemies_alive -= 1
	if was_killed:
		add_currency(reward)
	if enemies_alive <= 0 and is_wave_active:
		is_wave_active = false
		check_wave_complete()

func check_wave_complete() -> void:
	if current_wave >= waves_total:
		game_over.emit(true)

func start_wave() -> void:
	if not is_wave_active:
		current_wave += 1
		is_wave_active = true
		wave_changed.emit(current_wave)

func reset_game() -> void:
	currency = 200
	lives = 20
	current_wave = 0
	is_wave_active = false
	enemies_alive = 0
	selected_tower_type = ""
	is_placing_tower = false

func select_tower(tower_type: String) -> void:
	selected_tower_type = tower_type
	is_placing_tower = true

func cancel_placement() -> void:
	selected_tower_type = ""
	is_placing_tower = false
