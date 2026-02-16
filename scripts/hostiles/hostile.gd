extends RigidBody2D
class_name Hostile

var player_node: Node2D

@export var base_health: int = 1
var health: int = 1
@export var base_speed: float = 1.0

@onready var drops: Node2D = $Drops
var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var drop_rate: float = 0.1
@export var drop_table: Dictionary[String, int] = {
	"SemiAutomatic": 3,
	"Scope": 3,
	"BlueCow": 3,
	"Spray": 3,
	"ThreeSixty": 3,
	"Pressurer": 1,
	"HolyGuard": 1,
	"SmokeBomb": 1,
	"LaserBeam": 1 if GlobalVars.options_save.game_completed_hard else 0,
	"ResurrectionCoin": 1,
}


func random_drop() -> String:
	return drop_table.keys()[rng.rand_weighted(drop_table.values())]

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
	if rng.randf() < drop_rate:
		var drop: String = random_drop()
		get_tree().call_group("game", "drop_item", drop, global_position)
	queue_free()
