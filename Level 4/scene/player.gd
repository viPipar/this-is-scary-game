extends CharacterBody2D
@onready var anim: AnimatedSprite2D = $Sprite2D

const SPEED = 400.0

func _physics_process(delta: float) -> void:
	var direction := Vector2.ZERO

	# Biar kecepatan diagonal tetap konsisten
	if direction != Vector2.ZERO:
		direction = direction.normalized()
	else:
		anim.play("idle")

	velocity = direction * SPEED
	move_and_slide()
