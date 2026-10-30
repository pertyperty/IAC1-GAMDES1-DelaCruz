extends CanvasLayer

signal start_game

func _ready() -> void:
	$StartButton.pressed.connect(_on_start_button_pressed)
	$MessageTimer.timeout.connect(_on_message_timer_timeout)
	$StartButton.show()
	$Message.text = "Dodge the Creeps!"
	$Message.show()
	$HealthLabel.text = "HP: 3 / 3"

func show_message(message: String) -> void:
	$Message.text = message
	$Message.show()
	$MessageTimer.start()

func show_game_over() -> void:
	show_message("Game Over")
	await $MessageTimer.timeout
	$Message.text = "Dodge the Creeps!"
	$Message.show()
	await get_tree().create_timer(1.0).timeout
	$StartButton.show()

func update_score(score: int) -> void:
	$ScoreLabel.text = str(score)

func update_health(current: int, maximum: int) -> void:
	$HealthLabel.text = "HP: %d / %d" % [current, maximum]

func _on_start_button_pressed() -> void:
	$StartButton.hide()
	start_game.emit()

func _on_message_timer_timeout() -> void:
	$Message.hide()
