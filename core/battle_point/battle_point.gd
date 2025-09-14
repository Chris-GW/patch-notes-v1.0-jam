class_name BattlePoint
extends Node2D

signal battle_started(battle_point: BattlePoint)
signal battle_ended(battle_point: BattlePoint)

const CHASER_ENEMY: PackedScene = preload("res://enemies/chaser_enemy.tscn")

@export var enemy_wave := 3

@onready var wave_spawn_timer: Timer = $WaveSpawnTimer
@onready var spawn_points: Node2D = $SpawnPoints


func _ready() -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	if body is Player and wave_spawn_timer.is_stopped():
		start_battle()


func start_battle() -> void:
	wave_spawn_timer.start()
	battle_started.emit(self)


func _on_wave_spawn_timer_timeout() -> void:
	for spawn_point: Node2D in spawn_points.get_children():
		var new_enemy: BaseEnemy = CHASER_ENEMY.instantiate()
		new_enemy.global_position = spawn_point.global_position
		new_enemy.move_speed = randfn(new_enemy.move_speed, new_enemy.move_speed / 6.0)
		get_parent().add_child(new_enemy)
	
	enemy_wave = maxi(enemy_wave - 1, 0)
	if enemy_wave <= 0:
		battle_ended.emit(self)
		queue_free()
