extends Sprite2D

var bg_offset: float = 0.0

func _ready():
	position.x = posmod(bg_offset, 1920) - 960

func _process(delta):
	bg_offset -= 50 * delta
	position.x = posmod(bg_offset, 1920) - 960
