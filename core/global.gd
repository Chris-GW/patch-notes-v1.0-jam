extends Node

@onready var main_menu_audio_player: AudioStreamPlayer = $MainMenuAudioPlayer

var levels := [
	"res://levels/level_01.tscn",
	"res://levels/level_02.tscn"
]
var level_index := 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	main_menu_audio_player.finished.connect(main_menu_audio_player.play)
