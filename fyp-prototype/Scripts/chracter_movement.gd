extends CharacterBody3D

@onready var label: Label = $"../Label"


const MAGIC_PLATFORM = preload("uid://jbnapw0ohjf7")

@onready var dash_sound: AudioStreamPlayer3D = $DashSound
@onready var jump_sound: AudioStreamPlayer3D = $JumpSound
@onready var double_jump_sound: AudioStreamPlayer3D = $DoubleJump_Sound

@onready var model_mesh: MeshInstance3D = $Armature/Skeleton3D/Model

@onready var speed_lines_rect: ColorRect = $Speedlnes/ColorRect
@onready var speed_lines_material: ShaderMaterial = $Speedlnes/ColorRect.material as ShaderMaterial

@export var material_p2: Material

@export var player_id = 1

@export var stick_sensitivity := 3.0
@export var stick_deadzone := 0.15

# =====================
# Movement tuning
# =====================
@export var move_speed := 30.0
@export var ground_accel := 120.0
@export var ground_deaccel := 350.0

@export var air_accel := 30.0
@export var air_deaccel := 10.0

@export var jump_velocity := 20.0

@export var gravity_strength := 40.0
@export var fall_multiplier := 3.5

# =====================
# Dash tuning
# =====================
@export var dash_in_camera_direction := true

@export var dash_speed := 80.0
@export var dash_duration := 0.15
@export var dash_cooldown := 0.8

@export var max_jumps := 2
@export var max_dashes := 2

@export var dash_preserve_vertical := true
@export var dash_keep_best_speed := true

# =====================
# Wall run tuning (Titanfall/BO3-ish)
# =====================
@export var wall_run_speed := 65.0
#@export var wall_run_duration := 1.0
@export var wall_run_cooldown := 0.2

@export var wall_run_boost := 10.0

@export var wall_detect_distance := 1.0
@export var wall_ray_height := 1.0

@export var wall_stick_force := 25.0
@export var wall_run_gravity_scale := 0.35
@export var wall_run_max_fall_speed := 12.0

@export var wall_jump_up := 18.0
@export var wall_jump_push := 22.0
@export var wall_jump_forward_boost := 8.0

@export var wall_collision_mask := 1

# =====================
# Debug label tuning
# =====================
@export var show_debug_label := true
@export var show_speed_in_label := true

var debug_override_text := ""
var debug_override_timer := 0.0

# =====================
# State
# =====================
var jumps_left := 0
var has_Jumped := false
var dashes_left := 0

var is_dashing := false
var dash_timer := 0.0
var dash_cooldown_timer := 0.0
var dash_direction := Vector3.ZERO
var dash_saved_y := 0.0

var was_on_floor := false

var is_wall_running := false
var wall_run_cooldown_timer := 0.0
var wall_normal := Vector3.ZERO


@onready var cam_pivot: Node3D = $SprintArmPivot
var look_x := 0.0
@export var mouse_sensitivity := 0.002

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	jumps_left = max_jumps
	dashes_left = max_dashes
	
	$AnimationPlayer.get_animation("Wall_Running_left").loop_mode = Animation.LOOP_LINEAR
	$AnimationPlayer.get_animation("Wall_Running_right").loop_mode = Animation.LOOP_LINEAR
	$AnimationPlayer.get_animation("Falling").loop_mode = Animation.LOOP_LINEAR
	
	if player_id == 2:
		model_mesh.set_surface_override_material(0, material_p2.duplicate())


	speed_lines_rect.visible = false
	speed_lines_rect.modulate.a = 0.0
	if speed_lines_material:
		speed_lines_material = speed_lines_material.duplicate()
		speed_lines_rect.material = speed_lines_material
		speed_lines_material.set_shader_parameter("line_density", 0.27)
		speed_lines_material.set_shader_parameter("line_falloff", 0.56)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		# Horizontal rotation
		rotate_y(-event.relative.x * mouse_sensitivity)
		
		# Vertical rotation
		look_x -= event.relative.y * mouse_sensitivity
		look_x = clamp(look_x, -1.2, 1.2) # clamp vertical look
		cam_pivot.rotation.x = look_x

