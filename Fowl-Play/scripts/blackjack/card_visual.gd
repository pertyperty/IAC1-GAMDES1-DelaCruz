class_name BlackjackCardVisual
extends Node3D

@onready var front_label: Label3D = $FrontLabel
@onready var back_label: Label3D = $BackLabel

var card_data: BlackjackCard


func set_card(card: BlackjackCard):
	card_data = card
	update_visual()


func update_visual():
	if card_data == null:
		front_label.text = ""
		return

	front_label.text = card_data.get_rank_name() + "\n" + get_suit_symbol(card_data.suit)


func get_suit_symbol(suit: BlackjackCard.Suit) -> String:
	match suit:
		BlackjackCard.Suit.HEARTS:
			return "♥"
		BlackjackCard.Suit.DIAMONDS:
			return "♦"
		BlackjackCard.Suit.CLUBS:
			return "♣"
		BlackjackCard.Suit.SPADES:
			return "♠"

	return ""


func set_face_up(face_up: bool):
	front_label.visible = face_up
	back_label.visible = not face_up
