extends RigidBody2D

var world_bounds: Rect2

func _physics_process(delta):
	if world_bounds == null:
		return

	if not world_bounds.has_point(global_position):
		queue_free()

func _ready():
	await get_tree().create_timer(4.0).timeout
	queue_free()	

func _on_body_entered(body):
	if body.is_in_group("player"):
		print("Player ketimpa batu")
		queue_free()
