extends Area2D
class_name Bullet

var speed: Vector2 = Vector2.ZERO
var remaining_penetration: int
var damage: int
var map_rectangle: Rect2


func init(
	bullet_speed: Vector2,
	rotation_deg: int,
	penetration: int,
	bullet_damage: int,
	global_pos: Vector2,
	map_rect: Rect2,
) -> void:
	speed = bullet_speed
	rotation_degrees = rotation_deg
	remaining_penetration = penetration
	damage = bullet_damage
	global_position = global_pos
	map_rectangle = map_rect

func _process(_delta: float) -> void:
	global_position += speed * _delta

	if (
		global_position.x < map_rectangle.position.x
		or global_position.y < map_rectangle.position.y
		or global_position.x > map_rectangle.end.x
		or global_position.y > map_rectangle.end.y
	):
		queue_free()

func _on_area_entered(body: Node2D) -> void:
	if body.get_parent().has_method("hit") and remaining_penetration > 0:
		body.get_parent().call("hit", damage)
	remaining_penetration -= 1
	if remaining_penetration <= 0:
		queue_free()
