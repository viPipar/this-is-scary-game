extends Node2D
@onready var anim: AnimationPlayer = $"../AnimationPlayer"
@onready var player: CharacterBody2D = $"../player"
@onready var canvas: CanvasLayer = $"../CanvasLayer"
@onready var run: Button = $"../CanvasLayer/run"
@onready var hide: Button = $"../CanvasLayer/hide"
@onready var fight: Button = $"../CanvasLayer/fight"

func _ready():
	get_tree().paused = true

func _on_run_pressed() -> void:
	get_tree().paused = false
	anim.play("run")
	canvas.visible = false
	await get_tree().create_timer(12.0).timeout
	get_tree().paused = true
	canvas.visible = true
	run.queue_free()

func _on_hide_pressed() -> void:
	get_tree().paused = false
	anim.play("hide")
	canvas.visible = false
	await get_tree().create_timer(12.0).timeout
	get_tree().paused = true
	canvas.visible = true
	hide.queue_free()


func _on_fight_pressed() -> void:
	get_tree().paused = false
	anim.play("fight")
	canvas.visible = false
	await get_tree().create_timer(12.0).timeout
	get_tree().paused = true
	canvas.visible = true
	fight.queue_free()


func _on_carefully_pressed() -> void:
	get_tree().paused = false
	SceneTransition.change_scene("res://Level_5_Crossy/level_5_crossy.tscn")
