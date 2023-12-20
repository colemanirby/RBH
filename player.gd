extends Area2D

@export var speed = 400
var Bullet = preload("res://bullet.tscn")
var screen_size

signal hit
signal fire(bullet, direction, location)

# Called when the node enters the scene tree for the first time.
func _ready():
	hide()
	screen_size = get_viewport_rect().size

func start(pos):
	position = pos
	$AnimatedSprite2D.animation = "right"
	rotation = get_global_mouse_position().angle_to_point(position) + PI
	show()
	$CollisionShape2D.disabled = false

func _physics_process(delta):
	rotation = get_global_mouse_position().angle_to_point(position) + PI
	
func _input(event):
	if visible:
		if event.is_action_pressed("click"):
			fire.emit(Bullet, rotation, position)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#direction = get_global_mouse_position() - position
	var velocity = Vector2.ZERO
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1
	
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()
	
	position += velocity * delta
	position = position.clamp(Vector2.ZERO, screen_size)
	
	#if velocity.x != 0:
		#$AnimatedSprite2D.animation = "right"
		#$AnimatedSprite2D.flip_v = false
		#$AnimatedSprite2D.flip_h = velocity.x < 0
	#if velocity.y != 0:
		#$AnimatedSprite2D.animation = "up"
		#$AnimatedSprite2D.flip_v = velocity.y > 0
		
	#if velocity.x != 0 or velocity.y != 0:
		#$AnimatedSprite2D.animation = "right"


func _on_body_entered(body):
	$Yell.play()
	hide()
	hit.emit()
	
	# Using set_deferred() tells Godot to wait to disable the shape until it's safe to do so
	$CollisionShape2D.set_deferred("disabled", true)
