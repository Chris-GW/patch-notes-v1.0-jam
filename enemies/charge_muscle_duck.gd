extends BaseEnemy

@export var charge_length: float
@export var charge_speed: float
@export var charge_windup_sec: float
@export var charge_cooldown_sec: float
@export var charge_knockback: float

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
		if in_charge_attack():
			stop_charge_attack()
	else:
		var next_point := navigation_agent.get_next_path_position()
		var direction := global_position.direction_to(next_point)
		if in_charge_attack():
			update_charge_line()
			velocity = direction * charge_speed
			if state_machine.get_current_node() != "attack":
				state_machine.travel("attack")
		else:
			velocity = direction * move_speed
	
	try_charge_attack()
	
	if move_and_slide():
		if knockback.length_squared() > 20.0:
			var last_collision := get_last_slide_collision()
			knockback = last_collision.get_normal() * knockback.length()
		elif in_charge_attack():
			knockback_colliding_enemies()


func knockback_colliding_enemies() -> void:
	var charge_direction := velocity.normalized()
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		if collision.get_collider() is BaseEnemy:
			var collider: BaseEnemy = collision.get_collider()
			var enemy_direction := self.global_position.direction_to(collider.global_position)
			var knockback_direction := charge_direction.rotated(PI / 2.0)
			if enemy_direction.dot(knockback_direction) < 0.0:
				knockback_direction *= -1.0
			knockback_direction.rotated(randf_range(-PI / 8.0, PI / 8.0))
			var source_pos := collider.global_position - knockback_direction
			collider.apply_knockback(source_pos, charge_knockback)
		else:
			stop_charge_attack()


func stop_charge_attack() -> void:
	charge_line_2d.visible = false
	_on_navigation_update_timer_timeout()
	navigation_update_timer.start()


func try_charge_attack() -> bool:
	if not charge_cooldown_timer.is_stopped():
		return false # in attack cooldown
	if randf() < 0.95:
		return false # chance missed
	
	var target_position := find_charge_target().global_position
	var target_distance := self.global_position.distance_to(target_position)
	if target_distance > charge_length * 0.7:
		return false # out of attack range
	return ray_cast_charge_line(target_position)


func ray_cast_charge_line(target_position: Vector2) -> bool:
	var charge_direction := global_position.direction_to(target_position)
	var end_position := global_position + charge_direction * charge_length
	var ray_offset_direction := charge_direction.rotated(PI / 2.0)
	
	var collision_distance := INF
	var nearest_collision_point := end_position
	for ray_offset in [-16.0, 0.0, 16.0]:
		var offset: Vector2 = ray_offset_direction * ray_offset
		charge_ray_cast.position = offset
		charge_ray_cast.target_position = charge_ray_cast.to_local(end_position)
		charge_ray_cast.target_position += offset
		charge_ray_cast.force_raycast_update()
		
		if charge_ray_cast.is_colliding():
			var collision_point = charge_ray_cast.get_collision_point()
			var distance := global_position.distance_to(collision_point)
			if distance < collision_distance:
				collision_distance = distance
				nearest_collision_point = collision_point
	
	var target_distance := global_position.distance_to(target_position)
	target_distance -= 16.0
	if collision_distance < target_distance:
		return false # charge path obstructed to target
	do_prepare_charge_attack(nearest_collision_point)
	velocity = Vector2.ZERO
	return true


func do_prepare_charge_attack(end_position: Vector2) -> void:
	navigation_update_timer.stop()
	navigation_agent.target_position = end_position
	charge_line_2d.set_point_position(1, charge_line_2d.to_local(end_position))
	update_charge_line()
	charge_line_2d.visible = true
	charge_windup_timer.start(charge_windup_sec)
	charge_cooldown_timer.start(charge_windup_sec + charge_cooldown_sec)


func find_charge_target() -> Node2D:
	var charge_target: Node2D = target
	if !(is_instance_valid(target) and target.is_node_ready()):
		var player: Player = get_tree().get_first_node_in_group("player")
		charge_target = player
	return charge_target


func update_charge_line() -> void:
	var end_position := charge_line_2d.to_global(charge_line_2d.get_point_position(1))
	var charge_direction := global_position.direction_to(end_position)
	var distance := global_position.distance_to(end_position)
	distance = snappedf(distance, charge_line_2d.texture.get_size().x) 
	var start_position := end_position - charge_direction * distance
	
	charge_line_2d.global_position = self.global_position
	charge_line_2d.set_point_position(0, charge_line_2d.to_local(start_position))
	charge_line_2d.set_point_position(1, charge_line_2d.to_local(end_position))
	
	# rotate start / end cap sprites
	var start_sprite: Node2D = charge_line_2d.get_child(0)
	var end_sprite: Node2D = charge_line_2d.get_child(1)
	start_sprite.rotation = self.global_position.angle_to_point(end_position)
	end_sprite.rotation = start_sprite.rotation
	end_sprite.global_position = end_position


func in_charge_windup() -> bool:
	return not charge_windup_timer.is_stopped()


func in_charge_attack() -> bool:
	return not in_charge_windup() and charge_line_2d.visible


func apply_knockback(source_pos: Vector2, strength: float = 300.0):
	if in_charge_windup() or in_charge_attack():
		strength = sqrt(strength) 
	super.apply_knockback(source_pos, strength)


func die() -> void:
	charge_line_2d.visible = false
	charge_line_2d.reparent(self)
	super.die()
