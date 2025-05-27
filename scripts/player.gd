extends CharacterBody2D
class_name Player

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

var player_speed: int = 65

var bullet_scene: PackedScene = load("res://scenes/bullet.tscn")
var shoot_cooldown: float = 0.5
var time_since_last_shot: float = 0.0
var bullet_speed: int = 120
var bullet_penetration: int = 1
var bullet_damage: int = 1
var map_rect: Rect2

var active_items: Array[DroppedItem] = []
var stored_item: DroppedItem = null
var resurrection_coins: int = 2

var frozen: bool = true
var invincible: bool = false


func compute_item_affected_stat(stat_base: String, base_stat: float) -> float:
	for item: DroppedItem in active_items:
		if not item:
			continue
		var item_stat: float = item.stats.get(stat_base, base_stat)
		if item_stat < base_stat:
			base_stat = item_stat
	for item: DroppedItem in active_items:
		if not item:
			continue
		base_stat *= item.stats.get(stat_base + "_multiplier", 1.0)
	for item: DroppedItem in active_items:
		if not item:
			continue
		base_stat += item.stats.get(stat_base + "_offset", 0.0)
	return base_stat

func _ready() -> void:
	await get_tree().create_timer(0).timeout
	get_tree().call_group("game", "update_res_coins_label", resurrection_coins)

func _process(delta: float) -> void:
	if GlobalVars.halted:
		return

	if frozen:
		return

	# Movement
	var move_x: int = 0
	var move_y: int = 0
	if Input.is_action_pressed("move_down"):
		move_y += 1
	if Input.is_action_pressed("move_up"):
		move_y -= 1
	if Input.is_action_pressed("move_left"):
		move_x -= 1
	if Input.is_action_pressed("move_right"):
		move_x += 1
	if move_x or move_y:
		var move_angle: int
		if move_x < 0 and move_y < 0:
			move_angle = 315
		elif move_x < 0 and move_y > 0:
			move_angle = 225
		elif move_x > 0 and move_y < 0:
			move_angle = 45
		elif move_x > 0 and move_y > 0:
			move_angle = 135
		elif move_x > 0:
			move_angle = 90
		elif move_x < 0:
			move_angle = 270
		elif move_y < 0:
			move_angle = 0
		else:
			move_angle = 180
		move_angle -= 90  # 0 is to the right
		velocity = GlobalFunctions.calc_velocity(
			compute_item_affected_stat("movement_speed", player_speed),
			move_angle
		)
	else:
		velocity = Vector2.ZERO
	move_and_slide()

	# Bullets
	time_since_last_shot += delta
	var shoot_x: int = 0
	var shoot_y: int = 0
	if time_since_last_shot >= compute_item_affected_stat("cooldown", shoot_cooldown):
		if Input.is_action_pressed("shoot_down"):
			shoot_y += 1
		if Input.is_action_pressed("shoot_up"):
			shoot_y -= 1
		if Input.is_action_pressed("shoot_left"):
			shoot_x -= 1
		if Input.is_action_pressed("shoot_right"):
			shoot_x += 1
		if shoot_x or shoot_y:
			var angles: Array[int] = []
			
			# Main bullet
			var angle: int
			if shoot_x < 0 and shoot_y < 0:
				angle = 315
			elif shoot_x < 0 and shoot_y > 0:
				angle = 225
			elif shoot_x > 0 and shoot_y < 0:
				angle = 45
			elif shoot_x > 0 and shoot_y > 0:
				angle = 135
			elif shoot_x > 0:
				angle = 90
			elif shoot_x < 0:
				angle = 270
			elif shoot_y < 0:
				angle = 0
			else:
				angle = 180
			angle -= 90  # 0 is to the right
			angles.append(angle)

			# Spray
			for item: DroppedItem in active_items:
				if not item:
					continue
				if item.stats.get("spray"):
					angles.append(angle - 45)
					angles.append(angle - 22)
					angles.append(angle + 22)
					angles.append(angle + 45)
					break

			for item: DroppedItem in active_items:
				if not item:
					continue
				if item.stats.get("three_sixty"):
					angles.append(angle - 180)
					angles.append(angle - 135)
					angles.append(angle - 90)
					angles.append(angle - 45)
					angles.append(angle + 45)
					angles.append(angle + 90)
					angles.append(angle + 135)
					break

			for bullet_angle: int in angles:
				var bullet_velocity: Vector2 = GlobalFunctions.calc_velocity(
					compute_item_affected_stat("bullet_speed", bullet_speed),
					bullet_angle
				)
				var bullet: Bullet = bullet_scene.instantiate()
				bullet.init(
					bullet_velocity, bullet_angle,
					int(compute_item_affected_stat("penetration", bullet_penetration)),
					int(compute_item_affected_stat("damage", bullet_damage)),
					global_position, map_rect,
				)
				get_parent().add_child(bullet)
			time_since_last_shot = 0.0
	
	if Input.is_action_just_pressed("use_item"):
		if stored_item != null:
			for other_item: DroppedItem in active_items:
				if not other_item:
					continue
				if other_item.name == stored_item.name:
					active_items.erase(other_item)
					other_item.queue_free()
			stored_item.activate()
			active_items.append(stored_item)
			stored_item = null

