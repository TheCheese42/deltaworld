extends CanvasLayer
class_name ControlRebind

var _action: String
var _released_select: bool = false

func init(action: String) -> void:
	_action = action

func _input(event: InputEvent) -> void:
	if event is not InputEventKey:
		return
	if event.is_action("select") and event.is_released() and not _released_select:
		_released_select = true
		return
	if event.is_action("select") and not _released_select:
		return
	if not event.as_text().contains("Escape"):
		GlobalVars.options_save.keybinds[_action] = event
	await get_tree().create_timer(0.01).timeout
	get_tree().call_group("options", "set_options_enabled", true)
	get_tree().call_group("options", "update_displays")
	queue_free()
