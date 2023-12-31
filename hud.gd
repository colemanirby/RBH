extends CanvasLayer

signal start_game
signal mute_music
# Called when the node enters the scene tree for the first time.

var show_highscores = false
func _ready():
	#save_2()
	$Unpause.hide()
	$HighScores_Label.hide()
	load_highscores()
	
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
	$StartButton.show()
	
func update_score(score):
	$ScoreLabel.text = str(score)

func _on_message_timer_timeout():
	$Message.hide()


func _on_start_button_pressed():
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
	if visible:
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
	
	var high_score_result = json.get_data()
	var high_score_string: String = "High Scores: \n \n"
	sort_high_scores(high_score_result)
	var high_score_array = []
	for score in high_score_result:
		
		#high_score_string.insert(0, name + ": " + high_score_result[name] + "\n")
		#high_score_string += name + ": " + high_score_result[name] + "\n"
		high_score_array.append(high_score_result[score] + ": " + score + "\n")
	for i in high_score_array.size():
		print(i)
		high_score_string += high_score_array[high_score_array.size() - i - 1] 
	print("High Score String: ", high_score_string)
	$HighScores_Label.text = high_score_string
		#
#func save_2():
	#var save_dict = {
		#10: "CKI",
		#9: "BUB",
		#8: "DIC",
		#7: "FUK",
		#6: "ASS",
		#5: "LIK",
		#4: "PUS",
		#3: "TRD",
		#2: "BBW",
		#1: "BCH"
	#}
	#var save_game = FileAccess.open("res://Save/high_scores.json", FileAccess.WRITE)
	#
	#save_game.store_line(JSON.stringify(save_dict))
	#
#func save():
	#var save_dict = {
		#"CKI": "10",
		#"BUB": "9",
		#"DIC": "8",
		#"FUK": "7",
		#"ASS": "6",
		#"LIK": "5",
		#"PUS": "4",
		#"TRD": "3",
		#"BBW": "2",
		#"BCH": "1"
	#}
	#var save_game = FileAccess.open("res://Save/high_scores.json", FileAccess.WRITE)
	#
	#save_game.store_line(JSON.stringify(save_dict))

func sort_high_scores(high_score_result):
	#var sorted_result = {}
	#for name in high_score_result:
		#if(sorted_result.is_empty())
		#sorted_result[name] 
	pass
	
func _on_high_scores_pressed():
	hide_buttons()
	$HighScores_Label.show()

func show_buttons():
	$ScoreLabel.show()
	$Message.show()
	$StartButton.show()
	$HighScores.show()
	$Mute.show()
	
func hide_buttons():
	$ScoreLabel.hide()
	$Message.hide()
	$StartButton.hide()
	$HighScores.hide()
	$Mute.hide()
	
