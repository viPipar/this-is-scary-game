extends CharacterBody2D

const SPEED = 800.0

func _physics_process(delta: float) -> void:
	var direction := Vector2.ZERO

	# Input WASD
	if Input.is_action_pressed("right"):
		direction.x += 1
	if Input.is_action_pressed("left"):
		direction.x -= 1
	if Input.is_action_pressed("back"):
		direction.y += 1
	if Input.is_action_pressed("forward"):
		direction.y -= 1

	if direction != Vector2.ZERO:
		# --- MOVING ---
		direction = direction.normalized()
		
		# 1. Play "walk" directly on the AnimatedSprite2D
		$AnimatedSprite2D.play("walk")
	else:
		# --- IDLE ---
		# 2. Play "idle" directly when stopped
		# (Make sure your animation is named "idle" in the SpriteFrames panel)
		$AnimatedSprite2D.play("idle")

	# --- FLIP SPRITE ---
	# We access the flip_h property directly on the AnimatedSprite2D
	if direction.x < 0:
		$AnimatedSprite2D.flip_h = true
	elif direction.x > 0:
		$AnimatedSprite2D.flip_h = false

	velocity = direction * SPEED
	move_and_slide()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		print("aduh kena")
		get_tree().reload_current_scene()
