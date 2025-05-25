extends CharacterBody2D
class_name Player

var player_speed: int = 65

var bullet_scene: PackedScene = load("res://scenes/bullet.tscn")
var shoot_cooldown: float = 0.5
var time_since_last_shot: float = 0.0
var bullet_speed: int = 120
var bullet_penetration: int = 1
var bullet_damage: int = 1
var map_rect: Rect2

var frozen: bool = true


func _process(delta: float) -> void:
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
		velocity = GlobalFunctions.calc_velocity(player_speed, move_angle)
	else:
		velocity = Vector2.ZERO
	@warning_ignore("return_value_discarded")
	move_and_slide()

	# Bullets
	time_since_last_shot += delta
	var shoot_x: int = 0
	var shoot_y: int = 0
	if time_since_last_shot >= shoot_cooldown:
		if Input.is_action_pressed("shoot_down"):
			shoot_y += 1
		if Input.is_action_pressed("shoot_up"):
			shoot_y -= 1
		if Input.is_action_pressed("shoot_left"):
			shoot_x -= 1
		if Input.is_action_pressed("shoot_right"):
			shoot_x += 1
		if shoot_x or shoot_y:
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
			var bullet_velocity: Vector2 = GlobalFunctions.calc_velocity(bullet_speed, angle)
			var bullet: Bullet = bullet_scene.instantiate()
			bullet.init(
				bullet_velocity, angle, bullet_penetration,
				bullet_damage, global_position, map_rect,
			)
			get_parent().add_child(bullet)
			time_since_last_shot = 0.0
