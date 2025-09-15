extends PanelContainer


@export var visible_notifier: VisibleOnScreenNotifier2D

var fade_tween: Tween


func _ready() -> void:
	visible = false
	visible_notifier.screen_entered.connect(_on_screen_entered)
	visible_notifier.screen_exited.connect(_on_screen_exited)


func _on_screen_entered() -> void:
	visible = true
	if is_instance_valid(fade_tween):
		fade_tween.kill()
	fade_tween = create_tween()
	fade_tween.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	fade_tween.tween_property(self, "modulate:a", 1.0, 0.3)


func _on_screen_exited() -> void:
	if is_instance_valid(fade_tween):
		fade_tween.kill()
	fade_tween = create_tween()
	fade_tween.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	fade_tween.tween_property(self, "modulate:a", 0.0, 0.3)
	fade_tween.chain().tween_callback(set_visible.bind(true))
