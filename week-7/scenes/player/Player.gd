extends CharacterBody2D

const SPEED = 200.0
const JUMP_VELOCITY = -420.0

var was_in_air := false

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
		velocity.y += gravity * delta
		was_in_air = true

	if (Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("ui_up")) and is_on_floor():
		velocity.y = JUMP_VELOCITY
		was_in_air = true

	var dir := Input.get_axis("ui_left", "ui_right") + Input.get_axis("move_left", "move_right")
	velocity.x = clampf(dir, -1.0, 1.0) * SPEED

	move_and_slide()

	if was_in_air and is_on_floor():
		was_in_air = false
		_check_glass_landing()

func _check_glass_landing() -> void:
	for i in get_slide_collision_count():
		var collision := get_slide_collision(i)
		var body := collision.get_collider()
		if body and body.is_in_group("glass_tile") and body.has_method("on_landed"):
			body.on_landed()
