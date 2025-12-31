extends Control

const TowerCardScene = preload("res://scenes/ui/tower_card.tscn")

@onready var left_panel: PanelContainer = $MainLayout/LeftPanel
@onready var game_viewport: SubViewportContainer = $MainLayout/GameViewport
@onready var right_panel: PanelContainer = $MainLayout/RightPanel
@onready var sub_viewport: SubViewport = $MainLayout/GameViewport/SubViewport

# Left panel refs
@onready var currency_label: Label = $MainLayout/LeftPanel/VBox/StatsPanel/Stats/CurrencyLabel
@onready var lives_label: Label = $MainLayout/LeftPanel/VBox/StatsPanel/Stats/LivesLabel
@onready var party_grid: GridContainer = $MainLayout/LeftPanel/VBox/TowerSection/PartyPanel/PartyScroll/PartyGrid
@onready var empty_label: Label = $MainLayout/LeftPanel/VBox/TowerSection/PartyPanel/EmptyLabel

# Right panel refs
@onready var wave_label: Label = $MainLayout/RightPanel/VBox/WavePanel/WaveLabel
@onready var start_wave_btn: Button = $MainLayout/RightPanel/VBox/StartWaveBtn
@onready var enemy_info_panel: PanelContainer = $MainLayout/RightPanel/VBox/EnemyInfoPanel
@onready var enemy_name_label: Label = $MainLayout/RightPanel/VBox/EnemyInfoPanel/VBox/EnemyName
@onready var enemy_health_label: Label = $MainLayout/RightPanel/VBox/EnemyInfoPanel/VBox/EnemyHealth

func _ready() -> void:
	GameManager.currency_changed.connect(_on_currency_changed)
	GameManager.lives_changed.connect(_on_lives_changed)
	GameManager.wave_changed.connect(_on_wave_changed)
	GameManager.wave_completed.connect(_on_wave_completed)
	GameManager.game_over.connect(_on_game_over)
	GameManager.enemy_selected.connect(_on_enemy_selected)

	_on_currency_changed(GameManager.currency)
	_on_lives_changed(GameManager.lives)
	update_wave_label()
	populate_party_towers()
	enemy_info_panel.visible = false

func _on_wave_completed() -> void:
	enable_start_button()

func populate_party_towers() -> void:
	# Clear existing
	for child in party_grid.get_children():
		child.queue_free()

	# Only party pokemon are available as towers
	var has_party = GameManager.party.size() > 0
	empty_label.visible = not has_party

	for species_id in GameManager.party:
		var caught = GameManager.pokedex.get(species_id) as CaughtPokemon
		if not caught:
			continue
		var species = GameManager.get_species(species_id)
		if not species:
			continue

		var card = TowerCardScene.instantiate() as TowerCard
		var tower_data = TowerData.new()
		tower_data.tower_id = species_id
		tower_data.display_name = species.display_name + " Lv." + str(caught.level)
		tower_data.cost = species.deploy_cost
		tower_data.pokemon_type = species.pokemon_type
		tower_data.damage = species.base_damage * caught.get_stat_multiplier()
		tower_data.attack_range = species.base_range * caught.get_stat_multiplier()
		tower_data.attack_speed = species.base_attack_speed * caught.get_stat_multiplier()
		if species.tower_scene:
			tower_data.scene = species.tower_scene
		tower_data.icon = species.icon
		card.set_tower_data(tower_data)
		card.caught_pokemon = caught
		party_grid.add_child(card)

func _on_currency_changed(amount: int) -> void:
	currency_label.text = "$ %d" % amount

func _on_lives_changed(amount: int) -> void:
	lives_label.text = "♥ %d" % amount

func _on_wave_changed(_wave: int) -> void:
	update_wave_label()

func update_wave_label() -> void:
	wave_label.text = "Wave %d / %d" % [GameManager.current_wave, GameManager.waves_total]

func _on_start_wave_pressed() -> void:
	if not GameManager.is_wave_active:
		GameManager.start_wave()
		start_wave_btn.disabled = true

func _on_game_over(won: bool) -> void:
	start_wave_btn.disabled = true

func _on_enemy_selected(enemy: Node) -> void:
	enemy_info_panel.visible = true
	enemy_name_label.text = enemy.enemy_name if "enemy_name" in enemy else "Enemy"
	enemy_health_label.text = "HP: %d / %d" % [enemy.hp, enemy.max_hp] if "hp" in enemy else "HP: ?"

func enable_start_button() -> void:
	if GameManager.current_wave < GameManager.waves_total:
		start_wave_btn.disabled = false

func _on_back_pressed() -> void:
	GameManager.reset_game()
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")

func _on_ball_selected(ball_id: String) -> void:
	GameManager.selected_ball = ball_id
