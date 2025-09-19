class_name GlitchedSwordAttack
extends Node2D


@export var damage_amount := 5
@export var knockback_strenght: float
@export var attack_animation: String
@export var delay_sec := 1.0

var hit_enemies: Dictionary[RID, bool] = {}

@onready var delay_timer: Timer = $DelayTimer
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sword: AnimatedSprite2D = $Sword
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


func _on_hit_area_2d_area_entered(area: Area2D) -> void:
	if can_hurt_area(area):
		var enemy: BaseEnemy = area.get_parent()
		enemy.take_damage(damage_amount)
		enemy.apply_knockback(global_position, knockback_strenght)
		hit_enemies.set(area.get_rid(), true)


func can_hurt_area(area: Area2D) -> bool:
	var parent := area.get_parent()
	return (parent.is_in_group("enemies") 
			and not hit_enemies.has(area.get_rid()))
