extends BaseEnemy
class_name KakunaEnemy

func _ready() -> void:
	max_hp = 80.0
	speed = 50.0
	reward = 25
	pokemon_type = GameManager.PokemonType.BUG
	super._ready()
