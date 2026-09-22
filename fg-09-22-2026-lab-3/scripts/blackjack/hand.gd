class_name BlackjackHand
extends RefCounted

var cards: Array[BlackjackCard] = []


func add_card(card: BlackjackCard):
	cards.append(card)


func clear():
	cards.clear()


func get_value() -> int:
	var total := 0
	var ace_count := 0

	for card in cards:
		total += card.get_value()

		if card.is_ace():
			ace_count += 1

	while total > 21 and ace_count > 0:
		total -= 10
		ace_count -= 1

	return total


func is_bust() -> bool:
	return get_value() > 21


func is_blackjack() -> bool:
	return cards.size() == 2 and get_value() == 21


func card_count() -> int:
	return cards.size()
