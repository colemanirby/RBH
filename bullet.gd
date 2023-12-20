extends Area2D

@export var speed = 400

var velocity = Vector2.RIGHT
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	position += velocity * delta * speed

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

