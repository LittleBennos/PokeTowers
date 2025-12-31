extends PanelContainer
class_name TowerCard

signal deploy_pressed(tower_data: TowerData)

@export var tower_data: TowerData

var caught_pokemon: CaughtPokemon = null  # Set for caught pokemon cards

@onready var icon: TextureRect = $HBox/Icon
@onready var name_label: Label = $HBox/VBox/NameLabel
@onready var type_label: Label = $HBox/VBox/TypeLabel
@onready var cost_label: Label = $HBox/VBox/CostLabel
@onready var deploy_btn: Button = $HBox/DeployBtn

var _affordable: bool = true

func _ready() -> void:
	if tower_data:
		setup()
	GameManager.currency_changed.connect(_on_currency_changed)
	_on_currency_changed(GameManager.currency)

func setup() -> void:
	if not tower_data:
		return

	if icon and tower_data.icon:
		icon.texture = tower_data.icon

	if name_label:
		name_label.text = tower_data.display_name

	if type_label:
		type_label.text = tower_data.get_type_name()
		type_label.add_theme_color_override("font_color", tower_data.get_type_color())

	if cost_label:
		cost_label.text = "$%d" % tower_data.cost

func set_tower_data(data: TowerData) -> void:
	tower_data = data
	if is_node_ready():
		setup()
		_on_currency_changed(GameManager.currency)

func _on_currency_changed(amount: int) -> void:
	if not tower_data:
		return
	_affordable = amount >= tower_data.cost
	if deploy_btn:
		deploy_btn.disabled = not _affordable
	modulate = Color.WHITE if _affordable else Color(0.6, 0.6, 0.6)

func _on_deploy_btn_pressed() -> void:
	if tower_data and _affordable:
		GameManager.select_tower(tower_data.id)
		GameManager.selected_caught_pokemon = caught_pokemon
		deploy_pressed.emit(tower_data)
