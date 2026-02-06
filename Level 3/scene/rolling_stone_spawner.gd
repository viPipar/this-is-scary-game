extends Node2D

@export var rolling_stone_scene: PackedScene
@export var spawn_area_min := Vector2(3000, -300)
@export var spawn_area_max := Vector2(6000, 0)
@export var spawn_interval := 1.5
@export var world_bounds := Rect2(
	Vector2(0, -300),
	Vector2(21000, 2700)
)



func _ready():
	randomize()
	_spawn_loop()

func _spawn_loop():
	while true:
		spawn_rolling_stone()
		await get_tree().create_timer(spawn_interval).timeout

func spawn_rolling_stone():

	var stone = rolling_stone_scene.instantiate()
	stone.world_bounds = world_bounds
	
	var x = randf_range(spawn_area_min.x, spawn_area_max.x)
	var y = randf_range(spawn_area_min.y, spawn_area_max.y)

	stone.global_position = Vector2(x, y)
	add_child(stone)
