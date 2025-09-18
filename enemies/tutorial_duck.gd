extends BaseEnemy

@export var gate: Gate

var partrol_targets: Array[Node2D] = []
var patrol_index := 0


func _ready() -> void:
	for child in get_children():
		if child is Marker2D:
			partrol_targets.append(child)
			child.reparent.call_deferred(get_parent())
	
	navigation_agent.debug_enabled = true
	super._ready()
	self.died.connect(_on_died)


func _physics_process(delta: float) -> void:
	if navigation_agent.is_navigation_finished() or not is_instance_valid(target):
		if target == partrol_targets[patrol_index]:
			patrol_index = (patrol_index + 1) % partrol_targets.size() 
		target = partrol_targets[patrol_index]
		set_nav_target_position(target.global_position)
	super._physics_process(delta)


func _on_died() -> void:
	if is_instance_valid(gate):
		gate.open()
	var player: Player = get_tree().get_first_node_in_group("player")
	player.invincibility_timer.stop()
	player.take_damage(1)
