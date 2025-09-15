extends Control


@onready var ending_music_player: AudioStreamPlayer = $EndingMusicPlayer


func _ready() -> void:
	fade_in_ending_music()


func fade_in_ending_music():
	var target_volume_db := ending_music_player.volume_db
	var tween := create_tween()
	tween.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
	tween.tween_property(ending_music_player, "volume_db", target_volume_db, 2.0)
	ending_music_player.volume_db = -80.0
	ending_music_player.play()


func _on_main_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://ui/main_menu.tscn")


func _on_ending_music_player_finished() -> void:
	ending_music_player.play()
