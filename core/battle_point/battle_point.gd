class_name BattlePoint
extends Area2D

signal battle_started(battle_point: BattlePoint)
signal battle_ended(battle_point: BattlePoint)


# same order as in BattleWaveResource.packed_enemy_counts()
var enemy_scenes: Array[PackedScene] = [
	preload("res://enemies/chaser_basic_duck.tscn"),
	preload("res://enemies/ranged_muscle_duck.tscn"),
	preload("res://enemies/teleporter_muscle_duck.tscn"),
	preload("res://enemies/tank_fat_duck.tscn"),
	preload("res://enemies/boss.tscn"),
]

@export var battle_waves: Array[BattleWaveResource] = []

var enemy_count := 0
var battle_wave_index := 0
var queued_enemies: Array[BaseEnemy] = []

@onready var delayed_battle_wave_timer: Timer = $DelayedBattleWaveTimer


func _ready() -> void:
	pass


func _process(_delta: float) -> void:
	if not queued_enemies.is_empty():
		work_enemy_queue()


func work_enemy_queue() -> void:
	var spawn_points := get_children().filter(func (child):
		return child is SpawnPoint and child.can_spawn())
	
	for spawn_point: SpawnPoint in spawn_points:
		if queued_enemies.is_empty():
			break
		var new_enemy: BaseEnemy = queued_enemies.pop_back()
		new_enemy.move_speed = randfn(new_enemy.move_speed, new_enemy.move_speed / 6.0)
		new_enemy.died.connect(_on_enemy_died)
		spawn_point.spawn(new_enemy)
		get_parent().add_child(new_enemy)
		enemy_count += 1


func _on_body_entered(body: Node2D) -> void:
	if body is Player and not is_completed():
		start_battle()


func start_battle() -> void:
	set_monitoring.call_deferred(false)
	battle_started.emit(self)
	var battle_wave := get_battle_wave(battle_wave_index)
	await get_tree().create_timer(maxf(battle_wave.delay_sec, 0.5)).timeout
	queue_battle_wave(battle_wave)
	start_next_delayed_wave_timer()


func _on_delayed_battle_wave_timer_timeout() -> void:
	if has_next_battle_wave():
		battle_wave_index += 1
		var next_battle_wave: BattleWaveResource = battle_waves[battle_wave_index]
		queue_battle_wave(next_battle_wave)
		start_next_delayed_wave_timer()


func _on_enemy_died() -> void:
	enemy_count -= 1
	if has_next_battle_wave():
		check_next_wave_threshold()
	if is_completed():
		end_battle()


func end_battle() -> void:
	battle_ended.emit(self)
	for child in get_children():
		if child is SpawnPoint:
			child.spawn_villager()


func check_next_wave_threshold() -> bool:
	var next_battle_wave := get_battle_wave(battle_wave_index + 1)
	if (enemy_count <= next_battle_wave.next_wave_threshold 
			and queued_enemies.is_empty()):
		battle_wave_index += 1
		queue_battle_wave(next_battle_wave)
		start_next_delayed_wave_timer()
		return true
	return false


func queue_battle_wave(battle_wave: BattleWaveResource) -> void:
	if not is_instance_valid(battle_wave):
		return
	var enemy_type_index := 0
	for whised_enemy_count in battle_wave.packed_enemy_counts():
		if enemy_type_index >= enemy_scenes.size() - 1:
			break
		var enemy_scene := enemy_scenes[enemy_type_index]
		for i in range(maxi(whised_enemy_count, 0)):
			var enemy: BaseEnemy = enemy_scene.instantiate()
			queued_enemies.append(enemy)
		enemy_type_index += 1
	queued_enemies.shuffle()


func start_next_delayed_wave_timer() -> bool:
	delayed_battle_wave_timer.stop()
	if has_next_battle_wave():
		var next_battle_wave = battle_waves[battle_wave_index + 1]
		if next_battle_wave.delay_sec > 0.001:
			delayed_battle_wave_timer.start(next_battle_wave.delay_sec)
			return true
	return false


func has_next_battle_wave() -> bool:
	return battle_wave_index + 1 < battle_waves.size()


func is_completed() -> bool:
	return (enemy_count <= 0 
		and queued_enemies.is_empty()
		and battle_wave_index >= battle_waves.size() - 1)


func get_battle_wave(index: int) -> BattleWaveResource:
	return battle_waves[index]
