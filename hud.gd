extends CanvasLayer

signal start_game
signal mute_music
# Called when the node enters the scene tree for the first time.

func _ready():
	$Unpause.hide()
	
func show_message(text):
	$Message.text = text
	$Message.show()
	$MessageTimer.start()

func show_game_over():
	show_message("Game Over")
	
	await $MessageTimer.timeout
	
	$Message.text = "RBH"
	$Message.show()
	
	await get_tree().create_timer(1.0).timeout
	$StartButton.show()
	
func update_score(score):
	$ScoreLabel.text = str(score)

func _on_message_timer_timeout():
	$Message.hide()


func _on_start_button_pressed():
	$StartButton.hide()
	$Mute.hide()
	start_game.emit()

func _on_mute_pressed():
	mute_music.emit()
	

func _input(event):
	if event.is_action_pressed("esc"):
		get_tree().paused = true
		$Unpause.show()
		$Mute.show()
		print("pause!")


func _on_unpause_pressed():
	print("unpaused!")
	$Unpause.hide()
	$Mute.hide()
	get_tree().paused = false
