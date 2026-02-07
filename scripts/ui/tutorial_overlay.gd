extends CanvasLayer
class_name TutorialOverlay
## In-game tutorial that walks new players through core mechanics.
## Add as child of GameRoot; call start_tutorial() to begin.

signal tutorial_finished

enum Step {
	WELCOME,
	SELECT_POKEMON,
	PLACE_TOWER,
	ENEMIES_INCOMING,
	TYPE_EFFECTIVENESS,
	CATCH_EM,
	READY,
}

const STEP_DATA: Array[Dictionary] = [
	{
		"title": "Welcome to PokéTowers!",
		"body": "Defend the path by placing your Pokémon as towers.\nThey'll attack wild Pokémon that try to get through!",
		"highlight": "",
		"auto_advance": false,
	},
	{
		"title": "Select a Pokémon",
		"body": "Click \"Deploy\" on one of your party Pokémon in the left panel to select it for placement.",
		"highlight": "party_panel",
		"auto_advance": false,  # waits for signal
	},
	{
		"title": "Place Your Tower",
		"body": "Now click on a green placement zone to put your Pokémon on the field!",
		"highlight": "placement_zones",
		"auto_advance": false,  # waits for signal
	},
	{
		"title": "Enemies Incoming!",
		"body": "Press START WAVE to send the first wave of wild Pokémon down the path.\nDon't let them reach the end or you'll lose lives!",
		"highlight": "start_wave",
		"auto_advance": false,  # waits for wave start
	},
	{
		"title": "Type Effectiveness!",
		"body": "Just like the games — Fire beats Grass, Water beats Fire, and so on.\nSuper-effective hits deal double damage! Plan your team wisely.",
		"highlight": "",
		"auto_advance": false,
	},
	{
		"title": "Catch 'em!",
		"body": "When a wild Pokémon's HP drops below 25%, a catch attempt triggers automatically.\nChoose better Poké Balls for higher catch rates!",
		"highlight": "ball_settings",
		"auto_advance": false,
	},
	{
		"title": "You're Ready!",
		"body": "That's everything you need to know. Good luck, Trainer!\n\nTip: You can upgrade your party size and unlock new regions as you progress.",
		"highlight": "",
		"auto_advance": false,
	},
]

var current_step: int = -1
var is_active: bool = false

# UI nodes (built in code)
var dim_overlay: ColorRect
var popup_panel: PanelContainer
var title_label: Label
var body_label: Label
var next_btn: Button
var skip_btn: Button
var step_label: Label
var highlight_rect: ColorRect  # pulsing border around highlighted area

# Reference to GameRoot (set by caller)
var game_root: Control = null

func _ready() -> void:
	layer = 100
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_ui()
	visible = false

func _build_ui() -> void:
	# Full-screen dim
	dim_overlay = ColorRect.new()
	dim_overlay.color = Color(0, 0, 0, 0.45)
	dim_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim_overlay.mouse_filter = Control.MOUSE_FILTER_STOP  # block clicks behind
	add_child(dim_overlay)

	# Center popup
	var center = CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(center)

	popup_panel = PanelContainer.new()
	popup_panel.custom_minimum_size = Vector2(480, 0)
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.08, 0.14, 0.97)
	style.set_border_width_all(3)
	style.border_color = Color(1, 0.85, 0.2)
	style.set_corner_radius_all(14)
	style.set_content_margin_all(28)
	popup_panel.add_theme_stylebox_override("panel", style)
	center.add_child(popup_panel)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 14)
	popup_panel.add_child(vbox)

	# Step counter
	step_label = Label.new()
	step_label.add_theme_font_size_override("font_size", 11)
	step_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.6))
	step_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(step_label)

	# Title
	title_label = Label.new()
	title_label.add_theme_font_size_override("font_size", 24)
	title_label.add_theme_color_override("font_color", Color(1, 0.85, 0.2))
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title_label)

	# Body
	body_label = Label.new()
	body_label.add_theme_font_size_override("font_size", 15)
	body_label.add_theme_color_override("font_color", Color(0.85, 0.85, 0.9))
	body_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(body_label)

	# Buttons row
	var hbox = HBoxContainer.new()
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.add_theme_constant_override("separation", 16)
	vbox.add_child(hbox)

	skip_btn = Button.new()
	skip_btn.text = "Skip Tutorial"
	skip_btn.custom_minimum_size = Vector2(130, 38)
	skip_btn.pressed.connect(_on_skip_pressed)
	hbox.add_child(skip_btn)

	next_btn = Button.new()
	next_btn.text = "Next →"
	next_btn.custom_minimum_size = Vector2(130, 38)
	next_btn.pressed.connect(_on_next_pressed)
	hbox.add_child(next_btn)

	# Highlight rectangle (drawn on dim_overlay layer)
	highlight_rect = ColorRect.new()
	highlight_rect.color = Color(1, 0.85, 0.2, 0.15)
	highlight_rect.visible = false
	highlight_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(highlight_rect)

