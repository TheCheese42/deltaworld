@tool
extends Resource
class_name OptionsSave


func _init() -> void:
	version = JSON.parse_string(FileAccess.get_file_as_string("res://version.json"))

@export var language: String = OS.get_locale_language()
@export var volume: int = 100
@export var keybinds: Dictionary = {
	"move_up": InputMap.action_get_events("move_up")[0],
	"move_down": InputMap.action_get_events("move_down")[0],
	"move_left": InputMap.action_get_events("move_left")[0],
	"move_right": InputMap.action_get_events("move_right")[0],
	"shoot_up": InputMap.action_get_events("shoot_up")[0],
	"shoot_down": InputMap.action_get_events("shoot_down")[0],
	"shoot_left": InputMap.action_get_events("shoot_left")[0],
	"shoot_right": InputMap.action_get_events("shoot_right")[0],
	"use_item": InputMap.action_get_events("use_item")[0],
}
@export var achievement_lawyer: bool = false
@export var achievement_not_bug_feature: bool = false
@export var achievement_poor_spectre: bool = false
@export var achievement_unique_playstyle: bool = false

@export var window_mode: DisplayServer.WindowMode = DisplayServer.WINDOW_MODE_FULLSCREEN
@export var window_size: Vector2 = Vector2(480, 270)

var version: Array = JSON.parse_string(FileAccess.get_file_as_string("res://version.json"))
