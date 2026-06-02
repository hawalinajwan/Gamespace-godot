extends Node

const SAVE_PATH := "user://save.json"

var quests := {
	"belajar_melompat": {
		"title": "Belajar Melompat",
		"objectives": ["lompat_1", "lompat_2"],
		"completed": []
	},
	"jalan_jalan": {
		"title": "Jalan-jalan",
		"objectives": ["gerak_kiri", "gerak_kanan"],
		"completed": []
	}
}

# Loads saved quest progress when the singleton enters the scene tree.
func _ready() -> void:
	load_save()

# Marks one objective as completed if it belongs to the quest.
func complete_objective(quest_id: String, obj_id: String) -> void:
	if not quests.has(quest_id):
		return
	var quest: Dictionary = quests[quest_id]
	if obj_id in quest["objectives"] and not (obj_id in quest["completed"]):
		quest["completed"].append(obj_id)

# Returns true when every objective in a quest has been completed.
func is_quest_done(quest_id: String) -> bool:
	if not quests.has(quest_id):
		return false
	var quest: Dictionary = quests[quest_id]
	for objective in quest["objectives"]:
		if not (objective in quest["completed"]):
			return false
	return true

# Writes the current quest dictionary to user://save.json.
func save() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		return
	file.store_string(JSON.stringify(quests))

# Reads user://save.json and applies saved quest progress.
func load_save() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return
	var data = JSON.parse_string(file.get_as_text())
	if typeof(data) == TYPE_DICTIONARY:
		quests = data
