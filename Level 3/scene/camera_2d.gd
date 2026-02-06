extends Camera2D

@export var auto_zoom_speed := 0.0001
@export var zoom_speed := 0.1
@export var min_zoom := 0.4
@export var max_zoom := 4.0

var counter := 1.0

func _physics_process(delta: float) -> void:
	counter += 0.001
	zoom += Vector2(auto_zoom_speed * counter, auto_zoom_speed * counter)
	zoom.x = clamp(zoom.x, min_zoom, max_zoom)
	zoom.y = clamp(zoom.y, min_zoom, max_zoom)
	
	if zoom == Vector2(max_zoom,max_zoom):
		print("kejepit")
	
func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_pressed("scroll"):
		zoom -= Vector2(zoom_speed, zoom_speed)
		zoom.x = clamp(zoom.x, min_zoom, max_zoom)
		zoom.y = clamp(zoom.y, min_zoom, max_zoom)
