extends Control

@onready var slots_container: VBoxContainer = $CenterContainer/VBox/SlotsContainer
@onready var export_btn: Button = $CenterContainer/VBox/ButtonsHBox/ExportBtn
@onready var import_btn: Button = $CenterContainer/VBox/ButtonsHBox/ImportBtn
@onready var back_btn: Button = $CenterContainer/VBox/BackBtn
@onready var confirm_dialog: ConfirmationDialog = $ConfirmDialog
@onready var background: TextureRect = $Background

var pending_delete_slot: int = -1
var pending_import: bool = false

func _ready() -> void:
	load_background()
	style_ui()
	refresh_slots()

func load_background() -> void:
	if ResourceLoader.exists("res://assets/sprites/menu_bg.png"):
		background.texture = load("res://assets/sprites/menu_bg.png")

func style_ui() -> void:
	# Style slot panels
	for i in range(slots_container.get_child_count()):
		var panel = slots_container.get_child(i) as PanelContainer
		var panel_style = StyleBoxFlat.new()
		panel_style.bg_color = Color(1, 1, 1, 0.95)
		panel_style.set_corner_radius_all(8)
		panel_style.set_border_width_all(2)
		panel_style.border_color = Color(0.3, 0.3, 0.4)
		panel.add_theme_stylebox_override("panel", panel_style)

		# Style play button - green
		var play_btn = panel.get_node("HBox/PlayBtn")
		style_button_green(play_btn)

		# Style delete button - red
		var delete_btn = panel.get_node("HBox/DeleteBtn")
		style_button_red(delete_btn)

	# Style export/import buttons - neutral
	style_button_neutral(export_btn)
	style_button_neutral(import_btn)

	# Style back button
	style_button_neutral(back_btn)

func style_button_green(btn: Button) -> void:
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.3, 0.69, 0.31)
	style.set_corner_radius_all(6)
	style.set_border_width_all(2)
	style.border_color = Color(0.2, 0.5, 0.2)
	btn.add_theme_stylebox_override("normal", style)

	var hover = style.duplicate()
	hover.bg_color = Color(0.4, 0.8, 0.4)
	btn.add_theme_stylebox_override("hover", hover)

	var pressed = style.duplicate()
	pressed.bg_color = Color(0.25, 0.55, 0.25)
	btn.add_theme_stylebox_override("pressed", pressed)

	btn.add_theme_color_override("font_color", Color.WHITE)
	btn.add_theme_color_override("font_hover_color", Color.WHITE)

func style_button_red(btn: Button) -> void:
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.75, 0.25, 0.25)
	style.set_corner_radius_all(6)
	style.set_border_width_all(2)
	style.border_color = Color(0.5, 0.15, 0.15)
	btn.add_theme_stylebox_override("normal", style)

	var hover = style.duplicate()
	hover.bg_color = Color(0.85, 0.35, 0.35)
	btn.add_theme_stylebox_override("hover", hover)

	var pressed = style.duplicate()
	pressed.bg_color = Color(0.6, 0.2, 0.2)
	btn.add_theme_stylebox_override("pressed", pressed)

	btn.add_theme_color_override("font_color", Color.WHITE)
	btn.add_theme_color_override("font_hover_color", Color.WHITE)

func style_button_neutral(btn: Button) -> void:
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.95, 0.95, 0.98)
	style.set_corner_radius_all(6)
	style.set_border_width_all(2)
	style.border_color = Color(0.3, 0.3, 0.4)
	btn.add_theme_stylebox_override("normal", style)

	var hover = style.duplicate()
	hover.bg_color = Color(0.85, 0.85, 0.92)
	btn.add_theme_stylebox_override("hover", hover)

	var pressed = style.duplicate()
	pressed.bg_color = Color(0.75, 0.75, 0.82)
	btn.add_theme_stylebox_override("pressed", pressed)

	btn.add_theme_color_override("font_color", Color(0.2, 0.2, 0.25))
	btn.add_theme_color_override("font_hover_color", Color(0.1, 0.1, 0.15))

func refresh_slots() -> void:
	for i in range(SaveManager.NUM_SLOTS):
		var slot_panel = slots_container.get_child(i)
		var info = SaveManager.get_slot_info(i)
		update_slot_panel(slot_panel, i, info)

func update_slot_panel(panel: PanelContainer, slot: int, info: Dictionary) -> void:
	var name_label = panel.get_node("HBox/Info/NameLabel")
	var details_label = panel.get_node("HBox/Info/DetailsLabel")
	var play_btn = panel.get_node("HBox/PlayBtn")
	var delete_btn = panel.get_node("HBox/DeleteBtn")

	# Dark text for white card background
	name_label.add_theme_color_override("font_color", Color(0.15, 0.15, 0.2))
	details_label.add_theme_color_override("font_color", Color(0.4, 0.4, 0.5))

	if info.get("empty", true):
		name_label.text = "Slot %d - Empty" % (slot + 1)
		details_label.text = "New Game"
		delete_btn.visible = false
	else:
		var starter = info.get("starter", "???")
		var count = info.get("pokemon_count", 0)
		name_label.text = "Slot %d - %s" % [slot + 1, starter.capitalize()]
		details_label.text = "%d Pokemon caught" % count
		delete_btn.visible = true

	# Connect buttons if not already
	if not play_btn.pressed.is_connected(_on_slot_pressed):
		play_btn.pressed.connect(_on_slot_pressed.bind(slot))
	if not delete_btn.pressed.is_connected(_on_delete_pressed):
		delete_btn.pressed.connect(_on_delete_pressed.bind(slot))

func _on_slot_pressed(slot: int) -> void:
	SaveManager.load_slot(slot)
	if GameManager.starter_pokemon == "":
		get_tree().change_scene_to_file("res://scenes/ui/starter_select.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/ui/campaign_select.tscn")

func _on_delete_pressed(slot: int) -> void:
	pending_delete_slot = slot
	pending_import = false
	confirm_dialog.dialog_text = "Delete Slot %d? This cannot be undone." % (slot + 1)
	confirm_dialog.popup_centered()

func _on_confirm_dialog_confirmed() -> void:
	if pending_import:
		if SaveManager.import_from_file():
			refresh_slots()
	elif pending_delete_slot >= 0:
		SaveManager.delete_slot(pending_delete_slot)
		pending_delete_slot = -1
		refresh_slots()

func _on_export_pressed() -> void:
	if SaveManager.current_slot < 0:
		for i in range(SaveManager.NUM_SLOTS):
			if SaveManager.slot_exists(i):
				SaveManager.current_slot = i
				break

	if SaveManager.export_to_file():
		confirm_dialog.dialog_text = "Exported to:\n%s" % SaveManager.get_export_path()
		confirm_dialog.get_ok_button().text = "OK"
		confirm_dialog.popup_centered()

func _on_import_pressed() -> void:
	if not FileAccess.file_exists(SaveManager.get_export_path()):
		confirm_dialog.dialog_text = "No import file found at:\n%s" % SaveManager.get_export_path()
		confirm_dialog.popup_centered()
		return

	var target_slot = 0
	for i in range(SaveManager.NUM_SLOTS):
		if not SaveManager.slot_exists(i):
			target_slot = i
			break

	SaveManager.current_slot = target_slot
	pending_import = true
	pending_delete_slot = -1
	confirm_dialog.dialog_text = "Import save to Slot %d?" % (target_slot + 1)
	confirm_dialog.popup_centered()

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
