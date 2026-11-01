extends AudioStreamPlayer

# Background ambience: plays `tracks` one after
# another forever, each time with a slightly
# random pitch so repeats don't sound identical.

@export var tracks: Array[AudioStream] = []
# Pitch varies by up to +/- this much per track
@export var pitch_variance: float = 0.05

var _index: int = 0


func _ready() -> void:
	finished.connect(_play_next)
	if tracks.is_empty():
		push_warning("Ambience: no tracks set")
		return
	# Random first track, then alternate
	_index = randi() % tracks.size()
	_play_current()


func _play_next() -> void:
	_index = (_index + 1) % tracks.size()
	_play_current()


func _play_current() -> void:
	stream = tracks[_index]
	pitch_scale = 1.0 + randf_range(-pitch_variance, pitch_variance)
	play()
