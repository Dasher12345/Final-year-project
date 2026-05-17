extends Node3D

var check_1 = false
var check_2 = false

func _on_checkpoint_body_entered(body: Node3D) -> void:
	if body.is_in_group("players"):
		if body.name == "P1" and !check_1:
			get_tree().current_scene.set_checkpoint(body.global_transform)
			check_1 = true
			print("player reached checkpoint")
		if body.name == "P2" and !check_2:
			get_tree().current_scene.set_checkpoint(body.global_transform)
			check_2 = true
			print("player 2 reached checkpoint")
