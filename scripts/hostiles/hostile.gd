extends RigidBody2D
class_name Hostile

var player_node: Node2D

@export var base_health: int = 1
var health: int = 1
@export var base_speed: float = 1.0


func init(player: Node2D) -> void:
	player_node = player

func init_stats() -> void:
	health = base_health

func final_velocity() -> float:
	return base_speed * 50

func hit(damage: int) -> void:
	health -= damage
	if health <= 0:
		die()

func die() -> void:
	queue_free()
	# TODO drop table
