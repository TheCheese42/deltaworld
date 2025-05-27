extends Area2D
class_name DroppedItem

@export var stats: Dictionary[String, float] = {}
@export var duration: float = 0.0
@export var texture: Texture2D
@onready var sprite_2d: Sprite2D = $Sprite2D

var active: bool = false
var remaining_duration: float = 0.0
var ignore_collisions: bool = false

func _ready() -> void:
	sprite_2d.texture = texture

func _on_body_entered(body: Node2D) -> void:
	if ignore_collisions:
		return
	if body.has_method("pickup_item"):
		ignore_collisions = true
		body.call("pickup_item", self)

func _process(delta: float) -> void:
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
