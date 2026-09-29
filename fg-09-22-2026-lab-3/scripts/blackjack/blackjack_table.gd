class_name BlackjackTable
extends Node3D

const CARD_SCENE = preload("res://scenes/Card.tscn")

var game: BlackjackGame
var dealer_playing := false
var player_in_range := false
var current_player: CharacterBody3D = null
var blackjack_mode := false
var bet_input := ""

@onready var interaction_area: Area3D = $InteractionArea
@onready var blackjack_camera: Camera3D = $CameraPosition/Camera3D

@onready var player_card_positions: Node3D = $PlayerCardPos
@onready var dealer_card_positions: Node3D = $DealerCardPos

@onready var result_label: Label3D = $ResultLabel
@onready var player_value_label: Label3D = $PlayerValueLabel
@onready var dealer_value_label: Label3D = $DealerValueLabel
@onready var status_label: Label3D = $StatusLabel

@onready var game_ui: CanvasLayer = $GameUI

@onready var balance_label: Label = $GameUI/Controls/BalanceLabel
@onready var bet_label: Label = $GameUI/Controls/BetLabel
@onready var bet_status_label: Label = $GameUI/Controls/BetStatusLabel
@onready var play_prompt_label: Label = $GameUI/Controls/PlayPromptLabel

@onready var button_0: Button = $GameUI/Controls/Button0
@onready var button_1: Button = $GameUI/Controls/Button1
@onready var button_2: Button = $GameUI/Controls/Button2
@onready var button_3: Button = $GameUI/Controls/Button3
@onready var button_4: Button = $GameUI/Controls/Button4
@onready var button_5: Button = $GameUI/Controls/Button5
@onready var button_6: Button = $GameUI/Controls/Button6
@onready var button_7: Button = $GameUI/Controls/Button7
@onready var button_8: Button = $GameUI/Controls/Button8
@onready var button_9: Button = $GameUI/Controls/Button9
@onready var clear_button: Button = $GameUI/Controls/ClearButton

@onready var hit_button: Button = $GameUI/Controls/HitButton
@onready var stand_button: Button = $GameUI/Controls/StandButton
@onready var new_round_button: Button = $GameUI/Controls/NewRoundButton


func _ready():
	game = BlackjackGame.new()

	blackjack_camera.current = false
	game_ui.visible = false

	result_label.text = ""

	interaction_area.body_entered.connect(_on_player_entered)
	interaction_area.body_exited.connect(_on_player_exited)

	button_0.pressed.connect(_on_digit_pressed.bind(0))
	button_1.pressed.connect(_on_digit_pressed.bind(1))
	button_2.pressed.connect(_on_digit_pressed.bind(2))
	button_3.pressed.connect(_on_digit_pressed.bind(3))
	button_4.pressed.connect(_on_digit_pressed.bind(4))
	button_5.pressed.connect(_on_digit_pressed.bind(5))
	button_6.pressed.connect(_on_digit_pressed.bind(6))
	button_7.pressed.connect(_on_digit_pressed.bind(7))
	button_8.pressed.connect(_on_digit_pressed.bind(8))
	button_9.pressed.connect(_on_digit_pressed.bind(9))

	clear_button.pressed.connect(clear_bet)

	hit_button.pressed.connect(hit)
	stand_button.pressed.connect(stand)
	new_round_button.pressed.connect(start_betting)

	update_button_state()
	update_information()
	update_betting_ui()


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

		if event.keycode == KEY_F:
			if blackjack_mode and game.state == BlackjackGame.GameState.BETTING:
				confirm_bet()


func enter_blackjack_mode():
	if current_player == null:
		return

	blackjack_mode = true

	current_player.enter_blackjack_mode()

	blackjack_camera.current = true
	game_ui.visible = true

	start_betting()


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


func start_betting():
	if not blackjack_mode:
		return

	game.start_betting()

	bet_input = ""

	update_cards()
	update_button_state()
	update_information()
	update_betting_ui()


