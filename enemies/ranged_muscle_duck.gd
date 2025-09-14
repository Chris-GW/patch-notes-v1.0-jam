extends BaseEnemy

@export var distance_range: Vector2

var relative_target_position:= Vector2.ZERO

@onready var visible_notifier: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D
@onready var player: Player = get_tree().get_first_node_in_group("player")


func _ready() -> void:
	super._ready()


func _physics_process(delta: float) -> void:
	if knockback.length_squared() > 20.0:
		velocity = knockback
		knockback = knockback.move_toward(Vector2.ZERO, knockback_decay * delta)
	elif navigation_agent.is_navigation_finished():
		velocity = Vector2.ZERO
	elif state_machine.get_current_node() == "attack":
		velocity = Vector2.ZERO
	else:
		var next_point := navigation_agent.get_next_path_position()
		var direction := global_position.direction_to(next_point)
		velocity = direction * move_speed
	if move_and_slide() and knockback.length_squared() > 20.0:
		var last_collision := get_last_slide_collision()
		knockback = last_collision.get_normal() * knockback.length() + last_collision.get_remainder()


func _on_navigation_update_timer_timeout() -> void:
	var my_target := player
	if is_instance_valid(target) and target.is_node_ready():
		my_target = target
	navigation_agent.target_position = my_target.global_position + relative_target_position


func _on_repostion_timer_timeout() -> void:
	var my_target := player
	if is_instance_valid(target) and target.is_node_ready():
		my_target = target
	var new_distance := randf_range(distance_range.x, distance_range.y)
	var target_angle := my_target.global_position.angle_to_point(self.global_position)
	target_angle += randf_range(-PI/4, +PI/4)
	relative_target_position = Vector2.from_angle(target_angle) * new_distance
	_on_navigation_update_timer_timeout()
