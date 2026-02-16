extends Area2D
class_name DroppedItem

@export var stats: Dictionary[String, float] = {}
@export var duration: float = 0.0
@export var texture: Texture2D
@onready var sprite_2d: Sprite2D = $Sprite2D

var active: bool = false
var remaining_duration: float = 0.0
var ignore_collisions: bool = false
var lying_on_ground: bool = false

var life_time: float = 15.0
var is_blinking: bool = false

func _ready() -> void:
	sprite_2d.texture = texture

func _on_body_entered(body: Node2D) -> void:
	if ignore_collisions:
		return
	if body.has_method("pickup_item"):
		lying_on_ground = false
		ignore_collisions = true
		body.call("pickup_item", self)

func _process(delta: float) -> void:
	if lying_on_ground:
		life_time -= delta
	if life_time <= 0:
		queue_free()
	if life_time <= 5 and not is_blinking:
		is_blinking = true
		_blink_down()
	if active:
		remaining_duration -= delta
		if remaining_duration < 0.0:
			queue_free()

func activate() -> void:
	# Sprite and collisions are no longer needed
	sprite_2d.visible = false
	ignore_collisions = true
	active = true
	remaining_duration = duration

func _blink_down() -> void:
	var tween: Tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "modulate", Color(1.0, 1.0, 1.0, 0.4), 0.5)
	await tween.finished
	_blink_up()

func _blink_up() -> void:
	var tween: Tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.5)
	await tween.finished
	_blink_down()
