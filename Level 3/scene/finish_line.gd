extends Area2D


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		SceneTransition.change_scene("res://Level 4/scene/world.tscn")
