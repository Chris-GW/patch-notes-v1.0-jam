extends Node


var levels := [
	"res://levels/level_01.tscn",
	"res://levels/level_02.tscn",
	"res://levels/level_03.tscn",
	"res://levels/level_04.tscn",
	#"res://levels/level_05.tscn",
	"res://ui/finish_screen.tscn",
]
var level_index := 0

@onready var menu_music_player: AudioStreamPlayer = $MenuMusicPlayer


func _ready() -> void:
	pass


func change_next_level() -> void:
	level_index = clampi(level_index + 1, 0, levels.size() - 1)
	var next_level_file: String = levels[level_index]
	get_tree().change_scene_to_file(next_level_file)


func play_menu_music() -> void:
	if menu_music_player.playing:
		return
	menu_music_player.play()
	var tween := create_tween()
	tween.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(menu_music_player, "volume_db", 0.0, 0.5).from(-60.0)


func stop_menu_music() -> void:
	var tween := create_tween()
	tween.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(menu_music_player, "volume_db", -60.0, 0.5).from(0.0)
	tween.tween_callback(menu_music_player.stop)


func _on_menu_music_player_finished() -> void:
	menu_music_player.play()
