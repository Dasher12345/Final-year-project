extends Control

var progress = []
var scene_load_status = 0
var a_environment
var h_environment
func _ready():
	if LevelOptions.tutorial:
		$ColorRect.modulate.a = 1
		$Node3D.visible = false
		$Cyber.visible = false
		$apocolypse.visible = false
		a_environment = $apocolypse/WorldEnvironment.environment
		h_environment = $Node3D/WorldEnvironment.environment
		$Node3D/WorldEnvironment.environment = null
		$apocolypse/WorldEnvironment.environment = null
	else:
		a_environment = $apocolypse/WorldEnvironment.environment
		h_environment = $Node3D/WorldEnvironment.environment
		stage()
	ResourceLoader.load_threaded_request(LevelOptions.scene)
	
func stage():
	if LevelOptions.stage == "h":
		$Cyber.visible = false
		$apocolypse.visible = false
		$Node3D.visible = true
		$Node3D/WorldEnvironment.environment = h_environment
		$apocolypse/WorldEnvironment.environment = null
	elif LevelOptions.stage == "c":
		$Cyber.visible = true
		$apocolypse.visible = false
		$Node3D.visible = false
	elif LevelOptions.stage == "a":
		$Node3D.visible = false
		$Cyber.visible = false
		$apocolypse.visible = true
		$apocolypse/WorldEnvironment.environment = a_environment
		$Node3D/WorldEnvironment.environment = null
		
func _process(_delta: float) -> void:
	scene_load_status = ResourceLoader.load_threaded_get_status(LevelOptions.scene,progress)
	$Label.text = str(floor(progress[0]*100)) + "%"
	if scene_load_status == ResourceLoader.THREAD_LOAD_LOADED:
		var new_scene = ResourceLoader.load_threaded_get(LevelOptions.scene)
		get_tree().change_scene_to_packed(new_scene)
