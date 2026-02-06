extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var canvas: CanvasLayer = $"../CanvasLayer"

# Reference to the sprite
@onready var sprite = $AnimatedSprite3D

# References to the cameras (Make sure these paths match your Scene Tree!)
@onready var main_camera = $"../MainCamera"
@onready var fall_camera = $"../FallCamera"

var has_triggered_trap = false

func _physics_process(delta):
	# 1. Add Gravity (Movement on Y axis)
	if not is_on_floor():
		velocity.y -= gravity * delta

	# 2. TRAP LOGIC: Check for fall
	# If falling fast and not on floor, trigger the camera swap
	if not is_on_floor() and velocity.y < -2.0 and not has_triggered_trap:
		trigger_fall_trap()

	# 3. Get Input Direction (Relative to Camera)
	var input_dir = Input.get_vector("left", "right", "forward", "back")
	var direction = Vector3.ZERO
	
	# We use the CURRENT camera to determine direction.
	var camera = get_viewport().get_camera_3d()
	
	if camera and input_dir != Vector2.ZERO and not has_triggered_trap:
		var cam_basis = camera.global_transform.basis
		
		var forward_vector = -cam_basis.z
		forward_vector.y = 0
		forward_vector = forward_vector.normalized()
		
		var right_vector = cam_basis.x
		right_vector.y = 0
		right_vector = right_vector.normalized()
		
		direction = (forward_vector * input_dir.y) + (right_vector * input_dir.x)
	
	# 4. Apply Movement & Animation
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		
		# --- CHANGED: Play Walk Animation ---
		sprite.play("walk")
		
		# --- CHANGED: Flip Logic based on Input Keys ---
		# input_dir.x is -1 when pressing 'left' (A)
		# input_dir.x is 1 when pressing 'right' (D)
		if input_dir.x != 0:
			sprite.flip_h = input_dir.x < 0
			
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		
		# --- CHANGED: Play Idle Animation when stopped ---
		# Only play idle if we haven't fallen into the trap yet
		if not has_triggered_trap: 
			sprite.play("idle")

	move_and_slide()

func trigger_fall_trap():
	has_triggered_trap = true
	print("Trap Triggered! Switching cameras.")
	
	# Switch cameras
	if fall_camera:
		fall_camera.make_current()
		
		# Optional: Play a fall animation or stop animation here
		sprite.stop() 
		
		sprite.rotation_degrees = Vector3(0, 90, 0)
		sprite.billboard = BaseMaterial3D.BILLBOARD_DISABLED
	
	await get_tree().create_timer(2).timeout
	canvas.visible = true

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		# Ensure you have a singleton named SceneTransition for this to work
		if FileAccess.file_exists("res://Level 3/scene/level.tscn"):
			SceneTransition.change_scene("res://Level 3/scene/level.tscn")
		else:
			print("Scene path not found")

func _on_restart_pressed() -> void:
	get_tree().reload_current_scene()
