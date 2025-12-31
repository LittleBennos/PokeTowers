extends Node2D

enum Mode { PATH, ZONES }

@onready var line: Line2D = $Line2D
@onready var output_label: Label = $UI/OutputPanel/Output
@onready var background: TextureRect = $Background
@onready var map_label: Label = $UI/MapLabel
@onready var instructions: Label = $UI/Instructions
@onready var path_btn: Button = $UI/TopBar/PathBtn
@onready var zones_btn: Button = $UI/TopBar/ZonesBtn

var waypoints: Array[Vector2] = []
var zones: Array[Vector2] = []
var zone_sizes: Array[float] = []

var current_mode: Mode = Mode.PATH
var selected_point: int = -1
var selected_zone: int = -1
var dragging: bool = false
var drag_offset: Vector2 = Vector2.ZERO

const POINT_RADIUS := 15.0
const DEFAULT_ZONE_SIZE := 40.0
const MIN_ZONE_SIZE := 30.0
const MAX_ZONE_SIZE := 120.0
const ZONE_SIZE_STEP := 10.0
const MAP_LEFT := 200.0
const MAP_RIGHT := 1080.0
const MAP_TOP := 0.0
const MAP_BOTTOM := 720.0

func _ready() -> void:
	line.clear_points()
	if GameManager.selected_map_bg != "":
		var tex = load(GameManager.selected_map_bg)
		if tex:
			background.texture = tex
	if GameManager.selected_map_name != "":
		map_label.text = GameManager.selected_map_name
	update_mode_buttons()
	update_instructions()

func _input(event: InputEvent) -> void:
	if current_mode == Mode.PATH:
		handle_path_input(event)
	else:
		handle_zone_input(event)

func handle_path_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var pos = clamp_to_map(event.position)
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				var pt = get_point_at(event.position)
				if pt >= 0:
					# Start dragging existing point
					selected_point = pt
					dragging = true
					drag_offset = waypoints[pt] - event.position
				elif event.shift_pressed and waypoints.size() >= 2:
					# Insert point on segment
					var seg = get_segment_at(event.position)
					if seg >= 0:
						insert_point(seg + 1, pos)
				else:
					# Add new point at end
					add_waypoint(pos)
			else:
				dragging = false
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			var pt = get_point_at(event.position)
			if pt >= 0:
				delete_point(pt)
			else:
				undo_waypoint()
	elif event is InputEventMouseMotion and dragging and selected_point >= 0:
		waypoints[selected_point] = clamp_to_map(event.position + drag_offset)
		rebuild_line()
		update_output()
		queue_redraw()

func handle_zone_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var pos = clamp_to_map(event.position)
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				var z = get_zone_at(event.position)
				if z >= 0:
					selected_zone = z
					dragging = true
					drag_offset = zones[z] - event.position
				else:
					# Add new zone
					zones.append(pos)
					zone_sizes.append(DEFAULT_ZONE_SIZE)
					selected_zone = zones.size() - 1
					update_output()
			else:
				dragging = false
			queue_redraw()
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			var z = get_zone_at(event.position)
			if z >= 0:
				zones.remove_at(z)
				zone_sizes.remove_at(z)
				selected_zone = -1
				update_output()
				queue_redraw()
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			if selected_zone >= 0:
				zone_sizes[selected_zone] = min(zone_sizes[selected_zone] + ZONE_SIZE_STEP, MAX_ZONE_SIZE)
				update_output()
				queue_redraw()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			if selected_zone >= 0:
				zone_sizes[selected_zone] = max(zone_sizes[selected_zone] - ZONE_SIZE_STEP, MIN_ZONE_SIZE)
				update_output()
				queue_redraw()
	elif event is InputEventMouseMotion and dragging and selected_zone >= 0:
		zones[selected_zone] = clamp_to_map(event.position + drag_offset)
		update_output()
		queue_redraw()

func clamp_to_map(pos: Vector2) -> Vector2:
	pos.x = clamp(pos.x, MAP_LEFT, MAP_RIGHT)
	pos.y = clamp(pos.y, MAP_TOP, MAP_BOTTOM)
	return pos

func get_point_at(pos: Vector2) -> int:
	for i in range(waypoints.size()):
		if pos.distance_to(waypoints[i]) < POINT_RADIUS:
			return i
	return -1

func get_segment_at(pos: Vector2) -> int:
	for i in range(waypoints.size() - 1):
		var a = waypoints[i]
		var b = waypoints[i + 1]
		var dist = point_to_segment_dist(pos, a, b)
		if dist < 20:
			return i
	return -1

func point_to_segment_dist(p: Vector2, a: Vector2, b: Vector2) -> float:
	var ab = b - a
	var ap = p - a
	var t = clamp(ap.dot(ab) / ab.dot(ab), 0.0, 1.0)
	var closest = a + ab * t
	return p.distance_to(closest)

func get_zone_at(pos: Vector2) -> int:
	for i in range(zones.size()):
		var zpos = zones[i]
		var size = zone_sizes[i] if i < zone_sizes.size() else DEFAULT_ZONE_SIZE
		if abs(pos.x - zpos.x) < size / 2 and abs(pos.y - zpos.y) < size / 2:
			return i
	return -1

func add_waypoint(pos: Vector2) -> void:
	waypoints.append(pos)
	line.add_point(pos)
	selected_point = waypoints.size() - 1
	update_output()
	queue_redraw()

func insert_point(idx: int, pos: Vector2) -> void:
	waypoints.insert(idx, pos)
	rebuild_line()
	selected_point = idx
	update_output()
	queue_redraw()