func pickup_item(item: DroppedItem) -> void:
	if item.stats.has("resurrection_coin"):
		resurrection_coins += int(item.stats["resurrection_coin"])
		get_tree().call_group("game", "update_res_coins_label", resurrection_coins)
		item.queue_free()
		return
	if stored_item == null:
		stored_item = item
		get_tree().call_group("game", "store_item", item)
	else:
		for other_item: DroppedItem in active_items:
			if not other_item:
				continue
			if other_item.name == item.name:
				active_items.erase(other_item)
				other_item.queue_free()
		item.activate()
		active_items.append(item)

func _on_damage_hitbox_area_entered(body: Node2D) -> void:
	if invincible:
		body.get_parent().queue_free()
		return

	for item: DroppedItem in active_items:
		if not item:
			continue
		var invincibility_duration: float = item.stats.get("invincibility_duration", 0.0)
		if invincibility_duration:
			body.get_parent().queue_free()
			invincible = true
			var new_item: DroppedItem = item.duplicate()
			item.queue_free()
			add_child(new_item)
			new_item.ignore_collisions = true
			new_item.sprite_2d.visible = true
			new_item.position = Vector2.ZERO
			new_item.global_position = global_position
			new_item.scale = Vector2(0.001, 0.001)
			var tween: Tween = create_tween()
			tween.set_ease(Tween.EASE_IN_OUT)
			tween.tween_property(new_item, "scale", Vector2(2.0, 2.0), 1.5)
			tween.tween_property(new_item, "modulate", Color(1.0, 1.0, 1.0, 0.0), 1.5)
			var loops: int = int(invincibility_duration / 0.5)
			for i: int in loops:
				var player_tween: Tween = create_tween()
				player_tween.set_ease(Tween.EASE_IN_OUT)
				player_tween.tween_property(
					animated_sprite_2d, "self_modulate", Color(1.0, 1.0, 1.0, 0.6), 0.25
				)
				await player_tween.finished
				player_tween = create_tween()
				player_tween.set_ease(Tween.EASE_IN_OUT)
				player_tween.tween_property(
					animated_sprite_2d, "self_modulate", Color(1.0, 1.0, 1.0, 1.0), 0.25
				)
				await player_tween.finished
			new_item.queue_free()
			invincible = false
			return
	die()

func die() -> void:
	frozen = true
	GlobalVars.halted = true
	visible = false
	get_tree().call_group("game", "kill_all_hostiles")
	await get_tree().create_timer(2.0).timeout
	resurrection_coins -= 1
	if resurrection_coins < 0:
		get_tree().call_group("game", "back_to_menu")
		return
	else:
		get_tree().call_group("game", "update_res_coins_label", resurrection_coins)
	get_tree().call_group("game", "go_back_rounds", 5)
	get_tree().call_group("game", "move_player_to_center")
	visible = true
	frozen = false
	await get_tree().create_timer(0.5).timeout
	visible = false
	await get_tree().create_timer(0.5).timeout
	visible = true
	await get_tree().create_timer(0.5).timeout
	visible = false
	await get_tree().create_timer(0.5).timeout
	visible = true
	GlobalVars.halted = false
