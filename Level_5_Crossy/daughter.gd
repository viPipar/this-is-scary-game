extends CharacterBody2D

# --- KONFIGURASI ---
@export var tile_size = 64

# --- REFERENSI ---
@onready var sprite = $AnimatedSprite2D

# --- VARIABEL ---
var is_moving = false
var is_frozen = false # <--- 1. TAMBAHKAN VARIABEL INI

func _physics_process(_delta):
	# 2. CEK STATUS BEKU
	# Jika frozen, langsung berhenti, jangan cek input apa-apa lagi
	if is_frozen:
		return

	if is_moving:
		return

	if Input.is_action_just_pressed("forward"):
		sprite.play("forward")
		move(Vector2.UP)

func move(direction: Vector2):
	is_moving = true
	var target_pos = position + (direction * tile_size)
	var duration = 0.1
	
	var tween = create_tween()
	tween.tween_property(self, "position", target_pos, duration).set_trans(Tween.TRANS_SINE)
	
	var jump_tween = create_tween()
	jump_tween.tween_property(sprite, "position:y", -10, duration / 2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	jump_tween.tween_property(sprite, "position:y", 0, duration / 2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	
	await tween.finished
	is_moving = false

# --- 3. FUNGSI UNTUK DIPANGGIL OLEH AREA2D ---
func freeze_character():
	is_frozen = true
	print("Daughter membeku di garis finish!")
	# Kamu bisa tambah animasi menang di sini, misal:
	# sprite.play("win_pose")
	
func crash():
	$Scream.play()
	await get_tree().create_timer(0.25).timeout
	$Crash.play()
	
