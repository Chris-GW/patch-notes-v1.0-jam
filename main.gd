extends Node2D

@export var rotation_speed: float

@onready var godot_icon: TextureRect = $CanvasLayer/GodotIcon


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	godot_icon.rotation += rotation_speed * delta
