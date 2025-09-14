extends CanvasLayer


func _ready() -> void:
	%QuitButton.visible = not OS.has_feature("web")
	%ContinueGameButton.disabled = Global.level_index <= 0
	Global.play_menu_music()


func _on_continue_game_button_pressed() -> void:
	var next_level_file: String = Global.levels[Global.level_index]
	get_tree().change_scene_to_file(next_level_file)


func _on_new_game_button_pressed() -> void:
	Global.level_index = 0
	var next_level_file: String = Global.levels[Global.level_index]
	get_tree().change_scene_to_file(next_level_file)


func _on_options_button_pressed() -> void:
	get_tree().change_scene_to_file("res://ui/settings_ui/settings_ui.tscn")


func _on_quit_button_pressed() -> void:
	get_tree().quit()
