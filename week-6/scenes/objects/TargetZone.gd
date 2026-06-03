extends Area2D

@export var target_block_id: String = "block_a"

var block_inside: Node = null

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("sliding_block") and body.block_id == target_block_id:
		block_inside = body
		await get_tree().create_timer(0.1).timeout
		if is_instance_valid(body) and body == block_inside:
			body.global_position = global_position
			body.lock_in_place()
			_show_solved_effect()


func _on_body_exited(body: Node) -> void:
	if body == block_inside:
		block_inside = null


func _show_solved_effect() -> void:
	modulate = Color(0.3, 1.0, 0.4)
