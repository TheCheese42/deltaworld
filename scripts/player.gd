extends CharacterBody2D


func _process(_delta: float) -> void:
	var shoot_x: int = 0
	var shoot_y: int = 0
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
		# TODO: Bullet scene