func _physics_process(delta: float) -> void:
	# =====================
	# Label override timer (for short messages like WALL JUMP)
	# =====================
	if debug_override_timer > 0.0:
		debug_override_timer -= delta
		if debug_override_timer <= 0.0:
			debug_override_timer = 0.0
			debug_override_text = ""

	var on_floor_now := is_on_floor()

	# --- Landing reset ---
	if on_floor_now and not was_on_floor:
		jumps_left = max_jumps
		dashes_left = max_dashes
		play_anim("Landing")
		$AnimationPlayer.seek(0.3, true)
		
		has_Jumped = false
	
	elif not on_floor_now and was_on_floor and not has_Jumped:
		# Player simply ran off the platform without jumping
		if $AnimationPlayer.current_animation != "Running_to_Falling" and $AnimationPlayer.current_animation != "Falling":
			play_anim("Running_to_Falling")
			$AnimationPlayer.queue("Falling")
	
	was_on_floor = on_floor_now

	# --- Cooldowns ---
	if dash_cooldown_timer > 0.0:
		dash_cooldown_timer -= delta
		if dash_cooldown_timer < 0.0:
			dash_cooldown_timer = 0.0

	if wall_run_cooldown_timer > 0.0:
		wall_run_cooldown_timer -= delta
		if wall_run_cooldown_timer < 0.0:
			wall_run_cooldown_timer = 0.0

	# --- Camera-relative input ---
	var input_vec := Input.get_vector(action("left"), action("right"), 
									  action("forward"), action("back"))
	
	var is_moving_input := input_vec.length() > 0.1

	var move_dir := cam_pivot.global_transform.basis * Vector3(input_vec.x, 0, input_vec.y)
	move_dir.y = 0.0
	if move_dir.length() > 0.1:
		move_dir = move_dir.normalized()
	else:
		move_dir = Vector3.ZERO

	var cam_forward := -cam_pivot.global_transform.basis.z
	cam_forward.y = 0.0
	if cam_forward.length() > 0.001:
		cam_forward = cam_forward.normalized()

	var cam_right := cam_pivot.global_transform.basis.x
	cam_right.y = 0.0
	if cam_right.length() > 0.001:
		cam_right = cam_right.normalized()

	var wants_forward := input_vec.y < -0.2

	# =====================
	# Dash active
	# =====================
	if is_dashing:
		dash_timer -= delta

		var target_dash_speed := dash_speed
		if dash_keep_best_speed:
			var current_h := Vector3(velocity.x, 0, velocity.z).length()
			if current_h > target_dash_speed:
				target_dash_speed = current_h

		velocity.x = dash_direction.x * target_dash_speed
		velocity.z = dash_direction.z * target_dash_speed

		if dash_preserve_vertical:
			velocity.y = dash_saved_y
		else:
			velocity.y = 0.0

		if dash_timer <= 0.0:
			is_dashing = false
			
			if speed_lines_material:
				speed_lines_material.set_shader_parameter("line_density", 0.27)
				speed_lines_material.set_shader_parameter("line_falloff", 0.56)

	else:
		# =====================
		# Wall run update / start
		# =====================
		if is_wall_running:
			update_wall_run(delta, cam_forward, wants_forward)
		else:
			if (not on_floor_now) and wants_forward and wall_run_cooldown_timer <= 0.0:
				var found_wall := try_start_wall_run(cam_right)



		# =====================
		# Gravity (normal)
		# =====================
		if not is_wall_running:
			if velocity.y < 0.0:
				velocity.y -= gravity_strength * fall_multiplier * delta
			else:
				velocity.y -= gravity_strength * delta


		# =====================
		# Jump (normal + wall jump)
		# =====================
		if Input.is_action_just_pressed(action("jump")):
			if is_wall_running:
				do_wall_jump(cam_forward)
			else:
				if jumps_left > 0:
					velocity.y = jump_velocity
					jumps_left -= 1


		# =====================
		# Horizontal movement
		# =====================
		if not is_wall_running:
			var accel := air_accel
			var deaccel := air_deaccel
			if on_floor_now:
				accel = ground_accel
				deaccel = ground_deaccel

			if move_dir != Vector3.ZERO:
				velocity.x = move_toward(velocity.x, move_dir.x * move_speed, accel * delta)
				velocity.z = move_toward(velocity.z, move_dir.z * move_speed, accel * delta)
			else:
				velocity.x = move_toward(velocity.x, 0.0, deaccel * delta)
				velocity.z = move_toward(velocity.z, 0.0, deaccel * delta)

		# =====================
		# Dash start (blocked during wall run)
		# =====================
		if (not is_wall_running) and Input.is_action_just_pressed(action("dash")) and dashes_left > 0 and dash_cooldown_timer <= 0.0:
			start_dash(move_dir)

		# =====================
		# Ground animations
		# =====================
		
	if on_floor_now:
		var hspeed := Vector3(velocity.x, 0, velocity.z).length()
		# no input and no movement
		if not is_moving_input and hspeed < 0.1 and is_on_floor() and not $AnimationPlayer.is_playing():
			play_anim("Idle")
		
		if $AnimationPlayer.is_playing():
			if $AnimationPlayer.current_animation in ["Jumping", "Running_Jump", "Forward_Flip"]:
				pass 
			elif Input.is_action_pressed(action("forward")) and is_on_floor() and not is_dashing:
				play_anim("Running")
			elif Input.is_action_pressed(action("left")) and is_on_floor() and not is_dashing:
				play_anim("Run_Left")
			elif Input.is_action_pressed(action("right")) and is_on_floor() and not is_dashing:
				play_anim("Run_Right")
			elif Input.is_action_pressed(action("back")) and is_on_floor() and not is_dashing:
				play_anim("Walk_backwards")
			# nothing else playing → we can still run if input exists

		else:
			if Input.is_action_pressed(action("forward")) and hspeed > 0.1:
				play_anim("Running")
			elif Input.is_action_pressed(action("left")) and hspeed > 0.1:
				play_anim("Run_Left")
			elif Input.is_action_pressed(action("right")) and hspeed > 0.1:
				play_anim("Run_Right")
			elif Input.is_action_pressed(action("back")) and hspeed > 0.1:
				play_anim("Walk_backwards")

		# =====================
		# Jump animations
		# =====================
	
	if Input.is_action_just_pressed(action("jump")):
		if not has_Jumped and Input.is_action_pressed(action("forward")):
			play_anim("Running_Jump")
			jump_sound.play()
			has_Jumped = true
		
		elif not has_Jumped:
			play_anim("Jumping")
			$AnimationPlayer.seek(0.3, true)
			jump_sound.play()
			has_Jumped = true
		elif jumps_left == 0:
			spawn_magic_platform()
			play_anim("Forward_Flip")
			$AnimationPlayer.seek(0.3,true)
			double_jump_sound.play()
			$AnimationPlayer.queue("Flip_to_Falling3")
			$AnimationPlayer.queue("Falling")
			jumps_left -= 1
			
		# If player did the first running jump, starts falling, and has not double-jumped
	if not on_floor_now and velocity.y < 0.0 and has_Jumped and jumps_left == max_jumps - 1:
		if $AnimationPlayer.current_animation == "Running_Jump" and $AnimationPlayer.current_animation_position >= $AnimationPlayer.current_animation_length - 0.05:
			play_anim("RunningJump_to_Falling")
			$AnimationPlayer.queue("Falling")


	# =====================
	# Right Stick Camera
	# =====================

	var look_x_input := Input.get_action_strength("look_right_%d" % player_id) \
		- Input.get_action_strength("look_left_%d" % player_id)

	var look_y_input := Input.get_action_strength("look_down_%d" % player_id) \
		- Input.get_action_strength("look_up_%d" % player_id)

	# Deadzone
	if abs(look_x_input) < stick_deadzone:
		look_x_input = 0.0
	if abs(look_y_input) < stick_deadzone:
		look_y_input = 0.0

	# Apply rotation
	rotate_y(-look_x_input * stick_sensitivity * delta)

	look_x -= look_y_input * stick_sensitivity * delta
	look_x = clamp(look_x, -1.2, 1.2)
	cam_pivot.rotation.x = look_x

	var speed_ratio = clamp(Vector3(velocity.x, 0, velocity.z).length() / move_speed, 0.0, 1.0)
	
	if speed_ratio < 0.5:
		speed_lines_rect.visible = false
		speed_lines_rect.modulate.a = 0.0
	else:
		speed_lines_rect.visible = true
		speed_lines_rect.modulate.a = speed_ratio
	
	move_and_slide()

