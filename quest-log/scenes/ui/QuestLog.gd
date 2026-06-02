extends Control

var list: VBoxContainer

# Creates the quest list and starts periodic UI refreshes.
func _ready() -> void:
	size = Vector2(260, 300)
	$Panel.position = Vector2.ZERO
	$Panel.size = Vector2(260, 300)
	list = $Panel/QuestContainer
	refresh()

	var timer := Timer.new()
	timer.wait_time = 1.0
	timer.timeout.connect(refresh)
	timer.autostart = true
	add_child(timer)

# Rebuilds the visible quest checklist from QuestManager.quests.
func refresh() -> void:
	if list == null:
		return
	for child in list.get_children():
		child.queue_free()

	for quest_id in QuestManager.quests.keys():
		var quest: Dictionary = QuestManager.quests[quest_id]
		var done := QuestManager.is_quest_done(quest_id)
		var row := HBoxContainer.new()
		list.add_child(row)

		var title := Label.new()
		title.text = quest["title"]
		title.add_theme_font_size_override("font_size", 14)
		row.add_child(title)

		if done:
			var done_label := Label.new()
			done_label.text = "  ✓ SELESAI"
			done_label.add_theme_color_override("font_color", Color.GREEN)
			row.add_child(done_label)

		for objective in quest["objectives"]:
			var objective_row := HBoxContainer.new()
			list.add_child(objective_row)

			var checkbox := CheckBox.new()
			checkbox.disabled = true
			checkbox.button_pressed = objective in quest["completed"]
			objective_row.add_child(checkbox)

			var label := Label.new()
			label.text = objective.replace("_", " ").capitalize()
			objective_row.add_child(label)
