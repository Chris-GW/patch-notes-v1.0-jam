class_name BaseEnemy
extends CharacterBody2D


@export var move_speed: float
@export var max_health: float

var movement_delta: float
var health: float

@onready var navigation_agent: NavigationAgent2D = $NavigationAgent
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var health_bar: ProgressBar = %HealthBar


func _ready() -> void:
	_on_navigation_update_timer_timeout()
	health = max_health
	health_bar.min_value = 0.0
	health_bar.max_value = max_health
	health_bar.value = max_health


func _physics_process(delta: float) -> void:
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
	if health <= 0.0:
		die()


func die() -> void:
	queue_free()
