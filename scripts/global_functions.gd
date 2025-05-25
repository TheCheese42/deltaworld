extends Node

func _ready() -> void:
	DisplayServer.window_set_size(GlobalVars.options_save.window_size)
	DisplayServer.window_set_mode(GlobalVars.options_save.window_mode)
	@warning_ignore("return_value_discarded")
	get_tree().get_root().size_changed.connect(_resize)
	apply_options()
	await get_tree().create_timer(0.0).timeout
	get_tree().get_root().move_to_center()

func load_options() -> OptionsSave:
	var options: OptionsSave
	if not FileAccess.file_exists("user://saves/options.tres"):
		options = OptionsSave.new()
	else:
		options = load("user://saves/options.tres")
		if options == null:
			options = OptionsSave.new()
	return options

func apply_options() -> void:
	TranslationServer.set_locale(GlobalVars.options_save.language)
	for action: String in GlobalVars.options_save.keybinds:
		InputMap.action_erase_events(action)
		var event: InputEventKey = GlobalVars.options_save.keybinds[action]
		InputMap.action_add_event(action, event)

func save_options() -> void:
	var _err: Error = DirAccess.make_dir_absolute("user://saves")
	_err = ResourceSaver.save(GlobalVars.options_save, "user://saves/options.tres")

func reset_options() -> void:
	GlobalVars.options_save = OptionsSave.new()

func calc_velocity(speed: float, angle: float) -> Vector2:
	var x: int = round(speed * cos(deg_to_rad(angle)))
	var y: int = round(speed * sin(deg_to_rad(angle)))
	return Vector2(x, y)

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("fullscreen"):
		var mode: DisplayServer.WindowMode = DisplayServer.window_get_mode()
		if mode == DisplayServer.WINDOW_MODE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_size(GlobalVars.options_save.window_size)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		GlobalVars.options_save.window_mode = DisplayServer.window_get_mode()
		save_options()

func _resize() -> void:
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_WINDOWED:
		GlobalVars.options_save.window_size = DisplayServer.window_get_size()
