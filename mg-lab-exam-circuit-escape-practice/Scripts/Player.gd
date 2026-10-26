extends CharacterBody2D

@onready var walls: TileMapLayer = $"../Walls"
@onready var ground: TileMapLayer = $"../Ground"
@onready var doors: TileMapLayer = $"../Doors"

const TILE_SIZE: int = 64
const GRID_WIDTH: int = 13
const GRID_HEIGHT: int = 11

var grid_position: Vector2i = Vector2i(1, 1)
var is_moving: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	position = ground.map_to_local(grid_position)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var direction := Vector2i.ZERO
	
	if Input.is_action_just_pressed("right"):
		direction = Vector2i.RIGHT
	if Input.is_action_just_pressed("left"):
		direction = Vector2i.LEFT
	if Input.is_action_just_pressed("up"):
		direction = Vector2i.UP
	if Input.is_action_just_pressed("down"):
		direction = Vector2i.DOWN
		
	if direction != Vector2i.ZERO:
		move_one_tile(direction)

func is_inside_grid(cell: Vector2i) -> bool:
	return (
		cell.x >= 1
		and cell.x < GRID_WIDTH - 1
		and cell.y >= 1
		and cell.y < GRID_HEIGHT - 1
	)
	
func can_move_to(cell: Vector2i) -> bool:
	if not is_inside_grid(cell):
		return false
	
	if walls.get_cell_source_id(cell) != -1 or doors.get_cell_source_id(cell) != -1:
		return false
		
	return true

func move_one_tile(direction: Vector2i) -> void:
	if is_moving:
		return
	
	var next_position := grid_position + direction
	
	if not can_move_to(next_position):
		return
	
	is_moving = true
	grid_position = next_position
	
	var tween := create_tween()
	
	tween.tween_property(
		self,
		"position",
		ground.map_to_local(grid_position),
		0.15
	)
	
	await tween.finished
	
	is_moving = false
