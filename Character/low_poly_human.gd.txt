extends CharacterBody3D

var speed := 5.0
const JUMP_VELOCITY := 4.5

@onready var camera: Camera3D = $SprintArmPivot/Camera3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _physics_process(delta: float) -> void:
	# Add gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	var input_dir := Input.get_vector("left", "right", "forward", "back")
	
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction != Vector3.ZERO:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
	move_and_slide()
	

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("forward") and Input.is_action_just_pressed("sprint"):
		speed += 5
		print(123)
		animation_player.play("sprint")
		
	if Input.is_action_just_pressed("forward"):
		animation_player.play("run")
	if Input.is_action_just_released("forward"):
		animation_player.play("idel")
	
	#if Input.is_action_just_pressed("jump"):
		#animation_player.play("jump")
