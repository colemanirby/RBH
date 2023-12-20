extends Node

@export var mob_scene: PackedScene

var score

func game_over():
	$MobTimer.stop()
	$HUD.show_game_over()
	$Music.stop()

func new_game():
	score = 0
	$Player.start($StartPosition.position)
	$StartTimer.start()
	$HUD.update_score(score)
	$HUD.show_message("Have Fun!")
	get_tree().call_group("mobs", "queue_free")
	
	$Music.play()

func _on_player_fire(Bullet, direction, location):
	var spawned_bullet = Bullet.instantiate()
	add_child(spawned_bullet)
	spawned_bullet.rotation = direction
	spawned_bullet.position = location
	spawned_bullet.velocity = spawned_bullet.velocity.rotated(direction)
	
# every time the mob timer runs out, generate a new mob entity
func _on_mob_timer_timeout():
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

func killed():
	print("Killed Enemy")
	$EnemyDead.play()
	score += 1
	$HUD.update_score(score)
#func _on_score_timer_timeout():
	#score += 1
	#$HUD.update_score(score)

func _on_start_timer_timeout():
	$MobTimer.start()
