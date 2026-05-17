extends MeshInstance3D

func _physics_process(delta: float) -> void:
	$".".rotate_y(0.2*delta)
	$".".rotate_z(0.2*delta)
	$".".rotate_x(0.2*delta)
