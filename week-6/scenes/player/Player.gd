extends CharacterBody2D

const SPEED = 160.0

func _physics_process(_delta: float) -> void:
	var dir := Vector2.ZERO
	dir.x = Input.get_axis("ui_left", "ui_right") + Input.get_axis("move_left", "move_right")
	dir.y = Input.get_axis("ui_up", "ui_down") + Input.get_axis("move_up", "move_down")
	if dir != Vector2.ZERO:
		dir = dir.normalized()

	velocity = dir * SPEED
	move_and_slide()

	for i in get_slide_collision_count():
		var col := get_slide_collision(i)
		var body := col.get_collider()
		if body and body.is_in_group("sliding_block") and body.has_method("receive_push"):
			_push_block(body, col.get_normal())


func _push_block(block: Node, normal: Vector2) -> void:
	var push_dir := -normal
	if abs(push_dir.x) > abs(push_dir.y):
		push_dir = Vector2(sign(push_dir.x), 0)
	else:
		push_dir = Vector2(0, sign(push_dir.y))
	block.receive_push(push_dir)
