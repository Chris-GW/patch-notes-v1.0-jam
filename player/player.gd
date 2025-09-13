class_name Player
extends CharacterBody2D

signal damage_taken
signal heal_taken
signal died

const GLITCHED_SWORD_ATTACK: PackedScene = preload("res://player/glitched_sword_attack.tscn")
const PLAYER_GHOST: PackedScene = preload("res://player/player_ghost.tscn")

@export var move_speed: float
@export var move_smoothing: float

@export var dash_speed: float
@export var max_dash_charges: int

@export var max_health: float
@export var ghost_spawn_chance: float

var health := max_health
var dash_charges := max_dash_charges

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var attack_cooldown_timer: Timer = $AttackCooldownTimer
@onready var ghost_timer: Timer = $GhostTimer
@onready var dashing_timer: Timer = $DashingTimer
@onready var dash_refresh_timer: Timer = $DashRefreshTimer
@onready var invincibility_timer: Timer = $InvincibilityTimer

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var sword: Sprite2D = $Sword
@onready var hurt_area_2d: Area2D = $HurtArea2D


func _ready() -> void:
	health = max_health
	dash_charges = max_dash_charges


func _physics_process(delta: float) -> void:
	_update_movement_velocity(delta)
	_update_animation_parameters()
	_update_dash_refresh_timer()
	if ghost_timer.is_stopped() and randf() <= ghost_spawn_chance * delta:
		spawn_player_ghost()
	move_and_slide()


func _update_movement_velocity(delta: float) -> void:
	var input_direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var target_velocity := input_direction * move_speed
	if can_input_dash():
		dashing_timer.start()
		dash_charges -= 1
		hurt_area_2d.monitorable = false
	if not dashing_timer.is_stopped():
		if input_direction.is_zero_approx(): # stopping not allowed
			input_direction = velocity.normalized()
		target_velocity = input_direction * dash_speed
	
	var velocity_weight := 1.0 - exp(-move_smoothing * delta)
	velocity = velocity.lerp(target_velocity, velocity_weight)


func _update_animation_parameters() -> void:
	if can_input_attack():
		var mouse_direction := global_position.direction_to(get_global_mouse_position())
		animation_tree.set("parameters/attack/blend_position", mouse_direction)
		animation_tree.set("parameters/conditions/is_attacking", true)
		attack_cooldown_timer.start()
	else:
		animation_tree.set("parameters/conditions/is_attacking", false)
	animation_tree.set("parameters/conditions/is_dashing", not dashing_timer.is_stopped())
	
	if velocity.length_squared() > 100.0:
		animation_tree.set("parameters/run/blend_position", velocity.normalized())


func can_input_attack() -> bool:
	return (Input.is_action_pressed("attack") 
			and attack_cooldown_timer.is_stopped() 
			and dashing_timer.is_stopped())


func  can_input_dash() -> bool:
	return (Input.is_action_pressed("dash") 
			and dash_charges > 0 
			and dashing_timer.is_stopped())


func _on_animation_tree_animation_started(anim_name: StringName) -> void:
	if anim_name.begins_with("weapon"):
		spawn_glitched_sword_attack(anim_name)


func spawn_glitched_sword_attack(anim_name: StringName) -> void:
	var sword_attack: GlitchedSwordAttack = GLITCHED_SWORD_ATTACK.instantiate()
	sword_attack.global_position = self.global_position
	sword_attack.attack_animation = anim_name
	sword_attack.delay_sec = 1.3
	get_parent().add_child(sword_attack)


func spawn_player_ghost() -> void:
	var player_ghost: PlayerGhost = PLAYER_GHOST.instantiate()
	get_parent().add_child(player_ghost)
	ghost_timer.start()


func take_damage(damage: float) -> void:
	if not invincibility_timer.is_stopped():
		return
	health = clampf(health - damage, 0.0, max_health)
	hurt_area_2d.set_monitorable.call_deferred(false)
	damage_taken.emit()
	if health <= 0.0:
		died.emit()
		return
	
	var blink_interval := 0.1
	invincibility_timer.start()
	var tween := create_tween()
	tween.set_loops()
	tween.tween_property(sprite_2d, "modulate:a", 0.2, blink_interval).set_trans(Tween.TRANS_SINE)
	tween.tween_property(sprite_2d, "modulate:a", 1.0, blink_interval).set_trans(Tween.TRANS_SINE)
	await invincibility_timer.timeout
	tween.kill()
	sprite_2d.modulate.a = 1.0
	hurt_area_2d.set_monitorable.call_deferred(true)


func take_heal(heal_amount: float) -> void:
	health = clampf(health + heal_amount, 0.0, max_health)
	heal_taken.emit()


func is_full_health() -> bool:
	return health >= max_health


func _update_dash_refresh_timer() -> void:
	if dash_charges < max_dash_charges and dash_refresh_timer.is_stopped():
		dash_refresh_timer.start()
	elif dash_charges >= max_dash_charges:
		dash_refresh_timer.stop()
	if not dashing_timer.is_stopped():
		_spawn_dash_afterimages()


func _spawn_dash_afterimages() -> void:
	var after_image_sprite: Sprite2D = sprite_2d.duplicate()
	after_image_sprite.self_modulate = Color.BLACK
	after_image_sprite.self_modulate.a = 0.5
	after_image_sprite.z_index = -2
	after_image_sprite.global_position = sprite_2d.global_position
	get_parent().add_child(after_image_sprite)
	await get_tree().create_timer(0.1).timeout
	after_image_sprite.queue_free()


func _on_dash_refresh_timer_timeout() -> void:
	dash_charges = clampi(dash_charges + 1, 0, max_dash_charges)


func _on_dashing_timer_timeout() -> void:
	hurt_area_2d.set_monitorable.call_deferred(true)
