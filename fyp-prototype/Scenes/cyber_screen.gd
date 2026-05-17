extends Node3D
var CubeScene = preload("res://Scenes/cyber_cube.tscn")

func _ready() -> void:
	for i in range(10):
		var cube = CubeScene.instantiate()
		add_child(cube)
		cube.position = Vector3(i * 2, 137, (i * 2)+144)
