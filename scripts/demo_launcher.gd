extends Node
## Demo launcher — sets up 3 starter Pokémon and launches directly into gameplay
## on Route 1. Bypasses menus so the core loop is immediately playable.

func _ready() -> void:
	# Reset any leftover state
	GameManager.reset_game()
	GameManager.pokedex.clear()
	GameManager.party.clear()
	GameManager.placed_pokemon_uuids.clear()
	GameManager.species_catch_counts.clear()
	GameManager.zenny = 500  # Starting currency for catch balls

	# Create the three starters
	var starters = ["bulbasaur", "charmander", "squirtle"]
	for species_id in starters:
		var pokemon = CaughtPokemon.new()
		pokemon.species_id = species_id
		pokemon.catch_number = GameManager.get_next_catch_number(species_id)
		pokemon.level = 5
		pokemon.iv_phys_attack = randi_range(10, 25)
		pokemon.iv_spec_attack = randi_range(10, 25)
		pokemon.iv_defense = randi_range(10, 25)
		pokemon.iv_speed = randi_range(10, 25)
		pokemon.iv_range = randi_range(10, 25)
		pokemon.learn_moves_for_level()
		GameManager.pokedex[pokemon.uuid] = pokemon
		GameManager.party.append(pokemon.uuid)
		GameManager.mark_seen(species_id)

	# Load Route 1 map
	GameManager.selected_map = load("res://resources/maps/route_1.tres") as MapData
	GameManager.waves_total = GameManager.selected_map.waves_count

	# Go straight to game
	get_tree().change_scene_to_file("res://scenes/ui/game_root.tscn")
