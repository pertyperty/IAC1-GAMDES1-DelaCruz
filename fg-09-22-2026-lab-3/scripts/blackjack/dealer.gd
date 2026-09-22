class_name BlackjackDealer
extends RefCounted

var hand: BlackjackHand


func _init():
	hand = BlackjackHand.new()


func reset():
	hand.clear()


func add_card(card: BlackjackCard):
	hand.add_card(card)


func should_hit() -> bool:
	return hand.get_value() < 17


func is_bust() -> bool:
	return hand.is_bust()


func get_value() -> int:
	return hand.get_value()


func card_count() -> int:
	return hand.card_count()
