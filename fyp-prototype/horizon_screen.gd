extends Node3D

func _physics_process(delta: float) -> void:
	$Camera3D.rotate(Vector3.DOWN,0.2*delta)
