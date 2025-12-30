extends BaseEnemy
class_name GeodudeEnemy

func _ready() -> void:
	max_hp = 100.0
	speed = 60.0
	reward = 30
	pokemon_type = GameManager.PokemonType.ROCK
	super._ready()
