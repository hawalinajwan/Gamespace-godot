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

# Resets quest progress when the singleton enters the scene tree.
func _ready() -> void:
	reset_progress()

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

# Clears all completed objectives and saves the empty progress.
func reset_progress() -> void:
	for quest_id in quests:
		quests[quest_id]["completed"] = []
	save()

# Writes only completed objectives to user://save.json.
func save() -> void:
	var data := {}
	for quest_id in quests:
		data[quest_id] = quests[quest_id]["completed"].duplicate()
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		return
	file.store_string(JSON.stringify(data))

# Reads user://save.json and merges saved completed objectives.
func load_save() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return
	var data = JSON.parse_string(file.get_as_text())
	if typeof(data) != TYPE_DICTIONARY:
		return
	for quest_id in data.keys():
		if not quests.has(quest_id):
			continue
		if typeof(data[quest_id]) == TYPE_ARRAY:
			quests[quest_id]["completed"] = data[quest_id]
		elif typeof(data[quest_id]) == TYPE_DICTIONARY and data[quest_id].has("completed"):
			quests[quest_id]["completed"] = data[quest_id]["completed"]
