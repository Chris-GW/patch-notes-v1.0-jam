extends Node

@onready var main_menu_audio_player: AudioStreamPlayer = $MainMenuAudioPlayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	main_menu_audio_player.finished.connect(main_menu_audio_player.play)
