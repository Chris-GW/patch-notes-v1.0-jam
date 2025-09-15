extends BaseEnemy

@export var marker_a: Marker2D
@export var marker_b: Marker2D
@export var gate: Gate


func _ready() -> void:
	marker_a.reparent.call_deferred(get_parent())
	marker_b.reparent.call_deferred(get_parent())
	target = marker_b
	navigation_agent.debug_enabled = true
	super._ready()
	self.died.connect(_on_died)


func _physics_process(delta: float) -> void:
	if navigation_agent.is_navigation_finished() or not is_instance_valid(target):
		if target == marker_a:
			target = marker_b
			navigation_agent.target_position = target.global_position
		else:
			target = marker_a
			navigation_agent.target_position = target.global_position
	super._physics_process(delta)


func _on_died() -> void:
	if is_instance_valid(gate):
		gate.open()
	var player: Player = get_tree().get_first_node_in_group("player")
	player.invincibility_timer.stop()
	player.take_damage(1)