func start_tutorial() -> void:
	if is_active:
		return
	is_active = true
	visible = true
	current_step = -1
	_connect_game_signals()
	advance_step()

func advance_step() -> void:
	current_step += 1
	if current_step >= STEP_DATA.size():
		_finish()
		return
	_show_step(current_step)

func _show_step(idx: int) -> void:
	var data = STEP_DATA[idx]
	title_label.text = data.title
	body_label.text = data.body
	step_label.text = "Step %d / %d" % [idx + 1, STEP_DATA.size()]

	# Next button label
	if idx == STEP_DATA.size() - 1:
		next_btn.text = "Let's Go!"
	elif _step_waits_for_action(idx):
		next_btn.text = "Got it!"
	else:
		next_btn.text = "Next →"

	_update_highlight(data.highlight)

func _step_waits_for_action(idx: int) -> bool:
	# Steps 1-3 wait for player action after dismissing the popup
	return idx in [Step.SELECT_POKEMON, Step.PLACE_TOWER, Step.ENEMIES_INCOMING]

func _update_highlight(target: String) -> void:
	highlight_rect.visible = false
	if target == "" or not game_root:
		return

	var node: Control = null
	match target:
		"party_panel":
			node = game_root.get_node_or_null("MainLayout/LeftPanel/VBox/TowerSection")
		"placement_zones":
			# Can't highlight 2D zones from UI layer, skip
			pass
		"start_wave":
			node = game_root.get_node_or_null("MainLayout/RightPanel/VBox/StartWaveBtn")
		"ball_settings":
			node = game_root.get_node_or_null("MainLayout/RightPanel/VBox/BallSettingsPanel")

	if node:
		var rect = node.get_global_rect()
		highlight_rect.position = rect.position - Vector2(4, 4)
		highlight_rect.size = rect.size + Vector2(8, 8)
		highlight_rect.visible = true

func _on_next_pressed() -> void:
	var idx = current_step
	if _step_waits_for_action(idx):
		# Hide popup but stay active; wait for the action signal
		_hide_popup()
		return

	advance_step()

func _on_skip_pressed() -> void:
	_finish()

func _hide_popup() -> void:
	popup_panel.visible = false
	dim_overlay.color = Color(0, 0, 0, 0.0)  # remove dim so player can interact
	highlight_rect.visible = false

func _show_popup() -> void:
	popup_panel.visible = true
	dim_overlay.color = Color(0, 0, 0, 0.45)

func _finish() -> void:
	is_active = false
	visible = false
	_disconnect_game_signals()
	_save_tutorial_complete()
	tutorial_finished.emit()

func _save_tutorial_complete() -> void:
	# Persist flag via SaveManager
	# We store in the save file by adding a field. For demo mode (no slot),
	# we use a standalone file.
	var path = "user://tutorial_complete.flag"
	var f = FileAccess.open(path, FileAccess.WRITE)
	if f:
		f.store_string("1")

static func is_tutorial_complete() -> bool:
	return FileAccess.file_exists("user://tutorial_complete.flag")

# ── Signal connections to detect player actions ──

func _connect_game_signals() -> void:
	if not GameManager.pokemon_placed_signal.is_connected(_on_pokemon_placed):
		GameManager.pokemon_placed_signal.connect(_on_pokemon_placed)
	if not GameManager.wave_changed.is_connected(_on_wave_started):
		GameManager.wave_changed.connect(_on_wave_started)
	# We listen for tower selection as proxy for "select a pokemon"
	# The tower card emits via GameManager.select_tower → is_placing_tower
	set_process(true)

func _disconnect_game_signals() -> void:
	if GameManager.pokemon_placed_signal.is_connected(_on_pokemon_placed):
		GameManager.pokemon_placed_signal.disconnect(_on_pokemon_placed)
	if GameManager.wave_changed.is_connected(_on_wave_started):
		GameManager.wave_changed.disconnect(_on_wave_started)

var _was_placing: bool = false

func _process(_delta: float) -> void:
	if not is_active:
		return

	# Detect when player selects a pokemon (enters placing mode)
	if current_step == Step.SELECT_POKEMON and not popup_panel.visible:
		if GameManager.is_placing_tower and not _was_placing:
			# Player selected a pokemon, advance
			_show_popup()
			advance_step()
		_was_placing = GameManager.is_placing_tower

func _on_pokemon_placed(_uuid: String) -> void:
	if not is_active:
		return
	if current_step == Step.PLACE_TOWER and not popup_panel.visible:
		_show_popup()
		advance_step()

func _on_wave_started(_wave: int) -> void:
	if not is_active:
		return
	if current_step == Step.ENEMIES_INCOMING and not popup_panel.visible:
		_show_popup()
		advance_step()
