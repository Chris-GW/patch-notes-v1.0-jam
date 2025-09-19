@tool
class_name SpawnPoint
extends StaticBody2D

const VILLAGER = preload("res://core/villager/villager.tscn")

@export var spawn_cooldown_range: Vector2
@export_enum("tpye_snail", "type_duck") var type := 0 : set = set_type

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var spawn_cooldown_timer: Timer = $SpawnCooldownTimer

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var enter_mask_rect: ColorRect = $EnterMaskRect
@onready var spawn_path_2d: Path2D = %SpawnPath2D
@onready var path_follow_2d: PathFollow2D = %PathFollow2D


func _ready() -> void:
	setup_house_type()
	if path_follow_2d.get_child_count() > 0:
		path_follow_2d.get_child(0).queue_free()


func set_type(_type: int) -> void:
	type = _type
	setup_house_type()


func setup_house_type() -> void:
	if not is_node_ready():
		return
	var region_position := sprite_2d.region_rect.position
	var spawn_path_offset := Vector2.ZERO
	if type == 0: # type_snail
		region_position = Vector2(192.0, 0.0)
		spawn_path_offset = Vector2(-16.0, -32.0)
	elif type == 1: # type_duck
		region_position = Vector2(864.0, 0.0)
		spawn_path_offset = Vector2(-28.0, -38.0)
	sprite_2d.region_rect.position = region_position
	enter_mask_rect.position = spawn_path_offset


func spawn(enemy: Node2D) -> void:
	start_spawn_cooldown()
	enemy.process_mode = Node.PROCESS_MODE_DISABLED
	path_follow_2d.progress = 0.0
	path_follow_2d.add_child(enemy)
	animation_player.play("exit_house_spawn")
	await animation_player.animation_finished
	var battle_point := get_parent()
	enemy.reparent(battle_point.get_parent())
	enemy.process_mode = Node.PROCESS_MODE_INHERIT


func start_spawn_cooldown() -> void:
	var cooldown := randf_range(spawn_cooldown_range.x, spawn_cooldown_range.y)
	cooldown = maxf(cooldown, 0.5)
	spawn_cooldown_timer.start(cooldown)


func can_spawn() -> bool:
	return spawn_cooldown_timer.is_stopped() and path_follow_2d.get_child_count() <= 0


func spawn_villager() -> void:
	var villager: Node2D = VILLAGER.instantiate()
	spawn(villager)
