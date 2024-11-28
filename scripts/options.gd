extends CanvasLayer

var _selection_arrows: SelectionArrows
var _entries: Array[Control]
var _selected_entry: Control
var _options_disabled: bool = false

var rebind_scene: PackedScene = load("res://scenes/control_rebind.tscn")


func _ready() -> void:
	_selection_arrows = find_child("SelectionArrows")
	_selection_arrows.scale = Vector2(0.5, 0.5)
	_selection_arrows.margin = 5
	_selection_arrows.time_between_blinks = 0.0
	_entries = [
		find_child("LanguageDisplay"),
		find_child("VolumeDisplay"),
		find_child("MoveUpBox"),
		find_child("MoveDownBox"),
		find_child("MoveLeftBox"),
		find_child("MoveRightBox"),
		find_child("ShootUpBox"),
		find_child("ShootDownBox"),
		find_child("ShootLeftBox"),
		find_child("ShootRightBox"),
		find_child("UseItemBox"),
		find_child("BackLabel"),
	]
	_selected_entry = _entries[0]
	_selection_arrows.set_target(_selected_entry)
	update_displays()

func _input(event: InputEvent) -> void:
	if _options_disabled:
		return
	if event.is_action_pressed("back"):
		_quit()
	if event.is_action_pressed("up"):
		var cur_idx: int = _entries.find(_selected_entry)
		var new_entry: Control
		while true:
			cur_idx -= 1
			new_entry = _entries[cur_idx]
			if new_entry.visible:
				break
		_selected_entry = new_entry
		_selection_arrows.set_target(_selected_entry)
	elif event.is_action_pressed("down"):
		var cur_idx: int = _entries.find(_selected_entry)
		var new_entry: Control
		while true:
			cur_idx += 1
			if cur_idx >= len(_entries):
				cur_idx = 0
			new_entry = _entries[cur_idx]
			if new_entry.visible:
				break
		_selected_entry = new_entry
		_selection_arrows.set_target(_selected_entry)
	elif event.is_action_pressed("left"):
		_dispatch_entry_action(_selected_entry, "left")
	elif event.is_action_pressed("right"):
		_dispatch_entry_action(_selected_entry, "right")
	elif event.is_action_pressed("select"):
		_dispatch_entry_action(_selected_entry, "select")

func _dispatch_entry_action(entry: Control, type: String) -> void:
	if entry == find_child("LanguageDisplay"):
		var langs: PackedStringArray = TranslationServer.get_loaded_locales()
		var current_lang: String = TranslationServer.get_locale()
		var current_index: int = langs.find(current_lang)
		if type == "left":
			TranslationServer.set_locale(langs[current_index - 1])
		elif type == "right":
			var new_index: int = current_index + 1
			if new_index >= len(langs):
				new_index = 0
			TranslationServer.set_locale(langs[new_index])
	elif entry == find_child("VolumeDisplay"):
		var add: int = 2
		if Input.is_key_pressed(KEY_SHIFT):
			add = 10
		if type == "left":
			GlobalVars.options_save.volume = clamp(GlobalVars.options_save.volume - add, 0, 100)
		if type == "right":
			GlobalVars.options_save.volume = clamp(GlobalVars.options_save.volume + add, 0, 100)
	elif entry.has_meta("control_name"):
		var action: String = entry.get_meta("control_name")
		_rebind_control(action)
	elif entry == find_child("BackLabel") and type == "select":
		_quit()
	update_displays()

func _rebind_control(action: String) -> void:
	var control_rebind: CanvasLayer = rebind_scene.instantiate()
	@warning_ignore("unsafe_method_access")
	control_rebind.init(action)
	add_child(control_rebind)
	_options_disabled = true

func set_options_enabled(enabled: bool = true) -> void:
	_options_disabled = not enabled

func update_displays() -> void:
	var volume_display: Label = find_child("VolumeDisplay")
	volume_display.text = str(GlobalVars.options_save.volume)
	for entry: Control in _entries:
		if is_instance_of(entry, HBoxContainer) and entry.has_meta("control_name"):
			var action: String = entry.get_meta("control_name")
			var display: Label = entry.find_child("*Display")
			if GlobalVars.options_save.keybinds.has(action):
				var event: InputEventKey = GlobalVars.options_save.keybinds[action]
				display.text = event.as_text()

func _quit() -> void:
	await get_tree().create_timer(0.01).timeout
	get_tree().call_group("main_menu", "set_main_menu_enabled", true)
	GlobalFunctions.save_options()
	queue_free()
