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
	[{"type": "caterpie", "count": 6}],
	[{"type": "weedle", "count": 6}],
	[{"type": "caterpie", "count": 4}, {"type": "weedle", "count": 4}],
	[{"type": "pidgey", "count": 5}],
	[{"type": "caterpie", "count": 5}, {"type": "pidgey", "count": 3}],
	[{"type": "metapod", "count": 4}, {"type": "caterpie", "count": 6}],
	[{"type": "kakuna", "count": 4}, {"type": "weedle", "count": 6}],
	[{"type": "pidgey", "count": 10}],
	[{"type": "metapod", "count": 5}, {"type": "kakuna", "count": 5}],
	[{"type": "caterpie", "count": 8}, {"type": "weedle", "count": 8}, {"type": "pidgey", "count": 6}, {"type": "metapod", "count": 3}, {"type": "kakuna", "count": 3}],
]

var spawn_queue: Array = []
var spawn_timer: float = 0.0

func _ready() -> void:
	if path:
		_path = get_node(path) as Path2D
	GameManager.wave_changed.connect(_on_wave_changed)

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

	spawn_queue.shuffle()
	spawn_timer = 0.0

func _process(delta: float) -> void:
	if spawn_queue.size() > 0:
		spawn_timer += delta
		if spawn_timer >= spawn_interval:
			spawn_timer = 0.0
			spawn_enemy(spawn_queue.pop_front())

func spawn_enemy(enemy_type: String) -> void:
	if not _path:
		return

	var scene = enemy_scenes.get(enemy_type)
	if not scene:
		return

	var enemy = scene.instantiate() as BaseEnemy
	if not enemy:
		return

	_path.add_child(enemy)
	enemy.progress = 0
