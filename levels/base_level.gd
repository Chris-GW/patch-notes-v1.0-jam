class_name BaseLevel
extends Node2D

var current_battle_point: BattlePoint

@onready var nutral_music_player: AudioStreamPlayer = $NutralMusicPlayer
@onready var battle_music_player: AudioStreamPlayer = $BattleMusicPlayer
@onready var level_end_audio_player: AudioStreamPlayer = $LevelEndAudioPlayer

@onready var player: Player = %Player
@onready var player_camera: Camera2D = %PlayerCamera2D

@onready var health_bar: ProgressBar = %HealthBar
@onready var dash_charges_label: Label = %DashChargesLabel
@onready var wave_label: Label = %WaveLabel
@onready var enemies_left_label: Label = %EnemiesLeftLabel

@onready var y_sort_root: Node2D = %YSortRoot
@onready var ground_tile_map_layer: TileMapLayer = %GroundTileMapLayer
@onready var floor_tile_map_layer: TileMapLayer = %FloorTileMapLayer
@onready var decoration_tile_map_layer: TileMapLayer = %DecorationTileMapLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.stop_menu_music()
	%DiedPanelContainer.visible = false
	%LevelCompletedPanelContainer.visible = false
	%GamePausedUI.visible = false
	wave_label.visible = false
	enemies_left_label.visible = false
	health_bar.max_value = player.max_health
	health_bar.value = player.max_health
	
	for battle_point: BattlePoint in get_tree().get_nodes_in_group("battle_points"):
		battle_point.battle_started.connect(_on_battle_started)
		battle_point.battle_ended.connect(_on_battle_ended)


func _process(_delta: float) -> void:
	dash_charges_label.text = "Dash charges: %d / %d" % [player.dash_charges, player.max_dash_charges]
	if is_instance_valid(current_battle_point):
		wave_label.text = "Wave %d / %d" % [
				current_battle_point.battle_wave_index + 1, 
				current_battle_point.battle_waves.size()]
		enemies_left_label.text = "Enemies %d" % current_battle_point.enemy_count


func _on_battle_started(battle_point: BattlePoint) -> void:
	current_battle_point = battle_point
	wave_label.visible = true
	enemies_left_label.visible = true
	battle_music_player.play()
	var tween := create_tween()
	tween.set_parallel(true)
	tween.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(battle_music_player, "volume_db", 0.0, 1.0).from(-60.0)
	tween.tween_property(nutral_music_player, "volume_db", -60.0, 1.0).set_delay(0.5)
	tween.chain().tween_callback(nutral_music_player.stop)


func _on_battle_ended(_battle_point: BattlePoint) -> void:
	current_battle_point = null
	nutral_music_player.play()
	var tween := create_tween()
	tween.set_parallel(true)
	tween.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(nutral_music_player, "volume_db", 0.0, 1.0).from(-60.0)
	tween.tween_property(battle_music_player, "volume_db", -60.0, 1.0).set_delay(0.5)
	tween.chain().tween_callback(battle_music_player.stop)
	
	if is_level_complete():
		complete_level()


func is_level_complete() -> bool:
	for battle_point: BattlePoint in get_tree().get_nodes_in_group("battle_points"):
		if not battle_point.is_completed():
			return false
	return true


func complete_level() -> void:
	level_end_audio_player.play()
	%LevelCompletedPanelContainer.visible = true


func _on_player_damage_taken() -> void:
	health_bar.value = player.health

func _on_player_heal_taken() -> void:
	health_bar.value = player.health


func _on_player_died() -> void:
	get_tree().paused = true
	%DiedPanelContainer.visible = true


func _on_restart_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(self.scene_file_path)


func _on_nutral_music_player_finished() -> void:
	nutral_music_player.play()


func _on_battle_music_player_finished() -> void:
	battle_music_player.play()


func _on_next_level_button_pressed() -> void:
	Global.change_next_level()
