class_name SpawnPoint
extends Node2D

const VILLAGER = preload("res://core/villager/villager.tscn")

@onready var spawn_cooldown_timer: Timer = $SpawnCooldownTimer
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var spawn_marker_2d: Marker2D = $SpawnMarker2D


func spawn(enemy: BaseEnemy) -> void:
	spawn_cooldown_timer.start()
	enemy.global_position = spawn_marker_2d.global_position


func can_spawn() -> bool:
	return spawn_cooldown_timer.is_stopped()


func spawn_villager() -> Node2D:
	var villager: Node2D = VILLAGER.instantiate()
	villager.global_position = spawn_marker_2d.global_position
	get_parent().get_parent().add_child.call_deferred(villager)
	return villager
