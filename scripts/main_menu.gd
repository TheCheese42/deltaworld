extends CanvasLayer

var _selection_arrows: SelectionArrows
var _start_game_label: Label
var _load_game_label: Label
var _options_label: Label
var _quit_label: Label

var _selected_entry: Label
var _ordered_labels: Array[Label]

var _main_menu_disabled: bool = false

var _options_scene: PackedScene = load("res://scenes/options.tscn")
var _achievements_scene: PackedScene = load("res://scenes/achievements.tscn")
var _fade_scene: PackedScene = load("res://scenes/fade.tscn")


func _ready() -> void:
	GlobalFunctions.apply_options()
	_selection_arrows = find_child("SelectionArrows")
	_start_game_label = find_child("StartGameLabel")
	_load_game_label = find_child("LoadGameLabel")
	_options_label = find_child("OptionsLabel")
	_quit_label = find_child("QuitLabel")
	_selection_arrows.set_target(_start_game_label)
	_selected_entry = _start_game_label
	_ordered_labels = [_start_game_label, _load_game_label, _options_label, _quit_label]

func _input(event: InputEvent) -> void:
	if _main_menu_disabled:
		return
	if event.is_action_pressed("up"):
		var cur_idx: int = _ordered_labels.find(_selected_entry)
		var new_label: Label
		while true:
			cur_idx -= 1
			new_label = _ordered_labels[cur_idx]
			if new_label.visible:
				break
		_selected_entry = new_label
		_selection_arrows.set_target(_selected_entry)
	elif event.is_action_pressed("down"):
		var cur_idx: int = _ordered_labels.find(_selected_entry)
		var new_label: Label
		while true:
			cur_idx += 1
			if cur_idx >= len(_ordered_labels):
				cur_idx = 0
			new_label = _ordered_labels[cur_idx]
			if new_label.visible:
				break
		_selected_entry = new_label
		_selection_arrows.set_target(_selected_entry)
	elif event.is_action_pressed("select"):
		_dispatch_entry_action(_selected_entry)
	elif event.is_action_pressed("achievements"):
		_open_achievements()
		_main_menu_disabled = true

func _dispatch_entry_action(entry: Label) -> void:
	if entry == _start_game_label:
		_start_game()
	elif entry == _load_game_label:
		_load_game()
	elif entry == _options_label:
		_open_options()
		_main_menu_disabled = true
	elif entry == _quit_label:
		_quit()

func _quit() -> void:
	GlobalFunctions.save_options()
	get_tree().quit(0)

func _start_game() -> void:
	var fade_instance: Fade = _fade_scene.instantiate()
	fade_instance.duration = 0.5
	add_child(fade_instance)
	await fade_instance.half_reached
	@warning_ignore("return_value_discarded")
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _load_game() -> void:
	pass

func _open_options() -> void:
	var options_instance: CanvasLayer = _options_scene.instantiate()
	self.add_child(options_instance)

func set_main_menu_enabled(enabled: bool = true) -> void:
	_main_menu_disabled = not enabled

func _open_achievements() -> void:
	var achievements_instance: CanvasLayer = _achievements_scene.instantiate()
	self.add_child(achievements_instance)
