extends RigidBody2D

@export var minimum_speed: float = 110.0
@export var maximum_speed: float = 240.0
@export var spawn_margin: float = 55.0

var playing: bool = true
var screen_size: Vector2
var rng := RandomNumberGenerator.new()

func _ready() -> void:
	rng.randomize()
	screen_size = get_viewport_rect().size
	gravity_scale = 0.0
	lock_rotation = true
	collision_layer = 2
	collision_mask = 0
	$AnimatedSprite2D.play("enemy")
	recycle()

func _physics_process(_delta: float) -> void:
	if not playing:
		return
	var m := spawn_margin + 45.0
	if global_position.x < -m or global_position.x > screen_size.x + m or global_position.y < -m or global_position.y > screen_size.y + m:
		recycle()

func recycle() -> void:
	if not playing:
		return
	var edge := rng.randi_range(0, 3)
	var start := Vector2.ZERO
	match edge:
		0: start = Vector2(-spawn_margin, rng.randf_range(0.0, screen_size.y))
		1: start = Vector2(screen_size.x + spawn_margin, rng.randf_range(0.0, screen_size.y))
		2: start = Vector2(rng.randf_range(0.0, screen_size.x), -spawn_margin)
		_: start = Vector2(rng.randf_range(0.0, screen_size.x), screen_size.y + spawn_margin)
	var target := Vector2(
		rng.randf_range(screen_size.x * 0.20, screen_size.x * 0.80),
		rng.randf_range(screen_size.y * 0.20, screen_size.y * 0.80)
	)
	var direction := (target - start).normalized()
	global_position = start
	linear_velocity = direction * rng.randf_range(minimum_speed, maximum_speed)
	rotation = direction.angle() + PI / 2.0

func stop() -> void:
	playing = false
	linear_velocity = Vector2.ZERO
	freeze = true
	set_physics_process(false)
