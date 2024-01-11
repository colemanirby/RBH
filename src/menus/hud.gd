extends CanvasLayer

signal start_game
signal mute_music
var game_started = false
var is_paused = false
# Called when the node enters the scene tree for the first time.
var highscore_data
var current_score = 0

func _ready():
	$PauseMenu.connect("unpause", unpause)
	$LineEdit.text = "---"
	$PauseMenu.hide_elements()
	hide_for_ready()
	load_highscores()

func hide_for_ready():
	$LineEdit.hide()
	$PauseMenu.hide_elements()
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
	print("event: ", event)
	if event.is_action_pressed("esc"):
		if not is_paused:
			print("pausing")
			pause()
		elif is_paused:
			print("unpausing")
			unpause()
			
	if visible and not game_started:
		if event.is_action_pressed("click"):
			$HighScores_Label.hide()
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
	
	highscore_data = json.get_data()

func save_highscores(new_name):
	var scores = []
	var names = []
	var new_highscores = []
	
	#put entries into arrays for easier handling.
	#Mappings from scores to names should maintain 
	#a structure such that "entry = {scores[i]: names[i]}"
	for entry in highscore_data:
		var score_value = entry.keys()[0]
		scores.append(score_value)
		names.append(entry[score_value])

	var inserted_score = false
	
	#Now we can keep an eye out for an appropriate place to place a score
	#while building the new high scores. If we never found a place to
	#put it, it means it is the new highest score.
	for i in range(1, scores.size()):
		if current_score <= int(scores[i]) and not inserted_score:
			inserted_score = true
			new_highscores.append({str(current_score): new_name})
		new_highscores.append({scores[i]: names[i]})
	if not inserted_score:
		new_highscores.append({str(current_score): new_name})
	
	var save_game = FileAccess.open("res://Save/high_scores.json", FileAccess.WRITE)
	save_game.store_line(JSON.stringify(new_highscores))
	highscore_data = new_highscores
	
func _on_high_scores_pressed():
	hide_buttons()
	var high_score_string: String = "High Scores: \n \n"
	var high_score_array = []
	for entry in highscore_data:
		var score_value = entry.keys()[0]
		high_score_array.append(entry[score_value] + ": " + score_value + "\n")
		
	for i in high_score_array.size():
		high_score_string += high_score_array[high_score_array.size() - i - 1] 
		
	$HighScores_Label.text = high_score_string
	$HighScores_Label.show()

#can probably get away with seeing if we have a score that's higher than
#the lowest stored score. Order should be maintained by other functions.
func check_highscores():
	for entry in highscore_data:
		var score_value = entry.keys()[0]
		if current_score > int(score_value):
			return true
		elif current_score < int(score_value):
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
#this should only be called if a letter has been deleted
func _on_line_edit_text_changed(new_text):
	$LineEdit.text = new_text + "-"
	new_text = new_text.replace("-","")
	$LineEdit.set_caret_column(new_text.length())

#this action should only occur if a player has obtained a 
#high score.
func _on_line_edit_text_submitted(new_text):
	$EnterName.hide()
	$LineEdit.hide()
	$LineEdit.text = "---"
	$Saving.show()
	await get_tree().create_timer(1.0).timeout
	save_highscores(new_text)
	$Saving.hide()
	
	game_over_display()

#The text should always be full. This allows us to maintain a clean
#look to the text field by replacing the placeholders "-"
#with letters
func _on_line_edit_text_change_rejected(rejected_substring):
	if $LineEdit.text.contains("-"):
		$LineEdit.text[$LineEdit.text.find("-")] = rejected_substring.capitalize()
		var no_dashes = $LineEdit.text.replace("-", "")
		$LineEdit.set_caret_column(no_dashes.length())

#######################/Text Input for High Scores/#########################################
