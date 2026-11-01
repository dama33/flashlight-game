extends Node2D

var _collected: bool = false


func _on_area_2d_body_entered(body: Node2D) -> void:
	if _collected or not (body is Player):
		return
	_collected = true
	(body as Player).keycards += 1
	print("Key card picked up!")
	# Vanish right away, but stay alive until the
	# sound ends, or freeing would cut it off
	hide()
	$Area2D.set_deferred("monitoring", false)
	%PickupSound.play_clip()
	await %PickupSound.finished
	queue_free()
