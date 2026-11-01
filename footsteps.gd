class_name Footsteps
extends AudioStreamPlayer2D

# Footstep audio for the parent body. Add as a child
# of a CharacterBody2D and set `stream`. It watches how
# far the parent actually moved, so the parent's own
# script doesn't need to know about it.
#   loop_while_moving = false: one step every
#     `step_distance` px moved (player).
#   loop_while_moving = true: keep the clip playing
#     while moving, stop when still (monster).

@export var loop_while_moving: bool = false
@export var step_distance: float = 100.0
# Skip the start of the clip (seconds)
@export var start_offset: float = 0.0
@export var pitch_jitter: float = 0.08
# Slower than this (px/s) counts as standing still
@export var min_speed: float = 10.0

var _last_pos: Vector2 = Vector2.ZERO
var _travelled: float = 0.0


func _ready() -> void:
	_last_pos = global_position
	# First movement plays a step right away
	_travelled = step_distance


func _physics_process(delta: float) -> void:
	var pos: Vector2 = global_position
	var moved: float = pos.distance_to(_last_pos)
	_last_pos = pos
	# A jump this big is a teleport (respawn), not walking
	var teleported: bool = moved > step_distance
	var moving: bool = not teleported and moved / delta >= min_speed

	if loop_while_moving:
		if moving and not playing:
			_play_once()
		elif not moving and playing:
			stop()
	elif moving:
		_travelled += moved
		if _travelled >= step_distance:
			_travelled = 0.0
			_play_once()
	else:
		_travelled = step_distance


func _play_once() -> void:
	pitch_scale = 1.0 + randf_range(-pitch_jitter, pitch_jitter)
	play(start_offset)
