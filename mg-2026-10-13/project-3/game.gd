extends Node2D

const ENEMY_SCENE: PackedScene = preload("res://enemy.tscn")
const MAX_ENEMIES: int = 6

var enemy_count: int = 0
var game_over: bool = false

@onready var player: Area2D = $player
@onready var health_label: Label = $HUD/HealthLabel
@onready var game_over_label: Label = $HUD/GameOverLabel
@onready var spawn_timer: Timer = $SpawnTimer

func _ready() -> void:
	randomize()
	player.health_changed.connect(_on_health_changed)
	player.died.connect(_on_player_died)
	_on_health_changed(player.health, player.max_health)
	game_over_label.hide()
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	spawn_timer.start()

func _on_spawn_timer_timeout() -> void:
	if game_over or enemy_count >= MAX_ENEMIES:
		spawn_timer.stop()
		return
	var enemy := ENEMY_SCENE.instantiate()
	$Enemies.add_child(enemy)
	enemy_count += 1
	if enemy_count >= MAX_ENEMIES:
		spawn_timer.stop()

func _on_health_changed(current: int, maximum: int) -> void:
	health_label.text = "HP: %d / %d" % [current, maximum]

func _on_player_died() -> void:
	game_over = true
	spawn_timer.stop()
	for enemy in $Enemies.get_children():
		enemy.stop()
	game_over_label.show()

func _unhandled_key_input(event: InputEvent) -> void:
	if game_over and event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_R:
		get_tree().reload_current_scene()
