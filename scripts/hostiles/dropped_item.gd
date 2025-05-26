extends Area2D
class_name DroppedItem

@export var stats: Dictionary[String, float] = {}
@export var duration: float = 0.0
@export var texture: Texture2D
@onready var _sprite_2d: Sprite2D = $Sprite2D

var active: bool = false
var remaining_duration: float = 0.0

func _ready() -> void:
	_sprite_2d.texture = texture

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("pickup_item"):
		remove_child($CollisionShape2D)
		body.call("pickup_item", self)

func _process(delta: float) -> void:
	if active:
		remaining_duration -= delta
		if remaining_duration < 0.0:
			queue_free()

func activate() -> void:
	# Sprite and hitbox are no longer needed
	remove_child(_sprite_2d)
	remove_child($CollisionShape2D)
	active = true
	remaining_duration = duration
