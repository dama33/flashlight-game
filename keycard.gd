extends Node2D

var _collected: bool = false


func _on_area_2d_body_entered(body: Node2D) -> void:
	if _collected or not (body is Player):
		return
	_collected = true
	(body as Player).keycards += 1
	print("Key card picked up!")
	queue_free()
