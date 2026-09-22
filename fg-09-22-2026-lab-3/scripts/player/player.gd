extends CharacterBody3D

@export var move_speed: float = 4.5
@export var mouse_sensitivity: float = 0.002
@export var jump_velocity: float = 5
@export var gravity: float = 9.8
@onready var camera_arm: SpringArm3D = $CameraArm

var camera_pitch: float = -15.0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)

		camera_pitch -= event.relative.y * mouse_sensitivity * 10
		camera_pitch = clamp(camera_pitch, -60.0, 30.0)

		camera_arm.rotation.x = deg_to_rad(camera_pitch)

	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _physics_process(delta):
	var input_vector := Input.get_vector(
		"move_left",
		"move_right",
		"move_forward",
		"move_backward",
	)


	var direction := transform.basis * Vector3(
		input_vector.x,
		0,
		input_vector.y
	).normalized()

	direction.y = 0
	direction = direction.normalized()

	velocity.x = direction.x * move_speed
	velocity.z = direction.z * move_speed

	# Add gravity if the character is not on the floor.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump when the jump button is pressed and character is on the floor.
	if Input.is_action_just_pressed("move_jump") and is_on_floor():
		velocity.y = jump_velocity


	if direction:
		velocity.x = direction.x * move_speed
		velocity.z = direction.z * move_speed
	else:
		velocity.x = move_toward(velocity.x, 0, move_speed)
		velocity.z = move_toward(velocity.z, 0, move_speed)


	move_and_slide()
