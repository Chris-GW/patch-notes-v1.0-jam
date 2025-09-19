class_name BaseEnemy
extends CharacterBody2D

signal damage_taken
signal died

const MEDKIT_PICKUP: PackedScene = preload("res://core/pickups/medkit_pickup.tscn")

@export var attack_damage: int
@export var move_speed: float
@export var max_health: int
@export var medkit_spawn_chance: float
@export var knockback_decay: float ## how fast knockback fades

var movement_delta: float
var health: int

var knockback := Vector2.ZERO
var target: Node2D = null

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var state_machine := animation_tree.get("parameters/playback") as AnimationNodeStateMachinePlayback
@onready var navigation_agent: NavigationAgent2D = $NavigationAgent
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var health_bar: ProgressBar = %HealthBar
@onready var hurt_area_2d: Area2D = $HurtArea2D
@onready var hit_area_2d: Area2D = %HitArea2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var death_sfx_player_2d: AudioStreamPlayer2D = $DeathSfxPlayer2D


func _ready() -> void:
	_on_navigation_update_timer_timeout()
	health = max_health
	health_bar.max_value = max_health
	health_bar.value = max_health


func _physics_process(delta: float) -> void:
	if state_machine.get_current_node() == "death":
		return
	if knockback.length_squared() > 20.0:
		knockback = knockback.move_toward(Vector2.ZERO, knockback_decay * delta)
		velocity = knockback
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
		knockback = last_collision.get_normal() * knockback.length()


func _on_navigation_update_timer_timeout() -> void:
	if is_instance_valid(target) and target.is_node_ready():
		set_nav_target_position(target.global_position)
		return
	var player: Player = get_tree().get_first_node_in_group("player")
	set_nav_target_position(player.global_position)


func set_nav_target_position(target_position: Vector2) -> void:
	target_position += Vector2.DOWN * 8.0 # adjust origin to collision center
	navigation_agent.target_position = target_position


func take_damage(damage: int) -> void:
	health = clampi(health - damage, 0, max_health)
	health_bar.value = health
	damage_taken.emit()
	$HitSfxPlayer2D.play()
	if health <= 0:
		die()


func die() -> void:
	if randf() < medkit_spawn_chance:
		var medkit: MedkitPickup = MEDKIT_PICKUP.instantiate()
		medkit.global_position = global_position
		get_parent().add_child.call_deferred(medkit)
		var direction := Vector2.from_angle(randf_range(0.0, TAU))
		medkit.apply_central_impulse(direction * 500.0)
	hit_area_2d.queue_free()
	hurt_area_2d.queue_free()
	$CollisionShape2D.queue_free()
	died.emit()
	
	death_sfx_player_2d.reparent(get_parent())
	death_sfx_player_2d.play()
	await get_tree().create_timer(3.8).timeout
	death_sfx_player_2d.queue_free()


func _on_hit_area_2d_area_entered(area: Area2D) -> void:
	var parent := area.get_parent()
	if parent is Player:
		hurt_player(parent)
	if parent is PlayerGhost and state_machine.get_current_node() != "death":
		state_machine.travel("attack")


func hurt_player(player: Player) -> void:
	if state_machine.get_current_node() != "death":
		state_machine.travel("attack")
	player.take_damage(attack_damage)


func apply_knockback(source_pos: Vector2, strength: float = 300.0):
	if health <= 0:
		return
	var dir := source_pos.direction_to(global_position)
	knockback = dir * strength
