extends Node
class_name WaveManager

@export var path: NodePath
@export var spawn_interval: float = 0.8

var _path: Path2D

var enemy_scenes: Dictionary = {
	"caterpie": preload("res://scenes/enemies/caterpie.tscn"),
	"weedle": preload("res://scenes/enemies/weedle.tscn"),
	"pidgey": preload("res://scenes/enemies/pidgey.tscn"),
	"metapod": preload("res://scenes/enemies/metapod.tscn"),
	"kakuna": preload("res://scenes/enemies/kakuna.tscn"),
}

var wave_definitions: Array = [
	# Wave 1: caterpie swarm
	[{"type": "caterpie", "count": 6}],
	# Wave 2: weedle swarm
	[{"type": "weedle", "count": 6}],
	# Wave 3: mixed bugs
	[{"type": "caterpie", "count": 4}, {"type": "weedle", "count": 4}],
	# Wave 4: pidgey arrives
	[{"type": "pidgey", "count": 5}],
	# Wave 5: bugs + pidgey
	[{"type": "caterpie", "count": 5}, {"type": "pidgey", "count": 3}],
	# Wave 6: metapod tanks
	[{"type": "metapod", "count": 4}, {"type": "caterpie", "count": 6}],
	# Wave 7: kakuna tanks
	[{"type": "kakuna", "count": 4}, {"type": "weedle", "count": 6}],
	# Wave 8: flying assault
	[{"type": "pidgey", "count": 10}],
	# Wave 9: tank wave
	[{"type": "metapod", "count": 5}, {"type": "kakuna", "count": 5}],
	# Wave 10: forest swarm
	[{"type": "caterpie", "count": 8}, {"type": "weedle", "count": 8}, {"type": "pidgey", "count": 6}, {"type": "metapod", "count": 3}, {"type": "kakuna", "count": 3}],
]

var spawn_queue: Array = []
var spawn_timer: float = 0.0
var hud: CanvasLayer

func _ready() -> void:
	if path:
		_path = get_node(path) as Path2D
		print("WaveManager: Path resolved = ", _path)
	else:
		print("WaveManager: No path NodePath set!")
	GameManager.wave_changed.connect(_on_wave_changed)

func set_hud(hud_ref: CanvasLayer) -> void:
	hud = hud_ref

func _on_wave_changed(wave_num: int) -> void:
	start_wave(wave_num)

func start_wave(wave_num: int) -> void:
	if wave_num < 1 or wave_num > wave_definitions.size():
		return

	var wave_data = wave_definitions[wave_num - 1]
	spawn_queue.clear()

	for group in wave_data:
		for i in group.count:
			spawn_queue.append(group.type)

	# Shuffle for variety
	spawn_queue.shuffle()
	spawn_timer = 0.0

func _process(delta: float) -> void:
	if spawn_queue.size() > 0:
		spawn_timer += delta
		if spawn_timer >= spawn_interval:
			spawn_timer = 0.0
			spawn_enemy(spawn_queue.pop_front())
	elif GameManager.is_wave_active and GameManager.enemies_alive == 0:
		# Wave complete
		GameManager.is_wave_active = false
		if hud:
			hud.enable_start_button()

func spawn_enemy(enemy_type: String) -> void:
	if not _path:
		print("ERROR: No path!")
		return

	var scene = enemy_scenes.get(enemy_type)
	if not scene:
		print("ERROR: No scene for ", enemy_type)
		return

	var enemy = scene.instantiate() as BaseEnemy
	if not enemy:
		print("ERROR: Failed to instantiate ", enemy_type)
		return

	print("Spawning ", enemy_type)
	_path.add_child(enemy)
	enemy.progress = 0
