extends Node2D

var crack_stage := 0

const CRACKS = [
	[],
	[
		[Vector2(-10, -5), Vector2(0, 0), Vector2(8, 10)],
	],
	[
		[Vector2(-10, -5), Vector2(0, 0), Vector2(8, 10)],
		[Vector2(5, -12), Vector2(0, 0), Vector2(-6, 8)],
		[Vector2(-8, 6), Vector2(2, 2), Vector2(10, -3)],
	],
]

func _draw() -> void:
	if crack_stage == 0 or crack_stage >= 3:
		return

	var cracks = CRACKS[crack_stage]
	for crack in cracks:
		for i in range(crack.size() - 1):
			draw_line(crack[i], crack[i + 1], Color(0.1, 0.1, 0.1, 0.8), 1.5)
