class_name Player
extends CharacterBody2D

signal damage_taken
signal died

const GLITCHED_SWORD_ATTACK: PackedScene = preload("res://player/glitched_sword_attack.tscn")
const PLAYER_GHOST: PackedScene = preload("res://player/player_ghost.tscn")

@export var move_speed: float
@export var move_smoothing: float
@export var max_health: float
@export var ghost_spawn_chance: float

var health := max_health

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var attack_cooldown_timer: Timer = $AttackCooldownTimer
@onready var ghost_timer: Timer = $GhostTimer

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var sword: Sprite2D = $Sword


func _ready() -> void:
	health = max_health


func _physics_process(delta: float) -> void:
	_update_movement_velocity(delta)
	_update_animation_parameters()
	if ghost_timer.is_stopped() and randf() <= ghost_spawn_chance * delta:
		spawn_player_ghost()
	move_and_slide()


func _update_movement_velocity(delta: float) -> void:
	var input_direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var target_velocity := input_direction * move_speed
	
	var velocity_weight := 1.0 - exp(-move_smoothing * delta)
	velocity = velocity.lerp(target_velocity, velocity_weight)


func _update_animation_parameters() -> void:
	if Input.is_action_pressed("attack") and attack_cooldown_timer.is_stopped():
		var mouse_direction := global_position.direction_to(get_global_mouse_position())
		animation_tree.set("parameters/attack/blend_position", mouse_direction)
		animation_tree.set("parameters/conditions/is_attacking", true)
		attack_cooldown_timer.start()
	else:
		animation_tree.set("parameters/conditions/is_attacking", false)
	
	if velocity.length_squared() > 100.0:
		animation_tree.set("parameters/run/blend_position", velocity.normalized())


func _on_animation_tree_animation_started(anim_name: StringName) -> void:
	if anim_name.begins_with("weapon"):
		var sword_attack: GlitchedSwordAttack = GLITCHED_SWORD_ATTACK.instantiate()
		sword_attack.global_position = self.global_position
		sword_attack.attack_animation = anim_name
		sword_attack.delay_sec = 1.3
		get_parent().add_child(sword_attack)


func spawn_player_ghost() -> void:
	var player_ghost := PLAYER_GHOST.instantiate()
	get_parent().add_child(player_ghost)
	ghost_timer.start()


func take_damage(damage: float) -> void:
	health = clampf(health - damage, 0.0, max_health)
	damage_taken.emit()
	if health <= 0.0:
		died.emit()
