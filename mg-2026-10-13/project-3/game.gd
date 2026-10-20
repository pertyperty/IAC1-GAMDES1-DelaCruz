extends Node2D

@export var mob_scene: PackedScene = preload("res://enemy.tscn")
var score: int = 0
var running := false

func _ready() -> void:
	randomize()
	var border := Curve2D.new()
	for point in [Vector2.ZERO, Vector2(0, 720), Vector2(480, 720), Vector2(480, 0), Vector2.ZERO]:
		border.add_point(point)
	$MobPath.curve = border
	$Music.stream = $Music.stream.duplicate()
	$Music.stream.loop = true
	$HUD.start_game.connect(new_game)
	$player.health_changed.connect($HUD.update_health)
	$player.died.connect(game_over)
	$MobTimer.timeout.connect(_on_mob_timer_timeout)
	$ScoreTimer.timeout.connect(_on_score_timer_timeout)
	$StartTimer.timeout.connect(_on_start_timer_timeout)

func new_game() -> void:
	running = false
	get_tree().call_group("mobs", "queue_free")
	score = 0
	$HUD.update_score(score)
	$player.start($StartPosition.position)
	$HUD.show_message("Get Ready!")
	$DeathSound.stop()
	$Music.play()
	$StartTimer.start()

func game_over() -> void:
	running = false
	$StartTimer.stop()
	$MobTimer.stop()
	$ScoreTimer.stop()
	$Music.stop()
	$DeathSound.play()
	# Clear remaining mobs so they cannot hit the player during a new round.
	get_tree().call_group("mobs", "queue_free")
	$HUD.show_game_over()

func _on_start_timer_timeout() -> void:
	running = true
	$MobTimer.start()
	$ScoreTimer.start()

func _on_score_timer_timeout() -> void:
	if running:
		score += 1
		$HUD.update_score(score)

func _on_mob_timer_timeout() -> void:
	if not running:
		return
	var mob := mob_scene.instantiate() as RigidBody2D
	var location := $MobPath/MobSpawnLocation as PathFollow2D
	location.progress_ratio = randf()
	# Aim toward a random point inside the arena. This is independent of
	# the clockwise/counterclockwise direction of the perimeter path.
	var viewport_size := get_viewport_rect().size
	var target := Vector2(
		randf_range(viewport_size.x * 0.25, viewport_size.x * 0.75),
		randf_range(viewport_size.y * 0.25, viewport_size.y * 0.75)
	)
	var direction := (target - location.position).angle()
	mob.position = location.position
	mob.rotation = direction
	mob.linear_velocity = Vector2.RIGHT.rotated(direction) * randf_range(150.0, 250.0)
	$Enemies.add_child(mob)
