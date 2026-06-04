extends Node3D
var current_checkpoint_p1
var current_checkpoint_p2
var t = 0
var p1
var p2
var music_switched = false
var animation_started = false

func _ready():
	await get_tree().process_frame
	p1 = $LevelGenerator.p1
	current_checkpoint_p1 = p1.global_transform
	if LevelOptions.mult:
		p2 = $LevelGenerator.p2
		current_checkpoint_p2 = p2.global_transform
		print(p2.global_position)
	print(p1.global_position)
	respawn("p1")
	if LevelOptions.mult:
		respawn("p2")
	$Stage_OST.play()
	resume()

func _input(event):
	await get_tree().process_frame
	$LevelGenerator.p1._input(event)

func _process(delta: float) -> void:
	if $LevelGenerator.final_check != null and $LevelGenerator.final_check.f_check:
		switch_music()
		if not animation_started:
			animation_started = true
			finale_animation()
	if $LevelGenerator.endplat != null and $LevelGenerator.endplat.complete:
		$Timer.paused = true
		$Time.hide()
		$time_count.hide()
		Statsmanager.add_run(LevelOptions.seed, t)
		Statsmanager.complete_time = t
		
		
func _physics_process(delta: float) -> void:
	if p1 and p1.global_position.y <= 300:
		respawn("p1")
	if p2 and LevelOptions.mult and p2.global_position.y <= 300:
		respawn("p2")
		
func pause_menu():
	$Button3.play()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().paused = true
	$Resume.show()
	$Quit.show()
	$Pause.show()
	$Stage_OST.volume_db = -10
	
func resume():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	get_tree().paused = false
	$Resume.hide()
	$Quit.hide()
	$Pause.hide()
	$Stage_OST.volume_db = 0

func respawn(player):
	if player == "p1":
		p1.global_transform = current_checkpoint_p1

	if player == "p2":
		p2.global_transform = current_checkpoint_p2
		
func set_checkpoint(pos,player):
	if player == "p1":
		current_checkpoint_p1 = pos
	elif player == "p2":
		current_checkpoint_p2 = pos

func _on_timer_timeout() -> void:
	t += 1
	if t < 10:
		$time_count.text = "0%d" % t
	else:
		$time_count.text = "%d" % t


func _on_resume_pressed() -> void:
	$Button1.play()
	resume()


func _on_quit_pressed() -> void:
	get_tree().paused = false
	$Button1.play()
	close()
	
func _unhandled_input(event):
	if event.is_action_pressed("pause"):
		if get_tree().paused:
			resume()
		else:
			pause_menu()

func switch_music():
	if music_switched:
		return
	music_switched = true
	var tween := get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property($Stage_OST, "volume_db", -40, 0.5)
	$Final_Checkpoint.volume_db = -40
	$Final_Checkpoint.pitch_scale = 1.0
	$Final_Checkpoint.play()
	tween.tween_property($Final_Checkpoint, "volume_db", 0, 1.0)

func finale_animation():
	var tween = create_tween()
	tween.set_parallel(false)
	tween.tween_property($Final,"position:y",179,0.3)
	tween.tween_property($Final,"position:y",341,1)
	tween.tween_property($Final,"position:y",1292,0.3)

func close():
	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property($Gate1,"position:y",542,0.5)
	tween.tween_property($Gate2,"position:y",539.105,0.5)
	tween.tween_property($AudioStreamPlayer2D,"volume_db",-40,2)
	await tween.finished
	await get_tree().process_frame
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
