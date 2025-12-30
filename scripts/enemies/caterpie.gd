extends BaseEnemy
class_name CaterpieEnemy

func _ready() -> void:
	max_hp = 25.0
	speed = 130.0
	reward = 10
	pokemon_type = GameManager.PokemonType.BUG
	super._ready()
