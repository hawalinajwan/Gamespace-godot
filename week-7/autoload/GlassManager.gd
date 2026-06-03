extends Node

signal tile_cracked(tile_id: String, stage: int)
signal tile_broken(tile_id: String)
signal tile_respawned(tile_id: String)

const SAVE_PATH = "user://glass_save.json"

# State tiap tile: tile_id -> { stage, type }
# stage: 0=intact, 1=crack1, 2=crack2, 3=broken
# type: "delayed" atau "instant"
var tiles: Dictionary = {}
var saved_stages: Dictionary = {}

func _ready() -> void:
	load_save()

func register_tile(tile_id: String, tile_type: String) -> void:
	if not tiles.has(tile_id):
		tiles[tile_id] = { "stage": 0, "type": tile_type }
	if saved_stages.has(tile_id):
		tiles[tile_id]["stage"] = int(saved_stages[tile_id])

func on_player_landed(tile_id: String) -> void:
	if not tiles.has(tile_id):
		return

	var tile_data: Dictionary = tiles[tile_id]
	if int(tile_data["stage"]) >= 3:
		return

	if tile_data["type"] == "instant":
		tile_data["stage"] = 3
		emit_signal("tile_broken", tile_id)
	else:
		tile_data["stage"] = int(tile_data["stage"]) + 1
		if int(tile_data["stage"]) >= 3:
			emit_signal("tile_broken", tile_id)
		else:
			emit_signal("tile_cracked", tile_id, int(tile_data["stage"]))

	save()

func on_tile_respawned(tile_id: String) -> void:
	if not tiles.has(tile_id):
		return

	tiles[tile_id]["stage"] = 0
	emit_signal("tile_respawned", tile_id)
	save()

func save() -> void:
	var data: Dictionary = {}
	for tile_id in tiles:
		data[tile_id] = int(tiles[tile_id]["stage"])

	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data))
		file.close()

func load_save() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		return

	var parsed = JSON.parse_string(file.get_as_text())
	file.close()
	if typeof(parsed) == TYPE_DICTIONARY:
		saved_stages = parsed
