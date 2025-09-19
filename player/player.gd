class_name Player
extends CharacterBody2D

signal damage_taken
signal heal_taken
signal died

const GLITCHED_SWORD_ATTACK: PackedScene = preload("res://player/glitched_sword_attack.tscn")
const PLAYER_GHOST: PackedScene = preload("res://player/player_ghost.tscn")

@export var move_speed: float
@export var move_smoothing: float
@export var attack_smoothing: float

@export var dash_speed: float
@export var dash_steering: float
@export var max_dash_charges: int

@export var max_health: int
@export var ghost_spawn_chance: float

var health := max_health
var dash_charges := max_dash_charges

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var state_machine := animation_tree.get("parameters/playback") as AnimationNodeStateMachinePlayback

@onready var attack_cooldown_timer: Timer = $AttackCooldownTimer
@onready var ghost_timer: Timer = $GhostTimer
@onready var dashing_timer: Timer = $DashingTimer
@onready var dash_refresh_timer: Timer = $DashRefreshTimer
@onready var invincibility_timer: Timer = $InvincibilityTimer

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var hurt_area_2d: Area2D = $HurtArea2D


func _ready() -> void:
	health = max_health
	dash_charges = max_dash_charges
	animation_tree.active = true


func _process(_delta: float) -> void:
	if not dashing_timer.is_stopped():
		_spawn_dash_afterimages()


func _spawn_dash_afterimages() -> void:
	var after_image_sprite: Sprite2D = sprite_2d.duplicate()
	after_image_sprite.self_modulate = Color.BLACK
	after_image_sprite.self_modulate.a = 0.5
	after_image_sprite.global_position = sprite_2d.global_position
	get_parent().add_child(after_image_sprite)
	get_parent().move_child(after_image_sprite, 0)
	await get_tree().create_timer(3.0 /60.0).timeout
	after_image_sprite.queue_free()



func _physics_process(delta: float) -> void:
	_update_movement_velocity(delta)
	_update_animation_parameters()
	_update_dash_refresh_timer()
	if ghost_timer.is_stopped() and randf() <= ghost_spawn_chance * delta:
		spawn_player_ghost()
	move_and_slide()


func _update_movement_velocity(delta: float) -> void:
	var input_direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var velocity_weight := 1.0 - exp(-move_smoothing * delta)
	var target_velocity := input_direction * move_speed
	
	if can_input_dash():
		dashing_timer.start()
		play_random_dash_sfx()
		dash_charges -= 1
		hurt_area_2d.monitorable = false
	elif Input.is_action_just_pressed("dash") and dash_charges <= 0:
		$DashFailSfxPlayer.play()
	
	if not dashing_timer.is_stopped():
		if input_direction.is_zero_approx(): # stopping not allowed
			input_direction = velocity.normalized()
		# small steering influence
		var steering_weight := 1.0 - exp(-dash_steering * delta)
		input_direction = velocity.normalized().lerp(input_direction, steering_weight)
		target_velocity = input_direction * dash_speed
	if state_machine.get_current_node() == "attack":
		target_velocity = Vector2.ZERO
		velocity_weight =  1.0 - exp(-attack_smoothing * delta)
	
	velocity = velocity.lerp(target_velocity, velocity_weight)


var step_sound_timer: SceneTreeTimer

func _update_animation_parameters() -> void:
	var velocity_direction := velocity.normalized()
	var side_blend := velocity_direction.dot(Vector2.RIGHT)
	if not is_zero_approx(side_blend):
		animation_tree.set("parameters/roll/blend_position", side_blend)
		animation_tree.set("parameters/dash_run/blend_position", side_blend)
	if velocity.length_squared() > 30.0:
		animation_tree.set("parameters/run/blend_position", velocity_direction)
		if not is_instance_valid(step_sound_timer) or step_sound_timer.time_left <= 0.0:
			$StepSfxPlayer.play()
			step_sound_timer = get_tree().create_timer(0.5)
	else:
		$StepSfxPlayer.stop()
	if can_input_attack() and Input.is_action_pressed("attack_2"):
		animation_tree.set("parameters/roll_attack/blend_position", side_blend)
		animation_tree.set("parameters/conditions/is_attacking", false)
		animation_tree.set("parameters/conditions/is_attacking_2", true)
		attack_cooldown_timer.start()
	elif can_input_attack() and Input.is_action_pressed("attack"):
		var mouse_direction := global_position.direction_to(get_global_mouse_position())
		animation_tree.set("parameters/attack/blend_position", mouse_direction)
		animation_tree.set("parameters/conditions/is_attacking", true)
		animation_tree.set("parameters/conditions/is_attacking_2", false)
		attack_cooldown_timer.start()
	else:
		animation_tree.set("parameters/conditions/is_attacking", false)
		animation_tree.set("parameters/conditions/is_attacking_2", false)
	animation_tree.set("parameters/conditions/is_dashing", not dashing_timer.is_stopped())


