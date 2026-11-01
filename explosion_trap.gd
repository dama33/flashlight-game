extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _on_area_2d_body_entered(body: Node2D) -> void:
	# Insta kill the player
	print("Explosion trap triggered!")
	%AudioStreamPlayer2D.play()
	%Sprite.visible = false
	%AnimatedSprite2D.visible = true
	%AnimatedSprite2D.play()
	Player.instance.take_damage(Player.instance.max_health)
	Player.instance.explode()
	pass # Replace with function body.

func _on_animated_sprite_2d_animation_finished() -> void:
	queue_free()
