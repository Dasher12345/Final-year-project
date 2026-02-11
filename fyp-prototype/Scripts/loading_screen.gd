extends Control

var progress = []
var scene_load_status = 0

func _ready():
	ResourceLoader.load_threaded_request(LevelOptions.scene)
	
func _process(_delta: float) -> void:
	scene_load_status = ResourceLoader.load_threaded_get_status(LevelOptions.scene,progress)
	$Label.text = str(floor(progress[0]*100)) + "%"
	if scene_load_status == ResourceLoader.THREAD_LOAD_LOADED:
		var new_scene = ResourceLoader.load_threaded_get(LevelOptions.scene)
		get_tree().change_scene_to_packed(new_scene)
