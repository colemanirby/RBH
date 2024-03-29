extends Node

@export var mob_scene: PackedScene

var score

var play_music = false
var spawn_mob = true
var max_mob_count = 20
var mob_count = 0

func game_over():
	get_tree().call_group("mobs", "queue_free")
	mob_count = 0
	$MobTimer.stop()
	$GUI.show_game_over()
	$Music.stop()

func new_game():
	score = 0
	$Player.start($StartPosition.position)
	$StartTimer.start()
	$GUI.update_score(score)
	$GUI.show_message("Have Fun!")
	
	if play_music:
		$Music.play()

func _on_player_fire(Bullet, direction, location):
	var spawned_bullet = Bullet.instantiate()
	add_child(spawned_bullet)
	spawned_bullet.rotation = direction
	spawned_bullet.position = location
	
	#rotate the bullet's velocity vector to point in the direction the ship is facing
	spawned_bullet.velocity = spawned_bullet.velocity.rotated(direction)
	
# every time the mob timer runs out, generate a new mob entity
func _on_mob_timer_timeout():
	if spawn_mob and mob_count < max_mob_count:
		var mob = mob_scene.instantiate()
		
		var mob_spawn_location = get_node("MobPath/MobSpawnLocation")
		mob_spawn_location.progress_ratio = randf()
		
		var direction = mob_spawn_location.rotation + PI / 2
		
		mob.position = mob_spawn_location.position
		
		direction += randf_range(-PI / 4, PI / 4)
		#mob.rotation = direction
		
		var velocity = Vector2(randf_range(150.0, 150.0), 0.0)
		mob.linear_velocity = velocity.rotated(direction)

		mob.connect("killed", killed)
		add_child(mob)
		mob_count = mob_count + 1

func killed():
	$EnemyDead.play()
	mob_count = mob_count - 1
	score += 1
	$GUI.update_score(score)

func _on_start_timer_timeout():
	$MobTimer.start()


func _on_hud_mute_music():
	play_music = not play_music
	if not play_music:
		$Music.stop()
	else:
		$Music.play()
