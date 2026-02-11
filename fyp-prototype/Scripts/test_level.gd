extends Node3D

@export var min_z := -300.0
@export var max_z := -155.0
@export var speed := 20.0

var direction := -1

func _ready() -> void:
	$Stage_OST.play()
	resume()

func _physics_process(delta):
	if Input.is_action_just_pressed("pause") and get_tree().paused == false:
		pause_menu()
	elif Input.is_action_just_pressed("pause") and get_tree().paused == true:
		resume()
		
	var box = $CSGCombiner3D/CSGBox3D9
	
	box.position.z += direction * speed * delta

	# Change direction at limits
	if box.position.z <= min_z:
		box.position.z = min_z
		direction = 1

	elif box.position.z >= max_z:
		box.position.z = max_z
		direction = -1

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


func _on_quit_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")


func _on_resume_pressed() -> void:
	resume()
