extends Node2D

var current_dimension: int = 1
var current_room: int = 1
var current_map: Node2D
@onready var player: CharacterBody2D = $Player
@onready var maps: Node2D = $Maps
@onready var navigation_region_2d: GameNavRegion = $NavigationRegion2D
@onready var center: Marker2D = $Center

var hostile_scene: PackedScene = load("res://scenes/hostiles.tscn")
var hostile_instance: Node2D = hostile_scene.instantiate()

func _ready() -> void:
	_new_room()

func _new_room() -> void:
	var level_str: String = "d%dr%d" % [current_dimension, current_room]
	current_map = maps.find_child(level_str).duplicate()
	remove_child(maps)
	_init_map()
	player.global_position = center.global_position
	var level: Level = Level.new(level_str)
	await get_tree().create_timer(3.0).timeout
	for i: int in len(level.waves):
		var wave: Level.Wave = level.next_wave()
		# TODO Spawn Mobs

func _init_map() -> void:
	for child: Node2D in navigation_region_2d.get_children():
		child.queue_free()
	navigation_region_2d.add_child(current_map)
	navigation_region_2d.init_nav_region()
