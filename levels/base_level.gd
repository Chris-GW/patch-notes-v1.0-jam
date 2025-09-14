extends Node2D

@onready var player: Player = %Player
@onready var player_camera: Camera2D = %PlayerCamera2D

@onready var y_sort_root: Node2D = %YSortRoot

@onready var health_bar: ProgressBar = %HealthBar
@onready var dash_charges_label: Label = %DashChargesLabel

@onready var ground_tile_map_layer: TileMapLayer = %GroundTileMapLayer
@onready var floor_tile_map_layer: TileMapLayer = %FloorTileMapLayer
@onready var decoration_tile_map_layer: TileMapLayer = %DecorationTileMapLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%DiedPanelContainer.visible = false
	health_bar.max_value = player.max_health
	health_bar.value = player.max_health


func _process(_delta: float) -> void:
	dash_charges_label.text = "Dash charges: %d / %d" % [player.dash_charges, player.max_dash_charges]


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
