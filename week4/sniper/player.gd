extends CharacterBody2D

@export var speed: float = 180.0

func _ready() -> void:
	add_to_group("player")

func _physics_process(delta: float) -> void:
	var dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = dir * speed
	move_and_slide()

func take_damage(amount: float) -> void:
	print("Player kena damage:", amount)
