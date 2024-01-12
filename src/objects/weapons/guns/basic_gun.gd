extends Node2D

signal fire(bullet, direction, location)

@export var shot_delay = 0.1
var Bullet = preload("res://src/objects/weapons/bullets/basic/bullet.tscn")
var can_fire = true


# Called when the node enters the scene tree for the first time.
func _ready():
	hide()
	$Gun_Sprite.animation = "chillin"
	$Gun_Sprite.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if visible:
		if Input.is_action_pressed("click") and can_fire:
			can_fire = false
			$Gun_Sprite.animation = "firin"
			$Gun_Sprite.play()
			fire.emit(Bullet, global_rotation - PI / 2, global_position)
			$ShotTimer.start(shot_delay)
		else:
			$Gun_Sprite.animation = "chillin"
			
func _on_shot_timer_timeout():
	can_fire = true
