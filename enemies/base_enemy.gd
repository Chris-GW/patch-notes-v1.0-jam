class_name BaseEnemy
extends CharacterBody2D

signal damage_taken
signal died


@export var move_speed: float
@export var max_health: float

var movement_delta: float
var health: float

@onready var navigation_agent: NavigationAgent2D = $NavigationAgent
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var health_bar: ProgressBar = %HealthBar
@onready var hit_area_2d: Area2D = %HitArea2D


func _ready() -> void:
	_on_navigation_update_timer_timeout()
	health = max_health
	health_bar.max_value = max_health
	health_bar.value = max_health


func _physics_process(_delta: float) -> void:
	if navigation_agent.is_navigation_finished():
		velocity = Vector2.ZERO
	else:
		var next_point := navigation_agent.get_next_path_position()
		var direction := global_position.direction_to(next_point)
		velocity = direction * move_speed
	move_and_slide()


func _on_navigation_update_timer_timeout() -> void:
	var player: Player = get_tree().get_first_node_in_group("player")
	navigation_agent.target_position = player.global_position


func take_damage(damage: float) -> void:
	health = clampf(health - damage, 0.0, max_health)
	health_bar.value = health
	damage_taken.emit()
	if health <= 0.0:
		die()


func die() -> void:
	died.emit()
	queue_free()


func _on_hit_area_2d_area_entered(area: Area2D) -> void:
	var parent := area.get_parent()
	if parent is Player:
		hurt_player(parent)


func hurt_player(player: Player) -> void:
	player.take_damage(10.0)
	hit_area_2d.set_monitoring.call_deferred(false)
	await get_tree().create_timer(2.0).timeout
	hit_area_2d.set_monitoring(true)
