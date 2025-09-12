extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%QuitButton.visible = not OS.has_feature("web")


func _on_new_game_button_pressed() -> void:
	get_tree().change_scene_to_file("res://main.tscn")


func _on_options_button_pressed() -> void:
	pass # Replace with function body.


func _on_credits_button_pressed() -> void:
	pass # Replace with function body.


func _on_quit_button_pressed() -> void:
	get_tree().quit()
