extends CanvasLayer

@onready var output_device_option_button = %OutputDeviceOptionButton


func _ready():
	_setup_output_device_options()


func _setup_output_device_options():
	output_device_option_button.clear()
	var device_list = AudioServer.get_output_device_list()
	for device in device_list:
		output_device_option_button.add_item(device)
	output_device_option_button.select(0)


func _on_output_device_option_button_item_selected(index):
	var device = output_device_option_button.get_item_text(index)
	AudioServer.output_device = device


func _on_window_mode_option_button_item_selected(index):
	match index:
		0: # Full-Screen
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
		1: # Window Mode
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
		2: # Borderless Window
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
		3: # Borderless Full-Screen
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)


func _on_scale_mode_option_button_item_selected(index):
	match index:
		0: # Pixel-Perfect
			get_window().content_scale_stretch = Window.CONTENT_SCALE_STRETCH_INTEGER
		1: # Fit Window
			get_window().content_scale_stretch = Window.CONTENT_SCALE_STRETCH_FRACTIONAL


func _on_v_sync_mode_option_button_item_selected(index):
	match index:
		0: # enabled
			DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
		1: # disabled
			DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
		2: # adaptive
			DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ADAPTIVE)
		3: # mailbox
			DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_MAILBOX)


func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://ui/main_menu.tscn")
