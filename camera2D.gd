extends Camera2D

var zoom_increment = Vector2(0.1, 0.1)
var zoom_max = 3
var zoom_min = 1
var current_zoom

func _ready():
	#just to be safe
	current_zoom = zoom.x + zoom.y
	print("current_zoom: ", current_zoom)
	
func _input(event):
	if event.is_action_pressed("zoom_in"):
		current_zoom = zoom.x + zoom.y
		if current_zoom < zoom_max:
			zoom += zoom_increment
			print("zoom in: ", zoom)
	elif event.is_action_pressed("zoom_out"):
		current_zoom = zoom.x + zoom.y
		if current_zoom > zoom_min:
			zoom -= zoom_increment
			print("zoom out: ", zoom)