func can_input_attack() -> bool:
	return (attack_cooldown_timer.is_stopped() 
			and dashing_timer.is_stopped())


func  can_input_dash() -> bool:
	return (Input.is_action_pressed("dash") 
			and dash_charges > 0 
			and dashing_timer.is_stopped())


func play_random_dash_sfx() -> void:
	var length := 0.75
	var start: float = [0.0, 1.4, 2.8, 4.3, 5.6, 7.2, 8.6, 10.0, 11.4, 12.8, 14.2, 15.6, 17.1].pick_random()
	$DashSfxPlayer.play(start)
	print("DashSfxPlayer from ", start)
	await get_tree().create_timer(length).timeout
	$DashSfxPlayer.stop()
	


func _on_animation_tree_animation_started(anim_name: StringName) -> void:
	if anim_name.begins_with("player/attack"):
		var sword_animation := anim_name.replace("player/attack", "sword/attack")
		spawn_glitched_sword_attack(sword_animation)
	if anim_name.begins_with("player/roll"):
		var sword_animation := anim_name.replace("player/roll", "sword/attack")
		spawn_glitched_sword_attack(sword_animation)


func spawn_glitched_sword_attack(anim_name: StringName) -> void:
	var sword_attack: GlitchedSwordAttack = GLITCHED_SWORD_ATTACK.instantiate()
	sword_attack.global_position = self.global_position
	sword_attack.attack_animation = anim_name
	sword_attack.delay_sec = 1.3
	get_parent().add_child(sword_attack)


func spawn_player_ghost() -> void:
	var player_ghost: PlayerGhost = PLAYER_GHOST.instantiate()
	player_ghost.global_position = global_position
	get_parent().add_child(player_ghost)
	player_ghost.sprite_2d.frame = self.sprite_2d.frame
	ghost_timer.start()


func take_damage(damage: int) -> void:
	if not invincibility_timer.is_stopped():
		return
	health = clampi(health - damage, 0, max_health)
	hurt_area_2d.set_monitorable.call_deferred(false)
	damage_taken.emit()
	$HurtSfxPlayer.play()
	if health <= 0:
		$DeathAudioPlayer.play()
		died.emit()
		return
	
	if state_machine.get_current_node() != "death":
		state_machine.travel("hurt")
	var blink_interval := 0.1
	invincibility_timer.start()
	var tween := create_tween()
	tween.set_loops()
	tween.tween_property(sprite_2d, "modulate:a", 0.2, blink_interval).set_trans(Tween.TRANS_SINE)
	tween.tween_property(sprite_2d, "modulate:a", 1.0, blink_interval).set_trans(Tween.TRANS_SINE)
	await invincibility_timer.timeout
	tween.kill()
	sprite_2d.modulate.a = 1.0
	if dashing_timer.is_stopped():
		hurt_area_2d.set_monitorable.call_deferred(true)


func take_heal(heal_amount: int) -> void:
	health = clampi(health + heal_amount, 0, max_health)
	heal_taken.emit()
	$HealSfxPlayer.play()


func is_full_health() -> bool:
	return health >= max_health


func _update_dash_refresh_timer() -> void:
	if dash_charges < max_dash_charges and dash_refresh_timer.is_stopped():
		dash_refresh_timer.start()
	elif dash_charges >= max_dash_charges:
		dash_refresh_timer.stop()


func _on_dash_refresh_timer_timeout() -> void:
	dash_charges = clampi(dash_charges + 1, 0, max_dash_charges)


func _on_dashing_timer_timeout() -> void:
	if invincibility_timer.is_stopped():
		hurt_area_2d.set_monitorable.call_deferred(true)
