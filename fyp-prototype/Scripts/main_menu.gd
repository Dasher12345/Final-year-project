extends Node3D

var stage = false
var seed = false
var selection_mode := ""
var single = true
var font = load("res://assets/fonts/Mont-HeavyDEMO.otf")

var title_tween

func _ready() -> void:
	if LevelOptions.title == false:
		$Gate1.position.y = 542
		$Gate2.position.y = 539.105
		$Ring.hide()
		$TitleBg.hide()
		$Text.hide()
		$press.hide()
		main_menu()
		open()
	else:
		playtitle()
	LevelOptions.mult = false
	$Panel.hide()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	$Main_Menu.play()
	$Menu_2.play()
	$Menu_2.volume_db = -40
	$Start.disabled = true
	$Seed_Input.editable = false
	
func playtitle():
	title_tween = create_tween()
	title_tween.set_loops()
	title_tween.tween_property($press, "modulate:a", 0.0, 1.0)
	title_tween.tween_property($press, "modulate:a", 1.0, 1.0)
	
func _process(delta: float) -> void:
	if LevelOptions.title and Input.is_action_just_pressed("title"):
		$Button1.play()
		title_tween.kill()
		$press.hide()
		play_intro()
		
		
	if seed and stage:
		$Start.disabled = false
		
func _physics_process(delta: float) -> void:
	$BlueRing.rotate(0.2*delta)
	$Ring.rotate(0.2*delta)

func _on_quit_pressed() -> void:
	$Button1.play()
	get_tree().quit()
	
func dynamic_music(music):
	var tween := get_tree().create_tween()
	if music == $Main_Menu:
		tween.set_parallel(true)
		tween.tween_property($Menu_2,"volume_db",-40,0.5)
		tween.tween_property(music,"volume_db",0,1.0)
	elif music == $Menu_2:
		tween.set_parallel(true)
		tween.tween_property($Main_Menu,"volume_db",-40,0.5)
		tween.tween_property(music,"volume_db",0,1.0)
	
func music_fade_in(music):
	var tween := get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property(music,"volume_db",0,0.5)
	
func switch_game_options():
	var tween := get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property($Single,"position", Vector2(-1500, 322), 0.5)
	tween.tween_property($Multiplayer,"position", Vector2(-1500, 410), 0.5)
	tween.tween_property($Tutorial,"position", Vector2(-1500, 497), 0.5)
	tween.tween_property($Options,"position", Vector2(-1500, 583), 0.5)
	tween.tween_property($Quit,"position", Vector2(-1500, 669), 0.5)
	tween.tween_property($BlueRing,"position",Vector2(4000,562), 0.5)
	tween.tween_property($seed,"position", Vector2(15, 322), 0.5)
	tween.tween_property($back,"position", Vector2(0, 823), 0.5)
	tween.tween_property($stage,"position", Vector2(44, 410), 0.5)
	if single:
		tween.tween_property($Stats,"position", Vector2(72, 497), 0.5)
		tween.tween_property($Start,"position", Vector2(100, 583), 0.5)
	else:
		tween.tween_property($Start,"position", Vector2(72, 497), 0.5)
	tween.tween_property($NeonHexTexturesNetworking,"position",Vector2(1915, 328), 0.5)
	
func main_menu():
	var tween := get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property($Single,"position", Vector2(15, 322), 0.5)
	tween.tween_property($Multiplayer,"position", Vector2(44, 410), 0.5)
	tween.tween_property($Tutorial,"position", Vector2(72, 497), 0.5)
	tween.tween_property($Options,"position", Vector2(100, 583), 0.5)
	tween.tween_property($BlueRing,"position",Vector2(1508,562), 0.5)
	tween.tween_property($Quit,"position", Vector2(128, 669), 0.5)
	tween.tween_property($seed,"position", Vector2(-1500, 322), 0.5)
	tween.tween_property($back,"position", Vector2(-1500, 823), 0.5)
	tween.tween_property($stage,"position", Vector2(-1500, 410), 0.5)
	if single:
		tween.tween_property($Stats,"position", Vector2(-1500, 497), 0.5)
		tween.tween_property($Start,"position", Vector2(-1500, 583), 0.5)
	else:
		tween.tween_property($Start,"position", Vector2(-1500, 497), 0.5)
	tween.tween_property($NeonHexTexturesNetworking,"position",Vector2(9, 328), 0.5)
	$Panel.hide()
	$Stage_panel.hide()
	$Random_Seed.hide()
	$custom.hide()
	$Seed_Input.hide()
	$Apocolypse.hide()
	$CyberSpace.hide()
	$Horizon.hide()
	$seed.button_pressed = false
	$stage.button_pressed = false
	$Horizon.button_pressed = false
	$CyberSpace.button_pressed = false
	$Apocolypse.button_pressed = false
	$Random_Seed.button_pressed = false
	$custom.button_pressed = false
	$Stats.button_pressed = false
	$HBoxContainer.hide()
	$StatsScroll.hide()
	$Stage_panel.texture = $Questionmark.get_texture()
	single = false
	LevelOptions.mult = false
	
func _on_random_seed_toggled(pressed) -> void:
	if pressed:
		$Button3.play()
		selection_mode = "random"
		seed = true
		$Seed_Input.editable = false
		$custom.button_pressed = false

func _on_multiplayer_pressed() -> void:
	single = false
	LevelOptions.mult = true
	$Button2.play()
	$Start.position.y = 497
	dynamic_music($Menu_2)
	switch_game_options()

func _on_tutorial_pressed() -> void:
	$Button2.play()
	LevelOptions.tutorial = true
	LevelOptions.use_random_seed = false
	LevelOptions.scene = "res://Scenes/Test_Level.tscn"
	var loadingscreen = load("res://Scenes/loading_screen.tscn")
	get_tree().change_scene_to_packed(loadingscreen)


