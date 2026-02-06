extends Node2D


func _on_finish_body_entered(body: Node2D) -> void:
	if body.name == "Daughter":
		print("Daughter finish!")
		body.crash()


func _on_death_body_entered(body: Node2D) -> void:
	$CanvasLayer.visible = true
	$CanvasLayer/ColorRect.visible = true
