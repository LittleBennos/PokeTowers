extends CanvasLayer

@onready var currency_label: Label = $RightPanel/VBox/CurrencyLabel
@onready var lives_label: Label = $RightPanel/VBox/LivesLabel
@onready var wave_label: Label = $RightPanel/VBox/WaveLabel
@onready var start_wave_btn: Button = $RightPanel/VBox/StartWaveButton
@onready var tower_grid: GridContainer = $LeftPanel/VBox/TowerGrid
@onready var game_over_panel: Panel = $GameOverPanel
@onready var game_over_label: Label = $GameOverPanel/Label

var tower_data: Dictionary = {
	"pikachu": { "name": "Pikachu", "cost": 100, "scene": "res://scenes/towers/generic_pokemon.tscn" },
	"squirtle": { "name": "Squirtle", "cost": 75, "scene": "res://scenes/towers/generic_pokemon.tscn" },
	"charmander": { "name": "Charmander", "cost": 125, "scene": "res://scenes/towers/generic_pokemon.tscn" },
	"bulbasaur": { "name": "Bulbasaur", "cost": 80, "scene": "res://scenes/towers/generic_pokemon.tscn" },
}

func _ready() -> void:
	GameManager.zenny_changed.connect(_on_currency_changed)
	GameManager.lives_changed.connect(_on_lives_changed)
	GameManager.wave_changed.connect(_on_wave_changed)
	GameManager.game_over.connect(_on_game_over)

	_on_currency_changed(GameManager.zenny)
	_on_lives_changed(GameManager.lives)
	update_wave_label()
	game_over_panel.visible = false
	setup_tower_buttons()

func setup_tower_buttons() -> void:
	for key in tower_data:
		var data = tower_data[key]
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(85, 60)
		btn.text = "%s\n$%d" % [data.name, data.cost]
		btn.pressed.connect(_on_tower_button_pressed.bind(key))
		tower_grid.add_child(btn)

func _on_currency_changed(amount: int) -> void:
	currency_label.text = "$ %d" % amount
	update_tower_buttons()

func _on_lives_changed(amount: int) -> void:
	lives_label.text = "♥ %d" % amount

func _on_wave_changed(wave: int) -> void:
	update_wave_label()

func update_wave_label() -> void:
	wave_label.text = "Wave %d/%d" % [GameManager.current_wave, GameManager.waves_total]

func update_tower_buttons() -> void:
	for i in tower_grid.get_child_count():
		var btn = tower_grid.get_child(i) as Button
		var key = tower_data.keys()[i]
		btn.disabled = GameManager.currency < tower_data[key].cost

func _on_tower_button_pressed(tower_key: String) -> void:
	var data = tower_data[tower_key]
	if GameManager.currency >= data.cost:
		GameManager.select_tower(tower_key)

func _on_start_wave_button_pressed() -> void:
	if not GameManager.is_wave_active:
		GameManager.start_wave()
		start_wave_btn.disabled = true

func _on_game_over(won: bool) -> void:
	game_over_panel.visible = true
	game_over_label.text = "YOU WIN!" if won else "GAME OVER"
	start_wave_btn.disabled = true

func enable_start_button() -> void:
	if GameManager.current_wave < GameManager.waves_total:
		start_wave_btn.disabled = false
