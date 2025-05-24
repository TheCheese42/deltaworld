extends Node2D

var current_map: Node2D
@onready var player: CharacterBody2D = $Player
@onready var maps: Node2D = $Maps
@onready var navigation_region_2d: GameNavRegion = $NavigationRegion2D
@onready var center: Marker2D = $Center

var hostile_scene: PackedScene = load("res://scenes/hostiles.tscn")
var hostile_instance: Node2D = hostile_scene.instantiate()

func _ready() -> void:
	current_map = maps.find_child("d1r1").duplicate()
	remove_child(maps)
	_init_map()

	player.global_position = center.global_position

func _init_map() -> void:
	for child: Node2D in navigation_region_2d.get_children():
		child.queue_free()
	navigation_region_2d.add_child(current_map)
	navigation_region_2d.init_nav_region()
