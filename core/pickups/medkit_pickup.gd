class_name MedkitPickup
extends RigidBody2D

@export var heal_amount: int

@onready var freeze_timer: Timer = $FreezeTimer
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var pickup_area_2d: Area2D = $PickupArea2D
@onready var player: Player = get_tree().get_first_node_in_group("player")


func _physics_process(_delta: float) -> void:
	if pickup_area_2d.overlaps_body(player) and not player.is_full_health():
		pickup()
	if freeze_timer.is_stopped() and linear_velocity.is_zero_approx():
		freeze = true


func pickup() -> void:
	player.take_heal(heal_amount)
	queue_free()
