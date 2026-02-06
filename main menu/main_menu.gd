extends Node2D


func _on_start_pressed() -> void:
	$Click.play()
	SceneTransition.change_scene("res://VideoClip/intro/intro.tscn")


func _on_how_to_play_pressed() -> void:
	$Click.play()
	$Control.visible = !$Control.visible

func _on_credit_pressed() -> void:
	$Click.play()
	SceneTransition.change_scene("res://main menu/credit_scene.tscn")

func _on_exit_pressed() -> void:
	$Click.play()
	get_tree().quit()

func _on_x_pressed() -> void:
	$Click.play()
	$Control.visible = !$Control.visible
