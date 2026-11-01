extends Node2D

func _on_area_2d_body_entered(body: Node2D) -> void:
	%AnimatedSprite2D.play("default")
	Player.instance.SlowTimer.start()
	Player.instance.speed_scalar = .35

func _on_animated_sprite_2d_animation_finished() -> void:
	queue_free()