func _on_digit_pressed(digit: int):
	if game.state != BlackjackGame.GameState.BETTING:
		return

	if bet_input.length() >= 4:
		return

	if bet_input == "0":
		bet_input = ""

	bet_input += str(digit)

	update_betting_ui()


func clear_bet():
	if game.state != BlackjackGame.GameState.BETTING:
		return

	bet_input = ""

	update_betting_ui()


func confirm_bet():
	if game.state != BlackjackGame.GameState.BETTING:
		return

	if bet_input.is_empty():
		bet_status_label.text = "ENTER A BET"
		return

	var amount := int(bet_input)

	if amount <= 0:
		bet_status_label.text = "INVALID BET"
		return

	if amount > game.player_balance:
		bet_status_label.text = "NOT ENOUGH BALANCE"
		return

	if not game.place_bet(amount):
		bet_status_label.text = "INVALID BET"
		return

	game.start_round()

	bet_input = ""

	update_cards()
	update_button_state()
	update_information()
	update_betting_ui()


func hit():
	if game.state != BlackjackGame.GameState.PLAYER_TURN:
		return

	game.player_hit()

	if game.state == BlackjackGame.GameState.ROUND_OVER:
		game.settle_round()

	update_cards()
	update_button_state()
	update_information()
	update_betting_ui()


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

	if game.state == BlackjackGame.GameState.ROUND_OVER:
		game.settle_round()

	dealer_playing = false

	update_button_state()
	update_cards()
	update_information()
	update_betting_ui()


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
	var betting := game.state == BlackjackGame.GameState.BETTING
	var player_turn := game.state == BlackjackGame.GameState.PLAYER_TURN
	var round_over := game.state == BlackjackGame.GameState.ROUND_OVER

	button_0.disabled = not betting
	button_1.disabled = not betting
	button_2.disabled = not betting
	button_3.disabled = not betting
	button_4.disabled = not betting
	button_5.disabled = not betting
	button_6.disabled = not betting
	button_7.disabled = not betting
	button_8.disabled = not betting
	button_9.disabled = not betting
	clear_button.disabled = not betting

	hit_button.disabled = not player_turn
	stand_button.disabled = not player_turn

	new_round_button.disabled = not round_over

	var betting_visible := betting

	button_0.visible = betting_visible
	button_1.visible = betting_visible
	button_2.visible = betting_visible
	button_3.visible = betting_visible
	button_4.visible = betting_visible
	button_5.visible = betting_visible
	button_6.visible = betting_visible
	button_7.visible = betting_visible
	button_8.visible = betting_visible
	button_9.visible = betting_visible
	clear_button.visible = betting_visible

	bet_label.visible = betting_visible
	bet_status_label.visible = betting_visible
	play_prompt_label.visible = betting_visible


func update_betting_ui():
	balance_label.text = "BALANCE: $" + str(game.player_balance)
	bet_label.text = "BET: $" + (bet_input if not bet_input.is_empty() else "0")

	if game.state == BlackjackGame.GameState.BETTING:
		if bet_input.is_empty():
			bet_status_label.text = "ENTER YOUR BET"
		else:
			bet_status_label.text = "PRESS F TO PLAY"

		play_prompt_label.text = "F - PLAY"
	else:
		bet_status_label.text = ""
		play_prompt_label.text = ""


func update_information():
	player_value_label.text = "PLAYER: " + str(game.player_hand.get_value())

	if game.state == BlackjackGame.GameState.PLAYER_TURN:
		dealer_value_label.text = "DEALER: ?"
	else:
		dealer_value_label.text = "DEALER: " + str(game.dealer.get_value())

	if game.state == BlackjackGame.GameState.IDLE:
		status_label.text = ""

	elif game.state == BlackjackGame.GameState.BETTING:
		status_label.text = "PLACE YOUR BET"

	elif game.state == BlackjackGame.GameState.PLAYER_TURN:
		status_label.text = "YOUR TURN"

	elif game.state == BlackjackGame.GameState.DEALER_TURN:
		status_label.text = "DEALER TURN"

	elif game.state == BlackjackGame.GameState.ROUND_OVER:
		status_label.text = game.result
