extends Node3D

@export var min_z := -300.0
@export var max_z := -155.0
@export var speed := 20.0

var direction := -1

var current_checkpoint_p1 = Vector3(5.959,579.666,1.216)
var current_checkpoint_p2 = Vector3(5.959,579.666,-1.015)
var final_reached = false

@onready var p1 = $GridContainer/SubViewportContainer/SubViewport/P1
@onready var p2 = $GridContainer/SubViewportContainer2/SubViewport/P2
var p1_com = false
var p2_com = false
var p1_time = 0
var p2_time = 0

func _ready() -> void:
	p1.position = current_checkpoint_p1
	p2.position = current_checkpoint_p2
	$Stage_OST.play()
	resume()

func _physics_process(delta):
	if Input.is_action_just_pressed("pause") and get_tree().paused == false:
		pause_menu()
	elif Input.is_action_just_pressed("pause") and get_tree().paused == true:
		resume()
		
	if p1.position.y <= 300:
		p1.position = current_checkpoint_p1
	if p2.position.y <= 300:
		p2.position = current_checkpoint_p2
	if p1_com or p2_com:
		await get_tree().create_timer(5).timeout
		get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")

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


func _on_first_checkpoint_body_entered(body: CharacterBody3D) -> void:
	if body == $GridContainer/SubViewportContainer/SubViewport/P1:
		current_checkpoint_p1 = Vector3(-356,589,-37)
	if body == $GridContainer/SubViewportContainer2/SubViewport/P2:
		current_checkpoint_p2 = Vector3(-356,589,-35)


func _on_checkpoint_2_body_entered(body: CharacterBody3D) -> void:
	if body == $GridContainer/SubViewportContainer/SubViewport/P1:
		current_checkpoint_p1 = Vector3(-242,616,70)
	if body == $GridContainer/SubViewportContainer2/SubViewport/P2:
		current_checkpoint_p2 = Vector3(-242,616,68)


func _on_finalcheckpoint_body_entered(body: CharacterBody3D) -> void:
	if not final_reached:
		$Stage_OST.stop()
		$Final_Checkpoint.play()
		final_reached = true
	if body == $GridContainer/SubViewportContainer/SubViewport/P1:
		current_checkpoint_p1 = Vector3(-348,712,489)
	if body == $GridContainer/SubViewportContainer2/SubViewport/P2:
		current_checkpoint_p2 = Vector3(-349,712,489)
	


func _on_finishline_body_entered(body: CharacterBody3D) -> void:
	if body == $GridContainer/SubViewportContainer/SubViewport/P1:
		p1_com = true
		$p1Timer.paused = true
		$ColorRect.show()
		$p1complete.show()
		$p1finaltime.text = "Final Time: %ds" % p1_time
		$p1finaltime.show()
	if body == $GridContainer/SubViewportContainer2/SubViewport/P2:
		p2_com = true
		$p2Timer.paused = true
		$ColorRect2.show()
		$p2complete.show()
		$p2finaltime.text = "Fina; Time: %ds" % p2_time
		$p2finaltime.show()


func _on_p_1_timer_timeout() -> void:
	p1_time += 1
	$p1Time.text = "Time: %ds" % p1_time
	

func _on_p_2_timer_timeout() -> void:
	p2_time += 1
	$p2Time.text = "Time: %ds" % p2_time
