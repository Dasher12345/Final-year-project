extends Node3D

var p1 = false
var p2 = false
var winner
var complete

func _ready() -> void:
	open_gates()
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
	close_gates()
		
func _on_checkpoint_body_entered(body: Node3D) -> void:
	if body.is_in_group("players"):
		$Camera3D.make_current()
		print("End Reached")
		if body.name == "P1":
			p1 = true
		else:
			p2 = true
		finish()
	
func open_gates():
	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property($Gate1,"position:y",0,0.5)
	tween.tween_property($Gate2,"position:y",1078,0.5)

func close_gates():
	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property($Gate1,"position:y",542,0.5)
	tween.tween_property($Gate2,"position:y",539.105,0.5)
	tween.tween_property($AudioStreamPlayer2D,"volume_db",-40,2)
	await tween.finished
	await get_tree().process_frame
	get_tree().change_scene_to_file("res://Scenes/result.tscn")
