@tool
class_name Gate
extends AnimatableBody2D


@export var length_in_tiles := 1 : set = set_length_in_tiles
@export var is_open := false
@export var battle_point: BattlePoint

var gate_tween: Tween

@onready var clip_mask: Control = $ClipMask
@onready var move_handle: Node2D = %MoveHandle
@onready var right_sprite_2d: Sprite2D = $RightSprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	update_gate_length.call_deferred()
	if is_open:
		open()


func _enter_tree() -> void:
	if is_instance_valid(battle_point) and not Engine.is_editor_hint():
		battle_point.battle_started.connect(_on_battle_started)
		battle_point.battle_ended.connect(_on_battle_ended)


func _exit_tree() -> void:
	if is_instance_valid(battle_point) and not Engine.is_editor_hint():
		battle_point.battle_started.disconnect(_on_battle_started)
		battle_point.battle_ended.disconnect(_on_battle_ended)


func _on_battle_started(_battle_point: BattlePoint) -> void:
	close()

func _on_battle_ended(_battle_point: BattlePoint) -> void:
	open()



func update_gate_length() -> void:
	if not is_node_ready():
		return
	var delete_count := maxi(move_handle.get_child_count() - length_in_tiles, 0)
	for i in range(delete_count):
		var child := move_handle.get_child(length_in_tiles + i)
		move_handle.remove_child(child)
		child.queue_free()
	
	var add_count := maxi(length_in_tiles - move_handle.get_child_count(), 0)
	for i in range(add_count):
		var new_gate_sprite: Sprite2D = move_handle.get_child(0).duplicate()
		var tile_x := move_handle.get_child_count() * 32.0
		new_gate_sprite.position = Vector2.RIGHT * tile_x
		move_handle.add_child(new_gate_sprite)
	
	var gate_width := move_handle.get_child_count() * 32.0
	var rectangle_shape: RectangleShape2D = collision_shape_2d.shape
	rectangle_shape.set_size.call_deferred(Vector2(gate_width, rectangle_shape.size.y))
	collision_shape_2d.position.x = gate_width / 2.0
	right_sprite_2d.position.x = gate_width - 16.0
	clip_mask.size.x = gate_width


func open() -> void:
	is_open = true
	if is_instance_valid(gate_tween):
		gate_tween.kill()
	gate_tween = create_tween()
	gate_tween.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	gate_tween.tween_property(move_handle, "position:y", 48.0, 0.5)
	gate_tween.tween_callback(collision_shape_2d.set_disabled.bind(true))
	for child: Sprite2D in move_handle.get_children():
		child.frame = 0


func close() -> void:
	is_open = false
	if is_instance_valid(gate_tween):
		gate_tween.kill()
	collision_shape_2d.set_disabled.call_deferred(false)
	gate_tween = create_tween()
	gate_tween.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	gate_tween.tween_property(move_handle, "position:y", 16.0, 0.5)
	for child: Sprite2D in move_handle.get_children():
		child.frame = 1


func set_length_in_tiles(_length_in_tiles: int) -> void:
	length_in_tiles = maxi(_length_in_tiles, 1)
	update_gate_length()
