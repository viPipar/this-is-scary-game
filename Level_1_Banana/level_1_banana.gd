extends Node2D


func _on_banana_body_entered(body: Node2D) -> void:
	if body.name == "Father":
		print("Father mati")


func _on_finish_body_entered(body: Node2D) -> void:
	if body.name == "Father":
		await get_tree().create_timer(2.0).timeout
		print("Father menang")
