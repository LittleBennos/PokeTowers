extends Control

@onready var regions_list: VBoxContainer = $MainLayout/LeftPanel/VBox/RegionsScroll/RegionsList
@onready var regions_header: Label = $MainLayout/LeftPanel/VBox/RegionsHeader
@onready var maps_grid: GridContainer = $MainLayout/RightPanel/VBox/MapsScroll/MapsGrid
@onready var region_title: Label = $MainLayout/RightPanel/VBox/RegionTitle
@onready var start_btn: Button = $MainLayout/RightPanel/VBox/ButtonsHBox/StartBtn
@onready var back_btn: Button = $MainLayout/RightPanel/VBox/ButtonsHBox/BackBtn
@onready var left_panel: PanelContainer = $MainLayout/LeftPanel
@onready var right_panel: PanelContainer = $MainLayout/RightPanel

var campaigns: Array[CampaignData] = []
var selected_campaign: CampaignData = null
var selected_map: MapData = null
var selected_map_card: PanelContainer = null
var region_buttons: Array[Button] = []
var pulse_tween: Tween

func _ready() -> void:
	style_ui()
	load_campaigns()
	populate_regions()
	start_btn.disabled = true

func style_ui() -> void:
	# Left panel - dark semi-transparent
	var left_style = StyleBoxFlat.new()
	left_style.bg_color = Color(0.1, 0.12, 0.18, 0.95)
	left_style.set_corner_radius_all(10)
	left_style.set_content_margin_all(10)
	left_panel.add_theme_stylebox_override("panel", left_style)

	# Right panel - slightly lighter
	var right_style = StyleBoxFlat.new()
	right_style.bg_color = Color(0.15, 0.18, 0.25, 0.95)
	right_style.set_corner_radius_all(10)
	right_style.set_content_margin_all(15)
	right_panel.add_theme_stylebox_override("panel", right_style)

	# Header styling
	regions_header.add_theme_color_override("font_color", Color(0.6, 0.65, 0.75))

	# Back button - neutral
	style_button_neutral(back_btn)

	# Start button - green (will be styled more when enabled)
	style_button_start_disabled()

func style_button_neutral(btn: Button) -> void:
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.3, 0.32, 0.38)
	style.set_corner_radius_all(8)
	style.set_border_width_all(2)
	style.border_color = Color(0.4, 0.42, 0.5)
	btn.add_theme_stylebox_override("normal", style)

	var hover = style.duplicate()
	hover.bg_color = Color(0.38, 0.4, 0.48)
	btn.add_theme_stylebox_override("hover", hover)

	btn.add_theme_color_override("font_color", Color.WHITE)

func style_button_start_disabled() -> void:
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.25, 0.35, 0.28)
	style.set_corner_radius_all(10)
	style.set_border_width_all(3)
	style.border_color = Color(0.2, 0.3, 0.22)
	start_btn.add_theme_stylebox_override("normal", style)
	start_btn.add_theme_stylebox_override("disabled", style)
	start_btn.add_theme_color_override("font_color", Color(0.5, 0.6, 0.5))
	start_btn.add_theme_color_override("font_disabled_color", Color(0.4, 0.5, 0.4))

func style_button_start_enabled() -> void:
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.2, 0.65, 0.3)
	style.set_corner_radius_all(10)
	style.set_border_width_all(3)
	style.border_color = Color(0.15, 0.5, 0.2)
	start_btn.add_theme_stylebox_override("normal", style)

	var hover = style.duplicate()
	hover.bg_color = Color(0.25, 0.75, 0.35)
	start_btn.add_theme_stylebox_override("hover", hover)

	var pressed = style.duplicate()
	pressed.bg_color = Color(0.15, 0.55, 0.25)
	start_btn.add_theme_stylebox_override("pressed", pressed)

	start_btn.add_theme_color_override("font_color", Color.WHITE)
	start_btn.add_theme_color_override("font_hover_color", Color.WHITE)

	# Start pulsing animation
	if pulse_tween:
		pulse_tween.kill()
	pulse_tween = create_tween().set_loops()
	pulse_tween.tween_property(start_btn, "scale", Vector2(1.05, 1.05), 0.5).set_ease(Tween.EASE_IN_OUT)
	pulse_tween.tween_property(start_btn, "scale", Vector2(1.0, 1.0), 0.5).set_ease(Tween.EASE_IN_OUT)

func load_campaigns() -> void:
	var dir = DirAccess.open("res://resources/campaigns")
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".tres"):
				var campaign = load("res://resources/campaigns/" + file_name) as CampaignData
				if campaign:
					campaigns.append(campaign)
			file_name = dir.get_next()
	campaigns.sort_custom(func(a, b): return a.generation < b.generation)

func populate_regions() -> void:
	for child in regions_list.get_children():
		child.queue_free()
	region_buttons.clear()

	for campaign in campaigns:
		var btn = Button.new()
		btn.text = "Gen %d: %s" % [campaign.generation, campaign.region_name]
		btn.custom_minimum_size = Vector2(160, 40)
		btn.pressed.connect(_on_region_selected.bind(campaign, btn))
		style_region_button(btn, false)
		regions_list.add_child(btn)
		region_buttons.append(btn)

	if campaigns.size() > 0:
		_on_region_selected(campaigns[0], region_buttons[0])

