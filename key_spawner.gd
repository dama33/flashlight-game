extends Node2D

# Every Marker2D child is a possible keycard spot.

@export var keycard_scene: PackedScene
@export var count: int = 5


func _ready() -> void:
	var spots: Array[Marker2D] = []
	for child: Node in get_children():
		if child is Marker2D:
			spots.append(child as Marker2D)
	if spots.size() < count:
		push_warning("KeySpawner: only %d spots for %d cards" % [spots.size(), count])

	spots.shuffle()
	for i: int in mini(count, spots.size()):
		var card: Node2D = keycard_scene.instantiate() as Node2D
		# Card and marker share this parent, so the
		# marker's local position is enough
		card.position = spots[i].position
		add_child(card)
