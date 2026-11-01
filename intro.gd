extends CanvasLayer

# Intro cutscene: the eyes blink open a few times,
# then an unknown voice talks through `lines`.
# The game is paused until it ends. Enter or left
# click advances, Esc skips everything.

enum Phase { BLINK, TYPING, WAITING, DONE }

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
@onready var dialog_box: Control = %DialogBox
@onready var speaker_label: Label = %Speaker
@onready var text_label: Label = %Text
@onready var hint_label: Label = %Hint

var _phase: Phase = Phase.BLINK
var _line: int = -1
var _tween: Tween


func _ready() -> void:
	get_tree().paused = true
	dialog_box.hide()
	hint_label.hide()
	speaker_label.text = speaker
	_set_open(0.0)
	# Gentle pulse on the "continue" hint
	var pulse: Tween = create_tween().set_loops()
	pulse.tween_property(hint_label, "modulate:a", 0.3, 0.5)
	pulse.tween_property(hint_label, "modulate:a", 1.0, 0.5)
	_play_blinks()


func _unhandled_input(event: InputEvent) -> void:
	if _phase == Phase.DONE:
		return
	if event.is_action_pressed("ui_cancel"):
		_finish()
	elif _is_advance(event):
		_advance()
	else:
		return
	get_viewport().set_input_as_handled()


func _is_advance(event: InputEvent) -> bool:
	var key: InputEventKey = event as InputEventKey
	if key != null:
		return key.pressed and not key.echo and (key.keycode == KEY_ENTER or key.keycode == KEY_KP_ENTER)
	var mouse: InputEventMouseButton = event as InputEventMouseButton
	return mouse != null and mouse.pressed and mouse.button_index == MOUSE_BUTTON_LEFT


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
	if lines.is_empty():
		_finish()
		return
	dialog_box.show()
	_show_line(0)


func _show_line(i: int) -> void:
	_line = i
	_phase = Phase.TYPING
	hint_label.hide()
	text_label.text = lines[i]
	text_label.visible_ratio = 0.0
	var duration: float = maxf(lines[i].length() / chars_per_second, 0.05)
	_tween = create_tween()
	_tween.tween_property(text_label, "visible_ratio", 1.0, duration)
	_tween.tween_callback(_line_done)


func _line_done() -> void:
	_phase = Phase.WAITING
	text_label.visible_ratio = 1.0
	hint_label.show()


func _advance() -> void:
	match _phase:
		Phase.TYPING:
			# First press finishes the line
			_tween.kill()
			_line_done()
		Phase.WAITING:
			if _line + 1 < lines.size():
				_show_line(_line + 1)
			else:
				_finish()
		_:
			pass  # no advancing during the blink


func _finish() -> void:
	_phase = Phase.DONE
	if _tween != null and _tween.is_valid():
		_tween.kill()
	get_tree().paused = false
	queue_free()
