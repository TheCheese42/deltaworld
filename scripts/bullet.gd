extends Area2D
class_name Bullet

var speed: Vector2 = Vector2.ZERO
var remaining_penetration: int = 1


func init(bullet_speed: Vector2, rotation_deg: int, penetration: int, global_pos: Vector2) -> void:
	speed = bullet_speed
	rotation_degrees = rotation_deg
	remaining_penetration = penetration
	global_position = global_pos

func _process(_delta: float) -> void:
	global_position += speed * _delta


func _on_body_entered(_body: Node2D) -> void:
	queue_free()
