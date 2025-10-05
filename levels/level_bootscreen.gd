extends Node2D

@export_dir var save_dir: String

@onready var camera_2d: Camera2D = %Camera2D
@onready var sub_viewport: SubViewport = $SubViewportContainer/SubViewport


func _ready() -> void:
	%MenuPanelContainer.visible = false
	%RunGameButton.visible = false
	await get_tree().process_frame
	for node in get_tree().get_nodes_in_group("reparent_subviewport"):
		node.reparent.call_deferred(sub_viewport)
	await get_tree().process_frame
	take_screen_shots.call_deferred()


func take_screen_shots() -> void:
	for screenshot_rect in get_tree().get_nodes_in_group("screenshot_rect"):
		await take_screen_shot(screenshot_rect)
	get_tree().quit()


func take_screen_shot(reference_rect: ReferenceRect) -> void:
	sub_viewport.size = reference_rect.size
	camera_2d.position = reference_rect.position
	get_tree().call_group("screenshot_rect", "set_visible", false)
	reference_rect.visible = true
	for child in reference_rect.get_children():
		child.call("set_visible", true)
	await get_tree().process_frame
	
	var img_name := reference_rect.name
	var img: Image = sub_viewport.get_texture().get_image()
	# Save screenshot as PNG
	var path := save_dir + "/%s.png" % img_name
	var err := img.save_png(path)
	if err == OK:
		print("Screenshot saved to: %s" % path)
	else:
		push_error("Failed to save screenshot: %s" % path)
