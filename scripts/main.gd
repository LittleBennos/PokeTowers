extends Node2D

@export var map_data: MapData

@onready var wave_manager: WaveManager = $WaveManager
@onready var background: TextureRect = $Background
@onready var enemy_path: Path2D = $EnemyPath
@onready var path_line: Line2D = $EnemyPath/PathLine
@onready var tower_placement: TowerPlacement = $TowerPlacement

func _ready() -> void:
	# Use selected map from GameManager if available, else fall back to export
	var active_map = GameManager.selected_map if GameManager.selected_map else map_data
	if active_map:
		load_map(active_map)

func load_map(data: MapData) -> void:
	background.texture = data.background

	# Set path curve
	var curve = Curve2D.new()
	for point in data.path_points:
		curve.add_point(point)
	enemy_path.curve = curve

	# Set path line visual
	path_line.clear_points()
	for point in data.path_points:
		path_line.add_point(point)

	# Load zones
	tower_placement.load_zones_from_map(data)
