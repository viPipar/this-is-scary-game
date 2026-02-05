extends CharacterBody2D

var mov_speed = 750
var jump_height = -950
var gravity = 35

func _physics_process(delta: float) -> void:
	
	#basic move
	if Input.is_action_pressed("right"):
		velocity.x = mov_speed
	elif Input.is_action_pressed("left"):
		velocity.x = -mov_speed
	else:
		velocity.x = 0
	
	#jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_height
		
	#gravity
	if not is_on_floor():
		velocity.y += gravity
	
	move_and_slide()
