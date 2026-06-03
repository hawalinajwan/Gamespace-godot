extends CPUParticles2D

# "jump" | "land" | "run"
@export var dust_type: String = "jump"

func _ready() -> void:
	emitting = false
	one_shot = true

	match dust_type:
		"jump": _setup_jump()
		"land": _setup_land()
		"run": _setup_run()

func _setup_jump() -> void:
	amount = 12
	lifetime = 0.35
	explosiveness = 0.9
	direction = Vector2(0, -1)
	spread = 65.0
	gravity = Vector2(0, 60)
	initial_velocity_min = 40.0
	initial_velocity_max = 80.0
	scale_amount_min = 2.0
	scale_amount_max = 5.0
	color = Color(0.85, 0.80, 0.70, 0.75)
	color_ramp = _make_fade_gradient(Color(0.85, 0.80, 0.70, 0.75))

func _setup_land() -> void:
	amount = 20
	lifetime = 0.45
	explosiveness = 0.95
	direction = Vector2(0, 1)
	spread = 85.0
	gravity = Vector2(0, 30)
	initial_velocity_min = 60.0
	initial_velocity_max = 120.0
	scale_amount_min = 3.0
	scale_amount_max = 7.0
	color = Color(0.80, 0.75, 0.65, 0.80)
	color_ramp = _make_fade_gradient(Color(0.80, 0.75, 0.65, 0.80))

func _setup_run() -> void:
	amount = 6
	lifetime = 0.25
	explosiveness = 0.0
	direction = Vector2(0, -1)
	spread = 30.0
	gravity = Vector2(0, 80)
	initial_velocity_min = 20.0
	initial_velocity_max = 45.0
	scale_amount_min = 1.5
	scale_amount_max = 3.5
	color = Color(0.75, 0.70, 0.60, 0.55)
	color_ramp = _make_fade_gradient(Color(0.75, 0.70, 0.60, 0.55))

func _make_fade_gradient(base_color: Color) -> Gradient:
	var g = Gradient.new()
	g.set_color(0, base_color)
	g.set_color(1, Color(base_color.r, base_color.g, base_color.b, 0.0))
	return g

func emit_at(pos: Vector2) -> void:
	global_position = pos
	restart()
	emitting = true
