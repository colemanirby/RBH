extends CanvasLayer

signal start_game
signal mute_music
var game_started = false
# Called when the node enters the scene tree for the first time.
var high_score_result
var current_score = 0

func _ready():
	$LineEdit.text = "---"
	hide_for_ready()
	load_highscores()

func hide_for_ready():
	$LineEdit.hide()
	$Unpause.hide()
	$HighScores_Label.hide()
	$Saving.hide()
	$EnterName.hide()
	
func show_message(text):
	$Message.text = text
	$Message.show()
	$MessageTimer.start()

func show_game_over():
	var display_input_for_hs = check_highscores()
	if display_input_for_hs:
		$EnterName.show()
		$LineEdit.show()
		$LineEdit.grab_focus()
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
	$HighScores.hide()
	start_game.emit()

func _on_mute_pressed():
	mute_music.emit()
	

func _input(event):
	
	if event.is_action_pressed("esc"):
		get_tree().paused = true
		$Unpause.show()
		$Mute.show()
		print("pause!")
	if visible and not game_started:
		if event.is_action_pressed("click"):
			$HighScores_Label.hide()
			show_buttons()


func _on_unpause_pressed():
	print("unpaused!")
	$Unpause.hide()
	$Mute.hide()
	get_tree().paused = false

func load_highscores():
	var high_scores_path = "res://Save/high_scores.json"
	if not FileAccess.file_exists(high_scores_path):
		print("No highscores")
		return
	var load_file = FileAccess.open(high_scores_path, FileAccess.READ)
	var high_score_data = load_file.get_line()
	var json = JSON.new()
	var parse_result = json.parse(high_score_data)
	if not parse_result == OK:
		print("JSON Parse Error: ", json.get_error_message(), " in ", high_score_data, " at line ", json.get_error_line())
		return
	
	high_score_result = json.get_data()

func save_highscores(new_name):
	print("saving name: ", new_name)

	
func _on_high_scores_pressed():
	hide_buttons()
	var high_score_string: String = "High Scores: \n \n"
	var high_score_array = []
	for score in high_score_result:
		high_score_array.append(high_score_result[score] + ": " + score + "\n")
	for i in high_score_array.size():
		high_score_string += high_score_array[high_score_array.size() - i - 1] 
	$HighScores_Label.text = high_score_string
	$HighScores_Label.show()

func check_highscores():
	for score in high_score_result:
		print(score)
		print("going")
		if current_score > int(score):
			return true
		elif current_score < int(score):
			return false
		
	return false
		
		
func show_buttons():
	$ScoreLabel.show()
	$Message.show()
	$StartButton.show()
	$HighScores.show()
	$Mute.show()
	
func hide_buttons():
	$Saving.hide()
	$EnterName.hide()
	$ScoreLabel.hide()
	$Message.hide()
	$StartButton.hide()
	$HighScores.hide()
	$Mute.hide()
	

####################### Text Input for High Scores#########################################

func _on_line_edit_text_changed(new_text):
	$LineEdit.text = new_text + "-"
	new_text = new_text.replace("-","")
	$LineEdit.set_caret_column(new_text.length())


func _on_line_edit_text_submitted(new_text):
	$EnterName.hide()
	$LineEdit.hide()
	$LineEdit.text = "---"
	$Saving.show()
	await get_tree().create_timer(1.0).timeout
	save_highscores(new_text)
	$Saving.hide()
	
	game_over_display()


func _on_line_edit_text_change_rejected(rejected_substring):
	if $LineEdit.text.contains("-"):
		$LineEdit.text[$LineEdit.text.find("-")] = rejected_substring
		var no_dashes = $LineEdit.text.replace("-", "")
		$LineEdit.set_caret_column(no_dashes.length())

#######################/Text Input for High Scores/#########################################
