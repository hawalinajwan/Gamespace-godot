extends CharacterBody2D

@export var block_id: String = "block_a"
@export_enum("Horizontal", "Vertical", "Both") var allowed_motion: String = "Horizontal"

const SLIDE_SPEED = 140.0

var slide_direction: Vector2 = Vector2.ZERO
var is_locked: bool = false

func _ready() -> void:
	add_to_group("sliding_block")
	if PuzzleManager.block_states.get(block_id, false):
		is_locked = true


func receive_push(direction: Vector2) -> void:
	if is_locked:
		return
	if allowed_motion == "Horizontal" and direction.y != 0:
		return
	if allowed_motion == "Vertical" and direction.x != 0:
		return
	slide_direction = direction


func _physics_process(_delta: float) -> void:
	if is_locked or slide_direction == Vector2.ZERO:
		velocity = Vector2.ZERO
		return

	velocity = slide_direction * SLIDE_SPEED
	var prev_pos := global_position
	move_and_slide()

	if get_slide_collision_count() > 0:
		for i in get_slide_collision_count():
			var col := get_slide_collision(i)
			var collider := col.get_collider()
			if collider and not collider.is_in_group("sliding_block"):
				slide_direction = Vector2.ZERO
				velocity = Vector2.ZERO
				break

	if global_position.distance_to(prev_pos) < 0.1:
		slide_direction = Vector2.ZERO


func lock_in_place() -> void:
	is_locked = true
	slide_direction = Vector2.ZERO
	velocity = Vector2.ZERO
	PuzzleManager.register_block_solved(block_id)
