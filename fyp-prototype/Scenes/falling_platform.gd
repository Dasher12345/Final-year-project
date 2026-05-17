extends Node3D

var fall_speed = 200
var falling = false
var current_position: Vector3

func _ready() -> void:
	current_position = $MeshInstance3D.position
	
func _physics_process(delta: float) -> void:
	if falling:
		$MeshInstance3D.position.y -= (fall_speed*delta)

func fall():
	var tween = get_tree().create_tween()
	tween.tween_property($MeshInstance3D,"rotation_degrees:z",10,0.2)
	await get_tree().create_timer(2).timeout
	falling = true
	await get_tree().create_timer(3).timeout
	rise()

func _on_timer_timeout() -> void:
	if randf() < 0.3:
		fall()
	else:
		$Timer.start()

func rise():
	falling = false
	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property($MeshInstance3D,"rotation_degrees:z",0,0.2)
	tween.tween_property($MeshInstance3D,"position",current_position,0.5)
	$Timer.start()
