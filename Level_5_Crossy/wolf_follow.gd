extends CharacterBody2D

# --- KONFIGURASI ---
@export var speed = 300.0
@onready var anim = $AnimatedSprite2D # Pastikan punya AnimatedSprite2D

# Variabel untuk menyimpan target
var target: Node2D = null

func _physics_process(delta):
	# 1. Jika belum punya target, cari dulu
	if target == null:
		find_target()
	
	# 2. Jika target sudah ditemukan, KEJAR!
	if target != null:
		# Hitung arah ke target
		var direction = (target.global_position - global_position).normalized()
		
		# --- LOGIKA FLIP GAMBAR ---
		# Jika arah X negatif (< 0) berarti ke KIRI -> Flip True
		if direction.x < 0:
			anim.flip_h = true
		# Jika arah X positif (> 0) berarti ke KANAN -> Flip False (Normal)
		elif direction.x > 0:
			anim.flip_h = false
		# --------------------------
		
		# Opsional: Mainkan animasi lari jika bergerak
		# anim.play("run") 
		
		# Gerakkan body
		velocity = direction * speed
		move_and_slide()
		
	else:
		# Jika tidak ada target, diam
		velocity = Vector2.ZERO
		move_and_slide()
		anim.play("idle")

func find_target():
	var targets_in_group = get_tree().get_nodes_in_group("daughter")
	
	if targets_in_group.size() > 0:
		target = targets_in_group[0]
		print("Target ditemukan via Grup: ", target.name)
		return


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Daughter":
		print("Daughter died!")
