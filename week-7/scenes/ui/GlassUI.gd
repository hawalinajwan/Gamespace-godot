extends CanvasLayer

@onready var vbox: VBoxContainer = $Panel/VBox

func _ready() -> void:
	GlassManager.tile_cracked.connect(_refresh)
	GlassManager.tile_broken.connect(_refresh_any)
	GlassManager.tile_respawned.connect(_refresh_any)
	_refresh_any.call_deferred("")

func _refresh_any(_id: String) -> void:
	_refresh("", 0)

func _refresh(_id: String, _stage: int = 0) -> void:
	for child in vbox.get_children():
		child.queue_free()

	var stage_names = ["Utuh", "Retak", "Parah", "Pecah"]
	var stage_colors = [
		Color(1, 1, 1),
		Color(1, 0.8, 0.3),
		Color(1, 0.4, 0.2),
		Color(0.5, 0.5, 0.5),
	]

	for tile_id in GlassManager.tiles:
		var tile_data: Dictionary = GlassManager.tiles[tile_id]
		var stage := int(tile_data["stage"])
		var row := HBoxContainer.new()
		vbox.add_child(row)

		var label := Label.new()
		label.text = "%s: %s" % [tile_id, stage_names[stage]]
		label.add_theme_font_size_override("font_size", 12)
		label.modulate = stage_colors[stage]
		row.add_child(label)