func _on_single_pressed() -> void:
	single = true
	$Button2.play()
	$Start.position.y = 583
	dynamic_music($Menu_2)
	switch_game_options()


func _on_back_pressed() -> void:
	$Button1.play()
	main_menu()
	dynamic_music($Main_Menu)


func _on_custom_toggled(pressed) -> void:
	if pressed:
		$Button3.play()
		seed = true
		selection_mode = "custom"
		$Seed_Input.editable = true
		$Random_Seed.button_pressed = false


func _on_seed_toggled(button_pressed) -> void:
	if button_pressed:
		$Button3.play()
		$stage.button_pressed = false
		$Stats.button_pressed = false
		$Panel.show()
		$Seed_Input.show()
		$Random_Seed.show()
		$custom.show()
		$Apocolypse.hide()
		$CyberSpace.hide()
		$Horizon.hide()
		$Stage_panel.hide()


func _on_start_pressed() -> void:
	$Button2.play()
	match selection_mode:
		"random":
			LevelOptions.use_random_seed = true
			if LevelOptions.stage == "c":
				LevelOptions.scene = "res://Scenes/cyber_stage.tscn"
			elif LevelOptions.stage == "h":
				LevelOptions.scene = "res://Scenes/stage.tscn"
			elif LevelOptions.stage == "a":
				LevelOptions.scene = "res://Scenes/apocolypse_stage.tscn"

		"custom":
			LevelOptions.use_random_seed = false
			LevelOptions.seed = int($Seed_Input.text)
			if LevelOptions.stage == "c":
				LevelOptions.scene = "res://Scenes/cyber_stage.tscn"
			elif LevelOptions.stage == "h":
				LevelOptions.scene = "res://Scenes/stage.tscn"
			elif LevelOptions.stage == "a":
				LevelOptions.scene = "res://Scenes/apocolypse_stage.tscn"
		_:
			return

	var loadingscreen = load("res://Scenes/loading_screen.tscn")
	get_tree().change_scene_to_packed(loadingscreen)


func _on_stage_toggled(button_pressed) -> void:
	if button_pressed:
		$Button3.play()
		$seed.button_pressed = false
		$Stats.button_pressed = false
		$Panel.show()
		$Seed_Input.hide()
		$Random_Seed.hide()
		$custom.hide()
		$Apocolypse.show()
		$CyberSpace.show()
		$Horizon.show()
		$Stage_panel.show()

func _on_stats_toggled(button_pressed) -> void:
	if button_pressed:
		$Button3.play()
		$seed.button_pressed = false
		$stage.button_pressed = false
		$Panel.show()
		$Stage_panel.hide()
		$Seed_Input.hide()
		$Random_Seed.hide()
		$custom.hide()
		$Apocolypse.hide()
		$CyberSpace.hide()
		$Horizon.hide()
		$HBoxContainer.show()
		$StatsScroll.show()
		populate_stats()
	else:
		$HBoxContainer.hide()
		$StatsScroll.hide()

func _on_apocolypse_toggled(pressed) -> void:
	if pressed:
		$Button3.play()
		$Stage_panel.texture = $apocolypse_view.get_texture()
		LevelOptions.stage = "a"
		$CyberSpace.button_pressed = false
		$Horizon.button_pressed = false
		$Stage_panel.show()
		stage = true
		
func _on_horizon_toggled(pressed) -> void:
	if pressed:
		$Button3.play()
		$Stage_panel.texture = $horizon_view.get_texture()
		LevelOptions.stage = "h"
		$Stage_panel.show()
		$CyberSpace.button_pressed = false
		$Apocolypse.button_pressed = false
		stage = true
		
func _on_cyber_space_toggled(pressed) -> void:
	if pressed:
		$Button3.play()
		$Stage_panel.texture = $cyber_view.get_texture()
		LevelOptions.stage = "c"
		$Apocolypse.button_pressed = false
		$Horizon.button_pressed = false
		$Stage_panel.show()
		stage = true

func _on_options_pressed() -> void:
	$Button2.play()
	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property($Gate1,"position:y",542,0.5)
	tween.tween_property($Gate2,"position:y",539.105,0.5)
	tween.tween_property($Main_Menu,"volume_db",-40,2)
	await tween.finished
	await get_tree().process_frame
	get_tree().change_scene_to_file("res://Scenes/options.tscn")

func open():
	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property($Gate1,"position:y",0,0.5)
	tween.tween_property($Gate2,"position:y",1078,0.5)

func populate_stats():
	var container = $StatsScroll/ScrollContainer/VBoxContainer
	for child in container.get_children():
		child.queue_free()
	container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var data = Statsmanager.data
	for seed in data.keys():
		var row = HBoxContainer.new()
		row.add_theme_constant_override("separation", 500)
		row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.custom_minimum_size.y = 40
		var seed_label = Label.new()
		var time_label = Label.new()
		seed_label.add_theme_font_override("font", font)
		time_label.add_theme_font_override("font", font)
		seed_label.add_theme_font_size_override("font_size", 24)
		time_label.add_theme_font_size_override("font_size", 24)
		seed_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		time_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		seed_label.text = str(seed)
		var best = data[seed].get("best", null)
		time_label.text = str(best) if best != null else "---"
		row.add_child(seed_label)
		row.add_child(time_label)
		container.add_child(row)

func play_intro():
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property($Gate1,"position:y",542,0.5)
	tween.tween_property($Gate2,"position:y",539.105,0.5)
	await tween.finished
	$Ring.hide()
	$Text.hide()
	$TitleBg.hide()
	main_menu()
	await get_tree().create_timer(1).timeout
	LevelOptions.title = false
	open()
