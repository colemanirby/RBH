extends CanvasLayer

signal start_game
signal mute_music
var game_started = false
var is_paused = false
var lowest_score
var current_score = 0

func _ready():
	$PauseMenu.connect("unpause", unpause)
	$HighScoreScreen.connect("save_completed", game_over_display)
	hide_for_ready()
	lowest_score = $HighScoreScreen.get_lowest_score()

func hide_for_ready():
	$PauseMenu.hide_elements()
	$HighScoreScreen.hide_elements()
	
func show_message(text):
	$Message.text = text
	$Message.show()
	$MessageTimer.start()

func show_game_over():
	var display_input_for_hs = is_score_beat()
	if display_input_for_hs:
		$HighScoreScreen.show_screen(current_score)
	else:
		game_over_display()
	

func game_over_display():
	show_message("Game Over")
	
	await $MessageTimer.timeout
	game_started = false
	
	$Message.text = "Across The Stars"
	$Message.show()
	
	await get_tree().create_timer(1.0).timeout
	show_buttons()
	
	
func update_score(score):
	current_score = score
	$ScoreLabel.text = str(score)

func _on_message_timer_timeout():
	$Message.hide()

func _on_start_button_pressed():
	current_score = 0
	game_started = true
	$StartButton.hide()
	$Mute.hide()
	$HighScoreScreen.hide_elements()
	$HighScoresButton.hide()
	start_game.emit()

func _on_mute_pressed():
	mute_music.emit()
	

func _input(event):
	if event.is_action_pressed("esc"):
		if not is_paused:
			print("pausing")
			pause()
		elif is_paused:
			print("unpausing")
			unpause()
			
	if visible and not game_started:
		if event.is_action_pressed("click"):
			$HighScoreScreen.hide_highscores()
			show_buttons()
			
func pause():
	get_tree().paused = true
	is_paused = true
	$PauseMenu.show_elements()
	$Mute.show()
	print("pause!")
	
func unpause():
	print("unpause!")
	$PauseMenu.hide_elements()
	$Mute.hide()
	get_tree().paused = false
	is_paused = false

func _on_high_scores_pressed():
	hide_buttons()
	$HighScoreScreen.show_highscores()

func is_score_beat():
	return current_score > int(lowest_score)
		
		
func show_buttons():
	$ScoreLabel.show()
	$Message.show()
	$StartButton.show()
	$HighScoresButton.show()
	$Mute.show()
	
func hide_buttons():
	$ScoreLabel.hide()
	$Message.hide()
	$StartButton.hide()
	$HighScoresButton.hide()
	$Mute.hide()
	
