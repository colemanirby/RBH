extends Area2D

@export var max_speed = 400
var min_speed = 0.01
@export var shot_delay = 0.1
@export var velocity_increment = .0001
@export var velocity_decrement = 0.001
var velocity_direction_vector = Vector2.ZERO
var Bullet = preload("res://bullet.tscn")
var screen_size
var can_fire = true

signal hit
signal fire(bullet, direction, location)

# Called when the node enters the scene tree for the first time.
func _ready():
	hide()
	screen_size = get_viewport_rect().size

func start(pos):
	position = pos
	$AnimatedSprite2D.animation = "ship"
	$AnimatedSprite2D.play()
	show()
	$CollisionShape2D.disabled = false

func _physics_process(delta):
	if visible:
		if Input.is_action_pressed("right_click"):
			#This may be a bug in the engine? Found this old issue on github specifically for c# version:
			#https://github.com/godotengine/godot/issues/70499
			rotation = get_global_mouse_position().angle_to_point(position) + PI
		if Input.is_action_pressed("click") and can_fire:
			can_fire = false
			fire.emit(Bullet, rotation, position)
			$ShotTimer.start(shot_delay)

		#direction = get_global_mouse_position() - position
		var current_input = Vector2.ZERO
		if Input.is_action_pressed("move_right"):
			current_input.x += 1
		if Input.is_action_pressed("move_left"):
			current_input.x -= 1
		if Input.is_action_pressed("move_down"):
			current_input.y += 1
		if Input.is_action_pressed("move_up"):
			current_input.y -= 1
		

		calc_veloc(current_input)
		position += velocity_direction_vector * max_speed * delta
		#position = position.clamp(Vector2.ZERO, screen_size)
	
func calc_veloc(current_input: Vector2):
	
	var v_x = velocity_direction_vector.x
	var v_y = velocity_direction_vector.y
	var v_len = velocity_direction_vector.length()
	# player has input something
	if current_input.length() >= 1:
		var x_input = current_input.x
		var y_input = current_input.y
		if v_len >= 1 :
			handle_full_velocity(x_input, y_input)
		else:
			print("accumulate_velocity")
			accumulate_velocity(x_input, y_input)
	else:
		if velocity_direction_vector.length() != 0 :
			reduce_velocity(v_len, v_x, v_y)
	
func handle_full_velocity(x, y):
	print("--------------- Handle Full Velocity ---------------")
	print("Handle Full Velocity x: ", x)
	print("Handle Full Velocity y: ", y)
	print("velocity_direction_vector initial: ", velocity_direction_vector)
	velocity_direction_vector += Vector2(x * velocity_increment, y * velocity_increment)
	print("velocity_direction_vector increment: ", velocity_direction_vector)
	velocity_direction_vector = velocity_direction_vector.normalized()
	print("velocity_direction_vector final: ", velocity_direction_vector)
	print("*************** Handle Full Velocity ***************")

func reduce_velocity(current_speed, v_x, v_y):
	
	var reduced_velocity = Vector2(0, 0)
	
	if current_speed > min_speed:
		reduced_velocity.x = (1 - velocity_decrement)*v_x
		reduced_velocity.y = (1 - velocity_decrement)*v_y
		
	velocity_direction_vector = reduced_velocity
	
func accumulate_velocity(x, y):
	velocity_direction_vector += Vector2(x * velocity_increment, y * velocity_increment)
	print(velocity_direction_vector)


func _on_body_entered(_body):
	$Yell.play()
	hide()
	velocity_direction_vector = Vector2(0,0)
	hit.emit()
	
	# Using set_deferred() tells Godot to wait to disable the shape until it's safe to do so
	$CollisionShape2D.set_deferred("disabled", true)

func _on_shot_timer_timeout():
	can_fire = true
