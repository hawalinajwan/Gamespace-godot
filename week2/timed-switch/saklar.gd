extends Node2D

var aktif = false

@onready var timer = $Timer
@onready var sprite = $Sprite2D


func _on_area_2d_body_entered(body):

	if body.name == "player" and !aktif:
		aktif = true
		sprite.modulate = Color(0,1,0)
		timer.start()


func _on_timer_timeout():

	aktif = false
	sprite.modulate = Color(1,1,1)
