extends Control

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_map_editor_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/map_select.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()
