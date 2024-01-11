extends CanvasLayer

signal unpause

func hide_elements():
	$Unpause.hide()

func show_elements():
	$Unpause.show()


func _on_unpause_pressed():
	print("print unpause presssed")
	unpause.emit()
