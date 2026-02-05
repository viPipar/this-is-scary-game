extends CharacterBody2D

# --- KONFIGURASI BATAS & KECEPATAN ---
@export var speed = 100.0
@export var limit_left = -200.0   # Batas Kiri
@export var limit_right = 2000.0  # Batas Kanan

# --- REFERENSI NODE ---
@onready var anim = $AnimatedSprite2D 

# Variabel Arah (1 = Kanan, -1 = Kiri)
# Kita mulai dengan jalan ke Kanan (1)
var direction = 1 

func _physics_process(delta):
	# 1. CEK POSISI & TENTUKAN ARAH
	# Jika posisi saat ini melebihi batas kanan -> Suruh ke Kiri (-1)
	if global_position.x >= limit_right:
		direction = -1
		
	# Jika posisi saat ini kurang dari batas kiri -> Suruh ke Kanan (1)
	elif global_position.x <= limit_left:
		direction = 1

	# 2. GERAKKAN KARAKTER
	velocity.x = direction * speed
	velocity.y = 0 # Kalau mau dia melayang/tidak jatuh (NPC Top Down)
	
	# Jika ini game platformer (samping) dan butuh gravitasi, tambahkan ini:
	# if not is_on_floor(): velocity.y += 980 * delta
	
	move_and_slide()
	
	# 3. UPDATE ANIMASI
	update_animation()

func update_animation():
	if anim:
		anim.play("move") # Pastikan nama animasinya sesuai
		
		# Flip Sprite sesuai arah
		if direction > 0:
			anim.flip_h = false # Hadap Kanan
		else:
			anim.flip_h = true  # Hadap Kiri
