extends Node

const SAVE_PATH := "user://stats.json"

var data := {}
var complete_time = 0

func _ready() -> void:
	load_data()
	
func load_data():
	if not FileAccess.file_exists(SAVE_PATH):
		data = {}
		return
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	data = JSON.parse_string(file.get_as_text())
	if data == null:
		data = {}

func save_data():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(data))

func add_run(seed: int, time: float):
	var key := str(seed)
	if not data.has(key):
		data[key] = {
			"best": time,
			}
	else:
		var old_best = data[key].get("best", INF)
		if time < old_best:
			data[key]["best"] = time
	save_data()

func get_best_time(seed: int):
	var key := str(seed)
	if not data.has(key):
		return null
	return data[key]["best"]
