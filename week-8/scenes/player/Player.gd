extends CharacterBody2D

const SPEED = 200.0
const JUMP_VELOCITY = -420.0
const RUN_DUST_INTERVAL = 0.08

@onready var jump_dust = $JumpDust
@onready var land_dust = $LandDust
@onready var run_dust = $RunDust

var was_in_air: bool = false
var run_dust_timer: float = 0.0

func _physics_process(delta: float) -> void:
	_apply_gravity(delta)
	_handle_jump()
	_handle_movement()
	move_and_slide()
	_handle_landing()
	_handle_run_dust(delta)

func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		var grav = ProjectSettings.get_setting("physics/2d/default_gravity")
		velocity.y += grav * delta
		was_in_air = true

func _handle_jump() -> void:
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		was_in_air = true
		_emit_jump_dust()

func _handle_movement() -> void:
	var dir = Input.get_axis("ui_left", "ui_right")
	velocity.x = dir * SPEED

func _handle_landing() -> void:
	if was_in_air and is_on_floor():
		was_in_air = false
		_emit_land_dust()

func _handle_run_dust(delta: float) -> void:
	if is_on_floor() and abs(velocity.x) > 10.0:
		run_dust_timer -= delta
		if run_dust_timer <= 0.0:
			run_dust_timer = RUN_DUST_INTERVAL
			_emit_run_dust()
	else:
		run_dust_timer = 0.0

func _feet_position() -> Vector2:
	return global_position + Vector2(0, 16)

func _emit_jump_dust() -> void:
	jump_dust.emit_at(_feet_position())

func _emit_land_dust() -> void:
	land_dust.emit_at(_feet_position())

func _emit_run_dust() -> void:
	run_dust.scale.x = -sign(velocity.x) if velocity.x != 0 else 1.0
	run_dust.emit_at(_feet_position())
