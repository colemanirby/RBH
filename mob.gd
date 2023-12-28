extends RigidBody2D

@export var speed = 300

signal killed

var target

# Called when the node enters the scene tree for the first time.
func _ready():
	target = get_parent().get_node("Player")
	var mob_types = $AnimatedSprite2D.sprite_frames.get_animation_names()
	# randi() % n selects a random integer between 0 and n-1
	$AnimatedSprite2D.play(mob_types[randi() % mob_types.size()])

func _physics_process(delta):
	if target:
		var velocity = global_position.direction_to(target.global_position)
		move_and_collide(velocity * speed * delta)
		
func _on_visible_on_screen_notifier_2d_screen_exited():
	#queue_free()
	pass
	

func _on_area_2d_area_entered(_area):
	killed.emit()
	queue_free()

