extends BaseEnemy
class_name RattataEnemy

func _ready() -> void:
	max_hp = 30.0
	speed = 120.0
	reward = 15
	pokemon_type = GameManager.PokemonType.NORMAL
	super._ready()
