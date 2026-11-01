extends Node2D

var _triggered: bool = false

func _on_area_2d_body_entered(body: Node2D) -> void:
	# Snap once and ignore re-entry while it plays
	if _triggered:
		return
	_triggered = true
	%AnimatedSprite2D.play("default")
	%SnapSound.play()
	Player.instance.SlowTimer.start()
	Player.instance.speed_scalar = .35
	Player.instance.take_damage(1)

func _on_animated_sprite_2d_animation_finished() -> void:
	# Let the snap ring out before removing the trap
	if %SnapSound.playing:
		await %SnapSound.finished
	queue_free()
