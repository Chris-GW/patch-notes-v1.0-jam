extends Node2D


func _ready() -> void:
	for child in get_children():
		if child is BaseEnemy:
			child.navigation_agent.set_process_mode(Node.PROCESS_MODE_DISABLED)
			child.collision_shape.set_disabled.call_deferred(true)
