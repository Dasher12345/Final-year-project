extends Sprite2D

var bg_offset: float = 0.0

func _ready():
	position.x = posmod(bg_offset, 1920) - 560

func _process(delta):
	bg_offset += 100 * delta
	position.x = posmod(bg_offset, 1920) - 565
