extends CharacterBody3D

@export var move_speed: float = 4.0
@export var mouse_sensitivity: float = 0.002

@onready var camera_arm: SpringArm3D = $CameraArm
@onready var camera: Camera3D = $CameraArm/Camera3D

var camera_pitch: float = -15.0
var in_blackjack := false


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _unhandled_input(event):
	if event is InputEventMouseMotion and not in_blackjack:
		rotate_y(-event.relative.x * mouse_sensitivity)

		camera_pitch -= event.relative.y * mouse_sensitivity
		camera_pitch = clamp(camera_pitch, -60.0, 30.0)

		camera_arm.rotation.x = deg_to_rad(camera_pitch)

	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			if in_blackjack:
				exit_blackjack_mode()
			else:
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _physics_process(delta):
	if in_blackjack:
		velocity = Vector3.ZERO
		return

	var input_vector := Input.get_vector(
		"move_left",
		"move_right",
		"move_forward",
		"move_backward"
	)

	var direction := transform.basis * Vector3(
		input_vector.x,
		0,
		input_vector.y
	)

	direction.y = 0
	direction = direction.normalized()

	velocity.x = direction.x * move_speed
	velocity.z = direction.z * move_speed

	if not is_on_floor():
		velocity.y -= ProjectSettings.get_setting("physics/3d/default_gravity") * delta
	else:
		velocity.y = 0

	move_and_slide()


func enter_blackjack_mode():
	in_blackjack = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func exit_blackjack_mode():
	in_blackjack = false
	camera.current = true
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
