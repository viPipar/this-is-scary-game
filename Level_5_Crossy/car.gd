extends Sprite2D

# Variabel kecepatan dan status
var speed = 4000.0 
var is_moving = false # Awalnya diam

func _process(delta):
	# Jika saklar menyala, mobil bergerak ke kanan
	if is_moving:
		position.x += speed * delta

# Fungsi ini nanti akan "ditekan" oleh script Finish
func mulai_jalan():
	is_moving = true
	# Opsional: Mainkan suara mesin jika ada
	# $EngineSound.play()
