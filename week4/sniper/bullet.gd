extends Area2D

@export var speed        : float = 500.0
@export var damage       : float = 30.0
@export var max_distance : float = 800.0

# Di-set oleh sniper._fire() sebelum add_child
var direction : Vector2 = Vector2.RIGHT
var shooter   : Node2D  = null   # sniper yang menembak, diabaikan oleh collision

var _traveled : float = 0.0

# =============================================================================
func _ready() -> void:
	# Nonaktifkan collision 1 physics frame.
	# Tanpa ini bullet spawn overlap dengan CollisionShape sniper sendiri
	# → _on_body_entered langsung terpicu → queue_free() sebelum bergerak.
	$CollisionShape2D.disabled = true
	await get_tree().physics_frame
	$CollisionShape2D.disabled = false

# =============================================================================
func _physics_process(delta: float) -> void:
	var move : Vector2 = direction * speed * delta
	position  += move
	_traveled += move.length()
	if _traveled >= max_distance:
		queue_free()

# =============================================================================
func _on_body_entered(body: Node) -> void:
	# Abaikan sniper yang menembak
	if body == shooter:
		return
	if body.is_in_group("player"):
		if body.has_method("take_damage"):
			body.take_damage(damage)
		queue_free()
		return
	# Kena dinding/tilemap → hancur
	queue_free()
