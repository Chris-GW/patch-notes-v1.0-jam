class_name SpawnPoint
extends Node2D

const VILLAGER = preload("res://core/villager/villager.tscn")

@export var spawn_cooldown_range: Vector2
@export_enum("tpye_snail", "type_duck") var type := 0

@onready var spawn_cooldown_timer: Timer = $SpawnCooldownTimer
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var spawn_marker_2d: Marker2D = $SpawnMarker2D


func _ready() -> void:
	var region_size := Vector2(128.0, 96.0)
	var region_position := Vector2(192.0, 0.0)
	if type == 1:
		region_position = Vector2(864.0, 0.0)
	sprite_2d.region_rect = Rect2(region_position, region_size)



func spawn(enemy: BaseEnemy) -> void:
	start_spawn_cooldown()
	enemy.global_position = spawn_marker_2d.global_position


func start_spawn_cooldown() -> void:
	var cooldown := randf_range(spawn_cooldown_range.x, spawn_cooldown_range.y)
	cooldown = maxf(cooldown, 0.5)
	spawn_cooldown_timer.start(cooldown)


func can_spawn() -> bool:
	return spawn_cooldown_timer.is_stopped()


func spawn_villager() -> Node2D:
	var villager: Node2D = VILLAGER.instantiate()
	villager.global_position = spawn_marker_2d.global_position
	get_parent().get_parent().add_child.call_deferred(villager)
	return villager
