extends Node


var levels := [
	"res://levels/level_01.tscn",
	"res://levels/level_02.tscn",
	"res://levels/level_03.tscn",
	"res://levels/level_04.tscn",
	"res://levels/level_05.tscn",
]
var level_index := 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


func change_next_level() -> void:
	level_index = clampi(level_index + 1, 0, levels.size() - 1)
	var next_level_file: String = levels[level_index]
	get_tree().change_scene_to_file(next_level_file)
