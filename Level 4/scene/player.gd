extends CharacterBody2D
@onready var anim: AnimatedSprite2D = $Sprite2D

const SPEED = 400.0

func _physics_process(delta: float) -> void:
	var direction := Vector2.ZERO
	
	if direction.x > 0:
		anim.play("walk")
		anim.flip_h = false
	if direction.x < 0:
		anim.play("walk")
		anim.flip_h = true
		
	# Input WASD
	if Input.is_action_pressed("right"):
		direction.x += 1
		anim.play("walk")
		anim.flip_h = false
	if Input.is_action_pressed("left"):
		direction.x -= 1
		anim.play("walk")
		anim.flip_h = true
	if Input.is_action_pressed("back"):
		direction.y += 1
		anim.play("walk")
	if Input.is_action_pressed("forward"):
		direction.y -= 1
		anim.play("walk")

	# Biar kecepatan diagonal tetap konsisten
	if direction != Vector2.ZERO:
		direction = direction.normalized()
	else:
		anim.play("idle")

	velocity = direction * SPEED
	move_and_slide()
