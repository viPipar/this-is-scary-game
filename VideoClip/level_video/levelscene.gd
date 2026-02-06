extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().create_timer(3.5).timeout
	$fade/fadeplay.play("video_transition")
	await get_tree().create_timer(1.0).timeout
	$"1".visible=false
	
	await get_tree().create_timer(3.5).timeout
	$fade/fadeplay.play("video_transition")
	await get_tree().create_timer(1.0).timeout
	$"2".visible=false
	
	await get_tree().create_timer(3.5).timeout
	$fade/fadeplay.play("video_transition")
	await get_tree().create_timer(1.0).timeout
	$"3".visible=false
	
	await get_tree().create_timer(3.5).timeout
	$fade/fadeplay.play("video_transition")
	await get_tree().create_timer(1.0).timeout
	$"4".visible=false
	
	await get_tree().create_timer(3.5).timeout
	$fade/fadeplay.play("video_transition")
	await get_tree().create_timer(1.0).timeout
	$"5".visible=false
	
	await get_tree().create_timer(3.5).timeout
	$fade/fadeplay.play("video_transition")
	await get_tree().create_timer(1.0).timeout
	$"6".visible=false
	
	await get_tree().create_timer(3.5).timeout
	$fade/fadeplay.play("video_transition")
	await get_tree().create_timer(1.0).timeout
	$"7".visible=false
	
	await get_tree().create_timer(5.5).timeout	
	SceneTransition.change_scene("res://VideoClip/outro/outro.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
