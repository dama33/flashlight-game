extends Node2D

var _triggered: bool = false

func _on_area_2d_body_entered(body: Node2D) -> void:
	if _triggered or body != Player.instance:
		return
	_triggered = true
	# Stop re triggering while the close anim plays.
	# Deferred: can't change monitoring mid-signal.
	$Area2D.set_deferred("monitoring", false)
	%AnimatedSprite2D.play("default")
	Player.instance.SlowTimer.start()
	Player.instance.speed_scalar = .35

func _on_animated_sprite_2d_animation_finished() -> void:
	queue_free()

func _on_area_2d_area_entered(_area: Area2D) -> void:
	pass
