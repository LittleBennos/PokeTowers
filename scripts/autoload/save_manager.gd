extends Node

const SAVE_DIR = "user://saves/"
const SAVE_VERSION = 1
const NUM_SLOTS = 3

var current_slot: int = -1  # -1 = no slot selected

func _ready() -> void:
	# Ensure save directory exists
	DirAccess.make_dir_recursive_absolute(SAVE_DIR.replace("user://", OS.get_user_data_dir() + "/"))

func get_save_path(slot: int) -> String:
	return SAVE_DIR + "slot_%d.json" % slot

func slot_exists(slot: int) -> bool:
	return FileAccess.file_exists(get_save_path(slot))

func get_slot_info(slot: int) -> Dictionary:
	# Returns preview info for slot select screen
	if not slot_exists(slot):
		return {"empty": true}

	var file = FileAccess.open(get_save_path(slot), FileAccess.READ)
	if not file:
		return {"empty": true}

	var data = JSON.parse_string(file.get_as_text())
	if not data:
		return {"empty": true}

	return {
		"empty": false,
		"starter": data.get("starter", ""),
		"pokemon_count": data.get("pokedex", {}).size(),
		"timestamp": data.get("timestamp", 0)
	}

func save_game() -> void:
	if current_slot < 0:
		return

	var data = {
		"version": SAVE_VERSION,
		"timestamp": Time.get_unix_time_from_system(),
		"starter": GameManager.starter_pokemon,
		"pokedex": serialize_pokedex(),
		"pokedex_seen": GameManager.pokedex_seen,
		"selected_ball": GameManager.selected_ball
	}
	var file = FileAccess.open(get_save_path(current_slot), FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data, "\t"))

func load_slot(slot: int) -> bool:
	var path = get_save_path(slot)
	if not FileAccess.file_exists(path):
		# New slot - reset game state
		reset_game_state()
		current_slot = slot
		return true

	var file = FileAccess.open(path, FileAccess.READ)
	if not file:
		return false

	var data = JSON.parse_string(file.get_as_text())
	if not data:
		return false

	var version = data.get("version", 0)
	if version != SAVE_VERSION:
		return false

	# Restore state
	GameManager.starter_pokemon = data.get("starter", "")
	GameManager.selected_ball = data.get("selected_ball", "pokeball")
	deserialize_pokedex(data.get("pokedex", {}))

	# Handle typed array for pokedex_seen
	GameManager.pokedex_seen.clear()
	var seen_array = data.get("pokedex_seen", [])
	for item in seen_array:
		GameManager.pokedex_seen.append(item)

	current_slot = slot
	return true

func reset_game_state() -> void:
	GameManager.starter_pokemon = ""
	GameManager.pokedex.clear()
	GameManager.pokedex_seen.clear()
	GameManager.selected_ball = "pokeball"
	GameManager.party.clear()

func delete_slot(slot: int) -> void:
	var path = get_save_path(slot)
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)
	if current_slot == slot:
		reset_game_state()
		current_slot = -1

func serialize_pokedex() -> Dictionary:
	var result = {}
	for species_id in GameManager.pokedex:
		var pokemon: CaughtPokemon = GameManager.pokedex[species_id]
		result[species_id] = pokemon.to_dict()
	return result

func deserialize_pokedex(data: Dictionary) -> void:
	GameManager.pokedex.clear()
	for species_id in data:
		var pokemon = CaughtPokemon.from_dict(data[species_id])
		GameManager.pokedex[species_id] = pokemon

# Export/Import
func export_save() -> String:
	if current_slot < 0:
		return ""
	var path = get_save_path(current_slot)
	if not FileAccess.file_exists(path):
		return ""
	var file = FileAccess.open(path, FileAccess.READ)
	return file.get_as_text() if file else ""

func import_save(json_text: String) -> bool:
	if current_slot < 0:
		return false

	var data = JSON.parse_string(json_text)
	if not data or not data.has("version"):
		return false

	# Save imported data to current slot
	var file = FileAccess.open(get_save_path(current_slot), FileAccess.WRITE)
	if not file:
		return false
	file.store_string(json_text)

	# Reload slot
	return load_slot(current_slot)

func get_export_path() -> String:
	return OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS) + "/poketowers_save.json"

func export_to_file() -> bool:
	var json = export_save()
	if json == "":
		return false
	var file = FileAccess.open(get_export_path(), FileAccess.WRITE)
	if not file:
		return false
	file.store_string(json)
	return true

func import_from_file() -> bool:
	var path = get_export_path()
	if not FileAccess.file_exists(path):
		return false
	var file = FileAccess.open(path, FileAccess.READ)
	if not file:
		return false
	return import_save(file.get_as_text())
