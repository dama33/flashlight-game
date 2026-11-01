extends Node2D

# Ending cutscene. The whole sequence is in _play(),
# top to bottom. No skipping; any key restarts at
# the end.

@export_group("Lines")
# Shown while walking
@export var walking_lines: Array[String] = [
	"Your footsteps are heavy. That was a close one, maybe you should choose a better job to take next time.",
	"Something that doesn't involve stumbling around in dark research facility filled with traps. And running away from weird splitting monsters.",
]
# Shown after stopping, before the burst
@export var stopped_lines: Array[String] = [
	"(A sudden excruciating pain starts in your chest, spreading to your limbs)",
	"Or did you really run away?",
]

@export_group("Timing")
@export var fade_time: float = 1.5
# World px per second; the walk stops at walk_end_x
@export var walk_speed: float = 22.0
@export var walk_end_x: float = 200.0
@export var monster_speed: float = 45.0
@export var monster_exit_x: float = 420.0

@export_group("End")
@export_file("*.tscn") var restart_scene: String = "res://map.tscn"

@onready var fade: ColorRect = %Fade
@onready var end_label: Label = %EndLabel
@onready var dialog_box: DialogBox = %DialogBox
@onready var walker: AnimatedSprite2D = %Walker
@onready var foot_light: PointLight2D = %FootLight
@onready var burst: AnimatedSprite2D = %Burst
@onready var burst_sound: AudioStreamPlayer = %BurstSound
@onready var remains: Sprite2D = %Remains
@onready var monster: AnimatedSprite2D = %Monster

var _walk_tween: Tween
var _can_restart: bool = false


func _ready() -> void:
	fade.color.a = 1.0
	end_label.hide()
	burst.hide()
	remains.hide()
	monster.hide()
	_play()


func _process(_delta: float) -> void:
	# The light follows the feet while there's
	# someone to follow, then stays on the remains
	if walker.visible:
		foot_light.position = walker.position


func _play() -> void:
	await _fade_to(0.0)
	_start_walking()
	for line: String in walking_lines:
		await dialog_box.say(line)
	_stop_walking()
	await _wait(0.6)
	for line: String in stopped_lines:
		await dialog_box.say(line)
	dialog_box.hide()
	await _wait(0.8)
	await _burst()
	await _wait(0.8)
	await _monster_leaves()
	await _wait(1.0)
	await _fade_to(1.0)
	end_label.show()
	_can_restart = true


func _unhandled_input(event: InputEvent) -> void:
	if not _can_restart:
		return
	var key: InputEventKey = event as InputEventKey
	var mouse: InputEventMouseButton = event as InputEventMouseButton
	var pressed: bool = (key != null and key.pressed and not key.echo) or (mouse != null and mouse.pressed)
	if pressed:
		_can_restart = false
		get_tree().change_scene_to_file(restart_scene)


# --- Steps ------------------------------------------

func _start_walking() -> void:
	walker.play("walk")
	var distance: float = maxf(walk_end_x - walker.position.x, 0.0)
	_walk_tween = create_tween()
	_walk_tween.tween_property(walker, "position:x", walk_end_x, distance / walk_speed)
	# Reached the end before the lines did: stand
	_walk_tween.tween_callback(walker.stop)


func _stop_walking() -> void:
	if _walk_tween != null and _walk_tween.is_valid():
		_walk_tween.kill()
	walker.stop()


func _burst() -> void:
	var spot: Vector2 = walker.position
	walker.hide()
	remains.position = spot
	burst.position = spot
	remains.show()
	burst.show()
	burst.play("default")
	burst_sound.play()
	await burst.animation_finished
	burst.hide()


func _monster_leaves() -> void:
	monster.position = remains.position
	monster.show()
	monster.play("default")
	var distance: float = maxf(monster_exit_x - monster.position.x, 0.0)
	var tween: Tween = create_tween()
	tween.tween_property(monster, "position:x", monster_exit_x, distance / monster_speed)
	await tween.finished


func _fade_to(alpha: float) -> void:
	var tween: Tween = create_tween()
	tween.tween_property(fade, "color:a", alpha, fade_time)
	await tween.finished


func _wait(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout
