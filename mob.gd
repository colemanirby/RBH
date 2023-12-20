extends RigidBody2D

signal killed

# Called when the node enters the scene tree for the first time.
func _ready():
	var mob_types = $AnimatedSprite2D.sprite_frames.get_animation_names()
	# randi() % n selects a random integer between 0 and n-1
	$AnimatedSprite2D.play(mob_types[randi() % mob_types.size()])

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
	

func _on_area_2d_area_entered(area):
	killed.emit()
	queue_free()

