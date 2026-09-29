class_name BlackjackTable
extends Node3D

const CARD_SCENE = preload("res://scenes/Card.tscn")

var game: BlackjackGame
var dealer_playing := false
var player_in_range := false
var current_player: CharacterBody3D = null
var blackjack_mode := false

@onready var interaction_area: Area3D = $InteractionArea
@onready var blackjack_camera: Camera3D = $CameraPosition/Camera3D

@onready var player_card_positions: Node3D = $PlayerCardPos
@onready var dealer_card_positions: Node3D = $DealerCardPos
@onready var result_label: Label3D = $ResultLabel

@onready var player_value_label: Label3D = $PlayerValueLabel
@onready var dealer_value_label: Label3D = $DealerValueLabel
@onready var status_label: Label3D = $StatusLabel

@onready var hit_button: Button = $GameUI/Controls/HitButton
@onready var stand_button: Button = $GameUI/Controls/StandButton
@onready var new_round_button: Button = $GameUI/Controls/NewRoundButton

@onready var game_ui: CanvasLayer = $GameUI

func _ready():
	game = BlackjackGame.new()

	blackjack_camera.current = false
	game_ui.visible = false

	result_label.text = ""

	interaction_area.body_entered.connect(_on_player_entered)
	interaction_area.body_exited.connect(_on_player_exited)

	hit_button.pressed.connect(hit)
	stand_button.pressed.connect(stand)
	new_round_button.pressed.connect(start_game)

	update_button_state()
	update_information()


func _on_player_entered(body):
	if body is CharacterBody3D:
		current_player = body
		player_in_range = true


func _on_player_exited(body):
	if body == current_player and not blackjack_mode:
		current_player = null
		player_in_range = false


func _unhandled_input(event):
	if event is InputEventKey:
		if not event.pressed:
			return

		if event.keycode == KEY_E:
			if player_in_range and not blackjack_mode:
				enter_blackjack_mode()

		if event.keycode == KEY_ESCAPE:
			if blackjack_mode:
				exit_blackjack_mode()

		if event.keycode == KEY_SPACE:
			if blackjack_mode and game.state == BlackjackGame.GameState.IDLE:
				start_game()


func enter_blackjack_mode():
	if current_player == null:
		return

	blackjack_mode = true

	current_player.enter_blackjack_mode()

	blackjack_camera.current = true
	game_ui.visible = true


func exit_blackjack_mode():
	if current_player == null:
		return

	blackjack_mode = false

	game_ui.visible = false
	blackjack_camera.current = false

	current_player.exit_blackjack_mode()

	if not interaction_area.overlaps_body(current_player):
		current_player = null
		player_in_range = false


func start_game():
	if not blackjack_mode:
		return

	if game.state != BlackjackGame.GameState.IDLE and game.state != BlackjackGame.GameState.ROUND_OVER:
		return

	game.start_round()
	update_cards()
	update_button_state()
	update_information()


func hit():
	if game.state != BlackjackGame.GameState.PLAYER_TURN:
		return

	game.player_hit()
	update_cards()
	update_button_state()
	update_information()


func stand():
	if game.state != BlackjackGame.GameState.PLAYER_TURN:
		return

	game.player_stand()
	update_cards()
	update_button_state()
	update_information()

	play_dealer_turn()


func play_dealer_turn():
	if dealer_playing:
		return

	dealer_playing = true
	update_button_state()

	while game.state == BlackjackGame.GameState.DEALER_TURN:
		await get_tree().create_timer(1.0).timeout

		var drew_card := game.dealer_play_step()

		update_cards()
		update_information()

		if not drew_card:
			break

	dealer_playing = false
	update_button_state()
	update_cards()
	update_information()


func update_cards():
	clear_cards(player_card_positions)
	clear_cards(dealer_card_positions)

	for i in range(game.player_hand.cards.size()):
		var card_data: BlackjackCard = game.player_hand.cards[i]

		add_card_visual(
			card_data,
			player_card_positions,
			i
		)

	for i in range(game.dealer.hand.cards.size()):
		var card_data: BlackjackCard = game.dealer.hand.cards[i]

		var card_visual := add_card_visual(
			card_data,
			dealer_card_positions,
			i
		)

		if game.state == BlackjackGame.GameState.PLAYER_TURN and i == 0:
			card_visual.set_face_up(false)

	if game.state == BlackjackGame.GameState.ROUND_OVER:
		result_label.text = game.result
	else:
		result_label.text = ""


func add_card_visual(
	card_data: BlackjackCard,
	position_container: Node3D,
	index: int
) -> BlackjackCardVisual:
	var card_visual := CARD_SCENE.instantiate() as BlackjackCardVisual

	position_container.add_child(card_visual)

	card_visual.position = Vector3(
		index * 0.9 - 0.45,
		0,
		0
	)

	card_visual.set_card(card_data)

	return card_visual


func clear_cards(container: Node3D):
	for child in container.get_children():
		child.queue_free()


func update_button_state():
	var player_turn := game.state == BlackjackGame.GameState.PLAYER_TURN
	var round_over := game.state == BlackjackGame.GameState.ROUND_OVER

	hit_button.disabled = not player_turn
	stand_button.disabled = not player_turn
	new_round_button.disabled = not round_over


func update_information():
	player_value_label.text = "PLAYER: " + str(game.player_hand.get_value())

	if game.state == BlackjackGame.GameState.PLAYER_TURN:
		dealer_value_label.text = "DEALER: ?"
	else:
		dealer_value_label.text = "DEALER: " + str(game.dealer.get_value())

	if game.state == BlackjackGame.GameState.IDLE:
		status_label.text = "PLACE YOUR BET"

	elif game.state == BlackjackGame.GameState.PLAYER_TURN:
		status_label.text = "YOUR TURN"

	elif game.state == BlackjackGame.GameState.DEALER_TURN:
		status_label.text = "DEALER TURN"

	elif game.state == BlackjackGame.GameState.ROUND_OVER:
		status_label.text = game.result
