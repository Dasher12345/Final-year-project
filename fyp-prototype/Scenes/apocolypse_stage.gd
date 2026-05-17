extends Node3D
var final_checkpoint = false
var current_checkpoint_p1
var current_checkpoint_p2

var p1
var p2

func _ready():
	await get_tree().process_frame
	p1 = $LevelGenerator.p1
	current_checkpoint_p1 = p1.global_transform
	if LevelOptions.mult:
		p2 = $LevelGenerator.p2
		current_checkpoint_p2 = p2.global_transform
		print(p2.global_position)
	print(p1.global_position)
	respawn()
	$Stage_OST.play()
	resume()

func _input(event):
	await get_tree().process_frame
	$LevelGenerator.p1._input(event)

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("pause") and get_tree().paused == false:
		pause_menu()
	elif Input.is_action_just_pressed("pause") and get_tree().paused == true:
		resume()
	if final_checkpoint:
		$Stage_OST.stop()
		$Final_Checkpoint.play()
	if p1 and p1.global_position.y <= 300:
		respawn()

	if p2 and LevelOptions.mult and p2.global_position.y <= 300:
		respawn()
		
func pause_menu():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().paused = true
	$CanvasLayer.show()
	$CanvasLayer/Resume.disabled = false
	$CanvasLayer/Quit.disabled = false
	$Stage_OST.volume_db = -10
	
func resume():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	get_tree().paused = false
	$CanvasLayer.hide()
	$CanvasLayer/Resume.disabled = true
	$CanvasLayer/Quit.disabled = true
	$Stage_OST.volume_db = 0
	

func _on_resume_pressed() -> void:
	resume()

func _on_quit_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")

func _on_checkpoint_reached():
	final_checkpoint = true
	print("checkpoint")

func respawn():
	if p1:
		p1.global_transform = current_checkpoint_p1

	if p2 and LevelOptions.mult:
		p2.global_transform = current_checkpoint_p2
		
func set_checkpoint(pos):
	current_checkpoint_p1 = pos
