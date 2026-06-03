#!/usr/bin/env bash
set -euo pipefail

ROOT="${1:-.}"

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  exit 1
}

require_file() {
  [[ -f "$ROOT/$1" ]] || fail "missing $ROOT/$1"
}

require_text() {
  local file="$1"
  local pattern="$2"
  grep -Fq "$pattern" "$ROOT/$file" || fail "$ROOT/$file missing: $pattern"
}

require_file "project.godot"
require_file "autoload/PuzzleManager.gd"
require_file "scenes/world/PuzzleRoom.tscn"
require_file "scenes/player/Player.tscn"
require_file "scenes/player/Player.gd"
require_file "scenes/objects/SlidingBlock.tscn"
require_file "scenes/objects/SlidingBlock.gd"
require_file "scenes/objects/TargetZone.tscn"
require_file "scenes/objects/TargetZone.gd"
require_file "scenes/objects/Door.tscn"
require_file "scenes/objects/Door.gd"
require_file "scenes/ui/PuzzleUI.tscn"
require_file "scenes/ui/PuzzleUI.gd"
require_file "saves/.gdkeep"

require_text "project.godot" 'config/main_scene="res://scenes/world/PuzzleRoom.tscn"'
require_text "project.godot" 'PuzzleManager="*res://autoload/PuzzleManager.gd"'
require_text "project.godot" '2d/default_gravity=0'

require_text "autoload/PuzzleManager.gd" "signal block_placed(block_id: String)"
require_text "autoload/PuzzleManager.gd" "signal puzzle_solved"
require_text "autoload/PuzzleManager.gd" "func save() -> void:"
require_text "autoload/PuzzleManager.gd" "func load_save() -> void:"
require_text "autoload/PuzzleManager.gd" "func _ready() -> void:"
require_text "autoload/PuzzleManager.gd" "reset_puzzle()"

require_text "scenes/player/Player.gd" "func _push_block(block: Node, normal: Vector2) -> void:"
require_text "scenes/player/Player.tscn" "collision_mask = 3"

require_text "scenes/objects/SlidingBlock.gd" 'add_to_group("sliding_block")'
require_text "scenes/objects/SlidingBlock.gd" "func receive_push(direction: Vector2) -> void:"
require_text "scenes/objects/SlidingBlock.gd" "func lock_in_place() -> void:"
require_text "scenes/objects/SlidingBlock.gd" "@export_enum(\"Horizontal\", \"Vertical\", \"Both\") var allowed_motion"

require_text "scenes/objects/TargetZone.gd" "body_entered.connect(_on_body_entered)"
require_text "scenes/objects/TargetZone.gd" "body.block_id == target_block_id"
require_text "scenes/objects/TargetZone.gd" "body.global_position = global_position"

require_text "scenes/objects/Door.gd" "PuzzleManager.puzzle_solved.connect(_on_puzzle_solved)"
require_text "scenes/ui/PuzzleUI.gd" "PuzzleManager.block_placed.connect(_on_block_placed)"
require_text "scenes/ui/PuzzleUI.gd" "PuzzleManager.puzzle_solved.connect(_on_puzzle_solved)"

require_text "scenes/world/PuzzleRoom.tscn" 'instance=ExtResource("1_player")'
require_text "scenes/world/PuzzleRoom.tscn" 'instance=ExtResource("2_block")'
require_text "scenes/world/PuzzleRoom.tscn" 'block_id = "block_a"'
require_text "scenes/world/PuzzleRoom.tscn" 'block_id = "block_b"'
require_text "scenes/world/PuzzleRoom.tscn" 'target_block_id = "block_a"'
require_text "scenes/world/PuzzleRoom.tscn" 'target_block_id = "block_b"'

printf 'OK: sliding puzzle project verified at %s\n' "$ROOT"
