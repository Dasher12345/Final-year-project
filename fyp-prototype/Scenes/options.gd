extends Node2D

@onready var master_slider = $"VBoxContainer/Master Volume"
@onready var music_slider = $VBoxContainer/Music
@onready var sfx_slider = $VBoxContainer/SFX
var config = ConfigFile.new()
var master_value := 1.0
var music_value := 1.0
var sfx_value := 1.0

func _ready() -> void:
	await get_tree().process_frame
	load_audio()
	apply_audio_to_sliders()
	apply_audio()
	connect_sliders()
	await get_tree().process_frame
	open_gates()
	$AudioStreamPlayer2D.play()
	
func _on_back_pressed() -> void:
	$Button1.play()
	$CanvasLayer.hide()
	$VBoxContainer.hide()
	$CanvasLayer2.hide()
	$VBoxContainer2.hide()
	$CheckBox.hide()
	$CheckBox2.hide()
	$CheckBox3.hide()
	$CheckBox4.hide()
	$Volume.button_pressed = false
	$Display.button_pressed = false
	$Panel.hide()
	close_gates()
	
func open_gates():
	await get_tree().create_timer(0.5).timeout
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


func _on_volume_toggled(pressed) -> void:
	if pressed:
		$Button3.play()
		$Panel.show()
		$CanvasLayer.show()
		$VBoxContainer.show()
		$CanvasLayer2.hide()
		$VBoxContainer2.hide()
		$CheckBox.hide()
		$CheckBox2.hide()
		$CheckBox3.hide()
		$CheckBox4.hide()
		$Display.button_pressed = false
		

func _on_display_toggled(pressed) -> void:
	if pressed:
		$Button3.play()
		$Panel.show()
		$CanvasLayer.hide()
		$VBoxContainer.hide()
		$CanvasLayer2.show()
		$VBoxContainer2.show()
		$CheckBox.show()
		$CheckBox2.show()
		$CheckBox3.show()
		$CheckBox4.show()
		$Volume.button_pressed = false
		
func _on_master_changed(value):
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("Master"),
		linear_to_db(value)
	)

func _on_music_changed(value):
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("Music"),
		linear_to_db(value)
	)

func _on_sfx_changed(value):
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("SFX"),
		linear_to_db(value)
	)
func save_audio():
	config.set_value("audio", "master", master_slider.value)
	config.set_value("audio", "music", music_slider.value)
	config.set_value("audio", "sfx", sfx_slider.value)
	config.save("user://settings.cfg")

func load_audio():
	if config.load("user://settings.cfg") == OK:
		master_value = config.get_value("audio", "master", 1.0)
		music_value = config.get_value("audio", "music", 1.0)
		sfx_value = config.get_value("audio", "sfx", 1.0)

func _on_save_pressed() -> void:
	save_audio()
	load_audio()

func apply_audio():
	_on_master_changed(master_slider.value)
	_on_music_changed(music_slider.value)
	_on_sfx_changed(sfx_slider.value)
	
func connect_sliders():
	master_slider.value_changed.connect(_on_master_changed)
	music_slider.value_changed.connect(_on_music_changed)
	sfx_slider.value_changed.connect(_on_sfx_changed)
	
func apply_audio_to_sliders():
	master_slider.set_value_no_signal(master_value)
	music_slider.set_value_no_signal(music_value)
	sfx_slider.set_value_no_signal(sfx_value)
