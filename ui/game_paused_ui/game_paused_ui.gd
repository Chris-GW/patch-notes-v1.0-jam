class_name GamePausedUI
extends CanvasLayer


func _ready():
	%QuitButton.visible = not OS.has_feature("web")


func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		visible = not visible
		get_tree().paused = visible


func _on_continue_button_pressed():
	visible = false
	get_tree().paused = false


func _on_restart_mission_button_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_abort_mission_button_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://ui/main_menu.tscn")


func _on_settings_button_pressed():
	# TODO _on_settings_button_pressed
	get_tree().paused = false
	pass


func _on_quit_button_pressed():
	get_tree().quit()
