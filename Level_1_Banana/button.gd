extends Button

func _pressed():
	# Kode ini otomatis jalan saat tombol dipencet
	print("Game Diulang!")
	get_tree().reload_current_scene()
