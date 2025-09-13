class_name PlayerGhost
extends Node2D

@onready var stay_timer: Timer = $StayTimer
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var sword: Sprite2D = $Sword
@onready var distraction_area: Area2D = $DistractionArea2D


func _ready() -> void:
	var player: Player = get_tree().get_first_node_in_group("player")
	global_position = player.global_position
	sync_animation_tree.call_deferred(player)


func sync_animation_tree(player: Player) -> void:
	var playback1: AnimationNodeStateMachinePlayback = player.animation_tree["parameters/playback"]
	var playback2: AnimationNodeStateMachinePlayback = self.animation_tree["parameters/playback"]
	
	# Get the current state and its time from anim_tree1
	var current_state := playback1.get_current_node()
	var current_time := playback1.get_current_play_position()
	playback2.start(current_state, true)
	self.animation_tree.advance(current_time)
	self.animation_tree.advance(current_time)
	print(current_state, " - ", playback2.get_current_node())
	print(current_time, " - ", playback2.get_current_play_position())
	print("------")


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
