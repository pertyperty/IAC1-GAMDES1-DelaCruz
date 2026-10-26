extends CanvasLayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func update_circuits(current: int, required: int) -> void:
	$CircuitLabel.text = "Circuits: %d / %d" % [
		current,
		required
	]
	print(current)
	return

func update_terminals(current: int, required: int) -> void:
	$TerminalLabel.text ="Terminals: %d / %d" % [
		current,
		required
	]
	print(current)
	return
	
func objective_status(message: String) -> void:
	$ObjectiveLabel.text = "%s" % [
		message
	]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
