extends Area2D

# Variabel Target
var target_to_follow: Node2D = null

# --- VARIABEL FISIKA ---
var velocity = Vector2.ZERO
var grav = 1500.0 
var is_kicked = false 
var current_rotation_speed = 0.0 

# --- STATUS ---
# Variable untuk memastikan player aman
var is_safe_pass = false

# --- REFERENSI NODE ---
@onready var scan_area_node = $ScanArea  
@onready var pass_area_node = $PassArea

func _ready():
	# Pastikan sinyal body_entered dari Area2D (Banana) terhubung ke fungsi ini
	# Jika sudah connect via editor, baris di bawah ini tidak wajib, tapi aman untuk jaga-jaga
	if not is_connected("body_entered", _on_banana_body_entered):
		connect("body_entered", _on_banana_body_entered)

func _process(delta):
	# 1. LOGIKA MENGIKUTI (Hanya jika punya target, belum ditendang, dan bukan safe pass)
	if target_to_follow != null and not is_kicked and not is_safe_pass:
		global_position.x = target_to_follow.global_position.x
	
	# 2. LOGIKA JATUH (Jika ditendang/efek physics)
	if is_kicked:
		# Putar banana
		rotation_degrees += current_rotation_speed * delta
		
		# Terapkan gravitasi
		velocity.y += grav * delta
		global_position += velocity * delta
		
		# Hapus jika jatuh terlalu jauh ke bawah
		if velocity.y > 2000:
			queue_free()

# --- 1. LOGIKA KILL/FREEZE (Banana Utama) ---
func _on_banana_body_entered(body: Node2D) -> void:
	# Jika kena Father...
	if body.name == "Father":
		# ...dan Father TIDAK dalam kondisi "safe pass" (gagal lewat)
		if is_safe_pass:
			pass
		else:
			print("Father menginjak Banana! Membekukan Player...")
			
			# [BAGIAN PENTING]
			# Cek apakah si 'body' (Father) punya fungsi bernama 'freeze_player'
			# Ini adalah cara Banana "memberi sinyal" ke Father
			if body.has_method("freeze_player"):
				body.freeze_player(2.0) # Panggil fungsi di script Father dengan durasi 2 detik
			
			# Opsional: Hapus banana setelah diinjak agar tidak memicu freeze berkali-kali
			queue_free()

# --- 2. LOGIKA FOLLOW (ScanArea) ---
func _on_scan_area_body_entered(body: Node2D) -> void:
	# Jika sudah safe pass, abaikan scan (jangan ikutin lagi)
	if is_safe_pass:
		return

	if body.name == "Father":
		target_to_follow = body
		# Opsional: Matikan PassArea jika sudah terlanjur dikejar
		if pass_area_node:
			pass_area_node.set_deferred("monitoring", false)

# --- 3. LOGIKA AMAN & TENDANG (PassArea) ---
func _on_pass_area_body_entered(body: Node2D) -> void:
	if body.name == "Father":
		print("Father melewati PassArea! Banana ditendang!")
		
		# A. Status Aman
		is_safe_pass = true
		target_to_follow = null 
		
		# B. Logika Fisika Tendangan (KICK EFFECT)
		is_kicked = true
		
		# 1. Loncat ke atas (Nilai negatif = ke atas)
		velocity.y = -1000.0 
		
		# 2. Terlempar ke samping acak (Kiri atau Kanan)
		velocity.x = randf_range(-300.0, 300.0)
		
		# 3. Berputar acak
		current_rotation_speed = randf_range(-720.0, 720.0)

		# C. Matikan Sensor (Agar tidak bisa membunuh atau menscan lagi)
		if scan_area_node:
			scan_area_node.set_deferred("monitoring", false)
			
		# Matikan collision Banana utama agar tidak membunuh player saat terpental
		set_deferred("monitoring", false) 
		set_deferred("monitorable", false)
