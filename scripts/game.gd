extends Node2D

var player: CharacterBody2D
const PLAYER_SPEED: int = 60
var current_map: Node2D
var maps: Node2D

func _ready() -> void:
	player = $Player
	maps = $Maps
	current_map = maps.find_child("d1r1").duplicate()
	remove_child(maps)
	add_child(current_map)

	var center: Marker2D = $Center
	player.global_position = center.global_position

func _process(_delta: float) -> void:
	var velocity: Vector2i = Vector2i.ZERO
	if Input.is_action_pressed("move_down"):
		velocity.y += PLAYER_SPEED
	if Input.is_action_pressed("move_up"):
		velocity.y -= PLAYER_SPEED
	if Input.is_action_pressed("move_left"):
		velocity.x -= PLAYER_SPEED
	if Input.is_action_pressed("move_right"):
		velocity.x += PLAYER_SPEED
	player.velocity = velocity
	@warning_ignore("return_value_discarded")
	player.move_and_slide()
