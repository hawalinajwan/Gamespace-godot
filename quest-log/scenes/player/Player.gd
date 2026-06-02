extends CharacterBody2D

const SPEED := 220.0
const JUMP_VELOCITY := -420.0

var gravity := ProjectSettings.get_setting("physics/2d/default_gravity") as float
var moved_left := false
var moved_right := false
var jump_count := 0

# Updates movement, jumping, and quest objectives every physics tick.
func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

	var direction := Input.get_axis("ui_left", "ui_right")
	velocity.x = direction * SPEED

	if direction < 0.0 and not moved_left:
		moved_left = true
		_complete_and_save("jalan_jalan", "gerak_kiri")
	if direction > 0.0 and not moved_right:
		moved_right = true
		_complete_and_save("jalan_jalan", "gerak_kanan")

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
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
