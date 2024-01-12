extends CanvasLayer

signal start_game
signal mute_music
var game_started = false
var is_paused = false
var lowest_score
var current_score = 0

func _ready():
	connect_signals()
	$MainMenu.show_main_menu()
	hide_for_ready()
	lowest_score = $HighScoreScreen.get_lowest_score()

func connect_signals():
	$PauseMenu.connect("unpause", unpause)
	$HighScoreScreen.connect("save_completed", game_over_display)
	$MainMenu.connect("show_highscores", show_highscores)
	$MainMenu.connect("start_game", begin_game)

func hide_for_ready():
	$PauseMenu.hide_elements()
	$HighScoreScreen.hide_elements()
	$ScoreLabel.hide()
	$Message.hide()

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
	$MainMenu.show_game_over()
	game_started = false

func update_score(score):
	current_score = score
	$ScoreLabel.text = str(score)

func _on_message_timer_timeout():
	$Message.hide()

func begin_game():
	current_score = 0
	game_started = true
	$ScoreLabel.show()
	$HighScoreScreen.hide_elements()
	$MainMenu.hide_elements()
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
			$MainMenu.show_main_menu()

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

func show_highscores():
	$ScoreLabel.hide()
	$HighScoreScreen.show_highscores()

func is_score_beat():
	return current_score > int(lowest_score)
