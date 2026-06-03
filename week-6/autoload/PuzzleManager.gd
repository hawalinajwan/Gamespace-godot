extends Node

const SAVE_PATH = "user://puzzle_save.json"
const QUEST_ID = "sliding_puzzle"
const QUEST_OBJECTIVE_ID = "solve_puzzle"

var block_states: Dictionary = {
	"block_a": false,
	"block_b": false,
}

var solved_count: int = 0

signal block_placed(block_id: String)
signal puzzle_solved

func _ready() -> void:
	reset_puzzle()


func register_block_solved(block_id: String) -> void:
	if block_states.has(block_id) and not block_states[block_id]:
		block_states[block_id] = true
		solved_count += 1
		block_placed.emit(block_id)
		save()
		if is_puzzle_solved():
			_complete_quest_objective()
			puzzle_solved.emit()


func is_puzzle_solved() -> bool:
	return solved_count >= block_states.size()


func reset_puzzle() -> void:
	for key in block_states:
		block_states[key] = false
	solved_count = 0
	save()


func save() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(block_states))
		file.close()


func load_save() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		return

	var text := file.get_as_text()
	file.close()

	var parsed = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		return

	solved_count = 0
	for key in parsed:
		if block_states.has(key):
			block_states[key] = bool(parsed[key])
			if block_states[key]:
				solved_count += 1


func _complete_quest_objective() -> void:
	var quest_manager := get_node_or_null("/root/QuestManager")
	if quest_manager and quest_manager.has_method("complete_objective"):
		quest_manager.complete_objective(QUEST_ID, QUEST_OBJECTIVE_ID)
		if quest_manager.has_method("save"):
			quest_manager.save()
