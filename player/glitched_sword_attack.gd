class_name GlitchedSwordAttack
extends Node2D

@export var attack_animation: String
@export var delay_sec := 1.0

@onready var delay_timer: Timer = $DelayTimer
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sword: Sprite2D = $Sword
@onready var hit_area_2d: Area2D = %HitArea2D


func _ready() -> void:
	hit_area_2d.monitoring = false
	hit_area_2d.monitorable = false
	delay_timer.start(delay_sec)
	animation_player.play(attack_animation)
	animation_player.stop()


func on_delay_timeout() -> void:
	sword.self_modulate = Color("#FF000082")
	hit_area_2d.monitoring = true
	hit_area_2d.monitorable = true
	animation_player.play(attack_animation)
	await animation_player.animation_finished
	get_parent().remove_child(self)
	queue_free()