# =====================
# Dash helper
# =====================
func start_dash(direction: Vector3) -> void:
	var dir := direction
	
	if dash_in_camera_direction:
		dir = -cam_pivot.global_transform.basis.z
	
	elif dir == Vector3.ZERO:
		dir = -cam_pivot.global_transform.basis.z
	
	is_dashing = true
	dash_timer = dash_duration
	dash_cooldown_timer = dash_cooldown
	dashes_left -= 1
	
	dash_direction = dir.normalized()
	dash_saved_y = velocity.y
	
	dash_sound.play()
	
	if speed_lines_material:
		speed_lines_material.set_shader_parameter("line_density", 0.44)
		speed_lines_material.set_shader_parameter("line_falloff", 1.0)

# =====================
# Wall run helpers
# =====================
func try_start_wall_run(cam_right: Vector3) -> bool:
	var origin := global_transform.origin + Vector3.UP * wall_ray_height

	var left_hit := raycast_wall(origin, -cam_right)
	var right_hit := raycast_wall(origin, cam_right)

	if left_hit.has("normal") and not right_hit.has("normal"):
		begin_wall_run(left_hit["normal"] as Vector3)
		return true

	if right_hit.has("normal") and not left_hit.has("normal"):
		begin_wall_run(right_hit["normal"] as Vector3)
		return true

	if left_hit.has("normal") and right_hit.has("normal"):
		var vel_h := Vector3(velocity.x, 0, velocity.z)
		if vel_h.length() < 0.1:
			begin_wall_run(right_hit["normal"] as Vector3)
			return true

		var left_normal: Vector3 = left_hit["normal"] as Vector3
		var right_normal: Vector3 = right_hit["normal"] as Vector3

		var left_score: float = abs(vel_h.normalized().dot(left_normal))
		var right_score: float = abs(vel_h.normalized().dot(right_normal))

		if left_score > right_score:
			begin_wall_run(left_normal)
		else:
			begin_wall_run(right_normal)
		return true

	return false

