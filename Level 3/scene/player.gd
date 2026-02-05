extends CharacterBody2D

const SPEED = 400.0

func _physics_process(delta: float) -> void:
	var direction := Vector2.ZERO

	# Input WASD
	if Input.is_action_pressed("right"):
		direction.x += 1
	if Input.is_action_pressed("left"):
		direction.x -= 1
	if Input.is_action_pressed("down"):
		direction.y += 1
	if Input.is_action_pressed("up"):
		direction.y -= 1

	# Biar kecepatan diagonal tetap konsisten
	if direction != Vector2.ZERO:
		direction = direction.normalized()

	velocity = direction * SPEED
	move_and_slide()
