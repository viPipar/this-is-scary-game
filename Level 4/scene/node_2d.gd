extends Node2D
@onready var anim: AnimationPlayer = $"../AnimationPlayer"

func _ready():
	get_tree().paused = true

func _unhandled_input(event):
	if event.is_action_pressed("scroll"):
		get_tree().paused = true
	if event.is_action_pressed("left"):
		get_tree().paused = false

#anim.play("run")
#anim.play("hide")
#anim.play("fight")
