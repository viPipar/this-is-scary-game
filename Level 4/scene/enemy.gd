extends CharacterBody2D

@export var speed: float = 400
@export var player_path: NodePath

var player: CharacterBody2D

func _ready() -> void:
	player = get_node(player_path)

func _physics_process(delta: float) -> void:
	if player == null:
		return

	var direction = player.global_position - global_position

	if direction.length() > 500:
		direction = direction.normalized()
		velocity = direction * speed * 1.3
	elif direction.length() > 100:
		direction = direction.normalized()
		velocity = direction * speed 
	else:
		velocity = Vector2.ZERO

	move_and_slide()
