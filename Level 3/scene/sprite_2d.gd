extends Sprite2D

var tween: Tween
var moved := false

func _ready() -> void:
	# Pause game saat mulai
	get_tree().paused = true
	# Supaya Sprite2D ini tetap bisa menerima input walau game pause
	process_mode = Node.PROCESS_MODE_ALWAYS

func _process(delta: float) -> void:
	if moved:
		return
		
	# Klik untuk mulai game + gerakkan sprite
	if Input.is_action_just_pressed("ui_accept") or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		get_tree().paused = false   # resume game
		move_down()

func move_down():
	moved = true
	
	tween = create_tween()
	tween.tween_property(self, "position:y", position.y + 5000, 2.0)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN_OUT)
