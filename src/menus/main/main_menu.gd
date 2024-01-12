extends CanvasLayer

signal show_highscores
signal start_game

func show_main_menu():
	$Message.show()
	$StartButton.show()
	$HighScoresButton.show()
	$Mute.show()

func hide_elements():
	$Message.hide()
	$StartButton.hide()
	$HighScoresButton.hide()
	$Mute.hide()

func _on_high_scores_button_pressed():
	hide_elements()
	show_highscores.emit()


func _on_start_button_pressed():
	hide_elements()
	start_game.emit()

func show_message(text):
	$Message.text = text
	$Message.show()
	$MessageTimer.start()

func show_game_over():
	show_message("Game Over")
	
	await $MessageTimer.timeout
	
	$Message.text = "Across The Stars"
	$Message.show()
	
	await get_tree().create_timer(1.0).timeout
	show_main_menu()
