extends Control

# Map data: name -> background path
var maps: Dictionary = {
	"Viridian Forest": "res://assets/sprites/Verdian Forest Background.jpg",
}

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")

func _on_map_selected(map_name: String) -> void:
	var bg_path = maps[map_name]
	# Store selected map in autoload for path editor to use
	GameManager.selected_map_name = map_name
	GameManager.selected_map_bg = bg_path
	get_tree().change_scene_to_file("res://scenes/tools/path_editor.tscn")
