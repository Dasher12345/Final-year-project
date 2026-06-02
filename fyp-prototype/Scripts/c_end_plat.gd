extends Node3D

var p1 = false
var p2 = false
var winner
var complete

func _ready() -> void:
	complete = false
	
func finish():
	complete = true
	var tween = create_tween()
	tween.tween_property($finish,"position:x",137,0.3)
	tween.tween_property($finish,"position:x",592,1)
	tween.tween_property($finish,"position:x",3000,0.3)
	if p1:
		winner = $p1
	else:
		winner = $p2
	tween.tween_property(winner,"modulate:a",1.0,1.0)
	tween.tween_interval(2.0)
	tween.tween_property(winner,"modulate:a",0.0,1.0)
	await tween.finished
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
		
func _on_checkpoint_body_entered(body: Node3D) -> void:
	if body.is_in_group("players"):
		$Camera3D.make_current()
		print("End Reached")
		if body.name == "P1":
			p1 = true
		else:
			p2 = true
		finish()
