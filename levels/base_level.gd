extends Node2D

const BASE_ENEMY = preload("res://enemies/base_enemy.tscn")

@onready var player: Player = %Player
@onready var player_camera: Camera2D = %PlayerCamera2D

@onready var world_boundaries: ReferenceRect = %WorldBoundariesReferenceRect
@onready var y_sort_root: Node2D = %YSortRoot

@onready var health_bar: ProgressBar = %HealthBar
@onready var dash_charges_label: Label = %DashChargesLabel


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in range(7):
		_on_enemy_spawn_timer_timeout()
	health_bar.max_value = player.max_health
	health_bar.value = player.max_health


func _process(_delta: float) -> void:
	dash_charges_label.text = "Dash charges: %d / %d" % [player.dash_charges, player.max_dash_charges]


func _on_enemy_spawn_timer_timeout() -> void:
	spawn_enemy()


func spawn_enemy() -> BaseEnemy:
	var new_enemy: BaseEnemy = BASE_ENEMY.instantiate()
	new_enemy.global_position = random_position_outside_camera()
	new_enemy.move_speed = randfn(150.0, 30.0)
	y_sort_root.add_child(new_enemy)
	return new_enemy


func random_position_outside_camera() -> Vector2:
	var world_rect := world_boundaries.get_rect().grow(-128.0)
	var camera_world_rect := get_camera_world_rect(player_camera).grow(128.0)
	
	while true:
		var x := randf_range(world_rect.position.x, world_rect.end.x)
		var y := randf_range(world_rect.position.y, world_rect.end.y)
		var point := Vector2(x, y)
		if not camera_world_rect.has_point(point):
			return point
	return Vector2.ZERO


func get_camera_world_rect(camera: Camera2D) -> Rect2:
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	var half_world_size: Vector2 = (viewport_size * 0.5) * camera.zoom
	var center: Vector2 = camera.global_position
	return Rect2(center - half_world_size, half_world_size * 2.0)


func _on_player_damage_taken() -> void:
	health_bar.value = player.health

func _on_player_heal_taken() -> void:
	health_bar.value = player.health


func _on_player_died() -> void:
	get_tree().paused = true
	%DiedPanelContainer.visible = true


func _on_restart_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(self.scene_file_path)
