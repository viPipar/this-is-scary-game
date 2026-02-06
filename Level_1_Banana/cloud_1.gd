extends ParallaxLayer

var speed = -50

func _process(delta: float) -> void:
	self.motion_offset.x += speed * delta
