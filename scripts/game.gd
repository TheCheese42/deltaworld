extends Node2D

var current_dimension: int = 1
var current_room: int = 1
var current_map: Node2D
var room_done: bool = false
@onready var player: Player = $Player
@onready var maps: Node2D = $Maps
@onready var spawn_void_layer: TileMapLayer = $SpawnVoid
@onready var navigation_region_2d: GameNavRegion = $NavigationRegion2D
@onready var center: Marker2D = $Center
@onready var top_left: Marker2D = $TopLeft
@onready var bottom_right: Marker2D = $BottomRight
@onready var room_display: Label = $CanvasLayer/Control/RoomDisplay
@onready var mobs: Node2D = $Mobs
@onready var item_frame: TileMapLayer = $Misc/ItemFrame
@onready var res_coin_label: Label = $Misc/ResCoin/ResCoinLabel
@onready var progress_bar: ColorRect = $CanvasLayer/Control2/ProgressBar

var current_level: Level = null
var current_level_duration: float = 0.0
var current_level_progress: float = 0.0
var current_wave: Level.Wave = null
var current_wave_progress: float = 0.0

var rng: RandomNumberGenerator = RandomNumberGenerator.new()

var _hostile_scene: PackedScene = load("res://scenes/hostiles.tscn")
var _hostile_instance: Node2D = _hostile_scene.instantiate()
var _fade_scene: PackedScene = load("res://scenes/fade.tscn")
var _beam_scene: PackedScene = load("res://scenes/light_beam.tscn")


func _ready() -> void:
	var fade_instance: Fade = _fade_scene.instantiate()
	fade_instance.skip_to_second_half = true
	fade_instance.immediately_full_alpha = true
	fade_instance.duration = 0.5
	add_child(fade_instance)

	mobs.child_order_changed.connect(_mobs_changed)

	player.map_rect = Rect2(
		top_left.global_position,
		bottom_right.global_position - top_left.global_position
	)
	_new_room()

func _new_room() -> void:
	player.frozen = true
	room_done = false
	var level_str: String = "d%dr%d" % [current_dimension, current_room]
	current_map = maps.find_child(level_str).duplicate()
	remove_child(maps)
	_init_map()

	player.modulate.a = 0.0
	room_display.modulate.a = 0.0
	await get_tree().create_timer(1.0).timeout
	var current_dimension_str: String = (
		str(current_dimension) if current_dimension != 4 else tr("DELTAWORLD")
	)
	var current_room_str: String = str(current_room) if current_room != 5 else tr("BOSS")
	room_display.text = tr("ROOM_DISPLAY") % [current_dimension_str, current_room_str]
	var tween: Tween = create_tween()
	var target_color: Color = room_display.modulate
	target_color.a = 1.0
	tween.tween_property(room_display, "modulate", target_color, 0.4)
	await tween.finished
	await get_tree().create_timer(2.0).timeout
	tween = create_tween()
	target_color = room_display.modulate
	target_color.a = 0.0
	tween.tween_property(room_display, "modulate", target_color, 0.4)
	await tween.finished
	await get_tree().create_timer(0.5).timeout
	tween = create_tween()
	target_color = player.modulate
	target_color.a = 1.0
	tween.tween_property(player, "modulate", target_color, 0.1)
	player.global_position = center.global_position
	await tween.finished
	player.frozen = false

	await get_tree().create_timer(2.0).timeout
	current_level = Level.new(level_str)
	current_level_progress = 0.0
	current_level_duration = 0.0
	for wave: Array in current_level.waves:
		current_level_duration += wave[1]

func _process(delta: float) -> void:
	if GlobalVars.halted:
		return

	if not current_level or room_done:
		progress_bar.visible = false
		return

	current_wave_progress += delta
	current_level_progress += delta
	progress_bar.visible = true
	progress_bar.color = Color(0.224, 0.698, 0.133).lerp(
		Color(0.784, 0.078, 0.0), clampf(
			current_level_progress / current_level_duration - 0.7, 0.0, 1.0
		)
	)
	progress_bar.size.x = lerpf(240.0, 0.0, current_level_progress / current_level_duration)

	if not current_wave or current_wave.duration <= current_wave_progress:
		current_wave_progress = 0.0
		if current_level.current_wave >= len(current_level.waves):
			room_done = true
			return
		current_wave = current_level.next_wave()
		for mob_str: String in current_wave.mobs:
			var cells: Array[Vector2i] = spawn_void_layer.get_used_cells()
			var cell: Vector2i = cells[rng.randi_range(0, len(cells) - 1)]
			var mob: Hostile = _hostile_instance.find_child(mob_str).duplicate()
			mob.init(player)
			mobs.add_child(mob)
			mob.position = spawn_void_layer.map_to_local(cell) / 2

func _init_map() -> void:
	for child: Node2D in navigation_region_2d.get_children():
		child.queue_free()
	navigation_region_2d.add_child(current_map)
	navigation_region_2d.init_nav_region()

func _post_room() -> void:
	await get_tree().create_timer(2.0).timeout
	if current_room in [2, 4]:
		_setup_shop()
	else:
		_beam_to_next_room()

func _setup_shop() -> void:
	# TODO Shop
	_beam_to_next_room()

func _beam_to_next_room() -> void:
	await get_tree().create_timer(1.5).timeout
	player.frozen = true
	var beam_instance: LightBeam = _beam_scene.instantiate()
	add_child(beam_instance)
	beam_instance.global_position = player.global_position + Vector2(0, 16)
	beam_instance.start_setup()
	await beam_instance.setup_finished
	await get_tree().create_timer(0.5).timeout
	var tween: Tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	var target_position: Vector2 = player.global_position - Vector2(0, 40)
	tween.tween_property(player, "global_position", target_position, 2.0)
	await get_tree().create_timer(1.0).timeout
	beam_instance.z_index = 5
	beam_instance.start_beam()
	await beam_instance.beam_finished
	await get_tree().create_timer(0.5).timeout
	var fade_instance: Fade = _fade_scene.instantiate()
	fade_instance.duration = 0.5
	add_child(fade_instance)
	await fade_instance.half_reached
	_new_room()

func _mobs_changed() -> void:
	if room_done and len(mobs.get_children()) == 1:  # 1 Because of items
		_post_room()

func store_item(item: DroppedItem) -> void:
	item.position = item_frame.map_to_local(item_frame.get_used_cells()[0]) + Vector2(1, 1)

func update_res_coins_label(count: int) -> void:
	res_coin_label.text = tr("COINS_DISPLAY") % count

func kill_all_hostiles() -> void:
	for node: Node2D in mobs.get_children():
		if is_instance_of(node, Hostile):
			node.queue_free()
	room_done = false

func go_back_rounds(num: int) -> void:
	current_level.current_wave = current_level.current_wave - (num + 1)
	if current_level.current_wave < 0:
		current_level.current_wave = 0
	current_level_progress = 0.0
	current_wave_progress = 0.0
	if current_level.current_wave > 0:
		current_wave_progress = current_level.waves[current_level.current_wave][1]
		for wave: Array in current_level.waves.slice(0, current_level.current_wave + 1):
			current_level_progress += wave[1]
	else:
		current_wave = null

func move_player_to_center() -> void:
	player.global_position = center.global_position

func back_to_menu() -> void:
	await get_tree().create_timer(1.0).timeout
	var fade_instance: Fade = _fade_scene.instantiate()
	fade_instance.duration = 1.5
	add_child(fade_instance)
	await fade_instance.half_reached
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
