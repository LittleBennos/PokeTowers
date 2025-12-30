extends BaseEnemy
class_name PidgeyEnemy

func _ready() -> void:
	max_hp = 40.0
	speed = 110.0
	reward = 20
	pokemon_type = GameManager.PokemonType.FLYING
	super._ready()
