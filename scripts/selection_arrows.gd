extends Node2D
class_name SelectionArrows

var _target: Control = null
var margin: int = 7
var time_between_blinks: float = 0.6
var _time_since_last_blink: float = 0
var offset_y: int = -1

var left_arrow: Sprite2D
var right_arrow: Sprite2D

func _ready() -> void:
	left_arrow = $LeftArrow
	right_arrow = $RightArrow

func set_target(target: Control) -> void:
	_target = target
	layout()

func layout() -> void:
	if not _target:
		return
	var left: float = _target.global_position.x - margin
	var right: float = _target.global_position.x + _target.size.x + margin
	left_arrow.global_position.x = left - left_arrow.get_rect().size.x / 2
	right_arrow.global_position.x = right + right_arrow.get_rect().size.x / 2
	left_arrow.global_position.y = _target.global_position.y + _target.size.y / 2 + offset_y
	right_arrow.global_position.y = left_arrow.global_position.y

func _process(delta: float) -> void:
	layout()
	if time_between_blinks <= 0.0:
		return
	_time_since_last_blink += delta
	if _time_since_last_blink >= time_between_blinks:
		_time_since_last_blink = 0
		left_arrow.visible = not left_arrow.visible
		right_arrow.visible = not right_arrow.visible
