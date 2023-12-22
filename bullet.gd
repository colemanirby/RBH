extends Area2D

@export var speed = 800

var colors = ["Red", "Yellow", "Blue"]
var Flash: AnimatedSprite2D
var velocity = Vector2.RIGHT
# Called when the node enters the scene tree for the first time.
func _ready():
	$Flash.animation = "Flash"
	$Flash.frame = randi() % 3
	pass # Replace with function body.

func _physics_process(delta):
	position += velocity * speed * delta
	$Flash.frame  = randi() % 3
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

