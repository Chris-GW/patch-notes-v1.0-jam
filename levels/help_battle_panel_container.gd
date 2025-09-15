extends PanelContainer


@export var visible_notifier: VisibleOnScreenNotifier2D
@export var battle_point: BattlePoint

var fade_tween: Tween


func _ready() -> void:
	visible = false
	visible_notifier.screen_entered.connect(_on_screen_entered)
	visible_notifier.screen_exited.connect(_on_screen_exited)
	battle_point.battle_started.connect(_on_battle_started)


func _on_battle_started(_battle_point: BattlePoint) -> void:
	visible_notifier.screen_entered.disconnect(_on_screen_entered)
	visible_notifier.queue_free()
	await get_tree().create_timer(2.0).timeout
	_on_screen_exited()
	await get_tree().create_timer(1.0).timeout
	queue_free()


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
