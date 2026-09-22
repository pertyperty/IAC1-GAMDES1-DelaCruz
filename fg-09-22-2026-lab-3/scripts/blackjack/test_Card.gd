extends Node

func _ready():
	var deck := BlackjackDeck.new()

	print("Cards in new deck: ", deck.cards_remaining())

	deck.shuffle()

	print("Drawing 5 cards:")

	for i in range(5):
		var card := deck.draw_card()

		print(
			card.get_display_name(),
			" - Value: ",
			card.get_value()
		)

	print("Cards remaining: ", deck.cards_remaining())
