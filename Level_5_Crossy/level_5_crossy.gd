extends Node2D


func _on_finish_body_entered(body: Node2D) -> void:
	if body.name == "Daughter":
		print("Daughter finish!")