func begin_wall_run(hit_normal: Vector3) -> void:
	is_wall_running = true
	wall_normal = hit_normal.normalized()
	
	# Determine which side the wall is on (relative to camera)
	var cam_right := cam_pivot.global_transform.basis.x
	cam_right.y = 0.0
	cam_right = cam_right.normalized()
	
	# If dot > 0 => wall normal points toward camera-right direction
	# That usually means wall is on the RIGHT side of the player.
	var side := cam_right.dot(wall_normal)
	
	if side > 0.0:
		play_anim("Wall_Running_left")
	else:
		play_anim("Wall_Running_right")
	
	if velocity.y < -wall_run_max_fall_speed:
		velocity.y = -wall_run_max_fall_speed

func update_wall_run(delta: float, cam_forward: Vector3, wants_forward: bool) -> void:
	if is_on_floor():
		end_wall_run()
		return
	
	if not wants_forward:
		end_wall_run()
		return
	
	var cam_right := cam_pivot.global_transform.basis.x
	cam_right.y = 0.0
	if cam_right.length() > 0.001:
		cam_right = cam_right.normalized()
	
	var origin := global_transform.origin + Vector3.UP * wall_ray_height
	
	var left_hit := raycast_wall(origin, -cam_right)
	var right_hit := raycast_wall(origin, cam_right)
	
	var still_on_wall := false
	if left_hit.has("normal"):
		wall_normal = (left_hit["normal"] as Vector3).normalized()
		still_on_wall = true
	if right_hit.has("normal"):
		wall_normal = (right_hit["normal"] as Vector3).normalized()
		still_on_wall = true
	
	if not still_on_wall:
		end_wall_run()
		return
	
	var along := cam_forward - wall_normal * cam_forward.dot(wall_normal)
	if along.length() < 0.001:
		end_wall_run()
		return
	along = along.normalized()

	var boosted_wall_run_speed := wall_run_speed + wall_run_boost
	
	#velocity.x = along.x * wall_run_speed
	#velocity.z = along.z * wall_run_speed
	velocity.x = along.x * boosted_wall_run_speed
	velocity.z = along.z * boosted_wall_run_speed
	
	var wall_grav := gravity_strength * wall_run_gravity_scale
	velocity.y -= wall_grav * delta
	
	if velocity.y < -wall_run_max_fall_speed:
		velocity.y = -wall_run_max_fall_speed
	
	velocity += -wall_normal * wall_stick_force * delta

