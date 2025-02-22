extends RigidBody2D
class_name Zombie

@export var movement_speed: float = 30.0
@onready var navigation_agent: NavigationAgent2D = get_node("NavigationAgent2D")
var movement_delta: float


func _ready() -> void:
	@warning_ignore("return_value_discarded")
	navigation_agent.velocity_computed.connect(Callable(_on_velocity_computed))

func set_movement_target(movement_target: Vector2) -> void:
	navigation_agent.set_target_position(movement_target)

func _physics_process(delta: float) -> void:
	# Do not query when the map has never synchronized and is empty.
	if NavigationServer2D.map_get_iteration_id(navigation_agent.get_navigation_map()) == 0:
		return
	if navigation_agent.is_navigation_finished():
		return

	movement_delta = movement_speed * delta
	var next_path_position: Vector2 = navigation_agent.get_next_path_position()
	var new_velocity: Vector2 = global_position.direction_to(next_path_position) * movement_delta
	if navigation_agent.avoidance_enabled:
		navigation_agent.set_velocity(new_velocity)
	else:
		_on_velocity_computed(new_velocity)

func _process(_delta: float) -> void:
	@warning_ignore("return_value_discarded")
	move_and_collide(linear_velocity)

func _on_velocity_computed(safe_velocity: Vector2) -> void:
	#global_position = global_position.move_toward(global_position + safe_velocity, movement_delta)
	linear_velocity = safe_velocity
