extends Node2D

@onready var line: Line2D = $Line2D
@onready var output_label: Label = $UI/OutputPanel/Output
@onready var background: TextureRect = $Background

var waypoints: Array[Vector2] = []

@onready var map_label: Label = $UI/MapLabel

func _ready() -> void:
	line.clear_points()
	# Load selected map background
	if GameManager.selected_map_bg != "":
		var tex = load(GameManager.selected_map_bg)
		if tex:
			background.texture = tex
	if GameManager.selected_map_name != "":
		map_label.text = GameManager.selected_map_name

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			add_waypoint(event.position)
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			undo_waypoint()

func add_waypoint(pos: Vector2) -> void:
	# Clamp to map area (200-1080 x, 0-720 y)
	pos.x = clamp(pos.x, 200, 1080)
	pos.y = clamp(pos.y, 0, 720)
	waypoints.append(pos)
	line.add_point(pos)
	update_output()

func undo_waypoint() -> void:
	if waypoints.size() > 0:
		waypoints.pop_back()
		line.remove_point(line.get_point_count() - 1)
		update_output()

func clear_waypoints() -> void:
	waypoints.clear()
	line.clear_points()
	update_output()

func update_output() -> void:
	if waypoints.size() == 0:
		output_label.text = "Click to add waypoints\nRight-click to undo"
		return

	# Generate Curve2D format
	var curve_parts: Array[String] = []
	for wp in waypoints:
		curve_parts.append("0, 0, 0, 0, %d, %d" % [int(wp.x), int(wp.y)])

	var curve_str = "PackedVector2Array(%s)" % ", ".join(curve_parts)

	# Generate Line2D format
	var line_parts: Array[String] = []
	for wp in waypoints:
		line_parts.append("%d, %d" % [int(wp.x), int(wp.y)])

	var line_str = "PackedVector2Array(%s)" % ", ".join(line_parts)

	output_label.text = "Curve2D points:\n%s\n\nLine2D points:\n%s" % [curve_str, line_str]

func _on_clear_pressed() -> void:
	clear_waypoints()

func _on_copy_pressed() -> void:
	if waypoints.size() > 0:
		var curve_parts: Array[String] = []
		for wp in waypoints:
			curve_parts.append("0, 0, 0, 0, %d, %d" % [int(wp.x), int(wp.y)])
		DisplayServer.clipboard_set("PackedVector2Array(%s)" % ", ".join(curve_parts))
		print("Path copied to clipboard!")

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/map_select.tscn")
