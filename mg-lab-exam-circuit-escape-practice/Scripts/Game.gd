extends Node2D

const REQUIRED_CIRCUITS: int = 2
const REQUIRED_TERMINALS: int = 2

var collected_circuits: int = 0
var activated_terminals: int = 0

var terminals_unlocked: bool = false
var exit_unlocked: bool = false

@onready var collectibles: Node2D = $Collectibles
@onready var hud: CanvasLayer = $HUD
@onready var terminals: Node2D = $Terminals
@onready var doors: TileMapLayer = $Doors

const EXIT_CELL := Vector2i(4,7)
const EXIT_CELL2 := Vector2i(5,7)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var collectible_cell := Vector2i(2,7)
	var collectible_cell2 := Vector2i(1,3)

	$Collectibles/PowerCircuit.position = (
		$Ground.map_to_local(collectible_cell)
	)
	$Collectibles/PowerCircuit2.position = (
		$Ground.map_to_local(collectible_cell2)
	)
	
	for circuit in collectibles.get_children():
		circuit.collected.connect(_on_circuit_collected)
	
	for terminal in terminals.get_children():
		terminal.activation_requested.connect(
			_on_terminal_activation_requested
		)
	
	update_hud()

func unlock_exit() -> void:
	doors.erase_cell(EXIT_CELL)
	doors.erase_cell(EXIT_CELL2)

func _on_circuit_collected() -> void:
	collected_circuits += 1
	update_hud()
	check_objective_completion()

func _on_terminal_activation_requested(terminal: CircuitTerminal) -> void:
	if terminal.is_activated:
		return
	
	if not terminals_unlocked:
		hud.objective_status("Insufficient power")
		return
	
	terminal.is_activated = true
	activated_terminals += 1
	update_hud()
	check_objective_completion()
	

func check_objective_completion() -> void:
	if exit_unlocked:
		return

	if activated_terminals == REQUIRED_TERMINALS:
		exit_unlocked = true
		hud.objective_status("You have unlocked the door!")
		unlock_exit()
		return

	if collected_circuits >= REQUIRED_CIRCUITS:
		terminals_unlocked = true
		hud.objective_status("You can now activate the terminals!")
		update_hud()
		

func update_hud() -> void:
	hud.update_circuits(
		collected_circuits,
		REQUIRED_CIRCUITS	
	)
	
	hud.update_terminals(
		activated_terminals,
		REQUIRED_TERMINALS
	)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
