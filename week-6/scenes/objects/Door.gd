extends StaticBody2D

@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	PuzzleManager.puzzle_solved.connect(_on_puzzle_solved)
	if PuzzleManager.is_puzzle_solved():
		_open_door()


func _on_puzzle_solved() -> void:
	_open_door()


func _open_door() -> void:
	collision.disabled = true
	sprite.modulate = Color(0.3, 1.0, 0.4, 0.5)
	if has_node("DoorLabel"):
		$DoorLabel.text = "TERBUKA"
