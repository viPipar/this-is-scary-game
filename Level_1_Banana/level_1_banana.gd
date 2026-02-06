extends Node2D


func _on_banana_body_entered(body: Node2D) -> void:
	if body.name == "Father":
		print("Father mati")


func _on_finish_body_entered(body: Node2D) -> void:
	if body.name == "Father":
		await get_tree().create_timer(2.0).timeout
		print("Father menang")
		$CanvasLayer.visible = true
		$CanvasLayer/ColorRect/AnimationPlayer.play("restart_game")
		await get_tree().create_timer(1.0).timeout
		get_tree().change_scene_to_file("res://Level 2/scene/Level 2.tscn")
