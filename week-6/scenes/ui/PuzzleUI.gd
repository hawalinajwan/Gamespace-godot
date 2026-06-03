extends CanvasLayer

@onready var status_label: Label = $Panel/VBox/StatusLabel
@onready var blocks_label: Label = $Panel/VBox/BlocksLabel

func _ready() -> void:
	PuzzleManager.block_placed.connect(_on_block_placed)
	PuzzleManager.puzzle_solved.connect(_on_puzzle_solved)
	_refresh()


func _on_block_placed(_block_id: String) -> void:
	_refresh()


func _on_puzzle_solved() -> void:
	status_label.text = "PUZZLE SELESAI! Pintu terbuka."
	status_label.modulate = Color(0.3, 1.0, 0.4)


func _refresh() -> void:
	var total := PuzzleManager.block_states.size()
	var done := PuzzleManager.solved_count
	blocks_label.text = "Blok terpasang: %d / %d" % [done, total]
	if not PuzzleManager.is_puzzle_solved():
		status_label.text = "Geser blok ke zona hijau!"
		status_label.modulate = Color(1, 1, 1)
