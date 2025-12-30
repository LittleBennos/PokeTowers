extends Node2D
class_name TowerPlacement

@export var valid_placement_area: Area2D
@export var invalid_color: Color = Color(1, 0.3, 0.3, 0.5)
@export var valid_color: Color = Color(0.3, 1, 0.3, 0.5)

var tower_scenes: Dictionary = {
	"pikachu": preload("res://scenes/towers/pikachu.tscn"),
	"squirtle": preload("res://scenes/towers/squirtle.tscn"),
	"charmander": preload("res://scenes/towers/charmander.tscn"),
	"bulbasaur": preload("res://scenes/towers/bulbasaur.tscn"),
}

var tower_costs: Dictionary = {
	"pikachu": 100,
	"squirtle": 75,
	"charmander": 125,
	"bulbasaur": 80,
}

var ghost_tower: Node2D = null
var ghost_sprite: Sprite2D = null
var can_place: bool = false

@onready var towers_container: Node2D = $TowersContainer
@onready var placement_area: Area2D = $PlacementArea

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	if GameManager.is_placing_tower:
		update_ghost_tower()
	elif ghost_tower:
		remove_ghost_tower()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_event = event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.pressed:
			if GameManager.is_placing_tower and can_place:
				place_tower()
		elif mouse_event.button_index == MOUSE_BUTTON_RIGHT and mouse_event.pressed:
			GameManager.cancel_placement()

func update_ghost_tower() -> void:
	var mouse_pos = get_global_mouse_position()

	if not ghost_tower:
		create_ghost_tower()

	if ghost_tower:
		ghost_tower.global_position = mouse_pos
		can_place = is_valid_placement(mouse_pos)
		update_ghost_color()

func create_ghost_tower() -> void:
	var tower_type = GameManager.selected_tower_type
	if tower_type in tower_scenes:
		ghost_tower = tower_scenes[tower_type].instantiate()
		ghost_tower.set_process(false)
		add_child(ghost_tower)

		ghost_sprite = ghost_tower.get_node_or_null("Sprite2D")
		if ghost_tower.has_method("show_range_indicator"):
			ghost_tower.show_range_indicator()

func remove_ghost_tower() -> void:
	if ghost_tower:
		ghost_tower.queue_free()
		ghost_tower = null
		ghost_sprite = null

func update_ghost_color() -> void:
	if ghost_sprite:
		ghost_sprite.modulate = valid_color if can_place else invalid_color

func is_valid_placement(pos: Vector2) -> bool:
	# Check if in placement area (not on path)
	if placement_area:
		var space_state = get_world_2d().direct_space_state
		var query = PhysicsPointQueryParameters2D.new()
		query.position = pos
		query.collision_mask = 4  # Placement area layer
		var result = space_state.intersect_point(query)
		if result.size() == 0:
			return false

	# Check not overlapping other towers
	for tower in towers_container.get_children():
		if tower.global_position.distance_to(pos) < 50:
			return false

	return true

func place_tower() -> void:
	var tower_type = GameManager.selected_tower_type
	var cost = tower_costs.get(tower_type, 100)

	if not GameManager.spend_currency(cost):
		return

	var tower = tower_scenes[tower_type].instantiate()
	tower.global_position = get_global_mouse_position()
	towers_container.add_child(tower)

	GameManager.cancel_placement()
