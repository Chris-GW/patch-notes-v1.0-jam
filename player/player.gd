class_name Player
extends CharacterBody2D

const GLITCHED_SWORD_ATTACK = preload("res://player/glitched_sword_attack.tscn")

@export var move_speed: float
@export var move_smoothing: float

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var attack_cooldown_timer: Timer = $AttackCooldownTimer
@onready var camera_2d: Camera2D = $Camera2D

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var sword: Sprite2D = $Sword


func _ready() -> void:
	pass


func _physics_process(delta: float) -> void:
	var input_direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var target_velocity := input_direction * move_speed
	
	var velocity_weight := 1.0 - exp(-move_smoothing * delta)
	velocity = velocity.lerp(target_velocity, velocity_weight)
	update_animation_parameters()
	move_and_slide()


func update_animation_parameters() -> void:
	var can_attack := Input.is_action_pressed("attack") and attack_cooldown_timer.is_stopped()
	animation_tree.set("parameters/conditions/is_attacking", can_attack)
	
	if velocity.length_squared() > 100.0:
		animation_tree.set("parameters/run/blend_position", velocity)
	if velocity.length_squared() > 100.0 and attack_cooldown_timer.is_stopped():
		animation_tree.set("parameters/attack/blend_position", velocity)
	
	var state_machine := animation_tree.get("parameters/playback") as AnimationNodeStateMachinePlayback
	var current_state := state_machine.get_current_node()
	if current_state == "attack" and attack_cooldown_timer.is_stopped():
		attack_cooldown_timer.start()


func attack() -> void:
	var sword_attack: GlitchedSwordAttack = GLITCHED_SWORD_ATTACK.instantiate()
	sword_attack.global_position = self.global_position
	sword_attack.attack_animation = animation_player.current_animation
	sword_attack.delay_sec = 1.0
	
	await animation_player.animation_finished
	# reset sword to holding position
	sword.position = Vector2(55.0, -20.0)
	sword.rotation_degrees = 169.2