func delete_point(idx: int) -> void:
	if waypoints.size() > 0:
		waypoints.remove_at(idx)
		rebuild_line()
		selected_point = -1
		update_output()
		queue_redraw()

func undo_waypoint() -> void:
	if waypoints.size() > 0:
		waypoints.pop_back()
		line.remove_point(line.get_point_count() - 1)
		selected_point = -1
		update_output()
		queue_redraw()

func rebuild_line() -> void:
	line.clear_points()
	for wp in waypoints:
		line.add_point(wp)

func clear_all() -> void:
	if current_mode == Mode.PATH:
		waypoints.clear()
		line.clear_points()
		selected_point = -1
	else:
		zones.clear()
		zone_sizes.clear()
		selected_zone = -1
	update_output()
	queue_redraw()

func _draw() -> void:
	# Draw path points
	if current_mode == Mode.PATH:
		for i in range(waypoints.size()):
			var color = Color.YELLOW if i == selected_point else Color.WHITE
			draw_circle(waypoints[i], POINT_RADIUS, color)
			draw_circle(waypoints[i], POINT_RADIUS - 3, Color(0.2, 0.2, 0.2))
			# Draw index
			draw_string(ThemeDB.fallback_font, waypoints[i] + Vector2(-4, 5), str(i), HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color.WHITE)

	# Draw zones
	for i in range(zones.size()):
		var zpos = zones[i]
		var size = zone_sizes[i] if i < zone_sizes.size() else DEFAULT_ZONE_SIZE
		var rect = Rect2(zpos - Vector2(size/2, size/2), Vector2(size, size))
		var color = Color(0.3, 0.8, 0.3, 0.5) if current_mode == Mode.ZONES else Color(0.3, 0.5, 0.3, 0.3)
		if i == selected_zone and current_mode == Mode.ZONES:
			color = Color(0.5, 1.0, 0.5, 0.7)
		draw_rect(rect, color)
		draw_rect(rect, Color.WHITE, false, 2.0)
		# Draw index and size
		draw_string(ThemeDB.fallback_font, zpos + Vector2(-8, 5), str(i + 1), HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color.WHITE)
		if current_mode == Mode.ZONES:
			draw_string(ThemeDB.fallback_font, zpos + Vector2(-12, -size/2 + 14), str(int(size)), HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color.YELLOW)

func update_output() -> void:
	var text = ""

	# Path output
	if waypoints.size() > 0:
		var curve_parts: Array[String] = []
		for wp in waypoints:
			curve_parts.append("0, 0, 0, 0, %d, %d" % [int(wp.x - MAP_LEFT), int(wp.y)])
		text += "Path Curve2D:\nPackedVector2Array(%s)\n\n" % ", ".join(curve_parts)

		var line_parts: Array[String] = []
		for wp in waypoints:
			line_parts.append("%d, %d" % [int(wp.x - MAP_LEFT), int(wp.y)])
		text += "Path Line2D:\nPackedVector2Array(%s)\n\n" % ", ".join(line_parts)
	else:
		text += "Path: (empty)\n\n"

	# Zones output
	if zones.size() > 0:
		var zone_parts: Array[String] = []
		for i in range(zones.size()):
			var z = zones[i]
			var size = zone_sizes[i] if i < zone_sizes.size() else DEFAULT_ZONE_SIZE
			zone_parts.append("{pos=Vector2(%d, %d), size=%d}" % [int(z.x - MAP_LEFT), int(z.y), int(size)])
		text += "Zones:\n[%s]" % ", ".join(zone_parts)
	else:
		text += "Zones: (empty)"

	output_label.text = text

func update_mode_buttons() -> void:
	path_btn.button_pressed = current_mode == Mode.PATH
	zones_btn.button_pressed = current_mode == Mode.ZONES

func update_instructions() -> void:
	if current_mode == Mode.PATH:
		instructions.text = "PATH MODE\nClick: add point | Drag: move | Shift+click: insert | Right-click: delete"
	else:
		instructions.text = "ZONE MODE\nClick: add zone | Drag: move | Scroll: resize | Right-click: delete"

func set_mode(mode: Mode) -> void:
	current_mode = mode
	selected_point = -1
	selected_zone = -1
	dragging = false
	update_mode_buttons()
	update_instructions()
	queue_redraw()

func _on_path_pressed() -> void:
	set_mode(Mode.PATH)

func _on_zones_pressed() -> void:
	set_mode(Mode.ZONES)

func _on_clear_pressed() -> void:
	clear_all()

func _on_copy_pressed() -> void:
	var output = ""

	if waypoints.size() > 0:
		var curve_parts: Array[String] = []
		for wp in waypoints:
			curve_parts.append("0, 0, 0, 0, %d, %d" % [int(wp.x - MAP_LEFT), int(wp.y)])
		output += "# Path Curve2D\nPackedVector2Array(%s)\n\n" % ", ".join(curve_parts)

		var line_parts: Array[String] = []
		for wp in waypoints:
			line_parts.append("%d, %d" % [int(wp.x - MAP_LEFT), int(wp.y)])
		output += "# Path Line2D\nPackedVector2Array(%s)\n\n" % ", ".join(line_parts)

	if zones.size() > 0:
		var zone_parts: Array[String] = []
		for i in range(zones.size()):
			var z = zones[i]
			var size = zone_sizes[i] if i < zone_sizes.size() else DEFAULT_ZONE_SIZE
			zone_parts.append("{pos=Vector2(%d, %d), size=%d}" % [int(z.x - MAP_LEFT), int(z.y), int(size)])
		output += "# Zone positions (pos, size)\n[%s]" % ", ".join(zone_parts)

	if output != "":
		DisplayServer.clipboard_set(output)
		print("Copied to clipboard!")

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/map_select.tscn")