func do_wall_jump(cam_forward: Vector3) -> void:
	end_wall_run(false)

	var push := wall_normal * wall_jump_push
	var up := Vector3.UP * wall_jump_up
	var forward := cam_forward * wall_jump_forward_boost

	velocity = push + up + forward

	dashes_left = max_dashes

	# Count wall jump as the first jump in the air chain,
	# so the next jump can become the flip.
	jumps_left = max_jumps - 1
	has_Jumped = true

	play_anim("Jumping")
	jump_sound.play()
	$AnimationPlayer.seek(0.3, true)

	# Label flash
	debug_override_text = "WALL JUMP"
	debug_override_timer = 0.25

func end_wall_run(play_falling_anim: bool = true) -> void:
	if is_wall_running:
		is_wall_running = false
		wall_run_cooldown_timer = wall_run_cooldown
		
		if play_falling_anim and not is_on_floor():
			play_anim("Falling")


func raycast_wall(origin: Vector3, dir: Vector3) -> Dictionary:
	var space := get_world_3d().direct_space_state

	var query := PhysicsRayQueryParameters3D.new()
	query.from = origin
	query.to = origin + dir.normalized() * wall_detect_distance
	query.collision_mask = wall_collision_mask
	query.exclude = [self]

	return space.intersect_ray(query)



func spawn_magic_platform() -> void:
	var magic_platform = MAGIC_PLATFORM.instantiate()
	get_tree().current_scene.add_child(magic_platform)
	magic_platform.global_position = global_position
	
	await get_tree().create_timer(0.3).timeout
	
	for mesh in magic_platform.find_children("*", "MeshInstance3D", true, false):
		var mat := mesh.get_active_material(0).duplicate() as StandardMaterial3D
		mesh.set_surface_override_material(0, mat)
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		
		var tween := get_tree().create_tween()
		tween.tween_property(mat, "albedo_color:a", 0.0, 0.5)
		await tween.finished
	
	if is_instance_valid(magic_platform):
		magic_platform.queue_free()



# =====================
# Multiplayer input helper
# =====================

func action(name: String) -> String:
	return "%s_%d" % [name, player_id]

# =====================
# Animations
# =====================

func play_anim(Animation_name: String) -> void:
	if $AnimationPlayer.current_animation != Animation_name:
		$AnimationPlayer.play(Animation_name)
