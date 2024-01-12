extends CanvasLayer

var highscore_data

var final_score

signal save_completed

func _ready():
	hide_elements()
	load_highscores()

func hide_highscores():
	$HighScores_Label.hide()

func show_screen(the_score):
	final_score = the_score
	$EnterName.show()
	$LineEdit.show()
	$LineEdit.grab_focus()

func hide_elements():
	$HighScores_Label.hide()
	$LineEdit.hide()
	$Saving.hide()
	$EnterName.hide()

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

#The text should always be full. This allows us to maintain a clean
#look to the text field by replacing the placeholders "-"
#with letters
func _on_line_edit_text_change_rejected(rejected_substring):
	if $LineEdit.text.contains("-"):
		$LineEdit.text[$LineEdit.text.find("-")] = rejected_substring.capitalize()
		var no_dashes = $LineEdit.text.replace("-", "")
		$LineEdit.set_caret_column(no_dashes.length())

func show_highscores():
	print("showing high scores")
	var high_score_string: String = "High Scores: \n \n"
	var high_score_array = []
	for entry in highscore_data:
		var score_value = entry.keys()[0]
		high_score_array.append(entry[score_value] + ": " + score_value + "\n")
		
	for i in high_score_array.size():
		high_score_string += high_score_array[high_score_array.size() - i - 1] 
	
	print("high_score_string: ", high_score_string)
	$HighScores_Label.text = high_score_string
	$HighScores_Label.show()

func get_lowest_score():
	return highscore_data[0].keys()[0]
	
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
		if final_score <= int(scores[i]) and not inserted_score:
			inserted_score = true
			new_highscores.append({str(final_score): new_name})
		new_highscores.append({scores[i]: names[i]})
	if not inserted_score:
		new_highscores.append({str(final_score): new_name})
	
	var save_game = FileAccess.open("res://Save/high_scores.json", FileAccess.WRITE)
	save_game.store_line(JSON.stringify(new_highscores))
	highscore_data = new_highscores
	save_completed.emit()

