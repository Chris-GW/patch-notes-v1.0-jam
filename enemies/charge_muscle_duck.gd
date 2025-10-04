extends BaseEnemy

@export var charge_length: float
@export var charge_speed: float
@export var charge_windup_sec: float
@export var charge_cooldown_sec: float

@onready var charge_windup_timer: Timer = $ChargeWindupTimer
@onready var charge_cooldown_timer: Timer = $ChargeCooldownTimer
@onready var charge_line_2d: Line2D = $ChargeLine2D
@onready var charge_ray_cast: RayCast2D = $ChargeLineRayCast2D


func _ready() -> void:
	super._ready()
	charge_line_2d.visible = false
	charge_line_2d.reparent.call_deferred(get_parent())
	charge_cooldown_timer.start(charge_cooldown_sec)


func _physics_process(delta: float) -> void:
	if state_machine.get_current_node() == "death":
		return
	if knockback.length_squared() > 20.0:
		knockback = knockback.move_toward(Vector2.ZERO, knockback_decay * delta)
		velocity = knockback
	elif in_charge_windup():
		velocity = Vector2.ZERO
		if state_machine.get_current_node() != "attack":
			state_machine.travel("attack")
	elif state_machine.get_current_node() == "attack" and not in_charge_attack():
		velocity = Vector2.ZERO
	elif navigation_agent.is_navigation_finished():
		velocity = Vector2.ZERO
		if charge_line_2d.visible:
			charge_line_2d.visible = false
			_on_navigation_update_timer_timeout()
			navigation_update_timer.start()
	else:
		var next_point := navigation_agent.get_next_path_position()
		var direction := global_position.direction_to(next_point)
		if in_charge_attack():
			velocity = direction * charge_speed
			if state_machine.get_current_node() != "attack":
				state_machine.travel("attack")
		else:
			velocity = direction * move_speed
	
	if can_charge_attack():
		velocity = Vector2.ZERO
		windup_charge_attack()
	
	if move_and_slide():
		if knockback.length_squared() > 20.0:
			var last_collision := get_last_slide_collision()
			knockback = last_collision.get_normal() * knockback.length()
		elif in_charge_attack():
			for i in get_slide_collision_count():
				var slide_collision := get_slide_collision(i)
				var collider := slide_collision.get_collider()
				if collider is BaseEnemy:
					collider.apply_knockback(slide_collision.get_position(), 160.0)


func windup_charge_attack() -> void:
	var target_position := find_charge_target().global_position
	var charge_direction := self.global_position.direction_to(target_position)
	var end_position := self.global_position + charge_direction * charge_length
	place_charge_line(self.global_position, end_position)
	navigation_update_timer.stop()
	set_nav_target_position(end_position)
	charge_windup_timer.start(charge_windup_sec)
	charge_cooldown_timer.start(charge_windup_sec + charge_cooldown_sec)


func place_charge_line(start_position: Vector2, end_position: Vector2) -> void:
	charge_line_2d.global_position = start_position
	charge_line_2d.set_point_position(1, charge_line_2d.to_local(end_position))
	charge_line_2d.visible = true
	
	# rotate start / end cap sprites
	var start_sprite: Node2D = charge_line_2d.get_child(0)
	var end_sprite: Node2D = charge_line_2d.get_child(1)
	start_sprite.rotation = start_position.angle_to_point(end_position)
	end_sprite.rotation = start_sprite.rotation
	end_sprite.global_position = end_position


func find_charge_target() -> Node2D:
	var charge_target: Node2D = target
	if !(is_instance_valid(target) and target.is_node_ready()):
		var player: Player = get_tree().get_first_node_in_group("player")
		charge_target = player
	return charge_target


func can_charge_attack() -> bool:
	if not charge_cooldown_timer.is_stopped():
		return false
	var target_position := find_charge_target().global_position
	var target_distance := self.global_position.distance_to(target_position)
	if target_distance > charge_length * 0.666:
		return false
	charge_ray_cast.target_position = charge_ray_cast.to_local(target_position)
	charge_ray_cast.force_raycast_update()
	return not charge_ray_cast.is_colliding()


func in_charge_windup() -> bool:
	return not charge_windup_timer.is_stopped()


func in_charge_attack() -> bool:
	return not in_charge_windup() and charge_line_2d.visible


func apply_knockback(source_pos: Vector2, strength: float = 300.0):
	if in_charge_windup() or in_charge_attack():
		strength = sqrt(strength) 
	super.apply_knockback(source_pos, strength)


func die() -> void:
	super.die()
	charge_line_2d.queue_free()
