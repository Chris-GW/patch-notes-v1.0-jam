extends BaseEnemy

@export var distance_range: Vector2
@export var teleport_chance: float

@onready var teleporter_cooldown_timer: Timer = $TeleporterCooldownTimer
@onready var teleport_mark_sprite_2d: Sprite2D = $TeleportMarkSprite2D
@onready var player: Player = get_tree().get_first_node_in_group("player")


func _ready() -> void:
	super._ready()
	teleport_mark_sprite_2d.visible = false
	teleport_mark_sprite_2d.reparent.call_deferred(self.get_parent())


func _physics_process(delta: float) -> void:
	if teleporter_cooldown_timer.is_stopped() and randf() < teleport_chance * delta:
		do_teleport()
	elif teleport_mark_sprite_2d.visible:
		velocity = Vector2.ZERO
	else:
		super._physics_process(delta)


func _on_navigation_update_timer_timeout() -> void:
	super._on_navigation_update_timer_timeout()


func do_teleport() -> void:
	teleporter_cooldown_timer.start()
	if state_machine.get_current_node() != "death":
		state_machine.travel("attack")
	var teleport_position := find_teleport_position()
	teleport_mark_sprite_2d.global_position = teleport_position + Vector2.UP * 8.0
	teleport_mark_sprite_2d.visible = true
	
	await get_tree().create_timer(1.0).timeout
	knockback = Vector2.ZERO
	set_global_position.call_deferred(teleport_position)
	teleport_mark_sprite_2d.visible = false
	_on_navigation_update_timer_timeout.call_deferred()


func find_teleport_position() -> Vector2:
	var my_target: Node2D = player
	if is_instance_valid(target) and target.is_node_ready():
		my_target = target
	
	for i in range(10):
		var new_distance := randf_range(distance_range.x, distance_range.y)
		var angle := global_position.angle_to_point(my_target.global_position)
		angle += randf_range(PI / -3.0, PI / 3.0)
		var teleport_position = Vector2.from_angle(angle) * new_distance
		teleport_position = my_target.global_position + teleport_position
		navigation_agent.target_position = teleport_position
		if navigation_agent.is_target_reachable():
			return teleport_position
	return self.global_position


func die() -> void:
	teleport_mark_sprite_2d.queue_free()
	super.die()
