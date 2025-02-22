extends Node2D

var player: CharacterBody2D
var current_map: Node2D
var maps: Node2D

var hostile_scene: PackedScene = load("res://scenes/hostiles.tscn")
var hostile_instance: Node2D = hostile_scene.instantiate()

func _ready() -> void:
	player = $Player
	maps = $NavigationRegion2D/Maps
	current_map = maps.find_child("d1r1").duplicate()
	remove_child(maps)
	add_child(current_map)

	var center: Marker2D = $Center
	player.global_position = center.global_position

	var zombie: Zombie = hostile_instance.find_child("Zombie").duplicate()
	add_child(zombie)
	zombie.global_position = player.global_position - Vector2(80, 80)
	zombie.set_movement_target(player.global_position)
	var zombie2: Zombie = hostile_instance.find_child("Zombie").duplicate()
	add_child(zombie2)
	zombie2.global_position = player.global_position - Vector2(90, 80)
	zombie2.set_movement_target(player.global_position)
	zombie2.movement_speed = 45
