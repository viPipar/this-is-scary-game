extends CharacterBody2D

# --- KONFIGURASI ---
@export var tile_size = 64  # Jarak 1 lompatan (pixel)

# --- REFERENSI ---
@onready var sprite = $AnimatedSprite2D 

# --- VARIABEL ---
var is_moving = false 

func _physics_process(_delta):
	# 1. Cek apakah sedang bergerak
	# Kita tetap butuh ini agar posisi Grid tidak berantakan (tidak "tanggung" di tengah jalan)
	if is_moving:
		return

	# 2. Cek Input (PAKAI JUST_PRESSED)
	# 'just_pressed' artinya hanya mendeteksi "klik" pertama. 
	# Kalau ditahan, dia tidak akan dianggap True.
	if Input.is_action_just_pressed("forward"):
		move(Vector2.UP)
	elif Input.is_action_just_pressed("back"):
		move(Vector2.DOWN)
	# Tambahkan kiri kanan jika perlu
	elif Input.is_action_just_pressed("left"):
		move(Vector2.LEFT)
	elif Input.is_action_just_pressed("right"):
		move(Vector2.RIGHT)

func move(direction: Vector2):
	is_moving = true
	
	# Hitung tujuan
	var target_pos = position + (direction * tile_size)
	
	# Tentukan kecepatan animasi (Makin kecil makin cepat/snappy)
	# 0.1 detik itu sangat cepat, hampir instan, cocok untuk "tap tap"
	var duration = 0.1 
	
	# --- TWEEN POSISI ---
	var tween = create_tween()
	tween.tween_property(self, "position", target_pos, duration).set_trans(Tween.TRANS_SINE)
	
	# --- TWEEN LOMPAT ---
	var jump_tween = create_tween()
	# Naik
	jump_tween.tween_property(sprite, "position:y", -10, duration / 2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	# Turun
	jump_tween.tween_property(sprite, "position:y", 0, duration / 2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	
	# Tunggu animasi selesai baru bisa tap lagi
	await tween.finished
	is_moving = false
