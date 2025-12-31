extends Node

signal currency_changed(new_amount: int)
signal lives_changed(new_amount: int)
signal wave_changed(wave_num: int)
signal wave_completed()
signal game_over(won: bool)
signal enemy_killed(enemy: Node2D, reward: int)
signal enemy_selected(enemy: Node2D)
signal pokemon_caught(species_id: String)
signal catch_failed(species_id: String)
signal pokemon_evolved(old_species: String, new_species: String)

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
var selected_caught_pokemon: CaughtPokemon = null

# Map editor
var selected_map_name: String = ""
var selected_map_bg: String = ""

# Selected map for gameplay
var selected_map: MapData = null

# Pokemon collection (one per species)
var pokedex: Dictionary = {}  # species_id -> CaughtPokemon
var pokedex_seen: Array[String] = []
var starter_pokemon: String = ""
var available_pokemon: Array[String] = []  # Snapshot at game start
var party: Array[String] = []  # Selected party for current game (max 6)
const PARTY_SIZE = 6

# Ball settings
var selected_ball: String = "pokeball"
var ball_types: Dictionary = {}  # id -> BallData

# Species registry
var species_registry: Dictionary = {}  # id -> PokemonSpecies

func _ready() -> void:
	load_ball_types()
	load_species_registry()

func load_ball_types() -> void:
	ball_types["pokeball"] = preload("res://resources/balls/pokeball.tres")
	ball_types["greatball"] = preload("res://resources/balls/greatball.tres")
	ball_types["ultraball"] = preload("res://resources/balls/ultraball.tres")

func load_species_registry() -> void:
	# Load all pokemon species from resources/pokemon/
	var dir = DirAccess.open("res://resources/pokemon")
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".tres"):
				var species = load("res://resources/pokemon/" + file_name) as PokemonSpecies
				if species:
					species_registry[species.id] = species
			file_name = dir.get_next()

func get_species(species_id: String) -> PokemonSpecies:
	return species_registry.get(species_id)

func get_ball(ball_id: String) -> BallData:
	return ball_types.get(ball_id)

func mark_seen(species_id: String) -> void:
	if species_id not in pokedex_seen:
		pokedex_seen.append(species_id)

func is_caught(species_id: String) -> bool:
	return species_id in pokedex

func catch_pokemon(enemy: Node) -> bool:
	var species_id = enemy.species_id if "species_id" in enemy else ""
	if species_id == "" or species_id in pokedex:
		return false  # Already caught or no species

	var ball = ball_types.get(selected_ball) as BallData
	if not ball or currency < ball.cost:
		return false  # Can't afford

	spend_currency(ball.cost)

	var catch_rate = calculate_catch_rate(enemy, ball)
	if randf() < catch_rate:
		var caught = CaughtPokemon.new()
		caught.species_id = species_id
		pokedex[species_id] = caught
		pokemon_caught.emit(species_id)
		SaveManager.save_game()
		return true
	else:
		catch_failed.emit(species_id)
		return false

func calculate_catch_rate(enemy: Node, ball: BallData) -> float:
	var hp = enemy.hp if "hp" in enemy else 0.0
	var max_hp = enemy.max_hp if "max_hp" in enemy else 1.0
	var enemy_catch_rate = enemy.catch_rate if "catch_rate" in enemy else 0.5

	# HP ratio within catchable zone (0-25% HP)
	var hp_ratio = hp / (max_hp * 0.25)
	# Lower HP = better catch rate
	var base = 0.6 * (1.0 - hp_ratio)
	return clamp(base * ball.catch_modifier * enemy_catch_rate, 0.1, 0.95)

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
	wave_completed.emit()
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
	# Snapshot pokedex - caught pokemon available for next game
	available_pokemon.clear()
	for key in pokedex.keys():
		available_pokemon.append(key)

func select_tower(tower_type: String) -> void:
	selected_tower_type = tower_type
	is_placing_tower = true

func cancel_placement() -> void:
	selected_tower_type = ""
	is_placing_tower = false
	selected_caught_pokemon = null
