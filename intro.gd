extends CanvasLayer

# Intro cutscene: the eyes blink open a few times,
# then an unknown voice talks through `lines`.
# The game is paused until it ends. Enter or left
# click advances, Esc skips everything.

@export_group("Blink")
# Eye openness to move through: 0 = shut, 1 = open
@export var blink_steps: PackedFloat32Array = [0.25, 0.0, 0.55, 0.0, 1.0]
@export var open_time: float = 0.6
@export var close_time: float = 0.25
# Black screen before the first blink
@export var start_delay: float = 0.8

@export_group("Dialog")
@export var speaker: String = "Unknown Voice"
@export var lines: Array[String] = [
	"Hello, investigator.",
	"Welcome to facility 03Z. I see that you had let yourself in without invitation.",
	"But fear not, I am a gracious host. Feel free to explore the area.",
	"Do stay away from my pet, she had been...agitated.",
	"If you ever feel bored and want to leave. The exit is on the north part of the facility, it will require five different key cards to unlock.",
	"Have fun, and watch your steps."
]
@export var chars_per_second: float = 40.0

@onready var eyelids: ColorRect = %Eyelids
@onready var dialog_box: DialogBox = %DialogBox

var _done: bool = false
var _tween: Tween


func _ready() -> void:
	get_tree().paused = true
	dialog_box.chars_per_second = chars_per_second
	_set_open(0.0)
	_play_blinks()


func _unhandled_input(event: InputEvent) -> void:
	if not _done and event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_finish()


# --- Blink ------------------------------------------

func _play_blinks() -> void:
	_tween = create_tween()
	_tween.tween_interval(start_delay)
	var current: float = 0.0
	for target: float in blink_steps:
		var time: float = open_time if target > current else close_time
		_tween.tween_method(_set_open, current, target, time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		current = target
	_tween.tween_callback(_start_dialog)


func _set_open(amount: float) -> void:
	var mat: ShaderMaterial = eyelids.material as ShaderMaterial
	mat.set_shader_parameter("open", amount)


# --- Dialog -----------------------------------------

func _start_dialog() -> void:
	eyelids.hide()
	for line: String in lines:
		await dialog_box.say(line, speaker)
		if _done:
			return
	_finish()


func _finish() -> void:
	if _done:
		return
	_done = true
	if _tween != null and _tween.is_valid():
		_tween.kill()
	get_tree().paused = false
	queue_free()
