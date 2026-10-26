class_name CircuitTerminal
extends Area2D

signal activation_requested(terminal: CircuitTerminal)

var is_activated: bool = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	if is_activated:
		return
		
	activation_requested.emit(self)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
