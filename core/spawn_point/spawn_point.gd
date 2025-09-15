class_name SpawnPoint
extends Node2D

const VILLAGER = preload("res://core/villager/villager.tscn")

@export var spawn_cooldown_range: Vector2

@onready var spawn_cooldown_timer: Timer = $SpawnCooldownTimer
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var spawn_marker_2d: Marker2D = $SpawnMarker2D


func spawn(enemy: BaseEnemy) -> void:
	var cooldown := randf_range(spawn_cooldown_range.x, spawn_cooldown_range.y)
	cooldown = maxf(cooldown, 0.5)
	spawn_cooldown_timer.start(cooldown)
	enemy.global_position = spawn_marker_2d.global_position


func can_spawn() -> bool:
	return spawn_cooldown_timer.is_stopped()


func spawn_villager() -> Node2D:
	var villager: Node2D = VILLAGER.instantiate()
	villager.global_position = spawn_marker_2d.global_position
	get_parent().get_parent().add_child.call_deferred(villager)
	return villager
