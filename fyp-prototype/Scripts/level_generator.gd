extends Node3D

@export var section_scenes: Array[PackedScene] = []
@export var sections := 5
@export var check_platforms: Array[PackedScene] = []
@export var sub_sections: Array[PackedScene] = []
var stage = ["main", "sub"]
var p1
var p2
var s = 3

var rng := RandomNumberGenerator.new()
var last_position := Vector3(0, 780, 0)

func _ready():
	if LevelOptions.use_random_seed:
		rng.randomize()
		LevelOptions.seed = rng.randi_range(0, 999_999_999)
	else:
		LevelOptions.seed = clamp(LevelOptions.seed, 0, 999_999_999)

	rng.seed = LevelOptions.seed
	LevelOptions.save_seed()

	$seed.text = "SEED: %d" % LevelOptions.seed

	generate_level()


func generate_level():
	if LevelOptions.mult:
		var start_platform = await spawn_section(check_platforms[3])
		p1 = start_platform.get_node("GridContainer/SubViewportContainer/SubViewport/P1")
		p2 = start_platform.get_node("GridContainer/SubViewportContainer2/SubViewport/P2")
		p1.global_transform = start_platform.get_node("p1_spawn").global_transform
		p2.global_transform = start_platform.get_node("p2_spawn").global_transform
		p1.add_to_group("players")
		p2.add_to_group("players")
	else:
		var start_platform = await spawn_section(check_platforms[0])
		p1 = start_platform.get_node("P1")
		p1.add_to_group("players")
	var spawned := 1
	while spawned < sections:
		var section_select = stage[rng.randi_range(0, stage.size() - 1)]
		if section_select == "main":
			var scene = section_scenes[rng.randi_range(0, section_scenes.size() - 1)]
			await spawn_section(scene)
			spawned += 1
		elif section_select == "sub":
			var subs_c := 0
			var subs = sub_sections.duplicate()
			while subs_c < s and subs.size() > 0:
				var sub_select = subs[rng.randi_range(0, subs.size() - 1)]
				await spawn_section(sub_select)
				subs.erase(sub_select)
				subs_c += 1
			spawned += 1
		if spawned < sections:
			await spawn_section(check_platforms[1])
	await spawn_section(check_platforms[2])
	print("Seed:", LevelOptions.seed)


func spawn_section(scene: PackedScene):

	if scene == null:
		print("ERROR: Scene is null!")
		return null

	var section = scene.instantiate()
	add_child(section)

	section.position = last_position

	await get_tree().process_frame

	var end_marker = section.get_node("end")
	last_position = end_marker.global_position

	return section
