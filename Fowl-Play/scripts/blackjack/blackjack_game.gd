class_name BlackjackGame
extends RefCounted

enum GameState {
	IDLE,
	BETTING,
	PLAYER_TURN,
	DEALER_TURN,
	ROUND_OVER
}

var deck: BlackjackDeck
var player_hand: BlackjackHand
var dealer: BlackjackDealer

var state: GameState = GameState.IDLE
var result: String = ""

var player_balance: int = 1000
var current_bet: int = 0
var round_settled: bool = true


func _init():
	deck = BlackjackDeck.new()
	player_hand = BlackjackHand.new()
	dealer = BlackjackDealer.new()


func start_betting():
	if state != GameState.IDLE and state != GameState.ROUND_OVER:
		return

	current_bet = 0
	result = ""
	state = GameState.BETTING


func place_bet(amount: int) -> bool:
	if state != GameState.BETTING:
		return false

	if amount <= 0:
		return false

	if amount > player_balance:
		return false

	current_bet = amount
	return true


func start_round() -> bool:
	if state != GameState.BETTING:
		return false

	if current_bet <= 0:
		return false

	player_balance -= current_bet
	round_settled = false

	deck.reset()
	deck.shuffle()

	player_hand.clear()
	dealer.reset()

	result = ""
	state = GameState.PLAYER_TURN

	deal_initial_cards()

	if player_hand.is_blackjack() or dealer.hand.is_blackjack():
		finish_initial_blackjack_check()

	return true


func deal_initial_cards():
	player_hand.add_card(deck.draw_card())
	dealer.add_card(deck.draw_card())

	player_hand.add_card(deck.draw_card())
	dealer.add_card(deck.draw_card())


func player_hit() -> bool:
	if state != GameState.PLAYER_TURN:
		return false

	var card := deck.draw_card()

	if card == null:
		return false

	player_hand.add_card(card)

	if player_hand.is_bust():
		result = "Dealer wins"
		state = GameState.ROUND_OVER

	return true


func player_stand():
	if state != GameState.PLAYER_TURN:
		return

	state = GameState.DEALER_TURN


func dealer_play_step() -> bool:
	if state != GameState.DEALER_TURN:
		return false

	if dealer.should_hit():
		var card := deck.draw_card()

		if card == null:
			determine_result()
			return false

		dealer.add_card(card)
		return true

	determine_result()
	return false


func determine_result():
	if dealer.is_bust():
		result = "Player wins"
	elif player_hand.get_value() > dealer.get_value():
		result = "Player wins"
	elif player_hand.get_value() < dealer.get_value():
		result = "Dealer wins"
	else:
		result = "Push"

	state = GameState.ROUND_OVER


func finish_initial_blackjack_check():
	if player_hand.is_blackjack() and dealer.hand.is_blackjack():
		result = "Push"
	elif player_hand.is_blackjack():
		result = "Player wins - Blackjack"
	elif dealer.hand.is_blackjack():
		result = "Dealer wins - Blackjack"

	state = GameState.ROUND_OVER


func settle_round():
	if state != GameState.ROUND_OVER:
		return

	if round_settled:
		return

	match result:
		"Player wins":
			player_balance += current_bet * 2

		"Player wins - Blackjack":
			player_balance += int(current_bet * 2.5)

		"Push":
			player_balance += current_bet

		"Dealer wins":
			pass

	round_settled = true


func reset():
	deck.reset()
	player_hand.clear()
	dealer.reset()

	state = GameState.IDLE
	result = ""

	current_bet = 0
	round_settled = true