func style_region_button(btn: Button, selected: bool) -> void:
	var style = StyleBoxFlat.new()
	if selected:
		style.bg_color = Color(0.3, 0.5, 0.7)
		style.border_color = Color(0.4, 0.6, 0.85)
	else:
		style.bg_color = Color(0.2, 0.22, 0.28)
		style.border_color = Color(0.3, 0.32, 0.4)
	style.set_corner_radius_all(6)
	style.set_border_width_all(2)
	btn.add_theme_stylebox_override("normal", style)

	var hover = style.duplicate()
	hover.bg_color = style.bg_color.lightened(0.15)
	btn.add_theme_stylebox_override("hover", hover)

	btn.add_theme_color_override("font_color", Color.WHITE if selected else Color(0.8, 0.82, 0.88))

func _on_region_selected(campaign: CampaignData, btn: Button) -> void:
	selected_campaign = campaign
	selected_map = null
	selected_map_card = null
	start_btn.disabled = true
	start_btn.text = "SELECT A MAP"
	style_button_start_disabled()
	if pulse_tween:
		pulse_tween.kill()
	start_btn.scale = Vector2.ONE

	# Update region button highlights
	for region_btn in region_buttons:
		style_region_button(region_btn, region_btn == btn)

	region_title.text = "%s Region" % campaign.region_name
	populate_maps(campaign)

func populate_maps(campaign: CampaignData) -> void:
	for child in maps_grid.get_children():
		child.queue_free()

	for i in range(campaign.maps.size()):
		var map_data = campaign.maps[i]
		var card = create_map_card(map_data, i + 1)
		maps_grid.add_child(card)

func create_map_card(map_data: MapData, order: int) -> PanelContainer:
	var panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(180, 140)
	style_map_card(panel, false)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	panel.add_child(vbox)

	# Map thumbnail placeholder (colored box based on difficulty)
	var thumb = ColorRect.new()
	thumb.custom_minimum_size = Vector2(160, 60)
	thumb.color = get_difficulty_color(map_data.difficulty)
	thumb.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	vbox.add_child(thumb)

	# Map number + name
	var name_label = Label.new()
	name_label.text = "%d. %s" % [order, map_data.map_name]
	name_label.add_theme_font_size_override("font_size", 13)
	name_label.add_theme_color_override("font_color", Color.WHITE)
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(name_label)

	# Stars + waves
	var info_hbox = HBoxContainer.new()
	info_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_child(info_hbox)

	var stars_label = Label.new()
	var stars = "★".repeat(map_data.difficulty) + "☆".repeat(5 - map_data.difficulty)
	stars_label.text = stars
	stars_label.add_theme_font_size_override("font_size", 12)
	stars_label.add_theme_color_override("font_color", Color(1, 0.85, 0.2))
	info_hbox.add_child(stars_label)

	var waves_label = Label.new()
	waves_label.text = "  %d waves" % map_data.waves_count
	waves_label.add_theme_font_size_override("font_size", 11)
	waves_label.add_theme_color_override("font_color", Color(0.7, 0.72, 0.8))
	info_hbox.add_child(waves_label)

	# Make entire card clickable
	panel.gui_input.connect(_on_card_input.bind(map_data, panel))
	panel.mouse_entered.connect(_on_card_hover.bind(panel, true))
	panel.mouse_exited.connect(_on_card_hover.bind(panel, false))

	panel.set_meta("map_data", map_data)
	return panel

func get_difficulty_color(difficulty: int) -> Color:
	match difficulty:
		1: return Color(0.3, 0.6, 0.35)  # Easy - green
		2: return Color(0.4, 0.55, 0.3)  # Normal - yellow-green
		3: return Color(0.6, 0.5, 0.25)  # Medium - orange
		4: return Color(0.65, 0.35, 0.25)  # Hard - red-orange
		5: return Color(0.6, 0.25, 0.3)  # Very Hard - red
		_: return Color(0.4, 0.42, 0.48)

func style_map_card(panel: PanelContainer, selected: bool) -> void:
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.18, 0.2, 0.28)
	style.set_corner_radius_all(10)
	style.set_content_margin_all(10)
	style.set_border_width_all(3)

	if selected:
		style.border_color = Color(1, 0.85, 0.2)  # Yellow highlight
	else:
		style.border_color = Color(0.3, 0.32, 0.4)

	panel.add_theme_stylebox_override("panel", style)

func _on_card_input(event: InputEvent, map_data: MapData, panel: PanelContainer) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		select_map(map_data, panel)
		# Double click to start
		if event.double_click and selected_map:
			_on_start_pressed()

func _on_card_hover(panel: PanelContainer, hovering: bool) -> void:
	if panel != selected_map_card:
		var style = panel.get_theme_stylebox("panel").duplicate() as StyleBoxFlat
		if hovering:
			style.border_color = Color(0.5, 0.55, 0.65)
		else:
			style.border_color = Color(0.3, 0.32, 0.4)
		panel.add_theme_stylebox_override("panel", style)

func select_map(map_data: MapData, panel: PanelContainer) -> void:
	# Deselect previous
	if selected_map_card:
		style_map_card(selected_map_card, false)

	selected_map = map_data
	selected_map_card = panel
	style_map_card(panel, true)

	start_btn.disabled = false
	start_btn.text = "START: %s" % map_data.map_name
	style_button_start_enabled()

func _on_start_pressed() -> void:
	if selected_map:
		GameManager.selected_map = selected_map
		GameManager.waves_total = selected_map.waves_count
		get_tree().change_scene_to_file("res://scenes/ui/party_select.tscn")

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
