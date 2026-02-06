extends Sprite2D

var tween: Tween
var moved := false

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if moved:
		return
		
	if Input.is_action_just_pressed("ui_accept") or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		move_down()

func move_down():
	moved = true
	
	tween = create_tween()
	tween.tween_property(self, "position:y", position.y + 5000, 2.0)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN_OUT)
