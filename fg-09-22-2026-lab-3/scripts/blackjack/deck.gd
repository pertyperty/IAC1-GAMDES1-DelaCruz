class_name BlackjackDeck
extends RefCounted

var cards: Array[BlackjackCard] = []


func _init():
	reset()


func reset():
	cards.clear()

	for suit in BlackjackCard.Suit.values():
		for rank in BlackjackCard.Rank.values():
			cards.append(BlackjackCard.new(suit, rank))


func shuffle():
	cards.shuffle()


func draw_card() -> BlackjackCard:
	if cards.is_empty():
		return null

	return cards.pop_back()


func cards_remaining() -> int:
	return cards.size()
