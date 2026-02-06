extends Node2D


func _on_start_pressed() -> void:
	SceneTransition.change_scene("res://VideoClip/intro/intro.tscn")

func _on_how_to_play_pressed() -> void:
	$Control.visible = !$Control.visible

func _on_credit_pressed() -> void:
	SceneTransition.change_scene("res://ui/ui_scene/splash_screen.tscn")

func _on_exit_pressed() -> void:
	get_tree().quit()

func _on_x_pressed() -> void:
	$Control.visible = !$Control.visible
