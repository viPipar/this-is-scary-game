extends Area2D
@onready var car_object: Sprite2D = $"../Car"

# Pastikan sinyal body_entered sudah terhubung ke fungsi ini
func _on_body_entered(body: Node2D) -> void:
	# Cek apakah yang masuk adalah "Daughter"
	# Pastikan nama node di Scene Tree benar-benar "Daughter" atau gunakan Group
	if body.name == "Daughter":
		print("Finish tersentuh!")
		SceneTransition.change_scene("res://VideoClip/level_video/levelscene.tscn")
		# Cek apakah script Daughter punya fungsi 'freeze_character'
	# Cek apakah kita sudah memasukkan node Car di Inspector?
		if car_object != null:
			# Panggil fungsi 'mulai_jalan' yang ada di script Car
			if car_object.has_method("mulai_jalan"):
				car_object.mulai_jalan()
		else:
			print("LUPA MEMASUKKAN NODE CAR DI INSPECTOR!")
		
		if body.has_method("freeze_character"):
			body.freeze_character() # <--- Panggil fungsi di script Daughter tadi
