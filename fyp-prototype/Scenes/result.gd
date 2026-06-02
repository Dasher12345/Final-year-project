extends Node3D

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	stage()
	show_stats()
	$OST.play()
	
func stage():
	if LevelOptions.stage == "h":
		$Cyber.visible = false
		$Node3D2.visible = false
		$Node3D.visible = true
	elif LevelOptions.stage == "c":
		$Cyber.visible = true
		$Node3D2.visible = false
		$Node3D.visible = false
	elif LevelOptions.stage == "a":
		$Cyber.visible = false
		$Node3D2.visible = true
		$Node3D.visible = false

func show_stats():
	var data = Statsmanager.data
	var key := str(LevelOptions.seed)
	var best = data[key]["best"]
	var seed = key
	$Seed.text = "SEED: %d" % LevelOptions.seed
	$Time.text = "YOUR TIME: %d" % Statsmanager.complete_time
	$Best.text = "BEST TIME: %d" % best

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")


func _on_retry_pressed() -> void:
	var loadingscreen = load("res://Scenes/loading_screen.tscn")
	get_tree().change_scene_to_packed(loadingscreen)
