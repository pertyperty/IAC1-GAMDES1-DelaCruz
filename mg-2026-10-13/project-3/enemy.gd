extends RigidBody2D

func _ready() -> void:
	gravity_scale = 0.0
	collision_layer = 2
	collision_mask = 0
	var types := Array($AnimatedSprite2D.sprite_frames.get_animation_names())
	$AnimatedSprite2D.play(types.pick_random())

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
