extends Area2D

@export var max_speed = 400
@export var acceleration = 1600
@export var deceleration = 100
@export var shot_delay = 0.1
var velocity_increment = .075
var previous_velocity
var velocity_direction_vector = Vector2.ZERO
var Bullet = preload("res://bullet.tscn")
var screen_size
var can_fire = true

signal hit
signal fire(bullet, direction, location)

# Called when the node enters the scene tree for the first time.
func _ready():
	hide()
	previous_velocity = Vector2.ZERO
	screen_size = get_viewport_rect().size

func start(pos):
	position = pos
	$AnimatedSprite2D.animation = "ship"
	$AnimatedSprite2D.play()
	
	#This may be a bug in the engine? Found this old issue on github specifically for c# version:
	#https://github.com/godotengine/godot/issues/70499
	#rotation = get_global_mouse_position().angle_to_point(Vector2.UP)
	
	show()
	$CollisionShape2D.disabled = false

func _physics_process(_delta):
	if visible:
		if Input.is_action_pressed("right_click"):
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
	

	var velocity = calc_veloc_2(current_input, _delta)
	#velocity = velocity.normalized() * max_speed
	#$AnimatedSprite2D.play(
	position += velocity * _delta
	previous_velocity = velocity
	position = position.clamp(Vector2.ZERO, screen_size)
	
func calc_veloc_2(current_input: Vector2, delta):
	var v_x = velocity_direction_vector.x
	var v_y = velocity_direction_vector.y
	var v_len = velocity_direction_vector.length()
	if current_input.length() >= 1:
		# player has input something
		if(v_len >= 1):
			handle_full_velocity(current_input, v_x, v_y)
		else:
			accumulate_velocity(current_input)
	else:
		reduce_velocity()
	return velocity_direction_vector * max_speed
	
func handle_full_velocity(current_input, v_x, v_y):
	var x = current_input.x
	var y = current_input.y
	velocity_direction_vector += Vector2(x * velocity_increment, y * velocity_increment)
	velocity_direction_vector = velocity_direction_vector.normalized()

func reduce_velocity():
	velocity_direction_vector = velocity_direction_vector - Vector2(0.1*velocity_direction_vector.x, 0.1*velocity_direction_vector.y)
	
func accumulate_velocity(current_input):
	var x = current_input.x
	var y = current_input.y
	velocity_direction_vector += Vector2(x * velocity_increment, y * velocity_increment)
	
func handle_decrement_velocity(current_input):
	
	if velocity_direction_vector.x > -1:
		print("decrement")
		velocity_direction_vector -= Vector2(velocity_increment, 0)
	pass
	
func handle_increment_velocity(current_input):
	if velocity_direction_vector.x < 1:
		print("increment")
		velocity_direction_vector += Vector2(velocity_increment, 0)
	pass
	
# Speed up if requested. Slow down otherwise.
func calc_veloc(current_input, delta):
	var final_velocity_vector = previous_velocity
	var final_speed = 0
	if current_input.length() > 0:
		velocity_direction_vector.x += current_input.x * velocity_increment
		#if previous_velocity.length() < max_speed:
			#final_speed = previous_velocity.length() + (acceleration * delta)
			#final_velocity_vector = final_velocity_vector + current_input.normalized() * final_speed
		#else:
			#final_velocity_vector = current_input.normalized() * max_speed
		final_speed = previous_velocity.length() + (velocity_direction_vector.x * acceleration * delta)
		final_velocity_vector = velocity_direction_vector.normalized() * final_speed
	else:
		final_speed = previous_velocity.length() - (deceleration * delta)
		final_velocity_vector = final_velocity_vector.normalized() * final_speed
		
	return final_velocity_vector
		
	

func _on_body_entered(_body):
	$Yell.play()
	hide()
	hit.emit()
	
	# Using set_deferred() tells Godot to wait to disable the shape until it's safe to do so
	$CollisionShape2D.set_deferred("disabled", true)


func _on_shot_timer_timeout():
	can_fire = true
