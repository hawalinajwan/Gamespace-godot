extends CharacterBody2D

const SPEED := 220.0
const JUMP_VELOCITY := -420.0

var gravity := ProjectSettings.get_setting("physics/2d/default_gravity") as float
var moved_left := false
var moved_right := false
var jump_count := 0
var jump_was_down := false

# Updates movement, jumping, and quest objectives every physics tick.
func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

	var direction := _get_direction()
	velocity.x = direction * SPEED

	if direction < 0.0 and not moved_left:
		moved_left = true
		_complete_and_save("jalan_jalan", "gerak_kiri")
	if direction > 0.0 and not moved_right:
		moved_right = true
		_complete_and_save("jalan_jalan", "gerak_kanan")

	if _is_jump_pressed() and is_on_floor():
		velocity.y = JUMP_VELOCITY
		jump_count += 1
		if jump_count == 1:
			_complete_and_save("belajar_melompat", "lompat_1")
		elif jump_count == 2:
			_complete_and_save("belajar_melompat", "lompat_2")

	move_and_slide()

# Completes one quest objective and saves progress immediately.
func _complete_and_save(quest_id: String, obj_id: String) -> void:
	QuestManager.complete_objective(quest_id, obj_id)
	QuestManager.save()

# Returns horizontal input from actions, arrow keys, or A/D keys.
func _get_direction() -> float:
	var direction := Input.get_axis("ui_left", "ui_right")
	if Input.is_key_pressed(KEY_LEFT) or Input.is_key_pressed(KEY_A):
		direction -= 1.0
	if Input.is_key_pressed(KEY_RIGHT) or Input.is_key_pressed(KEY_D):
		direction += 1.0
	return clampf(direction, -1.0, 1.0)

# Returns true when any supported jump key is pressed this frame.
func _is_jump_pressed() -> bool:
	var jump_down := (
		Input.is_action_just_pressed("ui_accept")
		or Input.is_key_pressed(KEY_SPACE)
		or Input.is_key_pressed(KEY_UP)
		or Input.is_key_pressed(KEY_W)
	)
	var just_pressed := jump_down and not jump_was_down
	jump_was_down = jump_down
	return just_pressed
