extends StaticBody2D

@export var tile_id: String = "tile_001"
@export_enum("delayed", "instant") var tile_type: String = "delayed"

const STAGE_COLORS = [
	Color(0.6, 0.85, 1.0, 0.45),
	Color(0.9, 0.75, 0.5, 0.55),
	Color(0.9, 0.4, 0.3, 0.65),
	Color(0.3, 0.3, 0.3, 0.0),
]

@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var visual: ColorRect = $Visual
@onready var crack_draw: Node2D = $CrackLayer
@onready var respawn_timer: Timer = $RespawnTimer

var current_stage := 0

func _ready() -> void:
	add_to_group("glass_tile")
	GlassManager.register_tile(tile_id, tile_type)
	GlassManager.tile_cracked.connect(_on_tile_cracked)
	GlassManager.tile_broken.connect(_on_tile_broken)
	GlassManager.tile_respawned.connect(_on_tile_respawned)

	_apply_stage(int(GlassManager.tiles[tile_id]["stage"]))
	if current_stage == 3:
		respawn_timer.start()

func on_landed() -> void:
	GlassManager.on_player_landed(tile_id)

func _apply_stage(stage: int) -> void:
	current_stage = clampi(stage, 0, 3)
	visual.color = STAGE_COLORS[current_stage]
	crack_draw.crack_stage = current_stage
	crack_draw.queue_redraw()

	if current_stage >= 3:
		collision.set_deferred("disabled", true)
		if respawn_timer.is_stopped():
			respawn_timer.start()
	else:
		collision.set_deferred("disabled", false)

func _on_tile_cracked(id: String, stage: int) -> void:
	if id == tile_id:
		_apply_stage(stage)

func _on_tile_broken(id: String) -> void:
	if id == tile_id:
		_apply_stage(3)

func _on_tile_respawned(id: String) -> void:
	if id == tile_id:
		_apply_stage(0)

func _on_respawn_timer_timeout() -> void:
	GlassManager.on_tile_respawned(tile_id)
