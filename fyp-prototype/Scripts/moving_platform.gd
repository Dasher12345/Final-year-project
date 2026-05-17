extends Node3D

var speed = 5
var up = false
var down = false

func _ready() -> void:
	go_up()

func _physics_process(delta: float) -> void:
	if up:
		$MeshInstance3D.position.y += (speed*delta)
	if down:
		$MeshInstance3D.position.y -= (speed*delta)
		
func go_up():
	up = true
	await get_tree().create_timer(5).timeout
	up = false
	print($MeshInstance3D.position)
	await get_tree().create_timer(2).timeout
	go_down()
	
func go_down():
	down = true
	await get_tree().create_timer(5).timeout
	down = false
	await get_tree().create_timer(2).timeout
	go_up()
