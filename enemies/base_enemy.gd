class_name BaseEnemy
extends CharacterBody2D

signal damage_taken
signal died

const MEDKIT_PICKUP: PackedScene = preload("res://core/pickups/medkit_pickup.tscn")

@export var move_speed: float
@export var max_health: float
@export var medkit_spawn_chance: float
@export var knockback_decay: float ## how fast knockback fades

var movement_delta: float
var health: float

var knockback := Vector2.ZERO
var target: Node2D = null

@onready var navigation_agent: NavigationAgent2D = $NavigationAgent
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var health_bar: ProgressBar = %HealthBar
@onready var hit_area_2d: Area2D = %HitArea2D


func _ready() -> void:
	_on_navigation_update_timer_timeout()
	health = max_health
	health_bar.max_value = max_health
	health_bar.value = max_health


func _physics_process(delta: float) -> void:
	if knockback.length_squared() > 40.0:
		velocity = knockback
		knockback = knockback.move_toward(Vector2.ZERO, knockback_decay * delta)
	elif navigation_agent.is_navigation_finished():
		velocity = Vector2.ZERO
	else:
		var next_point := navigation_agent.get_next_path_position()
		var direction := global_position.direction_to(next_point)
		velocity = direction * move_speed
	if move_and_slide() and knockback.length_squared() > 40.0:
		var last_collision := get_last_slide_collision()
		knockback = last_collision.get_normal() * knockback.length() + last_collision.get_remainder()


func _on_navigation_update_timer_timeout() -> void:
	if is_instance_valid(target) and target.is_node_ready():
		navigation_agent.target_position = target.global_position
		return
	var player: Player = get_tree().get_first_node_in_group("player")
	navigation_agent.target_position = player.global_position


func take_damage(damage: float) -> void:
	health = clampf(health - damage, 0.0, max_health)
	health_bar.value = health
	damage_taken.emit()
	if health <= 0.0:
		die()


func die() -> void:
	if randf() < medkit_spawn_chance:
		var medkit: MedkitPickup = MEDKIT_PICKUP.instantiate()
		medkit.global_position = global_position
		get_parent().add_child.call_deferred(medkit)
		var direction := Vector2.from_angle(randf_range(0.0, TAU))
		medkit.apply_central_impulse(direction * 1000.0)
	died.emit()
	queue_free()


func _on_hit_area_2d_area_entered(area: Area2D) -> void:
	var parent := area.get_parent()
	if parent is Player:
		hurt_player(parent)


func hurt_player(player: Player) -> void:
	player.take_damage(10.0)


func apply_knockback(source_pos: Vector2, strength: float = 300.0):
	var dir := source_pos.direction_to(global_position)
	knockback = dir * strength
