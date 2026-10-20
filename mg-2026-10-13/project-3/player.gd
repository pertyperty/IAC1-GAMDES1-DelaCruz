extends Area2D

signal health_changed(current: int, maximum: int)
signal died

@export var speed: float = 400.0
@export var max_health: int = 3
@export var invincibility_duration: float = 1.0

var health: int = 3
var alive := false
var invincible := false
var damage_timer := 0.0
var screen_size: Vector2

func _ready() -> void:
	screen_size = get_viewport_rect().size
	collision_mask = 2
	body_entered.connect(_on_body_entered)
	hide()
	set_process(false)
	set_deferred("monitoring", false)

func start(start_position: Vector2) -> void:
	position = start_position
	health = max_health
	alive = true
	invincible = false
	damage_timer = 0.0
	$AnimatedSprite2D.modulate.a = 1.0
	$AnimatedSprite2D.rotation = 0.0
	$AnimatedSprite2D.flip_h = false
	$AnimatedSprite2D.play("up")
	show()
	set_process(true)
	set_deferred("monitoring", true)
	health_changed.emit(health, max_health)

func _process(delta: float) -> void:
	if not alive:
		return
	if invincible:
		damage_timer -= delta
		$AnimatedSprite2D.modulate.a = 0.4 if int(Time.get_ticks_msec() / 120) % 2 == 0 else 1.0
		if damage_timer <= 0.0:
			invincible = false
			$AnimatedSprite2D.modulate.a = 1.0

	var movement := Input.get_vector("left", "right", "up", "down")
	if movement != Vector2.ZERO:
		# The source sprites face up. Rotate them to the movement vector.
		# Input.get_vector normalizes diagonals, so diagonal movement is not faster.
		# Angle is snapped to 45-degree increments (8 possible facings).
		var facing := snappedf(movement.angle() + PI / 2.0, PI / 4.0)
		$AnimatedSprite2D.rotation = facing
		$AnimatedSprite2D.flip_h = false
		$AnimatedSprite2D.play("walk")
	else:
		$AnimatedSprite2D.stop()
	position += movement * speed * delta
	position = position.clamp(Vector2(28.0, 35.0), screen_size - Vector2(28.0, 35.0))

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("mobs"):
		take_damage(1)

func take_damage(amount: int = 1) -> void:
	if not alive or invincible:
		return
	health = maxi(0, health - amount)
	health_changed.emit(health, max_health)
	if health == 0:
		alive = false
		hide()
		set_process(false)
		set_deferred("monitoring", false)
		died.emit()
	else:
		invincible = true
		damage_timer = invincibility_duration
