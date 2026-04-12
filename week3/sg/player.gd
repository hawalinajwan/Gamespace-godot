extends CharacterBody2D

const Bullet = preload("res://bullet.tscn")

@export var num_pellets  = 5
	  # jumlah peluru
@export var spread_deg  = 20.0
   # total sudut sebar
@export var muzzle: Node2D         # drag Marker2D ke sini di Inspector

func _physics_process(delta):
	# arahkan player ke mouse
	look_at(get_global_mouse_position())

func _input(event):
	if event.is_action_pressed("shoot"):
		shoot_shotgun()

func shoot_shotgun():
	print("shoot dipanggil! jumlah peluru: ", num_pellets)
	var half = spread_deg / 2.0
	var step = spread_deg / (num_pellets - 1)

	for i in num_pellets:
		var angle_deg = -half + step * i
		var angle_rad = deg_to_rad(angle_deg)

		var b = Bullet.instantiate()
		get_parent().add_child(b)
		print("peluru ", i, " spawn di: ", b.position)

		b.position = muzzle.global_position
		b.direction = Vector2.from_angle(rotation + angle_rad)
