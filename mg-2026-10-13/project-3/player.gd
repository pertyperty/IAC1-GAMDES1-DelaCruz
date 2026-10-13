extends Area2D

signal health_changed(current: int, maximum: int)
signal died

@export var speed: float = 400.0
@export var max_health: int = 3
@export var invincibility_duration: float = 1.0

var health: int
var screen_size: Vector2
var invincible: bool = false
var alive: bool = true
var damage_timer: float = 0.0

func _ready() -> void:
	screen_size = get_viewport_rect().size
	health = max_health
	collision_mask = 2
	body_entered.connect(_on_body_entered)
	health_changed.emit(health, max_health)

func _process(delta: float) -> void:
	if not alive:
		return

	if invincible:
		damage_timer -= delta
		$AnimatedSprite2D.modulate.a = 0.45 if int(Time.get_ticks_msec() / 120) % 2 == 0 else 1.0
		if damage_timer <= 0.0:
			invincible = false
			$AnimatedSprite2D.modulate.a = 1.0

	var velocity := Input.get_vector("left", "right", "up", "down")
	if velocity != Vector2.ZERO:
		$AnimatedSprite2D.play("walk")
	else:
		$AnimatedSprite2D.stop()

	position += velocity * speed * delta
	position = position.clamp(Vector2(28.0, 35.0), screen_size - Vector2(28.0, 35.0))

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies"):
		take_damage(1)

func take_damage(amount: int = 1) -> void:
	if not alive or invincible:
		return
	health = maxi(health - amount, 0)
	health_changed.emit(health, max_health)
	if health == 0:
		alive = false
		$AnimatedSprite2D.stop()
		$AnimatedSprite2D.modulate.a = 1.0
		died.emit()
	else:
		invincible = true
		damage_timer = invincibility_duration
