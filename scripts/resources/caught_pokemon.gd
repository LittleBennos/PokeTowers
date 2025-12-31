extends Resource
class_name CaughtPokemon

@export var species_id: String = ""
@export var level: int = 1
@export var xp: int = 0

func get_xp_for_next_level() -> int:
	return level * 100

func get_stat_multiplier() -> float:
	# +10% stats per level
	return 1.0 + (level - 1) * 0.1

func add_xp(amount: int) -> bool:
	xp += amount
	var leveled = false
	while xp >= get_xp_for_next_level():
		xp -= get_xp_for_next_level()
		level += 1
		leveled = true
	return leveled

func get_xp_progress() -> float:
	return float(xp) / float(get_xp_for_next_level())

func to_dict() -> Dictionary:
	return {
		"species_id": species_id,
		"level": level,
		"xp": xp
	}

static func from_dict(data: Dictionary) -> CaughtPokemon:
	var pokemon = CaughtPokemon.new()
	pokemon.species_id = data.get("species_id", "")
	pokemon.level = data.get("level", 1)
	pokemon.xp = data.get("xp", 0)
	return pokemon
