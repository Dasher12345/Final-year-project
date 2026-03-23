extends Node3D

@export var camera_path: NodePath = NodePath("Camera3D")

@export var base_fov: float = 80.0
@export var max_speed_fov: float = 92.0
@export var speed_for_max_fov: float = 80.0

@export var dash_fov_bonus: float = 5.0
@export var wall_run_fov_bonus: float = 3.0

@export var fov_lerp_in_speed: float = 10.0
@export var fov_lerp_out_speed: float = 6.0

# @export var wall_tilt_degrees: float = 8.0
# @export var tilt_lerp_speed: float = 8.0

var player: Node = null
var cam: Camera3D = null

func _ready() -> void:
	player = get_parent()
	cam = get_node(camera_path) as Camera3D

	if cam != null:
		cam.fov = base_fov

func _process(delta: float) -> void:
	if player == null or cam == null:
		return

	update_dynamic_fov(delta)
	# update_wall_run_tilt(delta)

func update_dynamic_fov(delta: float) -> void:
	var hspeed := Vector3(player.velocity.x, 0.0, player.velocity.z).length()

	var speed_alpha := 0.0
	if speed_for_max_fov > 0.0:
		speed_alpha = clamp(hspeed / speed_for_max_fov, 0.0, 1.0)

	var target_fov = lerp(base_fov, max_speed_fov, speed_alpha)

	if player.is_dashing:
		target_fov += dash_fov_bonus

	if player.is_wall_running:
		target_fov += wall_run_fov_bonus

	var lerp_speed := fov_lerp_out_speed
	if target_fov > cam.fov:
		lerp_speed = fov_lerp_in_speed

	cam.fov = lerp(cam.fov, target_fov, delta * lerp_speed)

# func update_wall_run_tilt(delta: float) -> void:
# 	var target_tilt_radians := 0.0
#
# 	if player.is_wall_running:
# 		var side := get_wall_side()
# 		target_tilt_radians = deg_to_rad(wall_tilt_degrees * side)
#
# 	rotation.z = lerp(rotation.z, target_tilt_radians, delta * tilt_lerp_speed)

# func get_wall_side() -> float:
# 	if not player.is_wall_running:
# 		return 0.0
#
# 	var wall_normal: Vector3 = player.wall_normal
# 	if wall_normal == Vector3.ZERO:
# 		return 0.0
#
# 	var player_right := player.global_transform.basis.x.normalized()
# 	var dot_value := player_right.dot(wall_normal)
#
# 	if dot_value > 0.0:
# 		return 1.0
#
# 	if dot_value < 0.0:
# 		return -1.0
#
# 	return 0.0
