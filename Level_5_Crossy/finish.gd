extends Area2D

# Pastikan sinyal body_entered sudah terhubung ke fungsi ini
func _on_body_entered(body: Node2D) -> void:
	# Cek apakah yang masuk adalah "Daughter"
	# Pastikan nama node di Scene Tree benar-benar "Daughter" atau gunakan Group
	if body.name == "Daughter":
		print("Finish tersentuh!")
		
		# Cek apakah script Daughter punya fungsi 'freeze_character'
		if body.has_method("freeze_character"):
			body.freeze_character() # <--- Panggil fungsi di script Daughter tadi
