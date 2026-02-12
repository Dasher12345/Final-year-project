extends Node3D

@export var player1_path: NodePath
@export var mouse_sensitivity := 0.002

var player1: Node = null

func _ready() -> void:
	player1 = get_node(player1_path)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and player1:
		# Yaw (left/right)
		player1.rotate_y(-event.relative.x * mouse_sensitivity)

		# Pitch (up/down) - assumes player1 has look_x and cam_pivot like your script
		player1.look_x -= event.relative.y * mouse_sensitivity
		player1.look_x = clamp(player1.look_x, -1.2, 1.2)
		player1.cam_pivot.rotation.x = player1.look_x
