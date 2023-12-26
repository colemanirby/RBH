extends ParallaxLayer

var mirror_vector = Vector2(1920, 1080)

# Called when the node enters the scene tree for the first time.
func _ready():
	set_mirroring(mirror_vector)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
