class_name BattlePoint
extends Area2D

signal battle_started(battle_point: BattlePoint)
signal battle_ended(battle_point: BattlePoint)

var enemy_scenes: Array[PackedScene] = [
	preload("res://enemies/chaser_basic_duck.tscn"),
	preload("res://enemies/ranged_muscle_duck.tscn"),
	preload("res://enemies/teleporter_muscle_duck.tscn"),
	preload("res://enemies/tank_fat_duck.tscn"),
	#preload("res://enemies/boss.tscn"),
]

@export var enemy_wave: int

var enemy_count := 0

@onready var wave_spawn_timer: Timer = $WaveSpawnTimer


func _ready() -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	if body is Player and not is_completed():
		start_battle()


func start_battle() -> void:
	wave_spawn_timer.start()
	set_monitoring.call_deferred(false)
	battle_started.emit(self)


func _on_wave_spawn_timer_timeout() -> void:
	for spawn_point in get_children():
		if spawn_point is SpawnPoint and spawn_point.can_spawn():
			spawn_enemy(spawn_point)
	
	enemy_wave = maxi(enemy_wave - 1, 0)
	if enemy_wave <= 0:
		wave_spawn_timer.stop()


func spawn_enemy(spawn_point: SpawnPoint) -> void:
	var new_enemy: BaseEnemy = enemy_scenes.pick_random().instantiate()
	new_enemy.move_speed = randfn(new_enemy.move_speed, new_enemy.move_speed / 6.0)
	new_enemy.died.connect(_on_enemy_died)
	spawn_point.spawn(new_enemy)
	get_parent().add_child(new_enemy)
	enemy_count += 1


func _on_enemy_died() -> void:
	enemy_count -= 1
	if is_completed():
		for child in get_children():
			if child is SpawnPoint:
				child.spawn_villager()
		battle_ended.emit(self)


func is_completed() -> bool:
	return enemy_count <= 0 and enemy_wave <= 0
