extends Node
var seed: int = 0
var use_random_seed := true
var scene
var current_run_seed : int = -1
const save_path = "user://save_seed.data"
var stage = "c"
var mult = false
var tutorial = false
var title = true

func save_seed():
	var file = FileAccess.open(save_path,FileAccess.WRITE)
	if file:
		file.store_64(seed)
		file.close()
		
func load_seed():
	if not FileAccess.file_exists(save_path):
		return false
	var file = FileAccess.open(save_path,FileAccess.READ)
	if file:
		seed = file.get_64()
		file.close()
		return true
	return false
