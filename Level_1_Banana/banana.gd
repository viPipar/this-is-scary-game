extends Area2D

# Variabel untuk menyimpan target yang akan diikuti
var target_to_follow: Node2D = null

# --- VARIABEL FISIKA BARU ---
var velocity = Vector2.ZERO
var grav = 1500.0 
var is_kicked = false 

# [BARU] Variabel untuk menyimpan kecepatan putaran saat ini
var current_rotation_speed = 0.0 

# --- REFERENSI NODE ANAK (Wajib disesuaikan dengan nama di Scene Tree) ---
@onready var scan_area_node = $ScanArea  
@onready var pass_area_node = $PassArea

func _process(delta):
	# 1. LOGIKA MENGIKUTI (Sebelum ditendang)
	if target_to_follow != null and not is_kicked:
		global_position.x = target_to_follow.global_position.x
	
	# 2. LOGIKA SETELAH DITENDANG (Fisika Jatuh & PUTARAN)
	if is_kicked:
		# --- [BARU] LOGIKA PUTARAN ---
		# Menambahkan nilai rotasi setiap frame berdasarkan kecepatan putar dan delta time
		rotation_degrees += current_rotation_speed * delta
		# -----------------------------

		# Fisika Jatuh
		velocity.y += grav * delta
		global_position += velocity * delta
		
		if velocity.y > 2000:
			print("Banana hilang karena terlalu cepat jatuh")
			queue_free()

func _on_scan_area_body_entered(body: Node2D) -> void:
	if body.name == "Father":
		print("Father ditemukan, mulai mengikuti...")
		target_to_follow = body
		
		# REQUEST KAMU: Jika Scan kena, matikan PassArea
		# (PERINGATAN: Pastikan area Scan lebih kecil dari Pass, kalau tidak, pisang tidak akan pernah bisa ditendang)
		if pass_area_node:
			pass_area_node.set_deferred("monitoring", false)
			print("PassArea dinonaktifkan sementara.")

func _on_pass_area_body_entered(body: Node2D) -> void:
	if body.name == "Father" and not is_kicked:
		print("Father berhasil nendang banana!")
		is_kicked = true 
		
		# Atur tenaga tendangan
		velocity.y = -1200 
		velocity.x = randf_range(-200, 200)
		
		# --- [BARU] ATUR KECEPATAN PUTARAN AWAL ---
		# Pilih kecepatan acak antara -720 sampai 720 derajat per detik
		# (Negatif = putar kiri, Positif = putar kanan)
		current_rotation_speed = randf_range(-720.0, 720.0)
		# -----------------------------------------

		# REQUEST KAMU: Jika Pass kena (ditendang), matikan ScanArea
		if scan_area_node:
			scan_area_node.set_deferred("monitoring", false)
			target_to_follow = null 
			print("ScanArea dinonaktifkan.")
