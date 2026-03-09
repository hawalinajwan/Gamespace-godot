extends CharacterBody2D

var acceleration = 600
var max_speed = 400
var friction = 0.97
var turn_speed = 3
var drift = 0.1

func _physics_process(delta):

	var dir = 0
	var turn = 0

	if Input.is_action_pressed("ui_up"):
		dir = 1
	elif Input.is_action_pressed("ui_down"):
		dir = -1

	if Input.is_action_pressed("ui_left"):
		turn = -1
	elif Input.is_action_pressed("ui_right"):
		turn = 1

	# rotasi mobil
	rotation += turn * turn_speed * delta * velocity.length() / 200

	# percepatan
	velocity += transform.x * dir * acceleration * delta

	# DRIFT (ini kuncinya)
	velocity = velocity.lerp(transform.x * velocity.length(), drift)

	# friction
	velocity *= friction

	velocity = velocity.limit_length(max_speed)

	move_and_slide()
