class_name BattleWaveResource
extends Resource

@export var delay_sec := 0.0
@export var next_wave_threshold := 0

@export var chaser_count := 0
@export var teleporter_count := 0
@export var ranged_count := 0
@export var tank_count := 0
@export var boss_count := 0


func packed_enemy_counts() -> Array[int]:
	return [
		chaser_count,
		teleporter_count,
		ranged_count,
		tank_count,
		boss_count,
	]
