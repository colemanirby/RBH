extends CanvasLayer

var current_score = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	$ScoreLabel.hide()

func show_elements():
	$ScoreLabel.show()
	
func hide_elements():
	$ScoreLabel.hide()

func update_score(score):
	current_score = score
	$ScoreLabel.text = str(score)

func get_final_score():
	return current_score

func reset_score():
	current_score = 0
