extends Node3D
var retry = false

func _ready() -> void:
	print("Stage is: '", LevelOptions.stage, "'")
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	stage()
	show_stats()
	open_gates()
	$OST.play()
	
func stage():
	if LevelOptions.stage == "h":
		$Cyber.visible = false
		$apocolypse.visible = false
		$Node3D.visible = true
	elif LevelOptions.stage == "c":
		$Cyber.visible = true
		$apocolypse.visible = false
		$Node3D.visible = false
	elif LevelOptions.stage == "a":
		$Node3D.visible = false
		$Cyber.visible = false
		$apocolypse.visible = true
		$Node3D/WorldEnvironment.environment = null

func show_stats():
	var data = Statsmanager.data
	var key := str(LevelOptions.seed)
	var best = data[key]["best"]
	var seed = key
	$Seed.text = "SEED: %d" % LevelOptions.seed
	$Time.text = "YOUR TIME: %d" % Statsmanager.complete_time
	$Best.text = "BEST TIME: %d" % best

func _on_back_pressed() -> void:
	$Button1.play()
	close_gates()


func _on_retry_pressed() -> void:
	var loadingscreen = load("res://Scenes/loading_screen.tscn")
	get_tree().change_scene_to_packed(loadingscreen)

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
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
