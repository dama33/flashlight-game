class_name SoundClip
extends AudioStreamPlayer2D

# Plays just a slice of `stream`: start at
# clip_start, fade out after clip_length seconds.
# Lets one sound file serve several effects.
# Call play_clip() instead of play(). The Inspector's
# Pitch Scale and Volume Db are the base values.

@export var clip_start: float = 0.0
# Real seconds before the fade; 0 = play to the end
@export var clip_length: float = 0.0
@export var fade_time: float = 0.12
# Random +/- pitch per play, for variety
@export var pitch_jitter: float = 0.0

var _base_volume: float = 0.0
var _base_pitch: float = 1.0
var _tween: Tween


func _ready() -> void:
	_base_volume = volume_db
	_base_pitch = pitch_scale


func play_clip() -> void:
	if _tween != null and _tween.is_valid():
		_tween.kill()
	volume_db = _base_volume
	pitch_scale = _base_pitch + randf_range(-pitch_jitter, pitch_jitter)
	play(clip_start)
	if clip_length > 0.0:
		_tween = create_tween()
		_tween.tween_interval(clip_length)
		_tween.tween_property(self, "volume_db", -40.0, fade_time)
		_tween.tween_callback(stop)
