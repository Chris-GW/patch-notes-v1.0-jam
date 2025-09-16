class_name PlayerGhost
extends Node2D


@onready var stay_timer: Timer = $StayTimer
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var distraction_area: Area2D = $DistractionArea2D


func _ready() -> void:
	pass


func _physics_process(_delta: float) -> void:
	for body: Node2D in distraction_area.get_overlapping_bodies():
		if body is BaseEnemy:
			distract_enemy(body)


func distract_enemy(enemy: BaseEnemy) -> void:
	if is_instance_valid(enemy.target) and enemy.target.is_node_ready():
		var my_distance := global_position.distance_squared_to(enemy.global_position)
		var other_distance := enemy.global_position.distance_squared_to(enemy.target.global_position)
		if my_distance < other_distance:
			enemy.target = self
	else:
		enemy.target = self


func _on_stay_timer_timeout():
	queue_free()
