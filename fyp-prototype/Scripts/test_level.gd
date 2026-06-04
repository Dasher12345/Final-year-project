extends Node3D
var p1
var respawn_pos
var ins = false

func _ready():
	p1 = $start_platform.get_node("P1")
	respawn_pos = p1.global_transform
	$Stage_OST.play()
	resume()
	
func _physics_process(delta: float) -> void:
	if p1 and p1.global_position.y <= 100:
		respawn()

func pause_menu():
	$Button3.play()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().paused = true
	$Resume.show()
	$Quit.show()
	$Pause.show()
	$Panel.hide()
	$Stage_OST.volume_db = -10
	
func resume():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	get_tree().paused = false
	$Resume.hide()
	$Quit.hide()
	$Pause.hide()
	$Panel.show()
	$Stage_OST.volume_db = 0

func respawn():
	p1.global_transform = respawn_pos

func _unhandled_input(event):
	if event.is_action_pressed("pause"):
		if get_tree().paused:
			resume()
		else:
			pause_menu()
	if event.is_action_pressed("instructions"):
		if ins:
			$Instructions.hide()
			ins = false
		else:
			$Instructions.show()
			ins = true
			
func _on_resume_pressed() -> void:
	$Button1.play()
	resume()


func _on_quit_pressed() -> void:
	get_tree().paused = false
	$Button1.play()
	LevelOptions.tutorial = false
	close()

func close():
	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property($Gate1,"position:y",542,0.5)
	tween.tween_property($Gate2,"position:y",539.105,0.5)
	tween.tween_property($AudioStreamPlayer2D,"volume_db",-40,2)
	await tween.finished
	await get_tree().process_frame
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
