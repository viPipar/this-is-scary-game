extends CharacterBody2D

var mov_speed = 500
var jump_height = -950
var gravity = 35
var is_frozen = false

@onready var boom: AudioStreamPlayer = $Boom
@onready var fall: AudioStreamPlayer = $Fall
@onready var walk_audio: AudioStreamPlayer = $Walk
@onready var boing_audio: AudioStreamPlayer = $Boing
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	
	# 1. LOGIKA FREEZE (Saat kena Banana)
	if is_frozen:
		velocity.x = 0
		if not is_on_floor():
			velocity.y += gravity
		
		# Mainkan animasi Fall saat menginjak banana/frozen
		animated_sprite_2d.play("fall")
		
		if walk_audio.playing:
			walk_audio.stop()
			
		move_and_slide()
		return

	# 2. BASIC MOVE
	if Input.is_action_pressed("right"):
		velocity.x = mov_speed
		animated_sprite_2d.flip_h = false # Hadap kanan
	elif Input.is_action_pressed("left"):
		velocity.x = -mov_speed
		animated_sprite_2d.flip_h = true  # Hadap kiri (Flip H)
	else:
		velocity.x = 0
	
	# 3. JUMP
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_height
		boing_audio.play()
		
	# 4. GRAVITY
	if not is_on_floor():
		velocity.y += gravity
	
	move_and_slide()
	
	# 5. LOGIKA ANIMASI & AUDIO
	update_animations()

func update_animations():
	# Cek apakah sedang di udara (Melompat/Jatuh biasa)
	if not is_on_floor():
		# Jika sedang naik pakai animasi jump, jika turun pakai fall
		if velocity.y < 0:
			animated_sprite_2d.play("jump")
		
		if walk_audio.playing:
			walk_audio.stop()
			
	# Cek apakah sedang di lantai
	else:
		if velocity.x != 0:
			animated_sprite_2d.play("walk")
			if not walk_audio.playing:
				walk_audio.play()
		else:
			animated_sprite_2d.play("idle")
			if walk_audio.playing:
				walk_audio.stop()

# Fungsi untuk dipanggil Banana
func freeze_player(duration: float):
	is_frozen = true
	fall.play()
	await get_tree().create_timer(0.5).timeout
	boom.play()
	await get_tree().create_timer(1.5).timeout
	
	modulate = Color(1, 1, 1)
